# Memoria de Cálculo y Notas de Diseño: Controlador TDA1085C (Acople Directo 400–2.500 RPM)

## 1. Relevamiento Físico y Pinout Definitivo del Motor Universal (`Askoll C.E.SET. MCA 52/64-148/ALL7`)

### A. Pinout Definitivo de la Bornera de 7 Pines (Vista Frontal, de Izquierda a Derecha)

| Pin Bornera (Izq. $\rightarrow$ Der.) | Color de Cable | Bobinado / Elemento Interno | Conexión en Configuración Serie (Mazo Inferior Pines 1, 2, 5 y 6) |
| :---: | :--- | :--- | :--- |
| **Pin 1** | **Gris oscuro** | **Estator (Campo A)** | **Puente Serie:** Unir directamente con **Pin 2 (Violeta)** |
| **Pin 2** | **Violeta** | **Rotor (Carbón Izquierdo)** | **Puente Serie:** Unir directamente con **Pin 1 (Gris oscuro)** |
| **Pin 3** | **Rojo fino** | **Generador Tacométrico (A)** | Conectar a Bornera `J3` Pin 1 (`TACHO_AC` $\rightarrow R_{12} = 10\text{ k}\Omega$) |
| **Pin 4** | **Rojo fino** | **Generador Tacométrico (B)** | Conectar a Bornera `J3` Pin 2 (`GND_CHIP`) |
| **Pin 5** | **Negro** | **Estator (Campo B)** | **Alimentación (`MOTOR_OUT`):** Conectar a `J1` Pin 3 (`L2_AC_HOT`) |
| **Pin 6** | **Azul** | **Rotor (Carbón Derecho)** | **Alimentación (`MOTOR_OUT`):** Conectar a `J1` Pin 2 (`MT2` del Triac `BTB12-600BW`) |
| **Pin 7** | **Gris claro** | **Estator (Tap o Térmico interno)** | Sin uso en este esquema (aislar terminal) |

### B. Parámetros Eléctricos Medidos en Banco de Trabajo

1. **Etapa de Potencia (Motor en Conexión Serie):**
   * **Resistencia del Estator (Campo):**
     $$R_{\text{estator (Pin 1 – Pin 5)}} = \mathbf{2.1\text{ }\Omega}$$
   * **Resistencia del Rotor (Inducido / Armadura):**
     $$R_{\text{rotor (Pin 2 – Pin 6)}} = \mathbf{6.5\text{ }\Omega}$$
   * **Resistencia Total en Serie (DC):**
     $$R_{\text{total}} = R_{\text{estator}} + R_{\text{rotor}} = 2.1\text{ }\Omega + 6.5\text{ }\Omega = \mathbf{8.6\text{ }\Omega}$$
   * **Inductancia Total en Serie ($L_{\text{total}}$):**
     $$L_{\text{total}} = L_{\text{estator}} + L_{\text{rotor}} \approx \mathbf{25\text{ mH}\text{ a }30\text{ mH}} \quad (\text{Modelada como } 15\text{ mH} + 13\text{ mH} = 28\text{ mH})$$
   * **Constante de tiempo eléctrica del motor ($\tau_e$):**
     $$\tau_e = \frac{L_{\text{total}}}{R_{\text{total}}} = \frac{28\text{ mH}}{8.6\text{ }\Omega} = \mathbf{3.26\text{ ms}} \implies \phi = \arctan(\omega L / R) = \arctan\left(\frac{2\pi \cdot 50 \cdot 0.028}{8.6}\right) = \mathbf{45.6^\circ}$$

2. **Generador Tacométrico (Medido entre Pin 3 y Pin 4):**
   * **Polos Magnéticos:** **$8\text{ polos}$** ($4$ pares de polos $\implies 4$ ciclos AC por revolución).
   * **Resistencia de la bobina tacométrica:**
     $$R_{\text{tacho (Pin 3 – Pin 4)}} = \mathbf{73.0\text{ }\Omega}$$
   * **Relación Frecuencia–Velocidad:**
     $$f_{\text{tacho}} = \frac{\text{RPM} \cdot P}{120} = \frac{\text{RPM} \cdot 8}{120} = \frac{\text{RPM}}{15}\text{ [Hz]}$$
     * A **$400\text{ RPM}$ (Mínimo):** $f_{\text{min}} = \frac{400}{15} = \mathbf{26.67\text{ Hz}}$ ($V_{\text{pk}} \approx 1.41\text{ V}$).
     * A **$2.500\text{ RPM}$ (Tope deseado):** $f_{\text{max}} = \frac{2.500}{15} = \mathbf{166.67\text{ Hz}}$ ($V_{\text{pk}} \approx 8.84\text{ V}$).

