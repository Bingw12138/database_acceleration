`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.02.2016 15:20:25
// Design Name: 
// Module Name: mux_four_one
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


module mux_four_one
  #(
    parameter DATA_WIDTH = 32
  )
  (
    input wire [DATA_WIDTH*4-1 : 0] data_in,
    input wire [1:0] sel,
    output reg [DATA_WIDTH-1 : 0] data_out
   );
  always @ (data_in or sel)
    case (sel)
      0: data_out = data_in[DATA_WIDTH-1 : 0];
      1: data_out = data_in[DATA_WIDTH*2-1 : DATA_WIDTH];
      2: data_out = data_in[DATA_WIDTH*3-1 : DATA_WIDTH*2];
      3: data_out = data_in[DATA_WIDTH*4-1 : DATA_WIDTH*3];
    endcase
endmodule
