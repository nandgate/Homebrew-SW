const uint8_t CTRL_PIN[] = {
  [CTRL_RESET] = 4,
  [CTRL_IRQ0] = 7,
  [CTRL_IRQ1] = 8,
};

uint16_t ticker;
ctrl_t tickerPin;

void ctrl_Init(void) {
  pinMode(CTRL_PIN[CTRL_RESET], OUTPUT);
  ctrl_Inactive(CTRL_RESET);
  
  pinMode(CTRL_PIN[CTRL_IRQ0], OUTPUT);
  ctrl_Inactive(CTRL_IRQ0);

  pinMode(CTRL_PIN[CTRL_IRQ1], OUTPUT);
  ctrl_Inactive(CTRL_IRQ1);

  ticker = 0;
}

void ctrl_Active(ctrl_t pin) {
    digitalWrite(CTRL_PIN[pin], HIGH);
}

void ctrl_Inactive(ctrl_t pin) {
    digitalWrite(CTRL_PIN[pin], LOW);  
}

void ctrl_Pulse(ctrl_t pin, uint16_t duration) {
  ticker = duration;
  tickerPin = pin;
  ctrl_Active(pin);
}

void ctrl_Tick(void) {
  if (ticker > 0) {
    ticker--;
    if (0 == ticker) {
      ctrl_Inactive(tickerPin);
    }
  }
}
