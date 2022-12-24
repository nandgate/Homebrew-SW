//
//  ?: query (name, version, slots)
//  
//  Signal  Reset Irq0  Irq1  (all)
//  High:   I     O     P     *
//  Low:    i     o     p     &
//  Pulse:  !     @     #
//
//  Slot:   1 2 3 4 5 6 NONE (all)
//  Select: 1 2 3 4 5 6 0
//  Off:    Q W E R T Y U
//  Yellow: q w e r t y u
//  Green:  a s d f g h j
//  Red:    z x c v b n m
//

// ADC Conversions: (15V fill scale)
// Vadc = (V12 * 830.42) / (830.42 + 10500) = V12 * 0.073291
// Cnts = Vadc * (1024/1.1) = Vadc * 930.9091
// Cnts = V12 * 0.073291 * 930.9091 = V12 * 68.2274
// V12 = Cnts / 68.2274

#define V12_CONV  68.2274
#define V12_MON   A7


void com_Init(void) {
    Serial.begin(9600);
    analogReference(INTERNAL);
    analogRead(V12_MON); // throw away the fisrt sample from the ADC
}

void com_parse(char c) {

  switch(c) {
    case '?':
      Serial.print("\ntester,");
      Serial.print(VERSION);
      Serial.println(NUMBER_OF_SLOTS);
      break;

    case '-':
      Serial.print("12V_MON,");
      Serial.println((analogRead(V12_MON)+analogRead(V12_MON)) / (2 * V12_CONV)); // average two samples to lower LSB noise
      break;

    case 'I':
      ctrl_Inactive(CTRL_RESET);
      break;
    case 'O':
      ctrl_Inactive(CTRL_IRQ0);
      break;
    case 'P':
      ctrl_Inactive(CTRL_IRQ1);
      break;
    case '*':
      ctrl_Inactive(CTRL_RESET);
      ctrl_Inactive(CTRL_IRQ0);
      ctrl_Inactive(CTRL_IRQ1);
      break;
      
    case 'i':
      ctrl_Active(CTRL_RESET);
      break;
    case 'o':
      ctrl_Active(CTRL_IRQ0);
      break;
    case 'p':
      ctrl_Active(CTRL_IRQ1);
      break;
    case '&':
      ctrl_Active(CTRL_RESET);
      ctrl_Active(CTRL_IRQ0);
      ctrl_Active(CTRL_IRQ1);
      break;

    case '!':
      ctrl_Pulse(CTRL_RESET, PULSE_DURATION);
      break;
    case '@':
      ctrl_Pulse(CTRL_IRQ0, PULSE_DURATION);
      break;
    case '#':
      ctrl_Pulse(CTRL_IRQ1, PULSE_DURATION);
      break;
    
    case '1':
      bden_Select(BDEN_SLOT_0);
      break;
    case '2':
      bden_Select(BDEN_SLOT_1);
      break;
    case '3':
      bden_Select(BDEN_SLOT_2);
      break;
    case '4':
      bden_Select(BDEN_SLOT_3);
      break;
    case '5':
      bden_Select(BDEN_SLOT_4);
      break;
    case '6':
      bden_Select(BDEN_SLOT_5);
      break;
    case '0':
      bden_Select(BDEN_SLOT_NONE);
      break;

    case 'Q':
      led_Set(LED_0, LED_OFF);
      break;
    case 'W':
      led_Set(LED_1, LED_OFF);
      break;
    case 'E':
      led_Set(LED_2, LED_OFF);
      break;
    case 'R':
      led_Set(LED_3, LED_OFF);
      break;
    case 'T':
      led_Set(LED_4, LED_OFF);
      break;
    case 'Y':
      led_Set(LED_5, LED_OFF);
      break;
    case 'U':
      led_Set(LED_0, LED_OFF);
      led_Set(LED_1, LED_OFF);
      led_Set(LED_2, LED_OFF);
      led_Set(LED_3, LED_OFF);
      led_Set(LED_4, LED_OFF);
      led_Set(LED_5, LED_OFF);
      break;

    case 'a':
      led_Set(LED_0, LED_GREEN);
      break;
    case 's':
      led_Set(LED_1, LED_GREEN);
      break;
    case 'd':
      led_Set(LED_2, LED_GREEN);
      break;
    case 'f':
      led_Set(LED_3, LED_GREEN);
      break;
    case 'g':
      led_Set(LED_4, LED_GREEN);
      break;
    case 'h':
      led_Set(LED_5, LED_GREEN);
      break;
    case 'j':
      led_Set(LED_0, LED_GREEN);
      led_Set(LED_1, LED_GREEN);
      led_Set(LED_2, LED_GREEN);
      led_Set(LED_3, LED_GREEN);
      led_Set(LED_4, LED_GREEN);
      led_Set(LED_5, LED_GREEN);
      break;

    case 'z':
      led_Set(LED_0, LED_RED);
      break;
    case 'x':
      led_Set(LED_1, LED_RED);
      break;
    case 'c':
      led_Set(LED_2, LED_RED);
      break;
    case 'v':
      led_Set(LED_3, LED_RED);
      break;
    case 'b':
      led_Set(LED_4, LED_RED);
      break;
    case 'n':
      led_Set(LED_5, LED_RED);
      break;
    case 'm':
      led_Set(LED_0, LED_RED);
      led_Set(LED_1, LED_RED);
      led_Set(LED_2, LED_RED);
      led_Set(LED_3, LED_RED);
      led_Set(LED_4, LED_RED);
      led_Set(LED_5, LED_RED);
      break;

    case 'q':
      led_Set(LED_0, LED_YELLOW);
      break;
    case 'w':
      led_Set(LED_1, LED_YELLOW);
      break;
    case 'e':
      led_Set(LED_2, LED_YELLOW);
      break;
    case 'r':
      led_Set(LED_3, LED_YELLOW);
      break;
    case 't':
      led_Set(LED_4, LED_YELLOW);
      break;
    case 'y':
      led_Set(LED_5, LED_YELLOW);
      break;
    case 'u':
      led_Set(LED_0, LED_YELLOW);
      led_Set(LED_1, LED_YELLOW);
      led_Set(LED_2, LED_YELLOW);
      led_Set(LED_3, LED_YELLOW);
      led_Set(LED_4, LED_YELLOW);
      led_Set(LED_5, LED_YELLOW);
      break;
  }  
}

void com_prompt(void) {
  Serial.print(bden_IsMainBdReady() ? "M" : "~");

  bden_t s= bden_GetSelected();
  if (s < NUMBER_OF_SLOTS) {
    Serial.print(s+1);
  } else {
    Serial.print('0');
  }  
  Serial.println('>');
}

void com_tick(void) {
  if (Serial.available()) {
    com_parse(Serial.read());
    com_prompt();
  }
}
