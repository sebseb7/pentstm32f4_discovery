#include "main.h"

static __IO uint32_t TimingDelay;
void Delay(__IO uint32_t nTime)
{
	TimingDelay = nTime;

	while(TimingDelay != 0);
}

void TimingDelay_Decrement(void)
{
	if (TimingDelay != 0x00)
	{ 
		TimingDelay--;
	}
}


GPIO_InitTypeDef  GPIO_InitStructure;

int main(void)
{
	RCC_ClocksTypeDef RCC_Clocks;

	/* SysTick end of count event each 10ms */
	RCC_GetClocksFreq(&RCC_Clocks);
	SysTick_Config(RCC_Clocks.HCLK_Frequency / 100);

	/* GPIOD Periph clock enable */
	RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOD, ENABLE);

	/* Configure PD12, PD13, PD14 and PD15 in output pushpull mode */
	GPIO_InitStructure.GPIO_Pin = GPIO_Pin_12 | GPIO_Pin_13| GPIO_Pin_14| GPIO_Pin_15;
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_OUT;
	GPIO_InitStructure.GPIO_OType = GPIO_OType_PP;
	GPIO_InitStructure.GPIO_Speed = GPIO_Speed_100MHz;
	GPIO_InitStructure.GPIO_PuPd = GPIO_PuPd_NOPULL;
	GPIO_Init(GPIOD, &GPIO_InitStructure);

	while (1)
	{
		/* PD12 to be toggled */
		GPIO_SetBits(GPIOD, GPIO_Pin_12);

		/* Insert delay */
		Delay(0xFFFFF);

		/* PD13 to be toggled */
		GPIO_SetBits(GPIOD, GPIO_Pin_13);

		/* Insert delay */
		Delay(0xFFFFF);

		/* PD14 to be toggled */
		GPIO_SetBits(GPIOD, GPIO_Pin_14);

		/* Insert delay */
		Delay(0xFFFFF);

		/* PD15 to be toggled */
		GPIO_SetBits(GPIOD, GPIO_Pin_15);

		/* Insert delay */
		Delay(0xFFFFF);

		GPIO_ResetBits(GPIOD, GPIO_Pin_12|GPIO_Pin_13|GPIO_Pin_14|GPIO_Pin_15);

		/* Insert delay */
		Delay(0xFFFFFF);
	}
}
