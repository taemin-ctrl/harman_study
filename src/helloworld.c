#include <stdio.h>
#include <stdint.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "sleep.h"

typedef struct{
	volatile uint32_t DR;
	volatile uint32_t CR;
} GPIOA_TypeDef;

typedef struct{
	volatile uint32_t MODER;
	volatile uint32_t ODR;
	volatile uint32_t IDR;
} GPIOB_TypeDef;

#define GPIOA_BASEADDR 0x40000000U
#define GPIOA 	((GPIOA_TypeDef *)GPIOA_BASEADDR)

#define GPIOB_BASEADDR 0x44A00000U
#define GPIOB 	((GPIOB_TypeDef *)GPIOB_BASEADDR)

//#define GPIO_DR 	  *(volatile uint32_t *)(GPIO_BASEADDR +0x00)
//#define GPIO_CR 	  *(volatile uint32_t *)(GPIO_BASEADDR +0x04)

int switch_getstate(GPIOA_TypeDef *GPIOx, int bit);

int main()
{
	int counter = 0;
	//GPIO_CR = 0xff00; // *(volatile uint32_t *)(GPIO_BASEADDR +0x00) = 0xff00
	GPIOA ->CR = 0xff00;
	GPIOB -> MODER = 0x0f;

	while(1){
		xil_printf("counter : %d\n", counter++);
		if (switch_getstate(GPIOA, 13)){
			GPIOA -> DR ^= 0xf0;

		}
		if (switch_getstate(GPIOA, 8)){
			GPIOA -> DR ^= 0x0f;
		}
		GPIOB -> ODR ^= 0x0f;
		usleep(300000);
	}
	return 0;
}

int switch_getstate(GPIOA_TypeDef *GPIOx, int bit){
	int temp;
	temp = GPIOx->DR & (1U << bit);
	return (temp == 0) ? 0 : 1;
}
