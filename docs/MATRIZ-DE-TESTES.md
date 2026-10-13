# Matriz de testes — Sarue DTB Mod

Use uma linha por arquivo binário testado. Não marque um item como aprovado apenas porque o DTS compila.

## Legenda

- **OK:** testado e funcionando no aparelho descrito.
- **Falha:** testado e não funcionou.
- **Pendente:** ainda não testado ou evidência insuficiente.
- **N/A:** não se aplica.
- **Estático:** inferido por análise do DTB, sem teste físico.

## Estado inicial documentado

| Base/variante | Imagem | Controles | Analógicos | Áudio | Estado |
|---|---|---|---|---|---|
| K36 — K36/rf3536k4ka.dtb | OK observado | Falha registrada nos testes iniciais | Pendente/driver diferente | Falha registrada nos testes iniciais | Base de investigação; não assumir compatibilidade completa |
| E6 — V20/rk3326s-gamemt-e6.dtb | Pendente para o V20 | Pendente para o V20 | Pendente para o V20 | Pendente para o V20 | Referência comparativa, não DTB confirmado do V20 |
| GKD Pixel2 — V20/rk3326s-gkd-pixel2.dtb | Pendente para o V20 | Pendente para o V20 | Pendente para o V20 | Pendente para o V20 | Referência comparativa, não DTB confirmado do V20 |
| dts/experimental/* | Pendente por variante | Pendente por variante | Pendente por variante | Pendente por variante | Experimental até haver registro de teste |

Este quadro reflete os registros da análise inicial; atualize-o somente quando houver nova evidência.

## Ficha copiável para cada teste

    ID do teste:
    Data/hora:
    Aparelho e revisão física:
    SoC/placa identificada:
    Sistema e versão:
    Kernel:
    DTB (caminho):
    SHA-256 do DTB:
    Base original e hash:
    Alteração única investigada:
    Método de compilação:
    Warnings/erros de compilação:

    Boot:
    Imagem:
    Brilho/backlight:
    D-pad:
    A/B/X/Y:
    Start/Select:
    L1/L2/R1/R2:
    L3/R3:
    Analógico esquerdo (X/Y):
    Analógico direito (X/Y):
    Áudio do alto-falante:
    Áudio do fone:
    Suspensão/retomada:
    Reinicializações:
    Estabilidade prolongada:
    Regressões:
    Logs/evidências:
    Como reverter:
    Resultado final: OK / Falha / Parcial / Pendente
    Observações:

## Benchmark de desempenho

Para validar quantitativamente o relato de ganho de aproximadamente 30%, registre no mínimo:

1. Sistemas, versões de kernel e configurações comparadas.
2. DTB exato e SHA-256 de cada execução.
3. Mesma aplicação/carga, duração, resolução e configurações.
4. Temperatura inicial, condições térmicas e alimentação.
5. Métrica definida antes do teste (por exemplo, FPS médio, tempo de execução ou latência).
6. Número de repetições, valores individuais, média e dispersão.
7. Logs ou resultados brutos.

Não atribua um ganho ao DTB se outras variáveis mudaram ao mesmo tempo. Desempenho do SoC, configuração do sistema e efeitos do DTB devem ser avaliados separadamente.
