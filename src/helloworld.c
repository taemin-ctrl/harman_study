#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "sleep.h"

#define __IO volatile

typedef struct {
   __IO uint32_t CR;
   __IO uint32_t SOD;
   __IO uint32_t SID;
   __IO uint32_t SR;
}AXI4_TypeDef;

#define AXI4_BASEADDR      0x44a00000U
#define AXI4            ((AXI4_TypeDef *) AXI4_BASEADDR)

int main()
{
   AXI4 -> CR = 0;

   int temp=0;
   int sid_data;
   int sod_data;

   while(1){
      AXI4 -> SOD = 0x80; // 값 주기
      AXI4 -> CR = 1;      // 시작
      AXI4 -> CR = 0;      // start reg off

      //while ( ((AXI4-> SR) != 1) ){}
      usleep(300000);
      AXI4 -> SOD = 0xa1; // 값 주기
      AXI4 -> CR = 1;      // 시작
      AXI4 -> CR = 0;      // start reg off
      usleep(300000);

      AXI4 -> SOD = 0x00; // 값 주기
            AXI4 -> CR = 1;      // 시작
            AXI4 -> CR = 0;      // start reg off

            //while ( ((AXI4-> SR) != 1) ){}
            usleep(300000);


      //while ( ((AXI4-> SR) != 1) ){}

      sid_data = AXI4 -> SID;
      sod_data = AXI4 -> SOD;
      xil_printf(" sid_Data : %d\n", sid_data);
      xil_printf(" sod_Data : %d\n", sod_data);
      temp ++;
      usleep(300000);
   }
      return 0;
}
