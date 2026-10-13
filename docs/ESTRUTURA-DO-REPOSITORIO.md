# Estrutura do repositório

Guia para localizar os arquivos sem confundir referência, fonte descompilada e variante experimental.

| Caminho | Conteúdo | Como tratar |
|---|---|---|
| K36/ | DTB binário K36 usado como base de investigação | Preservar como referência; não sobrescrever |
| V20/ | DTBs candidatos E6 e GKD Pixel2 | Referências comparativas; origem específica do V20 não confirmada |
| analysis/ | Comparação inicial e conclusões documentadas | Atualizar com evidência e data, mantendo histórico |
| dts/ | Fontes descompiladas e recortes de nós/áreas de interesse | Usar para análise; identificar se é dump completo ou recorte |
| dts/experimental/ | Variantes de teste de controles e inversão analógica | Não classificar como estável sem teste físico registrado |
| references/aurknix/ | DTS de referência K36 proveniente do projeto Aurknix indicado no cabeçalho | Preservar atribuição, origem e licença declarada |
| assets/ | Identidade visual do projeto | Recursos de apresentação; não interferem no DTB |
| docs/ | Metodologia, matriz de testes e documentação | Fonte de orientação do projeto |

## Arquivos DTS e recortes atuais

- dts/rf3536k4ka.dts: árvore descompilada associada ao DTB K36.
- dts/rf3536k4ka-key.txt: recorte/saída de análise com linhas relevantes para teclas, GPIO e áreas correlatas.
- dts/rf3536k4ka-display.txt: recorte de análise de display e backlight.
- dts/rk3326s-gamemt-e6.dts: árvore descompilada do candidato E6.
- dts/rk3326s-gamemt-e6-key.txt e dts/rk3326s-gamemt-e6-display.txt: recortes de análise do candidato E6.
- dts/rk3326s-gkd-pixel2.dts: árvore descompilada do candidato GKD Pixel2.
- dts/rk3326s-gkd-pixel2-key.txt e dts/rk3326s-gkd-pixel2-display.txt: recortes de análise do candidato GKD Pixel2.
- dts/experimental/rf3536k4ka-rocknix-buttons.dts: variante experimental relacionada ao mapeamento de botões.
- dts/experimental/rf3536k4ka-rocknix-analog-invert-test.dts: experimento de inversão de analógicos.
- dts/experimental/rf3536k4ka-rocknix-buttons-analog-test.dts e rf3536k4ka-rocknix-buttons-fixed-test.dts: variantes de teste relacionadas a controles.
- dts/experimental/rf3536k4ka-play-type2-gpios.dts: experimento de mapeamento Type 2; não assumir aprovado.
- dts/rk3326s-gamemt-e6.dts e dts/rk3326s-gkd-pixel2.dts: fontes de comparação, não indicação de que o hardware E6/Pixel2 seja idêntico ao V20.

## Convenção recomendada para novos artefatos

Use nomes que indiquem base, objetivo e estado. Exemplos:

- <base>-<subsystem>-<objective>-experimental.dts
- <base>-<subsystem>-<objective>-validated.dtb

Não renomeie arquivos existentes apenas para padronizar sem atualizar referências e registrar o motivo. Para cada novo DTB, inclua origem, SHA-256, mudanças em relação à base e ficha de teste preenchida.
