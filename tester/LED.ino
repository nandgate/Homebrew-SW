
const uint8_t LED_C_PIN = 2;
const uint8_t LED_0_PIN = 3;
const uint8_t LED_1_PIN = 5;
const uint8_t LED_2_PIN = 6;
const uint8_t LED_3_PIN = 9;
const uint8_t LED_4_PIN = 10;
const uint8_t LED_5_PIN = 11;

const uint8_t LED_C[NUMBER_OF_COLORS] = {
  [LED_OFF] = LOW, 
  [LED_RED] = HIGH, 
  [LED_GREEN] = LOW
};

const uint8_t LED_N[NUMBER_OF_COLORS] = {
  [LED_OFF] = LOW, 
  [LED_RED] = LOW, 
  [LED_GREEN] = HIGH
};

const uint8_t LED_N_PIN[] = {
  [LED_0] = LED_0_PIN,
  [LED_1] = LED_1_PIN,
  [LED_2] = LED_2_PIN,
  [LED_3] = LED_3_PIN,
  [LED_4] = LED_4_PIN,
  [LED_5] = LED_5_PIN
};

void led_Init(void);
void led_Set(uint8_t led, uint8_t color);
void led_Scan(void);

uint8_t led_color[NUMBER_OF_LEDS];
uint8_t led_state;

void led_Init(void) {
  pinMode(LED_BUILTIN, OUTPUT);
  pinMode(LED_C_PIN, INPUT);
  pinMode(LED_0_PIN, INPUT);
  pinMode(LED_1_PIN, INPUT);
  pinMode(LED_2_PIN, INPUT);
  pinMode(LED_3_PIN, INPUT);
  pinMode(LED_4_PIN, INPUT);
  pinMode(LED_5_PIN, INPUT);

  // All leds off
  led_Set(LED_0, LED_OFF);
  led_Set(LED_1, LED_OFF);
  led_Set(LED_2, LED_OFF);
  led_Set(LED_3, LED_OFF);
  led_Set(LED_4, LED_OFF);
  led_Set(LED_5, LED_OFF);
  led_state= 0;
}

void led_Set(uint8_t led, uint8_t color) {
  led_color[led] = color; 
}

bool phase = true;

void led_Scan(void) {
  // turn off the current LED
  pinMode(LED_N_PIN[led_state], INPUT);      
  pinMode(LED_C_PIN, INPUT);

  // Advance to the next LED
  led_state++;
  if (led_state >= NUMBER_OF_LEDS) {
    led_state = 0;
    phase = !phase;
  }

  // Determine the state of the command and LED signals
  uint8_t c, n;
  if (led_color[led_state] == LED_YELLOW) {
      // Yellow alternates between red and green
      c= phase ? LED_RED : LED_GREEN;
      n= phase ? LED_RED : LED_GREEN;
  }
  else if ((led_color[led_state] == LED_RED) && phase) {
    // Don't show red half the time (to reduce brightness)
    c= LED_OFF;
    n= LED_OFF;
  }
  else {
    // Show red, green and off colors
    c= led_color[led_state];
    n= led_color[led_state];
  }

  // Update the outputs
  digitalWrite(LED_C_PIN, LED_C[c]);
  digitalWrite(LED_N_PIN[led_state], LED_N[n]);
  pinMode(LED_N_PIN[led_state], OUTPUT);
  pinMode(LED_C_PIN, OUTPUT);
}
