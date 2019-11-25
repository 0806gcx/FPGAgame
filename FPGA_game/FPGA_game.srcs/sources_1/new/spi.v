module spi
(
	input				clk,		//global clock
	input				spi_sck,
	input				spi_mosi,
	input				spi_cs,
	input		[15:0]	txd_data,	
	output	reg	[15:0]	rxd_data,
	output	reg			rxd_flag,
	output	reg			spi_miso,	
	output	reg			txd_flag
);
// ---------spi_receiver---------------
//synchronize the input signal
reg	spi_receive_sck_r0,	spi_receive_sck_r1;
reg	spi_mosi_r0,spi_mosi_r1;
always @ ( posedge clk)
		begin
                        spi_receive_sck_r0	<= spi_sck;		spi_receive_sck_r1	<= spi_receive_sck_r0;
                        spi_mosi_r0	<= spi_mosi;	        spi_mosi_r1	<= spi_mosi_r0;			
		end
reg	[4:0]	rxd_cnt /*synthesis noprune*/;
wire	mcu_data= spi_mosi_r1;
wire	mcu_read_flag = ( spi_receive_sck_r0 & ~spi_receive_sck_r1) ? 1'b1 : 1'b0;	//sck posedge capture
wire	mcu_read_done = (  rxd_cnt == 5'd16 ) ? 1'b1 : 1'b0;
//-----------------------------------
//sample input MOSI
reg		[15:0]	rxd_data_r;
always @ ( posedge clk)
begin
if(!spi_cs)
	begin
		if ( mcu_read_flag )
			begin
				rxd_data_r[4'd15-rxd_cnt]	<= mcu_data;
				rxd_cnt				<= rxd_cnt + 1'b1;
			end
		else
			begin
				rxd_data_r			<= rxd_data_r;
				rxd_cnt				<= rxd_cnt;
			end
	end
	else
		begin			
			rxd_data_r	<= rxd_data_r;
			rxd_cnt		<= 4'd0;
		end
end
//-----------------------------------
//output
always @ ( posedge clk)
begin

	 if ( mcu_read_done )
		begin
			rxd_data	<= rxd_data_r;
			rxd_flag	<= 1'b1;
		end
	else
		begin
			rxd_data	<= rxd_data;
			rxd_flag	<= 1'b0;
		end
end
// ---------spi_transfer---------------
//synchronize the input signal
reg	spi_sck_r0,	spi_sck_r1;
always @ ( posedge clk)
begin
	begin
      spi_sck_r0	<= spi_sck;		spi_sck_r1	<= spi_sck_r0;	
	end
end
wire	mcu_write_flag = ( ~spi_sck_r0 & spi_sck_r1) ? 1'b1 : 1'b0;	//sck negedge capture
//-----------------------------------
//FSM: encode
localparam	T_IDLE	= 2'd0;
localparam	T_START	= 2'd1;
localparam	T_SEND	= 2'd2;
localparam	SPI_MISO_DEFAULT = 1'b1;

//-----------------------------------
//transfer FSM
reg	[1:0]	txd_state;
reg	[5:0]	txd_cnt /*synthesis noprune*/;
always @ ( posedge clk)
begin
		case ( txd_state )
			T_IDLE:
				begin
					txd_cnt		<= 4'd0;
					spi_miso	<= SPI_MISO_DEFAULT;
						txd_state	<= T_START;
				end
			T_START:
				begin
					if ( !spi_cs)
						begin
						    spi_miso <= txd_data[4'd15-txd_cnt[5:0]];
						    txd_cnt  <= txd_cnt + 1'b1;
						    txd_state<= T_SEND;
						end
					else
						begin
						    spi_miso <= spi_miso;
						    txd_cnt  <= txd_cnt;
						    txd_state<= T_START;
						end
				end
			T_SEND:
				begin
					if ( spi_cs )
					begin
						txd_state	<= T_IDLE;
						txd_flag	<= ~txd_flag;
					end
					else
						begin
							if ( mcu_write_flag )
								 begin
									  if ( txd_cnt < 5'd16 )
											begin
											 spi_miso  <= txd_data[4'd15-txd_cnt[5:0]];
											 txd_cnt   <= txd_cnt + 1'b1;
											end
									  else
											begin
														spi_miso  <= 1'b1;
														txd_cnt   <= 0;
											end
								 end
							else
								begin
									spi_miso	<= spi_miso;
									txd_cnt		<= txd_cnt;
								end
						end
				end
			default:
				begin
					txd_cnt		<= 4'd0;
					spi_miso	<= SPI_MISO_DEFAULT;
					txd_state	<= T_IDLE;
				end
		endcase
end
//-----------------------------------
endmodule