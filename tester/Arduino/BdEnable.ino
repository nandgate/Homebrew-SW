#define BDEN_MAIN_BD_PIN  12

static bden_t bden_selected;

const uint8_t BDEN_PIN[] = {
  [BDEN_SLOT_0] = 19,
  [BDEN_SLOT_1] = 18,
  [BDEN_SLOT_2] = 17,
  [BDEN_SLOT_3] = 16,
  [BDEN_SLOT_4] = 15,
  [BDEN_SLOT_5] = 14,
};

void bden_Init(void) {
  pinMode(BDEN_PIN[BDEN_SLOT_0], OUTPUT);
  pinMode(BDEN_PIN[BDEN_SLOT_1], OUTPUT);
  pinMode(BDEN_PIN[BDEN_SLOT_2], OUTPUT);
  pinMode(BDEN_PIN[BDEN_SLOT_3], OUTPUT);
  pinMode(BDEN_PIN[BDEN_SLOT_4], OUTPUT);
  pinMode(BDEN_PIN[BDEN_SLOT_5], OUTPUT);
  pinMode(BDEN_MAIN_BD_PIN, INPUT_PULLUP);
  bden_selected = BDEN_SLOT_NONE;
}

void bden_Select(bden_t slot) {
  digitalWrite(BDEN_PIN[BDEN_SLOT_0], HIGH);
  digitalWrite(BDEN_PIN[BDEN_SLOT_1], HIGH);
  digitalWrite(BDEN_PIN[BDEN_SLOT_2], HIGH);
  digitalWrite(BDEN_PIN[BDEN_SLOT_3], HIGH);
  digitalWrite(BDEN_PIN[BDEN_SLOT_4], HIGH);
  digitalWrite(BDEN_PIN[BDEN_SLOT_5], HIGH);

  bden_selected = BDEN_SLOT_NONE;
  if (slot < NUMBER_OF_SLOTS) {
    digitalWrite(BDEN_PIN[slot], LOW);
    bden_selected = slot;
  }
}

bool bden_IsMainBdReady(void) {
  return digitalRead(BDEN_MAIN_BD_PIN) == LOW;
}

bden_t bden_GetSelected(void) {
  return bden_selected;
}
