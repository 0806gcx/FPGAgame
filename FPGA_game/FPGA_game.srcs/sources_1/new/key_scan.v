`timescale 1ns / 1ps

module key_scan(
		clk,
		sw,
		key
);
input clk; //��ʱ���źţ�48MHz
input [3:0]sw;
output reg [3:0] key;
// ---------------------------------------------------------------------------
reg [19:0] cnt; //�����Ĵ���
always @ (posedge clk)
cnt <= cnt + 1'b1;
reg [3:0] low_sw;
always @(posedge clk)
if (cnt == 20'hfffff) //��20ms��������ֵ���浽�Ĵ���low_sw��
low_sw <= sw;
always @ ( posedge clk)
key<= low_sw;
endmodule
