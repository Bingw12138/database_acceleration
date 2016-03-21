`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.02.2016 12:09:48
// Design Name: 
// Module Name: stringMatching
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module stringMatching
  #(parameter STR_LEN = 10, //must be 2, 4, 6, 8 or 10
    parameter DATA_WIDTH = 512) // must be a multiple of 64 bit
  (input wire [DATA_WIDTH -1 : 0] dataIn,
   output reg [DATA_WIDTH-1 : 0] dataOut,
   input wire WE, //tells the module to read or wirte or idle
   input wire clk,
   output reg found
   );
  
  reg [DATA_WIDTH-1 : 0] dataInReg;
  always @ (posedge clk)
    dataInReg <= dataIn;
    
  always @ (posedge clk)
    dataOut <= dataInReg;
    
  initial found = 0;
    
  localparam NO_BYTES = DATA_WIDTH / 8;
  localparam NO_RAMS = (NO_BYTES * STR_LEN)/ 4; //Number of RAM32M premitives needed 
  localparam NO_NIBBLES = (NO_BYTES * STR_LEN) * 2; //each block has 2 output nibbles.
  localparam DO_PER_RAM = 8; //data out per Ram
  localparam ADDRS_PER_RAM = 5 * 4; //4 slices, 5 bit address each
  
  reg [NO_RAMS*ADDRS_PER_RAM - 1 : 0] ADDR; //Totoal Address
  reg [NO_NIBBLES - 1 : 0] DI; //Data in nibbles
  wire [NO_NIBBLES - 1 : 0] DO;


// RAM32M: 32-deep by 8-wide Multi Port LUT RAM (Mapped to four SliceM LUT6s)
//         7 Series
// Xilinx HDL Libraries Guide, version 2015.4
  genvar i; 
  generate 
    for (i=0; i < NO_RAMS; i=i+1)
    begin
      RAM32M 
      #(
        .INIT_A(64'h0000000000000000), // Initial contents of A Port
        .INIT_B(64'h0000000000000000), // Initial contents of B Port
        .INIT_C(64'h0000000000000000), // Initial contents of C Port
        .INIT_D(64'h0000000000000000)  // Initial contents of D Port
      ) 
      RAM32M_inst
      (
        .DOA(DO[DO_PER_RAM*i +: 2]),     // Read port A 2-bit output
        .DOB(DO[DO_PER_RAM*i+2 +: 2]),     // Read port B 2-bit output
        .DOC(DO[DO_PER_RAM*i+4 +: 2]),     // Read port C 2-bit output
        .DOD(DO[DO_PER_RAM*i+6 +: 2]),     // Read/write port D 2-bit output
        .ADDRA(ADDR[ADDRS_PER_RAM*i +: 5]), // Read port A 5-bit address input
        .ADDRB(ADDR[ADDRS_PER_RAM*i+5 +: 5]), // Read port B 5-bit address input
        .ADDRC(ADDR[ADDRS_PER_RAM*i+10 +: 5]), // Read port C 5-bit address input
        .ADDRD(ADDR[ADDRS_PER_RAM*i+15 +: 5]), // Read/write port D 5-bit address input
        .DIA(DI[DO_PER_RAM*i +: 2]),     // RAM 2-bit data write input addressed by ADDRD,
                                        //   read addressed by ADDRA
        .DIB(DI[DO_PER_RAM*i+2 +: 2]),     // RAM 2-bit data write input addressed by ADDRD,
                                          //   read addressed by ADDRB
        .DIC(DI[DO_PER_RAM*i+4 +: 2]),     // RAM 2-bit data write input addressed by ADDRD,
                                          //   read addressed by ADDRC
        .DID(DI[DO_PER_RAM*i+6 +: 2]),     // RAM 2-bit data write input addressed by ADDRD,
                                          //   read addressed by ADDRD
        .WCLK(clk),   // Write clock input
        .WE(WE)        // Write enable input
      );
    end
  endgenerate
  

  integer byteCount;
  integer j;;
  integer dataInByteCount;
  integer charCount;
  integer nibbleCount;
  
  always @ (dataInReg)
  begin
    //mapping ADDR with data_in high nibbles
    for (j=0; j<NO_RAMS*ADDRS_PER_RAM; j=j+1)
    begin
      byteCount = j/(STR_LEN * 5);  //each byte is mapped to string_leng LUTs and each LUTs has 5 addres
      if (j % 5 == 4) //only intreasted in 4-bits put 5th bit always 0;
        ADDR[j] = 0;
      else if (j % 10 == 0) //read low nibble
        ADDR[j +: 4] = dataInReg[byteCount*8 +: 4];
      else if (j % 5 == 0) //read/write high nibble
        ADDR[j +: 4] = dataInReg[(byteCount*8+4) +: 4];
    end
    
    //while writing, DI will be carried at low nibbles in data_in(replicated for every 64bits)
    //following is 10 char example
    //ADR(3..0)|-,-,-,- | ADR(3..0)|-,-,-,- | ADR(3..0)|-,-,-,- | ADR(3..0)|C9H,C8H,C9L,C8L ||| ADR(3..0)|C7H,C6H,C7L,C6L | ADR(3..0)|C5H,C4H,C5L,C4L | ADR(3..0)|C3H,C2H,C3L,C2L | ADR(3..0)|C1H,C0H,C1L,C0L
     
    dataInByteCount = 0;
    charCount = 0;
    for (nibbleCount = 0; nibbleCount<NO_NIBBLES/4; nibbleCount=nibbleCount+1)
    begin
      DI[nibbleCount*4+3] = dataInReg[(dataInByteCount*8)+(64*(charCount/8))+3]; //second char high nibble
      DI[nibbleCount*4+2] = dataInReg[(dataInByteCount*8)+(64*(charCount/8))+2]; //first char high nibbgle
      DI[nibbleCount*4+1] = dataInReg[(dataInByteCount*8)+(64*(charCount/8))+1]; //second char low nibble
      DI[nibbleCount*4]   = dataInReg[(dataInByteCount*8)+(64*(charCount/8))]; //first char low nibble
      dataInByteCount = dataInByteCount + 1;
      if (dataInByteCount >= STR_LEN/2) //finished 
      begin
        dataInByteCount = 0;
        charCount = charCount + 1;
      end
    end
  end
  
  reg [NO_BYTES-1:0] stringMatch;
  reg [NO_BYTES*STR_LEN + (STR_LEN * (STR_LEN-1))-1 : 0] charFound; //vector conta
  
  initial stringMatch = 0;
  initial
    for (j=NO_BYTES*STR_LEN; j < (NO_BYTES*STR_LEN) +(STR_LEN * STR_LEN)-1; j=j+1)
      charFound[j] = 1;
    
  integer blockCount;
  reg tmp;
  always @ (posedge clk)
  begin
    //get char histogram
    for (blockCount=0; blockCount< NO_BYTES*(STR_LEN/2) ; blockCount=blockCount+1)
    begin
      charFound[blockCount*2] = DO[blockCount*4] & DO[blockCount*4+2];
      charFound[blockCount*2+1] = DO[blockCount*4+1] & DO[blockCount*4+3];
    end
    
    //AND char in a diagnoal way based on histogram
    for (byteCount = 0; byteCount<(NO_BYTES); byteCount=byteCount+1)
    begin
      tmp = 1;
      for (j = 0; j < STR_LEN/2; j=j+1)
        tmp = tmp & charFound[byteCount*STR_LEN + (STR_LEN * 2 *j) + (2*j)] & charFound[byteCount*STR_LEN + (STR_LEN * 2 *j) + (2*j) + STR_LEN + 1];
      stringMatch[byteCount] = tmp;
    end
    
    if (stringMatch[NO_BYTES-STR_LEN-1 : 0] > 0)
      found = 1;  
  end
endmodule
