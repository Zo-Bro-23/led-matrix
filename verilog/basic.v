module oldledmatrix(output [15:0] GPIO, input CLOCK_50);
	assign GPIO[3] = 0;
	assign GPIO[7] = 0;
	assign GPIO[15] = 0;
	ocustomclock(CLOCK_50, GPIO[12], GPIO[13], GPIO[14], GPIO[11:8], GPIO[2:0], GPIO[6:4]);
endmodule

module orun(output R1, G1, B1, GND1, R2, G2, B2, E, A, B, C, D, CLK, LAT, OE, GND2);
	 
endmodule

module ocustomclock(input CLOCK_50, output reg clk, lat, oe, output reg [3:0] addr, output reg [3:0] rgb1, output reg [3:0] rgb2);
	reg [24:0] counter = 0;
	reg [24:0] bigcounter = 0;
	
	always @ (posedge CLOCK_50) begin
		counter <= counter + 1;
		bigcounter <= bigcounter + 1;
		addr <= 9;
		rgb1 <= 3'b001;
		rgb2 <= 3'b000;
		if (bigcounter >= 126) clk <= 0;
		else if (counter == 1) begin
			clk <= !clk;
		end
		if (counter == 1) counter <= 0;
		if (bigcounter == 500) oe <= 0;
		if (bigcounter == 520) lat <= 1;
		if (bigcounter == 538) lat <= 0;
		if (bigcounter == 580) oe <= 1;
		if (bigcounter == 7800) begin
			bigcounter <= 0;
			//addr <= addr + 1;
		end
	end
endmodule
