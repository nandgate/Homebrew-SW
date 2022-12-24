
#include "BdEnable.h"
#include "Comm.h"
#include "CtrlPins.h"
#include "LED.h"

#define VERSION "0.1,"
#define HEART_BEAT_LED  13
#define HEART_BEAT_RATE 2000

void setup() {
  pinMode(HEART_BEAT_LED, OUTPUT);
  bden_Init();
  com_Init();
  ctrl_Init();
  led_Init();

  com_parse('0');   // no slot selected
  com_parse('U');   // all LEDS off
  com_parse('*');   // all ctrl inactive
  com_parse('?');   // show query message
  com_parse('-');   // show 12V_MON message
  com_prompt();     // show prompt
}

void heartbeat(void) {
  static uint16_t ticks;

  digitalWrite(HEART_BEAT_LED, (ticks < (HEART_BEAT_RATE/2)) ? LOW : HIGH);
  ticks = (ticks < HEART_BEAT_RATE) ? ticks+1 : 0;
}

void loop() {
  heartbeat();
  led_Scan();
  ctrl_Tick();
  com_tick();
  delayMicroseconds(50);
}
