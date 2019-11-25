module display(
		CLK_1M,
		A,
		B,
		C,
		D,
		SEL1,
		sel,
		seg
);//INPUT CLK:1M
input [3:0]A,B,C,D;
input [2:0]SEL1;
input CLK_1M;
output reg [7:0]seg;
output reg [3:0]sel;
reg [1:0]t;
reg [3:0]s;
reg [11:0]num;
reg CLK_1K;
always@(posedge CLK_1M) begin
	num=num+1;
	if(num==0)
	CLK_1K=~CLK_1K;
end
always@(posedge CLK_1K) begin
t<=t+1;
case(t)
		2'b00:begin sel<=4'b1110;s<=B; end
		2'b01:begin sel<=4'b1101;s<=C; end
		2'b10:begin sel<=4'b1011;s<=D; end
		2'b11:begin sel<=4'b0111;s<=A; end
default:sel<=4'b1111;
endcase
end
always@(posedge CLK_1K) begin
     case(s)
           4'b0000:seg[6:0] <=7'b1000000;//0
           4'b0001:seg[6:0] <=7'b1111001;//1
           4'b0010:seg[6:0] <=7'b0100100;//2
           4'b0011:seg[6:0] <=7'b0110000;//3
           4'b0100:seg[6:0] <=7'b0011001;//4
           4'b0101:seg[6:0] <=7'b0010010;//5
           4'b0110:seg[6:0] <=7'b0000010;//6
           4'b0111:seg[6:0] <=7'b1111000;//7
           4'b1000:seg[6:0] <=7'b0000000;//8
           4'b1001:seg[6:0] <=7'b0010000;//9        
           default:seg[6:0] <=7'b0111111;//-
         endcase
			end
always@(posedge CLK_1K) begin
if(SEL1==t) 
seg[7]<=0;
else 
seg[7]<=1;
end
endmodule
