`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.02.2016 03:23:41
// Design Name: 
// Module Name: select_testbench
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


module select_testbench(

    );
    
    reg [511:0] data_in;
    reg [15:0] sel;
    reg clk;
    reg req;
    wire [511:0] data_out;
    wire busy;
    
    always
      #1 clk = ~clk;
    
    initial
      #1000 $stop;
      
    initial
    begin
      clk = 0;
      data_in = 512'h000000AF000000AE000000AD000000AC000000AB000000AA000000A9000000A8000000A7000000A6000000A5000000A4000000A3000000A2000000A1000000A0;
      sel = 16'b0000111100001111;
      req = 1;
      #2
      req = 0;

      
      while(busy) #1;
      data_in = 512'h000000BF000000BE000000BD000000BC000000BB000000BA000000B9000000B8000000B7000000B6000000B5000000B4000000B3000000B2000000B1000000B0;
      sel = 16'b1111000011110000;
      req = 1;
      #2
      req = 0;

      while(busy) #1;
      data_in = 512'h000000CF000000CE000000CD000000CC000000BB000000CA000000C9000000C8000000C7000000B6000000C5000000C4000000C3000000C2000000C1000000C0;
      sel = 16'b0000111100001111;
      req = 1;
      #2
      req = 0;
      
      while(busy) #1;
      data_in = 512'h000000DF000000DE000000DD000000DC000000DB000000DA000000D9000000D8000000D7000000D6000000D5000000D4000000D3000000D2000000D1000000D0;
      sel = 16'b0101010101010101;
      req = 1;
      #2
      req = 0;
    end
    
    select test (.dataIn(data_in), .sel(sel), .clk(clk), .req(req), .dataOut(data_out), .busy(busy));
    
    
endmodule
