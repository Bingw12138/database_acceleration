`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.02.2016 02:24:13
// Design Name: 
// Module Name: select
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

//define states
`define FETCH 0
`define CAL_SEL 1
`define SHUFFLE 2
`define OUTPUT 3

module select(
input_data,
sel,
output_data
    );

//Generic parameters
parameter TUPLE_WIDTH = 32;
parameter NUMBER_OF_TUPLES = 16;

//Port declearation
input wire [TUPLE_WIDTH*NUMBER_OF_TUPLES-1 : 0] input_data;    
input wire [NUMBER_OF_TUPLES-1 : 0] sel;
output wire [TUPLE_WIDTH*NUMBER_OF_TUPLES-1 : 0] output_data;

reg [1:0] state;  //which state the divice is currently in
reg [NUMBER_OF_TUPLES-1 : 0] internal_sel;  //store sel bits in regs
reg [TUPLE_WIDTH*NUMBER_OF_TUPLES+3*TUPLE_WIDTH-1 : 0] internal_input;
reg [TUPLE_WIDTH*NUMBER_OF_TUPLES-1 : 0] tmp_output;
reg [2*NUMBER_OF_TUPLES-1 : 0] mux_sel;

// task perform four to one mux
task four_to_one_mux;
input [4*data_size-1 : 0] mux_input;
input [1:0] mux_sel;
output [TUPLE_WIDTH-1 : 0] mux_output;
begin
  case (mux_sel)
    0: mux_output = mux_input[TUPLE_WIDTH-1 : 0];
    1: mux_output = mux_input[TUPLE_WIDTH*2-1 : 0];
    2: mux_output = mux_input[TUPLE_WIDTH*3-1 : 0];
    3: mux_output = mux_input[TUPLE_WIDTH*4-1 : 0];
  endcase
end
endtask

//set the initial state as FETCH
initial state = FETCH;

always @ (posedge clk)
  case (state)
    FETCH:
    begin
      //extend the input with 3 more tuples, ready for shuffle
      internal_input = {{input_data}, {3*TUPLE_WIDTH{1'b0}}};
      internal_sel = sel;
    end
    CAL_SEL:
    begin
      for (i = 0; i < NUMBER_OF_TUPLES; i = i+1)
      begin
      end
    end
    SHUFFLE:
    begin
      for (i = 0; i < NUMBER_OF_TUPLES; i= i+1)
      begin
        tmp_out[TUPLE_WIDTH * (i+1) : TUPLE_WIDTH* i] 
          = four_to_one_mux (internal_input[TUPLE_WIDTH * (i+4) : data_size * i], mux_sel[i]);
      end
    end
  endcase
endmodule
