module TOP(CLK,SCK,mosi,cs,KEY,sel,seg,output_flag,miso,sda,SCK_I2C,flag_I2C,LED_2);

input CLK;
input SCK;
input mosi;
input cs;
input [3:0]KEY;
output [3:0]sel;
output [7:0]seg;
output output_flag;
output miso;
input sda;
output SCK_I2C;
output flag_I2C;
output LED_2;
//----------PLL--------------
wire CLK_1M;
wire CLK_50M;
wire CLK_100M;

   clk_wiz_0 instance_name
   (
    // Clock out ports
    .clk_out1(CLK_100M),     // output clk_out1
    .clk_out2(CLK_1M),     // output clk_out2
    .clk_out3(CLK_50M),     // output clk_out3
   // Clock in ports
    .clk_in1(CLK)
    );
//---------KEY---------------
wire [3:0]key_pp;
key_scan key_scan_m0(
		.clk (CLK_50M),
		.sw (KEY),
		.key(key_pp)
);
//----------spi--------------
wire [15:0]data;
wire [15:0]receive_data;
wire receive_flag;
spi spi_m0(
	.clk		(CLK_100M),		
	.spi_sck	(SCK),
	.spi_mosi (mosi),
	.spi_cs	(cs),
	.txd_data	(data),	
	.rxd_data	(receive_data),
	.rxd_flag	(receive_flag),
	.spi_miso	(miso),	
	.txd_flag	(output_flag)
);
//----------I2C----------------*--
wire [15:0]I2C_data_m0;
I2C I2C_m0(
    .CLK_5M(CLK_1M),
    .sda(sda),
    .SCK(SCK_I2C),
    .data(I2C_data_m0),
    .output_light(flag_I2C),
    .reset(LED_2)
    );
//----------scan_seg--------------
wire		[3:0]A0;
wire		[3:0]B0;
wire		[3:0]C0;
wire		[3:0]D0;
wire		[3:0]select;
scan_seg scan_seg_m0(
		.clk		(CLK_100M),
		.in_data	(I2C_data_m0),
		.FLAG		(receive_flag),
		.A_out			(A0),
		.B_out			(B0),
		.C_out			(C0),
		.D_out			(D0),
		.select	(select),
		.out_data	(data)
);
//----------display--------------
display display_m0(
		.CLK_1M	(CLK_1M),
		.A			(A0),
		.B			(B0),
		.C			(C0),
		.D			(D0),
		.SEL1		(select),
		.sel		(sel),
		.seg		(seg)
);

endmodule
