
#include "main.h"

void delay1Microsecond() {
    for(uint32_t i = 0; i < 32000; i++) {
        __NOP;
    }
}

void delayMicrosecond(uint32_t us) {
    while(us--) {
        delay1Microsecond();
    }
}

void delay(uint32_t ms) {
    while(ms--) {
        delayMicrosecond(1000);
    }
}

int main(void) {
    RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA, ENABLE);
    GPIO_InitTypeDef gpioInit;
    gpioInit.GPIO_Pin = GPIO_Pin_0;
    gpioInit.GPIO_Mode = GPIO_Mode_Out_PP;
    gpioInit.GPIO_Speed = GPIO_Speed_50MHz;
    GPIO_Init(GPIOA, &gpioInit);
    while(1) {
        GPIO_SetBits(GPIOA, GPIO_Pin_0);
        delay(500);
        GPIO_ResetBits(GPIOA, GPIO_Pin_0);
        delay(500);
    }
}
