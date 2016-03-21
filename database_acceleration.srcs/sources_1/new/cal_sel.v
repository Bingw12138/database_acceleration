`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.03.2016 07:38:48
// Design Name: 
// Module Name: cal_sel
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


module cal_sel
  (
    input wire [3 : 0] sel,
    output reg [3:0] newSel,
    output reg [1:0] muxSel
  );
  
  /*
  integer i;
  reg [1:0]zeroCount = 0;
  always @ (sel)
  begin
    for (i=0; i<4; i=i+1)
      if (sel[i] == 1'b0)
        zeroCount = zeroCount+1;
      else
      begin
        muxSel = i;
        newSel[i] = 0;
      end
    if (zeroCount >= 3)
      muxSel = 3;
  end
  */
  always @ (sel)
    case (sel)
      4'b0000:
      begin
        newSel = 4'b0000;
        muxSel = 3;
      end
      4'b0001:
      begin
        newSel = 4'b0000;
        muxSel = 0;
      end
      4'b0010:
      begin
        newSel = 4'b0000;
        muxSel = 1;
      end
      4'b0011:
      begin
        newSel = 4'b0010;
        muxSel = 0;
      end      
      4'b0100:
      begin
        newSel = 4'b0000;
        muxSel = 2;
      end      
      4'b0101:
      begin
        newSel = 4'b0100;
        muxSel = 0;
      end      
      4'b0110:
      begin
        newSel = 4'b0100;
        muxSel = 1;
      end      
      4'b0111:
      begin
        newSel = 4'b0110;
        muxSel = 0;
      end      
      4'b1000:
      begin
        newSel = 4'b0000;
        muxSel = 3;
      end      
      4'b1001:
      begin
        newSel = 4'b1000;
        muxSel = 0;
      end      
      4'b1010:
      begin
        newSel = 4'b1000;
        muxSel = 1;
      end      
      4'b1011:
      begin
        newSel = 4'b1010;
        muxSel = 0;
      end      
      4'b1100:
      begin
        newSel = 4'b1000;
        muxSel = 2;
      end      
      4'b1101:
      begin
        newSel = 4'b1100;
        muxSel = 0;
      end      
      4'b1110:
      begin
        newSel = 4'b1100;
        muxSel = 1;
      end      
      4'b1111:
      begin
        newSel = 4'b1110;
        muxSel = 0;
      end
    endcase      
endmodule
