`timescale 1ns / 1ps

module key_scan(
		clk,
		sw,
		key
);
input clk; //主时钟信号，48MHz
input [3:0]sw;
output reg [3:0] key;
// ---------------------------------------------------------------------------
reg [19:0] cnt; //计数寄存器
always @ (posedge clk)
cnt <= cnt + 1'b1;
reg [3:0] low_sw;
always @(posedge clk)
if (cnt == 20'hfffff) //满20ms，将按键值锁存到寄存器low_sw中
low_sw <= sw;
always @ ( posedge clk)
key<= low_sw;
endmodule
