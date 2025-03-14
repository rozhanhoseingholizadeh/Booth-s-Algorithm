`timescale 1ns / 1ps


module Booth
	#(parameter CLKS_PER_BIT = 5208)
	(
	input clk,
	input load,
	input [3:0] Multiplier,
	input [3:0] Multiplicand,
	output reg [7:0] Product,
	output reg booth_dv 
    );
	 
	 reg [3:0] Accumulator = 	4'b0;
	 reg Q_minus_one  	   = 	0;
	 reg [3:0] Q_temp      = 	4'b0;
	 reg [3:0] M_temp      = 	4'b0;
	 reg [2:0] Count       = 	3'd4;
	 

	always @(posedge clk)begin
		
		if (load == 1)begin
			Accumulator  = 	4'b0;
			Q_minus_one  = 	0;
			Product 	 = 	8'b0;
			Count 		 = 	3'd4;
			Q_temp 		 = 	Multiplicand;
			M_temp 		 = 	Multiplier;
			booth_dv 	<= 	0;
		end

		else if((Q_temp[0] == Q_minus_one) && (Count > 3'd0))   // 00 & 11
			begin
				Q_minus_one 	=  Q_temp[0];
				Q_temp 			= {Accumulator[0],Q_temp[3:1]};		      // right shift Multiplicand							
				Accumulator 	= {Accumulator[3],Accumulator[3:1]};  // right shift Accumulator	
				Count 			= Count - 1'b1;					
			end

		else if((Q_temp[0] == 1 && Q_minus_one == 0) && (Count > 3'd0))   // Start of a string of ones ---> 10
			begin
				Accumulator 	= Accumulator - M_temp;
				Q_minus_one 	= Q_temp[0];
				Q_temp 			= {Accumulator[0],Q_temp[3:1]};		      // right shift Multiplicand
				Accumulator 	= {Accumulator[3],Accumulator[3:1]};  // right shift Accumulator
				Count 			= Count - 1'b1;
		end                     

		else if((Q_temp[0] == 0 && Q_minus_one == 1) && (Count > 3'd0))   //The end of a string of ones ---> 01
			begin
				Accumulator 	= Accumulator + M_temp;
				Q_minus_one 	=  Q_temp[0];
				Q_temp 			= {Accumulator[0],Q_temp[3:1]};		      // right shift Multiplicand
				Accumulator 	= {Accumulator[3],Accumulator[3:1]};  // right shift Accumulator
				Count 			= Count - 1'b1;
			end
		
		else 
			begin
				Count = 3'b0;
				booth_dv <= 1;
			end
			Product = {Accumulator, Q_temp};
	
	end

endmodule