
#include "BdEnable.h"
#include "CtrlPins.h"
#include "LED.h"

void setup() {
  bden_Init();
  ctrl_Init();
  led_Init();
  Serial.begin(9600);

  led_Set(LED_0, LED_OFF);
  led_Set(LED_1, LED_OFF);
  led_Set(LED_2, LED_OFF);
  led_Set(LED_3, LED_OFF);
  led_Set(LED_4, LED_OFF);
  led_Set(LED_5, LED_OFF);
}

void read(void) {
  int c= Serial.read();

  switch(c) {
    case '~':
      ctrl_Pulse(CTRL_RESET, 200);
      break;
    
    case '`':
      Serial.write(bden_IsMainBdReady() ? "Main ready\n" : "Main not ready\n");
      break;
    case '\t':
      bden_Select(BDEN_SLOT_NONE);
      break;
    case 'Q':
      bden_Select(BDEN_SLOT_0);
      break;
    case 'W':
      bden_Select(BDEN_SLOT_1);
      break;
    case 'E':
      bden_Select(BDEN_SLOT_2);
      break;
    case 'R':
      bden_Select(BDEN_SLOT_3);
      break;
    case 'T':
      bden_Select(BDEN_SLOT_4);
      break;
    case 'Y':
      bden_Select(BDEN_SLOT_5);
      break;

    
    case 'q':
      led_Set(LED_0, LED_OFF);
      break;
    case 'w':
      led_Set(LED_1, LED_OFF);
      break;
    case 'e':
      led_Set(LED_2, LED_OFF);
      break;
    case 'r':
      led_Set(LED_3, LED_OFF);
      break;
    case 't':
      led_Set(LED_4, LED_OFF);
      break;
    case 'y':
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

    case '1':
      led_Set(LED_0, LED_YELLOW);
      break;
    case '2':
      led_Set(LED_1, LED_YELLOW);
      break;
    case '3':
      led_Set(LED_2, LED_YELLOW);
      break;
    case '4':
      led_Set(LED_3, LED_YELLOW);
      break;
    case '5':
      led_Set(LED_4, LED_YELLOW);
      break;
    case '6':
      led_Set(LED_5, LED_YELLOW);
      break;
  }

}

void loop() {
  led_Scan();
  ctrl_Tick();
  
  read();
  delay(1);

  //Serial.println(millis());
}
