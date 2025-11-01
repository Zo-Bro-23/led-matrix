module lettering(output [15:0] GPIO, input CLOCK_50, output [17:0] LEDR);
	letterbody(CLOCK_50, GPIO[2:0], GPIO[6:4], GPIO[11:8], GPIO[12], GPIO[13], GPIO[14], GPIO[3], GPIO[15], GPIO[7]);
endmodule

module letterbody(input CLOCK, output reg [2:0] RGB1, output reg [2:0] RGB2, output reg [3:0] addr, output reg CLK, LAT, OE, output GND1, GND2, GND3);
	assign GND1 = 0;
	assign GND2 = 0;
	assign GND3 = 0;
	
	reg clk;
	
	reg [24:0] clkcounter = 0;
	reg [24:0] rowcounter = 8025;
	reg [24:0] addrcounter = 0;
	reg [24:0] animcounter = 0;
	reg [24:0] lettercounter = 0;
	
	reg [111:0] store1 = 112'b0000111110011001100110011001111101101111011011110110100110010001100111001111100101101111111101111111011101100000;
	reg [111:0] store2 = 112'b0000010001100110100110011001011000111001100111111001101111110001011110000110111100010111001110010001110110010000;
	reg [111:0] store3 = 112'b0011001001100110111110011001011011000111110100111001110110010001011110010110111111010001001110010001110111110000;
	reg [111:0] store4 = 112'b0011111101101001100101101111011000111001111000110110100110011111100101111111100111110001111101111111011110010000;
	
	reg [255:0] row = 0;
	
	reg [215:0] message = 216'h00001B04050B0F0F03000D010009001B040C120F17000F0C0C0508;
	
	always @ (posedge CLOCK) begin
		clkcounter = clkcounter + 1;
		if (clkcounter == 1) begin
			clkcounter = 0;
			clk = !clk;
			if (rowcounter <= 63) CLK = clk;
			else CLK = 0;
		end
	end
	
	always @ (posedge clk) begin
		if (rowcounter <= 63) begin
			if (addrcounter <= 5 && addrcounter >= 2) begin
				RGB1 <= {3{row[(addrcounter - 2) * 64 + rowcounter]}};
			end
			else begin
				RGB1 <= 3'b000;
			end
			RGB2 <= 3'b000;
		end
		if (rowcounter == 500) OE <= 0;
		if (rowcounter == 550) LAT <= 1;
		if (rowcounter == 600) LAT <= 0;
		if (rowcounter == 650) OE <= 1;
		rowcounter <= rowcounter + 1;
		if (rowcounter == 8000) begin
			addr <= addr + 1;
			addrcounter[3:0] <= addr + 2;
		end
		if (rowcounter == 8050) rowcounter <= 0;
		
		animcounter <= animcounter + 1;
		if (animcounter == 8000000) begin // Any way to optimize this using bit-shift operators?
			row[55:0] <= row[63:8];
			row[63:56] <= {2'b00, store1[(message[(lettercounter * 8) +: 8] * 4) +: 4], 2'b00};
			row[119:64] <= row[127:72];
			row[127:120] <= {2'b00, store2[(message[(lettercounter * 8) +: 8] * 4) +: 4], 2'b00};
			row[183:128] <= row[191:136];
			row[191:184] <= {2'b00, store3[(message[(lettercounter * 8) +: 8] * 4) +: 4], 2'b00};
			row[247:192] <= row[255:200];
			row[255:248] <= {2'b00, store4[(message[(lettercounter * 8) +: 8] * 4) +: 4], 2'b00};
			lettercounter <= lettercounter + 1;
			animcounter <= 0;
			if (lettercounter == 26) lettercounter <= 0;
		end
	end
endmodule
