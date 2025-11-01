module pledmatrix(output [15:0] GPIO, input CLOCK_50);
	run(CLOCK_50, GPIO[2:0], GPIO[6:4], GPIO[11:7], GPIO[12], GPIO[13], GPIO[14], GPIO[3], GPIO[15]);
endmodule

module prun(input CLOCK, output [2:0] RGB1, output [2:0] RGB2, output [4:0] addr, CLK, LAT, OE, GND1, GND2);
	assign GND1 = 0;
	assign GND2 = 0;
	assign addr[4] = 0;
	
	wire clk;
	wire sig1;
	wire sig2;
	internalclk(CLOCK, clk);
	row(clk, {64{3'b010}}, {64{3'b001}}, sig1, RGB1, RGB2, sig2);
	column(clk, sig2, addr[3:0], CLK, LAT, OE, sig1);
endmodule

module pcolumn(input CLK, input insig, output reg [3:0] addr, output reg clk, lat, oe, output reg outsig);
	reg [24:0] counter = 0;
	
	always @ (posedge CLK) begin
		if (insig == 1) begin
			outsig <= 1;
			counter <= counter + 1;
			if (counter == 500) oe <= 0;
			if (counter == 520) lat <= 1;
			if (counter == 538) lat <= 0;
			if (counter == 580) oe <= 1;
			if (counter == 7800) begin
				counter <= 0;
				addr <= addr + 1;
				outsig <= 0;
			end
		end
		outsig <= 0;
	end
endmodule

module prow(input clk, input [191:0] pixels1, pixels2, input insig, output reg [2:0] rgb1, rgb2, output reg outsig);
	reg [24:0] counter = 0;
	always @ (negedge clk) begin
		if (insig == 0) begin
			rgb1 <= pixels1[3*(counter) +: 3];
			rgb2 <= pixels2[3*(counter) +: 3];
			if (counter == 63) begin
				outsig <= 1;
				counter <= 0;
			end
			else outsig <= 0;
			counter <= counter + 1;
		end
		outsig <= 1;
	end
endmodule

module pinternalclk(input clk, output reg CLK);
	reg [24:0] counter = 0;
	
	always @ (posedge clk) begin
		counter <= counter + 1;
		if (counter == 1) begin
			counter <= 0;
			CLK <= !CLK;
		end
	end
endmodule
