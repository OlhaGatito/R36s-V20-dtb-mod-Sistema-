# Análise inicial — K36 vs candidatos

Data: 2026-10-01

## Arquivos analisados

- `K36/rf3536k4ka.dtb`
- `V20/rk3326s-gamemt-e6.dtb`
- `V20/rk3326s-gkd-pixel2.dtb`
- DTS descompilados correspondentes em `dts/`

> Os arquivos E6 e GKD Pixel2 são candidatos de comparação. Eles não devem ser tratados como o DTB específico do R36S V20 até confirmarmos a origem/hardware.

## 1. K36 — estado atual conhecido

O `rf3536k4ka.dtb` é o DTB K36 que inicializa o R36S V20 do usuário e apresenta imagem, mas atualmente não fornece controles/teclado nem áudio funcionais no sistema testado.

### GPIO

No K36, os phandles principais são:

- GPIO0 = phandle `0x5c`
- GPIO1 = phandle `0xc9`
- GPIO2 = phandle `0x6f`
- GPIO3 = phandle `0x66`

O bloco `play_joystick` usa principalmente:

- GPIO3 para a matriz de botões
- GPIO2-13 e GPIO2-14 para os rocker/thumb buttons
- SARADC para os quatro eixos

### ADC / analógicos

`play_joystick`:

- ADC0 → left-x, Linux ABS_X (code 0)
- ADC1 → left-y, Linux ABS_Y (code 1)
- ADC2 → right-x, Linux ABS_RX (code 3)
- ADC3 → right-y, Linux ABS_RY (code 4)
- threshold: `0x6d6` em todos os eixos

O K36 usa o driver:

`compatible = "play_joystick";`

Isso é estruturalmente diferente dos candidatos E6/Pixel2, que usam `rocknix-singleadc-joypad`.

### Áudio

O K36 possui:

- `rk817-codec`
- `rk817-sound`
- formato I2S
- CPU DAI e codec DAI próprios do DTB
- speaker control em GPIO3-7
- headphone detect em GPIO2-22
- detecção adicional via SARADC

Portanto, o K36 não está simplesmente sem uma seção de áudio. O problema precisa ser investigado comparando GPIO, pinctrl, DAI, codec, routing e hardware real.

## 2. E6 — diferenças relevantes

O GameMT E6 usa:

`rocknix-singleadc-joypad`

com:

- SARADC channel 1 para o multiplexador
- amux mapping 0,1,2,3
- GPIOs de seleção do multiplexador em GPIO2
- botões principalmente em GPIO3
- ajuste de analógicos diferente do K36

O áudio usa:

- RK817 codec
- I2S
- headphone detect em GPIO0-11
- routing:
  - Headphone → HPOL
  - Headphone → HPOR
  - Speaker → HPOL
  - Speaker → HPOR

Isso mostra que um bloco de áudio do E6 não deve ser transplantado cegamente para o K36.

## 3. GKD Pixel2 — diferenças relevantes

O Pixel2 também usa:

`rocknix-singleadc-joypad`

mas seu joystick é principalmente GPIO, com:

- DPAD e botões em GPIO3
- SELECT/START em GPIO3
- thumb buttons em GPIO2
- sem a mesma estrutura ADC multiplexada do E6
- PWM associado ao joypad

O áudio usa RK817 + I2S e:

- headphone detect em GPIO2-22
- `rocknix,auto-playback-path`
- routing do speaker para `SPKO`

Também não é seguro transplantar o bloco inteiro.

## 4. Display

O K36 é muito diferente dos candidatos e isso é importante para o híbrido.

### K36

- MIPI DSI
- painel Sitronix ST7703
- 4 lanes DSI
- resolução ativa: 640x480
- sequência de inicialização própria
- reset em GPIO3-15
- PWM backlight próprio

### E6

- MIPI DSI
- painel `simple-panel-dsi`
- 2 lanes
- resolução descrita: 480x854
- reset em GPIO0-17
- sequência de inicialização diferente

### Pixel2

- MIPI DSI
- ST7703
- 2 lanes
- resolução ativa: 480x640
- enable/reset próprios
- sequência de inicialização diferente

**Conclusão:** o bloco de display do K36 deve ser preservado como base, pois é o que já produz imagem no V20 do usuário.

## 5. Primeira hipótese de trabalho

Não substituir o DTB inteiro.

A estratégia inicial será:

1. preservar K36:
   - DDR/RAM
   - display/DSI/panel
   - backlight
   - partes de boot/clock que comprovadamente funcionam
2. investigar o input do V20 real;
3. comparar o bloco `play_joystick` K36 com o driver/input do DTB V20 correto;
4. investigar áudio separadamente;
5. criar variantes híbridas pequenas e identificáveis;
6. compilar e testar uma alteração por vez.

## 6. Próximo dado necessário

Precisamos adicionar ao repositório o **DTS do DTB específico do R36S V20 2025-05-18**.

Os E6 e GKD Pixel2 são úteis como referência de hardware RK3326, mas não devem ser usados como substitutos do V20 sem confirmação.

