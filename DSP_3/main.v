`timescale 1ns / 1ps
module SPI_DAC_MCP4921 (
	input wire clk,
	input wire rst,
	output reg cs_n,
	output reg sck,
	output reg mosi
);

	reg [1:0] state;
	reg [4:0] bit_count;
	reg [15:0] spi_data;

	reg [11:0] dac_data;

	reg sck_enable;
	reg [7:0] clk_div;

	reg [1:0]reverse;

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			clk_div <= 8'd0;
		end else if (clk_div == 8'd255) begin
			clk_div <= 8'd0;
			sck_enable <= 1'b1;  // SCK 활성화 신호 설정
		end else begin
			clk_div <= clk_div + 1;
			sck_enable <= 1'b0;  // 활성화 신호 해제
		end
	end


	always @(posedge clk or posedge rst) begin
		if (rst) begin
			state <= 2'b00;
			cs_n <= 1'b1;
			sck <= 1'b0;
			mosi <= 1'b0;
			bit_count <= 0;
			dac_data <= 12'd1000;
			reverse <= 2'b00;
			
		end else if (sck_enable) begin
			if(state == 2'b00) begin
				cs_n <= 1'b0;
				spi_data <= {4'b0101, dac_data};
				
				if(dac_data == 10'd0) begin
					reverse <= 2'b01;
				end else if(dac_data == 12'd1000) begin
					reverse <= 2'b00;
				end
				
				if(reverse == 2'b00) begin
					dac_data <= dac_data - 1;
				end else begin
					dac_data <= dac_data + 1;
				end
				
				bit_count <= 15;
				state <= 2'b01;
			end else if(state == 2'b01) begin
				if(!sck) begin
					mosi <= spi_data[bit_count];
				end
				sck <= ~sck;
				if (sck) begin
					if (bit_count == 0)
						state <= 2'b10;
					else
						bit_count <= bit_count - 1;
						
				end
			end else begin
				cs_n <= 1'b1;
				state <= 2'b00;
				mosi<=0;
			end
		end
	end
	
endmodule