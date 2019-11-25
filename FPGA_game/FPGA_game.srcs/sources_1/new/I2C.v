`timescale 1ns / 1ps
module I2C(
    CLK_5M,
    sda,
    SCK,
    data,
    output_light,
    reset
    );
parameter [7:0]addr=8'b00111100;
parameter [6:0]w_adder=7'b1000001;
parameter [6:0]r_adder=7'b0111000;

input CLK_5M;

output reg SCK;
output reg [15:0]data;
output reg output_light;

input sda;//I2CÊı¾İÏß

output reg reset;
reg sendstate;
reg [4:0]num;
reg CLK;
reg sda_r0,sda_r1;
reg [23:0]receive;
reg [4:0]state;
reg pp_1,pp_2;

always@(posedge CLK_5M)
    begin
        num=num+1;
        if(num==0)
        CLK<=~CLK;
        output_light<=SCK;
    end
always@(posedge CLK)
    begin
        sda_r0<=sda; sda_r1<=sda_r0;
    end
wire sda_flag= ( sda_r1 & ~sda_r0) ? 1'b1 : 1'b0;	//sck posedge capture
always@(posedge CLK)
begin
    if(!reset)
        begin
            reset<=1;
            SCK=1;      
            sendstate<=1; 
            state<=5'b10111;
        end
    else if(!sendstate)
        begin
//            if(!sda)
//                begin
                    SCK<=1;
                    sendstate<=1;
                    state<=5'b10111;
//                end
        end
    else 
        begin
            case(SCK)
                1'b1:begin
                        if(pp_1)
                            begin
                                pp_1<=0;
                                SCK<=0;  
                                state=state-1;                             
                            end
                        else
                            begin
                                pp_1<=1;
                                receive[state]<=sda;
                            end
                     end
                1'b0:begin
                        if(state==0)
                            begin
                                sendstate<=0;
                                data[15:0]<=receive[23:8];
                            end
                        else if(pp_2)
                            SCK<=1;
                        else
                         pp_2=pp_2+1;
                     end
            endcase
       end
end
endmodule
