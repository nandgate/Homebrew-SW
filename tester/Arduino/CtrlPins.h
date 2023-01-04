
#define PULSE_DURATION 200

typedef enum {
  CTRL_RESET= 0,
  CTRL_IRQ0,
  CTRL_IRQ1
} ctrl_t;

void ctrl_Init(void);
void ctrl_Active(ctrl_t pin);
void ctrl_Inactive(ctrl_t pin);
void ctrl_Pulse(ctrl_t pin, uint16_t duration);
void ctrl_Tick(void);
