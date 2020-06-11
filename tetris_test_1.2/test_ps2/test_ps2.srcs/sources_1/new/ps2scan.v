`timescale 1ns / 1ps
module ps2scan(clk_50M,rst,ps2k_clk,ps2k_data,ps2_byte,ps2_state,LED1,LED2,LED3,LED4);
input clk_50M; //50M时钟信号
input rst;  //复位信号
input ps2k_clk;   //PS2接口时钟信号
input ps2k_data;  //PS2接口数据信号
output[7:0] ps2_byte;    // 1byte键值，只做简单的按键扫描
output wire ps2_state;    //键盘当前状态，ps2_state=1表示有键被按下
output wire LED1,LED2,LED3,LED4;
reg ps2k_clk_r0,ps2k_clk_r1,ps2k_clk_r2;  //ps2k_clk状态寄存器
wire neg_ps2k_clk;   // ps2k_clk下降沿标志位

always @ (posedge clk_50M or negedge rst) begin
    if(!rst) begin
           ps2k_clk_r0 <= 1'b0;
           ps2k_clk_r1 <= 1'b0;
           ps2k_clk_r2 <= 1'b0;
       end

    else begin                         //锁存状态，进行滤波
           ps2k_clk_r0 <= ps2k_clk;
           ps2k_clk_r1 <= ps2k_clk_r0;
           ps2k_clk_r2 <= ps2k_clk_r1;
       end

end
assign neg_ps2k_clk = ~ps2k_clk_r1 & ps2k_clk_r2;    //下降沿

reg[7:0] ps2_byte_r;     //PC接收来自PS2的一个字节数据存储器
reg[7:0] temp_data;  //当前接收数据寄存器
reg[3:0] num; //计数寄存器

always @ (posedge clk_50M or negedge rst) begin
    if(!rst) begin
           num <= 4'd0;
           temp_data <= 8'd0;
       end
    else if(neg_ps2k_clk) begin //检测到ps2k_clk的下降
           case (num)
              4'd0:  num <= num+1'b1;
              4'd1:  begin
                         num <= num+1'b1;
                         temp_data[0] <= ps2k_data;  //bit0
                     end
              4'd2:  begin
                         num <= num+1'b1;
                         temp_data[1] <= ps2k_data;  //bit1
                     end
              4'd3:  begin
                         num <= num+1'b1;
                         temp_data[2] <= ps2k_data;  //bit2
                     end
              4'd4:  begin
                         num <= num+1'b1;
                        temp_data[3] <= ps2k_data;  //bit3
                     end
              4'd5:  begin
                         num <= num+1'b1;
                         temp_data[4] <= ps2k_data;  //bit4
                     end
              4'd6:  begin
                         num <= num+1'b1;
                         temp_data[5] <= ps2k_data;  //bit5
                     end
              4'd7:  begin
                         num <= num+1'b1;
                         temp_data[6] <= ps2k_data;  //bit6
                     end
              4'd8:  begin
                         num <= num+1'b1;
                         temp_data[7] <= ps2k_data;  //bit7
                     end
              4'd9:  begin
                         num <= num+1'b1;  //奇偶校验位，不做处理
                     end
              4'd10: begin
                         num <= 4'd0;  // num清零
                     end
              default: ;
              endcase
       end
end

reg key_f0;       //松键标志位，置1表示接收到数据8'hf0（键盘断码），再接收到下一个数据后清零
reg ps2_state_r;  //键盘当前状态，ps2_state_r=1表示有键被按下


always @ (posedge clk_50M or negedge rst) begin //接收数据的相应处理，这里只对1byte的键值进行处理
    if(!rst) begin
           key_f0 <= 1'b0;
           ps2_state_r <= 1'b0;
       end
    else if(num==4'd10&&neg_ps2k_clk) begin   //刚传送完一个字节数据
           if(temp_data == 8'hf0) key_f0 <= 1'b1;
           else begin
                  if(!key_f0) begin //说明有键按下
                         ps2_state_r <= 1'b1;
                         ps2_byte_r <= temp_data; //锁存当前键值
                     end
                  else begin
                         ps2_state_r <= 1'b0;
                         key_f0 <= 1'b0;
                     end
              end
       end
end

reg[7:0] ps2_asci=0;   //接收数据的相应ASCII码
always @ (posedge clk_50M) begin
    case (ps2_byte_r)    //键值转换为ASCII码，这里做的比较简单，只处理字母
       8'h15: ps2_asci <= 8'h51;   //Q
       8'h1d: ps2_asci <= 8'h57;   //W
       8'h24: ps2_asci <= 8'h45;   //E
       8'h2d: ps2_asci <= 8'h52;   //R
       8'h2c: ps2_asci <= 8'h54;   //T
       8'h35: ps2_asci <= 8'h59;   //Y
       8'h3c: ps2_asci <= 8'h55;   //U
       8'h43: ps2_asci <= 8'h49;   //I
       8'h44: ps2_asci <= 8'h4f;   //O
       8'h4d: ps2_asci <= 8'h50;   //P              
       8'h1c: ps2_asci <= 8'h41;   //A
       8'h1b: ps2_asci <= 8'h53;   //S
       8'h23: ps2_asci <= 8'h44;   //D
       8'h2b: ps2_asci <= 8'h46;   //F
       8'h34: ps2_asci <= 8'h47;   //G
       8'h33: ps2_asci <= 8'h48;   //H
       8'h3b: ps2_asci <= 8'h4a;   //J
       8'h42: ps2_asci <= 8'h4b;   //K
       8'h4b: ps2_asci <= 8'h4c;   //L
       8'h1a: ps2_asci <= 8'h5a;   //Z
       8'h22: ps2_asci <= 8'h58;   //X
       8'h21: ps2_asci <= 8'h43;   //C
       8'h2a: ps2_asci <= 8'h56;   //V
       8'h32: ps2_asci <= 8'h42;   //B
       8'h31: ps2_asci <= 8'h4e;   //N
       8'h3a: ps2_asci <= 8'h4d;   //M
       default: ;
       endcase
end
assign ps2_byte = ps2_asci;
assign ps2_state = ps2_state_r;

assign LED1=ps2_byte&8'h41;//a
assign LED2=ps2_byte&8'h42;//b
assign LED3=ps2_byte&8'h43;//c
assign LED4=ps2_byte&8'h44;//D
//initial
//begin
//LED1=0;
//LED2=0;
//LED3=0;
//LED4=0;
//LED5=0;
//end
//always@(*)begin
//if(ps2_byte==8'h41)//A
//LED1<=1;
//else if(ps2_byte==8'h42)//B
//LED2<=1;
//else if(ps2_byte==8'h43)//c
//LED3<=1;
//else if(ps2_byte==8'h44)//D
//LED4<=1;
//else LED5<=1;
//end

endmodule
