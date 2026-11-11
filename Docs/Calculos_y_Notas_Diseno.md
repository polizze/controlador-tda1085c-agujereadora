# Memoria de Cálculo y Notas de Diseño: Controlador TDA1085C (Acople Directo 400–2.500 RPM)

## 1. Mapeo Eléctrico del Motor Universal (`Askoll C.E.SET. MCA 52/64-148/ALL7`)

* **Datos de Placa:** $220\text{–}240\text{ V AC}$, $50\text{ Hz}$, $1.5\text{ A}$, $330\text{ W}$ absorbidos, $11.000\text{ RPM}$ nominales, Aislación Clase F ($155^\circ\text{C}/180^\circ\text{C}$), protector térmico bimetálico interno en serie con el campo.
* **Conexión Serie para Giro Horario (Sentido de corte de mechas helicoidales derechas):**
  1. **Puente Serie en Bornera:** Unir **Pin 1 (Negro - Campo A)** con **Pin 2 (Violeta - Carbón Izquierdo)**.
  2. **Alimentación de Potencia AC (desde el Triac `BTB12-600BW`):** Ingresar entre **Pin 6 (Azul - Campo B + Protector Térmico)** y **Pin 7 (Naranja - Carbón Derecho)**.
  3. **Realimentación de Velocidad (Tacómetro AC):** **Pin 3 y Pin 4 (Cables Rojos finos)**, resistencia óhmica $60\text{–}180\text{ }\Omega$ ($\approx 120\text{ }\Omega$ a $25^\circ\text{C}$).
  4. **Pin 5 (Gris - Tap intermedio de campo):** No se utiliza; dejar aislado con termocontraíble.

---

## 2. Etapa de Potencia: Triac `BTB12-600BW` y Disipación Térmica

### A. Advertencia de Seguridad Eléctrica (`BTB` = Aleta NO Aislada)
A diferencia de la serie `BTA` (aislada internamente con cerámica de alúmina hasta $2.500\text{ Vrms}$), la sigla **`BTB`** de STMicroelectronics indica que **la aleta metálica TO-220 está soldada directamente al sustrato del terminal `MT2` (`A2`)**.
* Por lo tanto, el disipador de aluminio extruido ($40\text{ mm} \times 20\text{ mm} \times 80\text{ mm}$) se encuentra **permanentemente electrificado a potencial de red $220\text{ V AC}$**.
* **Regla de Montaje Mecánico:**
  * Opción A (Recomendada para menor resistencia térmica): Montar el `BTB12-600BW` directo al disipador con grasa siliconada y fijar el disipador exclusivamente sobre el PCB o soportes plásticos aislantes dentro de un gabinete dieléctrico cerrado, garantizando $> 10\text{ mm}$ de distancia en aire respecto al chasis metálico de la agujereadora.
  * Opción B: Intercalar lámina de **Mica o Kapton** + grasa térmica + **niple pasamuros aislante de Nylon/Teflón (bushing TO-220)** en el tornillo M3, verificando con multímetro en escala de $> 20\text{ M}\Omega$ la aislación entre `MT2` y el disipador antes de energizar.

### B. Dimensionamiento del Disparo de Gate (`BW` = Snubberless, $I_{GT} = 50\text{ mA}$)
La versión sufijo **`BW`** opera en los cuadrantes I, II y III con alta inmunidad $(dV/dt)_c > 500\text{ V}/\mu\text{s}$ y $(dI/dt)_c > 6.5\text{ A/ms}$, pero exige una corriente de disparo garantizada de **$I_{GT} = 50\text{ mA}$** (frente a los $35\text{ mA}$ de la serie `CW`).
* Tensión de salida del Pin 13 (`TRIG_OUT`) del `TDA1085C` con $+V_{CC} = 15.24\text{ V}$:
  $$V_{13,\text{pk}} \approx V_{CC} - 1.4\text{ V} = 13.84\text{ V}$$
* Con caída de compuerta $V_{GT} \approx 1.1\text{ V}$ y resistencia serie **$R_G = 150\text{ }\Omega\text{ (1 W)}$**:
  $$I_{G,\text{pk}} = \frac{13.84\text{ V} - 1.1\text{ V}}{150\text{ }\Omega} \approx 85\text{ mA}\quad (\text{Simulado en LTspice: } 87.88\text{ mA} > 1.75 \times I_{GT})$$
* Si se emplea $R_G = 120\text{ }\Omega\text{ (1 W)}$, el pico asciende a $\approx 106\text{ mA}$. El valor de **$150\text{ }\Omega\text{ (1 W)}$** asegura disparo franco incluso en frío sin sobrecargar innecesariamente la fuente sin transformador.
* **Reserva de Energía en $+V_{CC}$ (Pin 9/10):** Durante cada pulso de disparo de $t_p \approx 55\text{–}80\text{ }\mu\text{s}$ (y eventuales re-disparos si la corriente inductiva se extingue), la carga extraída del capacitor $C_{\text{VCC}}$ es $\Delta Q = I_{G,\text{pk}} \cdot t_p \approx 88\text{ mA} \times 80\text{ }\mu\text{s} = 7.04\text{ }\mu\text{C}$. Con **$C_{\text{VCC}} = 220\text{ }\mu\text{F} / 25\text{ V}$** (o $470\text{ }\mu\text{F} / 25\text{ V}$), la caída instantánea por pulso es despreciable ($\Delta V = \frac{\Delta Q}{C} = 32\text{ mV}$) y el rizado total de 50 Hz se mantiene en **$0.43\text{ Vpp}$** (`15.24 V` medios).

