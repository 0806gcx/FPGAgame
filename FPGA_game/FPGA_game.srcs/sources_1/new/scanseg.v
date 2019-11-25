module scan_seg(
		clk,
		in_data,
		FLAG,
		A_out,
		B_out,
		C_out,
		D_out,
		select,
		out_data
);
input clk;
input [15:0]in_data;
input FLAG;
output reg [3:0] A_out,B_out,C_out,D_out;
output reg [2:0] select;
output reg [15:0] out_data;
reg [15:0]data;
//*************************************************************************************
always@(posedge clk)
begin
	if(FLAG)
		begin
			data<=in_data;
			A_out<=data%10;
			B_out<=data/10%10;
			C_out<=data/100%10;
			D_out<=data/1000%10;
			out_data<=data;
		end
	else
		begin
         out_data<=9;
		end
end
endmodule