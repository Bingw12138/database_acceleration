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

module select
(
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

//store and extend input
reg [TUPLE_WIDTH*NUMBER_OF_TUPLES+3*TUPLE_WIDTH-1 : 0] internal_input;
reg [TUPLE_WIDTH*NUMBER_OF_TUPLES-1 : 0] tmp_output;
//selection signal for each mux, 2 bits each
reg [2*NUMBER_OF_TUPLES-1 : 0] mux_sel;
reg [1:0] count_trailing_zero;
//store how many tuples selected, 8 bits should be enough
reg [7:0] number_of_selected_tuples;

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
initial count_zero = 0;
initial number_of_selected_tuples = 0;

always @ (posedge clk)
  case (state)
    FETCH:
    begin
      //extend the input with 3 more tuples, ready for shuffle
      internal_input = {{input_data}, {3*TUPLE_WIDTH{1'b0}}};
      internal_sel = sel;
      state = CAL_SEL;
    end
    CAL_SEL:
    begin
      for (i = 0; i < NUMBER_OF_TUPLES; i = i+1)
      begin
        for (j = 0; j <  4; j = j + 1)
          if (internal_sel[i+j] == 1)
          begin
            count_trailing_zero = j;
            number_of_selected_tuples = number_of_selected_tuples + 1;
            internal_sel[i+j] = 1'b0;
            break;
          end
        mux_sel[2*i+1:2*i] = count_trailing_zero;
        count_trailing_zero = 0;
      end
      state = SHUFFLE;
    end
    SHUFFLE:
    begin
      for (i = 0; i < NUMBER_OF_TUPLES; i= i+1)
      begin
        four_to_one_mux (internal_input[TUPLE_WIDTH*(i+4)-1 : TUPLE_WIDTH*i], mux_sel[2*i+1:2*i],
          tmp_output[TUPLE_WIDTH*(i+1)-1: TUPLE_WIDTH*i]);
      end
      state = FETCH;
    end
  endcase
endmodule