---

## 3. Escalado del Lazo de Velocidad para 400 RPM a 2.500 RPM

### A. Frecuencia del Generador Tacométrico
Para un imán tacométrico de $P = 8$ polos ($4$ pares de polos):
$$f_{\text{tacho}} = \frac{\text{RPM} \cdot P}{120} \implies \begin{cases} f(400\text{ RPM}) = 26.67\text{ Hz} & (V_{\text{pk}} \approx 1.41\text{ V}) \\ f(2.500\text{ RPM}) = 166.67\text{ Hz} & (V_{\text{pk}} \approx 8.84\text{ V}) \end{cases}$$

### B. Protección de Entrada Tacómetro (Pin 12)
* Resistor limitador en serie: **$R_{12} = 10\text{ k}\Omega$**.
* Capacitor cerámico en derivación (Pin 12 a `GND_CHIP`): **$C_{\text{TACHO}} = 10\text{ nF}$** ($f_c = \frac{1}{2\pi \cdot 10\text{ k}\Omega \cdot 10\text{ nF}} = 1.59\text{ kHz}$), encargado de absorber picos inductivos y ruido de conmutación de las delgas del colector sin introducir retardo de fase en la señal tacométrica.

### C. Bomba de Carga (Pin 11) e Integrador F/V (Pin 4)
La corriente media inyectada por el espejo interno del `TDA1085C` en el Pin 4 es proporcional a $C_{11}$ y a $f_{\text{tacho}}$:
$$V_{\text{Pin 4}}(\text{RPM}) = R_4 \cdot \left( G_0 \cdot C_{11} \cdot \Delta V_{11} \cdot f_{\text{tacho}} + I_{\text{offset}(R_{11})} \right)$$

| Configuración de $C_{11}$ y $R_4$ | Tensión en Pin 4 a $400\text{ RPM}$ | Tensión en Pin 4 a $2.500\text{ RPM}$ | Ajuste del Preset Serie `RV1` ($50\text{ k}\Omega$) |
| :--- | :---: | :---: | :---: |
| **Opción A:** $C_{11} = 470\text{ pF}$, $R_4 = 330\text{ k}\Omega$ | $0.58\text{ V}$ | **$3.07\text{ V}$** | Ajustar `RV1` a **$48.5\text{ k}\Omega$** |
| **Opción B:** $C_{11} = 1.0\text{ nF}$, $R_4 = 270\text{ k}\Omega$ | $0.96\text{ V}$ | **$5.14\text{ V}$** | Ajustar `RV1` a **$24.1\text{ k}\Omega$** |

### D. Calibración de Tope con Preset Multivuelta de $50\text{ k}\Omega$ (`RV1`) en Serie con Potenciómetro de Panel de $10\text{ k}\Omega$
Conectando entre `+VCC` (Pin 9, $15.24\text{ V}$) y `GND_CHIP` (Pin 8) la cadena serie:
$$\text{+VCC (Pin 9)} \longrightarrow \underbrace{RV_1}_{\text{Preset } 50\text{ k}\Omega} \longrightarrow \underbrace{RV_{\text{panel}}}_{\text{Pot. } 10\text{ k}\Omega\text{ (Cursor a Pin 5)}} \longrightarrow \underbrace{R_{\text{min}}}_{2.2\text{ k}\Omega\text{ (Piso)} } \longrightarrow \text{GND\_CHIP (Pin 8)}$$
* La relación entre el extremo superior ($100\%$ del potenciómetro) y el extremo inferior ($0\%$ del potenciómetro) queda fijada por:
  $$\frac{V_{\text{SET}}(100\%)}{V_{\text{SET}}(0\%)} = \frac{10\text{ k}\Omega + 2.2\text{ k}\Omega}{2.2\text{ k}\Omega} = 5.545 \approx \frac{V_{\text{Pin 4}}(2.500\text{ RPM})}{V_{\text{Pin 4}}(400\text{ RPM})}$$
* De este modo, **calibrando un único preset multivuelta (`RV1` de $50\text{ k}\Omega$)** en la placa se ajustan simultáneamente el techo de **$2.500\text{ RPM}$** al $100\%$ del potenciómetro y el piso de **$400\text{ RPM}$** al $0\%$ del potenciómetro, tanto si se suelda $C_{11} = 470\text{ pF}$ como si se suelda $C_{11} = 1\text{ nF}$.