---

## 2. Etapa de Potencia: Triac `BTB12-600BW` y Disipación Térmica

### A. Advertencia de Seguridad Eléctrica (`BTB` = Aleta NO Aislada)
A diferencia de la serie `BTA` (aislada internamente), la sigla **`BTB`** indica que **la aleta metálica TO-220 está unida internamente al terminal `MT2` (`A2`)**.
* El disipador de aluminio extruido ($40\text{ mm} \times 20\text{ mm} \times 80\text{ mm}$) queda **permanentemente vivo a $220\text{ V AC}$**.
* **Regla de Montaje Mecánico:** El disipador **NO debe tocar el chasis metálico** de la agujereadora. Debe montarse aislado dentro de un gabinete dieléctrico o utilizando **lámina de Mica/Kapton + grasa siliconada + niple aislante (bushing plástico) en el tornillo M3**, verificando aislación $> 20\text{ M}\Omega$ antes de energizar.

### B. Dimensionamiento del Disparo de Gate (`BW` = Snubberless, $I_{GT} = 50\text{ mA}$)
La versión **`BW`** requiere **$I_{GT} = 50\text{ mA}$**:
* Con $+V_{CC} = 15.24\text{ V}$, la salida del Pin 13 (`TRIG_OUT`) entrega $V_{13,\text{pk}} \approx 13.8\text{ V}$.
* Usando **$R_{\text{GATE1}} = 150\text{ }\Omega\text{ (1 W)}$**:
  $$I_{G,\text{pk}} = \frac{13.8\text{ V} - 1.1\text{ V}}{150\text{ }\Omega} \approx 85\text{ mA}\quad (\text{Simulado en LTspice: } \mathbf{88.05\text{ mA}} = 1.76 \times I_{GT})$$
* **Filtro $+V_{CC}$ (Pin 9/10):** Con **$C_{\text{VCC1}} = 220\text{ }\mu\text{F} / 25\text{ V}$** (o $470\text{ }\mu\text{F} / 25\text{ V}$) y las dos resistencias de caída en serie **$2 \times 4.7\text{ k}\Omega\text{ / 3 W}$** montadas a $5\text{ mm}$ de altura sobre el PCB, la tensión media se mantiene en **$15.24\text{ V}$** con un rizado de apenas **$0.431\text{ Vpp}$**.

---

## 3. Diseño del Conversor F/V (Pines 12, 11, 4) y Lazo PI (Pin 16)

### A. Entrada del Tacómetro (Pin 12)
* Con $R_{\text{tacho}} = 73.0\text{ }\Omega$ y resistor limitador **$R_{12} = 10\text{ k}\Omega$**, la corriente pico a $2.500\text{ RPM}$ es:
  $$I_{12,\text{pk}} = \frac{8.84\text{ V}}{73.0\text{ }\Omega + 10.000\text{ }\Omega} = \mathbf{0.842\text{ mA}}$$
* El capacitor cerámico **$C_{12} = 10\text{ nF}$** en paralelo entre el Pin 12 y `GND_CHIP` forma un filtro pasabajos con frecuencia de corte:
  $$f_c = \frac{1}{2\pi \cdot (10\text{ k}\Omega \parallel 73\text{ }\Omega_{\text{fuente}}) \cdot 10\text{ nF}} \implies f_{c,\text{entrada}} = \frac{1}{2\pi \cdot 10\text{ k}\Omega \cdot 10\text{ nF}} = \mathbf{1.59\text{ kHz}}$$
  filtrando limpiamente los picos inductivos y el ruido de conmutación de escobillas sin atenuar los $166.6\text{ Hz}$ de las $2.500\text{ RPM}$.

