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
`define RUN 1
`define OUTPUT 2
`define IDLE 3

module select
  #(
  //Generic parameters
  parameter TUPLE_WIDTH = 32,
  parameter NUMBER_OF_TUPLES = 16)
  (
  //port declearation
  input wire [TUPLE_WIDTH*NUMBER_OF_TUPLES-1 : 0] dataIn,
  input wire [NUMBER_OF_TUPLES-1 : 0] sel,
  input wire clk,
  input wire req,
  output reg [TUPLE_WIDTH*NUMBER_OF_TUPLES-1 : 0] dataOut,
  output wire busy
  );

  reg [TUPLE_WIDTH*(NUMBER_OF_TUPLES+3)-1 : 0] currentDataIn;
  reg [NUMBER_OF_TUPLES+3-1 : 0] currentSel;
  reg [NUMBER_OF_TUPLES-1 : 0] newSel;
  reg [2*NUMBER_OF_TUPLES-1 : 0] muxSel;
  reg [1:0] state;
  reg [1:0] nextState;
  reg [2*TUPLE_WIDTH*NUMBER_OF_TUPLES-1: 0] tmp_out;
  
  integer noSelectedThisTime= 0;
  integer currentSelected;
  integer noSelectedBefore;
  
  initial noSelectedBefore = 0;
  initial state = `FETCH;
  
  task calMuxSel;
    integer i;
    begin
      for (i = 0; i<NUMBER_OF_TUPLES; i=i+1)
        case (currentSel[i +: 4])
          4'b0000:
          begin
            muxSel [2*i +: 2] = 2'b11;
            currentSel[i+:4] = 4'b0000;
            newSel[i] = 0;
          end
          4'b0001:
          begin
            muxSel[2*i +: 2] = 2'b00;
            currentSel[i+:4] = 4'b0000;
            newSel[i] = 1;
          end
          4'b0010:
          begin
            muxSel[2*i +: 2] = 2'b10;
            currentSel[i+:4] = 4'b0000;
            newSel[i] = 1;
          end
          4'b0011:
          begin
            muxSel[2*i +: 2] = 2'b00;
            currentSel[i+:4] = 4'b0010;
            newSel[i] = 1;
          end      
          4'b0100:
          begin
            muxSel[2*i +: 2] = 2'b10;
            currentSel[i+:4] = 4'b0000;
            newSel[i] = 1;
          end      
          4'b0101:
          begin
            muxSel[2*i +: 2] = 2'b00;
            currentSel[i+:4] = 4'b0100;
            newSel[i] = 1;
          end      
          4'b0110:
          begin
            muxSel[2*i +: 2] = 2'b01;
            currentSel[i+:4] = 4'b0100;
            newSel[i] = 1;
          end      
          4'b0111:
          begin
            muxSel[2*i +: 2] = 2'b00;
            currentSel[i+:4] = 4'b0110;
            newSel[i] = 1;
          end      
          4'b1000:
          begin
            muxSel[2*i +: 2] = 2'b11;
            currentSel[i+:4] = 4'b0000;
            newSel[i] = 1;
          end      
          4'b1001:
          begin
            muxSel[2*i +: 2] = 2'b00;
            currentSel[i+:4] = 4'b1000;
            newSel[i] = 1;
          end      
          4'b1010:
          begin
            muxSel[2*i +: 2] = 2'b01;
            currentSel[i+:4] = 4'b1000;
            newSel[i] = 1;
          end      
          4'b1011:
          begin
            muxSel[2*i +: 2] = 2'b00;
            currentSel[i+:4] = 4'b1010;
            newSel[i] = 1;
          end      
          4'b1100:
          begin
            muxSel[2*i +: 2] = 2'b10;
            currentSel[i+:4] = 4'b1000;
            newSel[i] = 1;
          end      
          4'b1101:
          begin
            muxSel[2*i +: 2] = 2'b00;
            currentSel[i+:4] = 4'b1100;
            newSel[i] = 1;
          end      
          4'b1110:
          begin
            muxSel[2*i +: 2] = 2'b01;
            currentSel[i+:4] = 4'b1100;
            newSel[i] = 1;
          end      
          4'b1111:
          begin
            muxSel[2*i +: 2] = 2'b00;
            currentSel[i+:4] = 4'b1110;
            newSel[i] = 1;
          end
        endcase
      end
  endtask
  
  task shuffle;
    integer i;
    begin
      for (i=0; i<NUMBER_OF_TUPLES;i=i+1)
        case (muxSel[2*i+:2])
          0: tmp_out[(i+noSelectedBefore)*TUPLE_WIDTH +:TUPLE_WIDTH] = currentDataIn[i*TUPLE_WIDTH +:TUPLE_WIDTH];
          1: tmp_out[(i+noSelectedBefore)*TUPLE_WIDTH +:TUPLE_WIDTH] = currentDataIn[(i+1)*TUPLE_WIDTH +:TUPLE_WIDTH];
          2: tmp_out[(i+noSelectedBefore)*TUPLE_WIDTH +:TUPLE_WIDTH] = currentDataIn[(i+2)*TUPLE_WIDTH +:TUPLE_WIDTH];
          3: tmp_out[(i+noSelectedBefore)*TUPLE_WIDTH +:TUPLE_WIDTH] = currentDataIn[(i+3)*TUPLE_WIDTH +:TUPLE_WIDTH];
        endcase
    end
  endtask
  
  task countSelectedTuples;
    integer i;
    begin : forCount
      for (i = NUMBER_OF_TUPLES - 1; i >= 0 ; i=i-1)
        if (newSel[i] == 1)
        begin
          noSelectedThisTime = i + 1;
          disable forCount;
        end 
    end
  endtask
  
  assign busy = (state != `FETCH);
  always @ (posedge clk)
      state <= nextState;
  
  //FSM
  always @ (state, dataIn, sel,req)
    case (state)
      `FETCH:
        if (req)
        begin
          currentDataIn = {{3*TUPLE_WIDTH*{1'b0}},{dataIn}};
          currentSel = {3'b0,sel};
          nextState = `RUN;
        end
      `RUN:
      begin
        calMuxSel(); //claculate sel signals for mux
        shuffle(); //use muxSel signals to do shuffle
        countSelectedTuples();
        currentSelected = noSelectedThisTime+noSelectedBefore;
        if (currentSelected >= 16)
          nextState = `OUTPUT;
        else
        begin
          noSelectedBefore = currentSelected;
          nextState = `FETCH;
        end
      end
      `OUTPUT:
      begin
        noSelectedBefore = currentSelected - 16;
        dataOut = tmp_out[NUMBER_OF_TUPLES*TUPLE_WIDTH-1:0];;
        tmp_out = tmp_out >> (16 * TUPLE_WIDTH);
        nextState = `FETCH;
      end
      default:
      begin
        state <= `FETCH;
      end
    endcase
endmodule