module ledmatrix(output [15:0] GPIO, input CLOCK_50, output [17:0] LEDR);
	run(CLOCK_50, GPIO[2:0], GPIO[6:4], GPIO[11:8], GPIO[12], GPIO[13], GPIO[14], GPIO[3], GPIO[15], GPIO[7]);
endmodule

module run(input CLOCK, output reg [2:0] RGB1, output reg [2:0] RGB2, output reg [3:0] addr, output reg CLK, LAT, OE, output GND1, GND2, GND3);
	assign GND1 = 0;
	assign GND2 = 0;
	assign GND3 = 0;
	
	reg clk;
	reg frown;
	
	reg [24:0] clkcounter = 0;
	reg [24:0] rowcounter = 8025; // Starting high to allow it time to setup before starting the first line
	reg [24:0] addrcounter = 0;
	reg [24:0] animcounter = 0;
	
	reg [191:0] pixels1 = {16{24'b111110101100011010001000}}; // Pixels on a row from right to left
	reg [191:0] pixels2 = {16{24'b111110101100011010001000}};
	
	reg [191:0] eyes = {{14{3'b000}}, {6{3'b101}}, {24{3'b000}}, {6{3'b101}}, {14{3'b000}}};
	reg [191:0] smile;
	reg [191:0] white = {64{3'b000}};
	reg [191:0] yellow = {64{3'b110}};
	
	always @ (posedge CLOCK) begin
		clkcounter = clkcounter + 1;
		if (clkcounter == 1) begin
			clkcounter = 0;
			clk = !clk;
			if (rowcounter <= 63) CLK = clk;
			else CLK = 0;
		end
	end
	
	always @ (posedge clk) begin // Don't know why posedge works and negedge doesn't
		if (rowcounter <= 63) begin
			if (frown == 0) begin
				if (addrcounter <= 4 || addrcounter >= 10) RGB1 <= 3'b000;
				else RGB1 <= eyes[3*(rowcounter) +: 3];
				if (addrcounter <= 0 || addrcounter >= 15) RGB2 <= 3'b000;
				else if (rowcounter >= (addrcounter + 15) && rowcounter <= (addrcounter + 17)) RGB2 <= 3'b110;
				else if (rowcounter >= (63 - addrcounter - 17) && rowcounter <= (63 - addrcounter - 15)) RGB2 <= 3'b110;
				else RGB2 <= 3'b000;
			end
			
			// RGB1 <= pixels1[3*(rowcounter) +: 3];
			// RGB2 <= pixels2[3*(rowcounter) +: 3];
			
			else begin
				if (addrcounter <= 6 || addrcounter >= 10) RGB1 <= 3'b000;
				else RGB1 <= eyes[3*(rowcounter) +: 3];
				if (addrcounter <= 0 || addrcounter >= 15) RGB2 <= 3'b000;
				else if (rowcounter >= (15 - addrcounter + 15) && rowcounter <= (15 - addrcounter + 17)) RGB2 <= 3'b011;
				else if (rowcounter >= (63 - 15 + addrcounter - 17) && rowcounter <= (63 - 15 + addrcounter - 15)) RGB2 <= 3'b011;
				else RGB2 <= 3'b000;
			end
		end
		if (rowcounter == 500) OE <= 0; // Don't know why active high works and not active low
		if (rowcounter == 550) LAT <= 1;
		if (rowcounter == 600) LAT <= 0;
		if (rowcounter == 650) OE <= 1;
		rowcounter <= rowcounter + 1;
		if (rowcounter == 8000) begin
			addr <= addr + 1; // Confusing because of non blocking assignment
			addrcounter[3:0] <= addr + 2; // WHY? WHY??? Why does Matrix update address befofre
		end
		if (rowcounter == 8050) rowcounter <= 0; // Generally good to allow space?
		
		animcounter = animcounter + 1;
		if (animcounter == 25000000) begin
			frown <= !frown;
			animcounter <= 0;
		end
	end
endmodule
