# Metodologia Sarue — mapeamento e comparação de DTBs

Este documento registra um fluxo conservador para investigar DTBs de consoles RK3326, com foco no R36S V20. Ele distingue evidência extraída do arquivo, hipótese técnica e resultado observado no aparelho.

## 1. Identificação e preservação

Antes de interpretar ou editar um arquivo:

- Registre o caminho, nome, tamanho, origem declarada e data de obtenção.
- Preserve uma cópia imutável do DTB original.
- Calcule SHA-256 quando houver ferramenta disponível; use o hash para detectar alterações, não para inferir compatibilidade.
- Anote modelo/revisão física, sistema operacional, versão do kernel e método de extração, se conhecidos.
- Marque explicitamente a origem como **confirmada**, **declarada pelo fornecedor**, **inferida** ou **desconhecida**.

O nome de arquivo ou a string model isoladamente não prova que o DTB pertence à placa física.

## 2. Conversão DTB → DTS

O fluxo habitual utiliza dtc (Device Tree Compiler) para descompilar o blob em texto. Exemplo genérico:

    dtc -I dtb -O dts -o candidato.dts candidato.dtb

Opções e avisos podem variar conforme a versão do dtc. Preserve o arquivo binário e registre os avisos de conversão. Um DTS descompilado pode conter phandles numéricos, propriedades reordenadas ou referências sem os nomes originais dos headers.

Se houver fontes DTS originais do fabricante, prefira-as como contexto, mas confirme que correspondem ao binário em análise.

## 3. Comparação em camadas

Não compare somente o arquivo inteiro linha a linha. Compare primeiro a identidade e depois os subsistemas.

### Identidade e inicialização

- model, compatible, aliases e nós de memória.
- DDR/timing, clocks, reguladores e componentes essenciais ao boot.
- Nós habilitados/desabilitados e referências por phandle.

### Tela e iluminação

- display-subsystem, VOP, MIPI DSI/PHY, painel e sequências de inicialização.
- Resolução, timings, número de lanes, reset e polaridade.
- backlight, PWM, níveis de brilho e GPIO de enable.

**Regra do projeto:** como a base K36 já produziu imagem no aparelho de teste, preservar inicialmente o caminho de display que funciona. Não transplante painel, DSI, timings ou reset de uma placa diferente sem evidência do painel físico.

### Controles e ADC

Inspecione em conjunto:

- joypad e seu compatible (por exemplo, play_joystick ou rocknix-singleadc-joypad);
- nós de botões e propriedades linux,code;
- gpios, GPIO controller, pinctrl, polaridade ativa e estados;
- io-channels, canal SARADC, io-channel-names;
- amux-count, amux-channel-mapping, amux-a-gpios, amux-b-gpios, amux-en-gpios;
- limites ADC, escala, deadzone, fuzz, flat, intervalo de polling e inversão dos eixos;
- eventos observados no Linux (/dev/input/event* e /dev/input/js*) quando acessíveis.

Mapeie cada controle em uma tabela: nome físico → nó → GPIO/canal → código Linux → evidência do teste. Não deduza um GPIO físico apenas pelo número de phandle; resolva a referência para o controlador e a linha correspondentes.

### Áudio

Compare o caminho completo, não apenas o codec:

- codec/PMIC, I2S/DAI, clocks e formato;
- sound card e referências por phandle;
- rockchip,audio-routing;
- speaker enable e headphone detect;
- GPIO, polaridade, ADC de detecção e estados pinctrl associados.

A semelhança de codec ou SoC não garante que a pinagem ou o roteamento sejam iguais.

## 4. Como comparar sem confundir ruído com diferença real

1. Converta os arquivos com versões registradas das ferramentas.
2. Normalize apenas aspectos que não alterem o significado, como diferenças de formatação. Guarde também a saída original.
3. Compare primeiro os nós críticos e suas dependências; depois examine o diff completo.
4. Siga cada phandle até o nó referenciado.
5. Registre cada diferença como **confirmada**, **provável**, **desconhecida** ou **não aplicável**.
6. Não use diferenças de tamanho do arquivo como indicador de melhor desempenho ou compatibilidade.
7. Quando dois DTBs diferirem em muitos subsistemas, não transplante blocos grandes sem justificar cada dependência.

## 5. Regras de modificação segura

- Uma hipótese por variante experimental.
- Não modificar GPIO, pinctrl, AMUX ou ADC sem identificar a função e documentar a evidência.
- Não alterar o bloco de display funcional para resolver um problema de controles ou áudio.
- Não substituir o DTB de boot original durante a investigação.
- Dê a cada variante um nome descritivo, finalidade, base exata e estado de teste.
- Registre as propriedades alteradas e as que foram explicitamente preservadas.
- Revise o diff depois da edição; a intenção do patch não basta.

## 6. Compilação e validação

Exemplo genérico de compilação:

    dtc -I dts -O dtb -o experimental.dtb experimental.dts

A compilação sem erro valida parte da sintaxe, não o funcionamento elétrico. Antes de testar:

- verifique erros e warnings;
- confirme que o arquivo produzido não está vazio;
- confira os nós alterados e suas referências;
- compare a árvore compilada com a versão de entrada quando possível;
- mantenha cópia do DTB anterior e um procedimento de recuperação testável.

## 7. Matriz de teste no console

Para cada variante, registrar:

- modelo/revisão do aparelho e sistema/kernel;
- hash do DTB testado;
- inicialização, imagem, brilho, controles digitais, analógicos e áudio;
- estabilidade durante uso prolongado e após reinicializações;
- regressões, logs e método de retorno à versão anterior.

Use docs/MATRIZ-DE-TESTES.md como modelo.

## 8. Registro de evidência

Cada conclusão deve dizer qual é sua base:

- **Estática:** inferida de propriedades do DTS/DTB.
- **Compilação:** arquivo foi compilado e passou pelas verificações documentadas.
- **Teste de hardware:** comportamento observado no aparelho identificado.
- **Benchmark:** medida quantitativa com procedimento reproduzível.
- **Relato do usuário:** observação válida para documentar, mas sem protocolo independente anexado.

### Observação sobre o ganho de desempenho

O projeto registra o relato de aproximadamente 30% de ganho e maior estabilidade no R36S V20 com RK3326S. Até existir um protocolo comparativo com mesma carga, versão de sistema, condições térmicas e resultados brutos, esse dado deve ser apresentado como observação do usuário, não como promessa de desempenho causada por um DTB específico.