### B. Bomba de Carga (Pin 11) e Integrador (Pin 4)
La tensión continua en el Pin 4 (`V_TACHO`) para $f(2.500\text{ RPM}) = 166.6\text{ Hz}$ es:
* **Con $C_{11} = 1.0\text{ nF}$, $R_{11} = 470\text{ k}\Omega$ y $R_4 = 270\text{ k}\Omega \parallel C_4 = 470\text{ nF}$:**
  * A **$2.500\text{ RPM}$ ($166.6\text{ Hz}$):** $V_{\text{Pin 4}} = \mathbf{5.14\text{ V}}$ ($\text{rizado } 0.24\text{ Vpp}$).
  * A **$400\text{ RPM}$ ($26.67\text{ Hz}$):** $V_{\text{Pin 4}} = \mathbf{0.93\text{ V}}$.
* **Con $C_{11} = 470\text{ pF}$, $R_{11} = 470\text{ k}\Omega$ y $R_4 = 330\text{ k}\Omega \parallel C_4 = 470\text{ nF}$:**
  * A **$2.500\text{ RPM}$ ($166.6\text{ Hz}$):** $V_{\text{Pin 4}} = \mathbf{3.07\text{ V}}$.
  * A **$400\text{ RPM}$ ($26.67\text{ Hz}$):** $V_{\text{Pin 4}} = \mathbf{0.56\text{ V}}$.

### C. Calibración de Consigna (Pin 5) con Preset Multivuelta de $50\text{ k}\Omega$ en Serie
La red divisora entre `+VCC` (Pin 9, $15.24\text{ V}$) y `GND_CHIP` (Pin 8) está compuesta por:
$$\text{Pin 9 (+VCC)} \xrightarrow{RV_1\text{ (Preset }50\text{ k}\Omega)} \text{Tope Pot.} \xrightarrow{RV_{\text{panel}}\text{ (}10\text{ k}\Omega)} \text{Base Pot.} \xrightarrow{R_{\text{MIN1}}\text{ (}2.2\text{ k}\Omega)} \text{Pin 8 (GND\_CHIP)}$$
* Con $C_{11} = 1\text{ nF}$ y $R_4 = 270\text{ k}\Omega$, ajustando el preset multivuelta `RV1` a **$24.1\text{ k}\Omega$** (mitad de recorrido):
  * Al **$100\%$ del potenciómetro**: $V_{\text{Pin 5, max}} = 15.24\text{ V} \cdot \frac{10\text{ k}\Omega + 2.2\text{ k}\Omega}{24.1\text{ k}\Omega + 10\text{ k}\Omega + 2.2\text{ k}\Omega} = \mathbf{5.12\text{ V}} \implies \mathbf{2.500\text{ RPM}}$.
  * Al **$0\%$ del potenciómetro**: $V_{\text{Pin 5, min}} = 15.24\text{ V} \cdot \frac{2.2\text{ k}\Omega}{36.3\text{ k}\Omega} = \mathbf{0.924\text{ V}} \implies \mathbf{400\text{ RPM}}$.

### D. Compensador Proporcional-Integral (Pin 16 `LOOP_COMP`)
El amplificador de error de transconductancia ($g_m \approx 340\text{ }\mu\text{A/V}$) ataca la red del Pin 16 compuesta por **$R_{16} = 47\text{ k}\Omega + C_{16} = 1\text{ }\mu\text{F}$** en paralelo con **$C_{17} = 47\text{ nF}$**:
* **Ganancia proporcional del amplificador:** $K_p = g_m \cdot R_{16} = 340\text{ }\mu\text{A/V} \times 47\text{ k}\Omega = \mathbf{16.0\text{ V/V}}$ ($24.1\text{ dB}$).
* **Cero de compensación PI:** $f_z = \frac{1}{2\pi R_{16} C_{16}} = \mathbf{3.39\text{ Hz}}$ ($\tau_i = 47\text{ ms}$).
* **Polo de atenuación de rizado tacométrico:** $f_p = \frac{1}{2\pi R_{16} C_{17}} = \mathbf{72.0\text{ Hz}}$.
* En la simulación transitoria ([`etapa2_lazo_pi_conversor_fv.log`](../Simulations/etapa2_lazo_pi_conversor_fv.log)), ante un escalón brusco de par de perforación en $t = 0.60\text{ s}$ a $2.500\text{ RPM}$, la caída transitoria es de apenas **$2.2\%$** ($2.435\text{ RPM}$ mínimas) y el integrador incrementa $V_{\text{Pin 16}}$ de **$2.93\text{ V}$ a $4.46\text{ V}$**, restableciendo las **$2.500\text{ RPM}$** sin sobreimpulso ni oscilaciones.
