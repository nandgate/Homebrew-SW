typedef enum {
  BDEN_SLOT_0 = 0,
  BDEN_SLOT_1,
  BDEN_SLOT_2,
  BDEN_SLOT_3,
  BDEN_SLOT_4,
  BDEN_SLOT_5,
  NUMBER_OF_SLOTS,
  BDEN_SLOT_NONE = 255,  
} bden_t;

void bden_Init(void);
void bden_Select(bden_t slot);
bool bden_IsMainBdReady(void);
