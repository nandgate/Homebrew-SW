typedef enum {
  LED_0,
  LED_1,
  LED_2,
  LED_3,
  LED_4,
  LED_5,
  NUMBER_OF_LEDS
} led_t;

typedef enum {
  LED_OFF,
  LED_RED,
  LED_GREEN,
  LED_YELLOW,
  NUMBER_OF_COLORS
} led_color_t;


void led_Init(void);
void led_Set(uint8_t led, uint8_t color);
void led_Scan(void);
