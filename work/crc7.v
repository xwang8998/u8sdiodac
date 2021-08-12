// ==========================================================================
// CRC Generation Unit - Linear Feedback Shift Register implementation
// (c) Kay Gorontzi, GHSi.de, distributed under the terms of LGPL
// https://www.ghsi.de/CRC/
// ==========================================================================
module crc7(BITVAL, ENABLE, BITSTRB, rst_n, CRC);
   input        BITVAL;                            // Next input bit
   input        ENABLE;                            // Enable calculation
   input        BITSTRB;                           // Current bit valid (Clock)
   input        rst_n;                             // Init CRC value
   output [6:0] CRC;                               // Current output CRC value

   reg    [6:0] CRC;                               // We need output registers
   wire         inv;

   assign inv = BITVAL ^ CRC[6];                   // XOR required?

   always @(posedge BITSTRB or negedge rst_n) begin
      if (0==rst_n) begin
         CRC <= 0;                                  // Init before calculation
         end
      else begin
         if (ENABLE == 1'b1) begin
             CRC[6] <= CRC[5];
             CRC[5] <= CRC[4];
             CRC[4] <= CRC[3];
             CRC[3] <= CRC[2] ^ inv;
             CRC[2] <= CRC[1];
             CRC[1] <= CRC[0];
             CRC[0] <= inv;
             end
         else
             CRC <= CRC;
         end
      end

endmodule

//
// ==========================================================================
// CRC Generation Unit - Linear Feedback Shift Register implementation
// (c) Kay Gorontzi, GHSi.de, distributed under the terms of LGPL
// ==========================================================================
// X^16+X^12+X^5+1
// 512 bytes with 0xFF data --> CRC16 = 0x7FA1
//
module crc16(BITVAL, ENABLE, BITSTRB, rst_n, CRC, CRCX);
   input        BITVAL;                            // Next input bit
   input        ENABLE;                            // Enable calculation
   input        BITSTRB;                           // Current bit valid (Clock)
   input        rst_n;                             // Init CRC value
   output [15:0] CRC;                               // Current output CRC value

   reg    [15:0] CRC;                               // We need output registers
   output [15:0] CRCX;                               // We also need num buffered output 
   wire         inv;
   
   assign inv = BITVAL ^ CRC[15];                   // XOR required?

   assign CRCX = { CRC[14:12], CRC[11] ^ inv, CRC[10:5],  CRC[4] ^ inv, CRC[3:0], inv };


   always @(posedge BITSTRB or negedge rst_n) begin
      if (1'b0 == rst_n) begin
         CRC <= 0;                                  // Init before calculation
         end
      else begin
         if (ENABLE == 1'b1) begin
             CRC <= CRCX;
             end
         else
             CRC <= CRC;
         end
      end
   
endmodule

`ifdef CHK_C_CODE
//CRC16
// ==========================================================================
// CRC Generation Unit - Linear Feedback Shift Register implementation
// (c) Kay Gorontzi, GHSi.de, distributed under the terms of LGPL
// ==========================================================================
char *MakeCRC(char *BitString)
   {
   static char Res[17];                                 // CRC Result
   char CRC[16];
   int  i;
   char DoInvert;
   
   for (i=0; i<16; ++i)  CRC[i] = 0;                    // Init before calculation
   
   for (i=0; i<strlen(BitString); ++i)
      {
      DoInvert = ('1'==BitString[i]) ^ CRC[15];         // XOR required?

      CRC[15] = CRC[14];
      CRC[14] = CRC[13];
      CRC[13] = CRC[12];
      CRC[12] = CRC[11] ^ DoInvert;
      CRC[11] = CRC[10];
      CRC[10] = CRC[9];
      CRC[9] = CRC[8];
      CRC[8] = CRC[7];
      CRC[7] = CRC[6];
      CRC[6] = CRC[5];
      CRC[5] = CRC[4] ^ DoInvert;
      CRC[4] = CRC[3];
      CRC[3] = CRC[2];
      CRC[2] = CRC[1];
      CRC[1] = CRC[0];
      CRC[0] = DoInvert;
      }
      
   for (i=0; i<16; ++i)  Res[15-i] = CRC[i] ? '1' : '0'; // Convert binary to ASCII
   Res[16] = 0;                                         // Set string terminator

   return(Res);
   }

// A simple test driver: result should be 0x7FA1

#include <stdio.h>

int main()
   {
   char *Result;                                       // Declare two strings
   char Data[8192];
   int i;
   for (i=0;i<512*8; i++) Data[i] = '1';
   Data[i] = 0;

   Result = MakeCRC(Data);                                    // Calculate CRC

   printf("CRC of [%s]\n is [%s] with P=[10001000000100001]\n", Data, Result);

   return(0);
   }

`endif
