`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:11:30 11/14/2022 
// Design Name: 
// Module Name:    top 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Top(
    input                   I_clk   , // ϵͳ50MHzʱ��
    input                   I_rst_n , // ϵͳ��λ
    output         [3:0]    O_red   , // VGA��ɫ����
    output         [3:0]    O_green , // VGA��ɫ����
    output         [3:0]    O_blue  , // VGA��ɫ����
    output                  O_hs    , // VGA��ͬ���ź�
    output                  O_vs      // VGA��ͬ���ź�
    );
	
    //��Ƶϵͳʱ�ӣ�����25MHZ��ʱ��
	reg R_clk_25M;
	always @(posedge I_clk or negedge I_rst_n)
	begin
		 if(!I_rst_n)
			  R_clk_25M   <=  1'b0;
		 else
			  R_clk_25M   <=  ~R_clk_25M;     
	end
		
	reg [11:0] vga_data;//vga��ɫ��ʾ
	wire [9:0] col_addr;//x��ֵ
	wire [8:0] row_addr;//y��ֵ
	

	reg  [18:0] R_rom_addr; // ROM�ĵ�ַ������Ҫ�������ص�����󣬷�������out of range
	wire [11:0] W_rom_data; // ROM�д洢�����ݣ��ܹ��洢12λ
	
    //����vgaģ�����r��g��b����ͬ���źš���ͬ���ź�
    vga vga_test(.vga_clk(R_clk_25M),.clrn(I_rst_n),.d_in(vga_data),.row_addr(row_addr),.col_addr(col_addr),.r(O_red),.g(O_green),.b(O_blue),.hs(O_hs),.vs(O_vs));
	
    //��Ҫ��ʾ��������ʾͼƬ����Ҫ�Ȼ�ȡͼƬ��ַR_rom_addr
	always @(posedge R_clk_25M or negedge I_rst_n)
	begin
		if(!I_rst_n)
			R_rom_addr <= 19'd0;
		else if(col_addr>=0&&col_addr<=639&&row_addr>=0&&row_addr<=479)
			begin //����������Ǳ���ͼȫ����ʾ
                if(R_rom_addr == 307199)
					R_rom_addr <= 19'd0;
				else
					R_rom_addr <= row_addr*40+col_addr;
			end
//			������(x,y)ΪͼƬ���Ͻǵ�����Ϊ������ʾͼƬ��ע������(x,y)�ķ�Χ��x:0~639; y:0~479
//			begin
//				if(R_rom_addr == imgSize) //imgSize��ͼ���С-1����height*width-1
//					R_rom_addr <= 19'd0;
//				else if(col_addr>=x && col_addr<=x+img_width-1 && row_addr>=y && row_addr <= y+img_height-1)
//					R_rom_addr <= R_rom_addr+1'd1;
//			end

	end
	
	//�����Ѿ��õ���ͼƬ���ص��ַR_rom_addrȡ��Ӧ������R_rom_data
	stone myStone (
  .clka(R_clk_25M), // input clka
  .wea(wea), // input [0 : 0] wea
  .addra(R_rom_addr), // input [11 : 0] addra
  .dina(dina), // input [15 : 0] dina
  .douta(W_rom_data) // output [15 : 0] douta
);
	
    //��������ʾ�����ݸ�vga_data,�Ȱ���ͼƬ��ʾ����Ҳ������������
	always @(posedge R_clk_25M or negedge I_rst_n)
	begin
	if(!I_rst_n)
		vga_data<=12'b0;
	else if(col_addr>=0&&col_addr<=639&&row_addr>=0&&row_addr<=479)
		vga_data<=W_rom_data[11:0];
	else
		vga_data<=12'b1;
	end
	
endmodule
