`timescale 1ns / 1ps


module Booth_tb;

	// Inputs
	reg clk;
	reg load;
	reg [3:0] Multiplier;
	reg [3:0] Multiplicand;

	// Outputs
	wire [7:0] Product;

	// Instantiate the Unit Under Test (UUT)
	Booth uut (
		.clk(clk), 
		.load(load), 
		.Multiplier(Multiplier), 
		.Multiplicand(Multiplicand), 
		.Product(Product),
		.booth_dv(booth_dv)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		load = 1;
		Multiplier = -3;
		Multiplicand = 7;

		#1000000;
        
		// Add stimulus here
		load = 0;
				
		#1000000;

		// Initialize Inputs
		load = 1;
		Multiplier = -5;
		Multiplicand = 3;

		#100;
        
		// Add stimulus here
		load = 0;
	end

	always @(*)
		#10 clk <= ~clk;
      
endmodule