`timescale 1ns / 1ps

// Clock rate = 50MHz
// baud rate UART = 9600
// CLKS_PER_BIT = (Frequency of CLK)/(Frequency of UART) = 50M / 9600 = 5208

module UART_RX
	  #(parameter CLKS_PER_BIT = 5208)
	  (
		input        CLK,
		input        RX_IN,
		output       RX_DV,
		output reg   [7:0] RX_OUT
		);
		
	  parameter IDLE = 2'b00;
	  parameter START = 2'b01;
	  parameter RECV = 2'b10;
	  parameter STOP = 2'b11;
	  
	  reg [13:0]   Count = 0;
	  reg [2:0]    Bit_Index = 0;
	  reg          RX_DV = 0;
	  reg [1:0]		STATE = 0;
  

always @(posedge CLK) begin
	case (STATE)
		IDLE : begin
			 RX_DV      <= 0;
			 Count 		<= 0;
			 Bit_Index  <= 0;
			 
			 if (RX_IN == 1'b0)
				STATE <= START;
			 else
				STATE <= IDLE;
		  end

		START : begin
			 if (Count == (CLKS_PER_BIT-1)/2) begin
				if (RX_IN == 1'b0) begin
				  Count	<= 0;
				  STATE  <= RECV;
				end
				else
				  STATE <= IDLE;
			 end
			 else begin
				Count 	<= Count + 1;
				STATE    <= START;
			 end
		  end


		RECV :
		  begin
			 if (Count < CLKS_PER_BIT-1) begin
				Count 	<= Count + 1;
				STATE    <= RECV;
			 end
			 else begin
				Count          	<= 0;
				RX_OUT[Bit_Index] <= RX_IN;
					
				if (Bit_Index < 7) begin
				  Bit_Index <= Bit_Index + 1;
				  STATE   	<= RECV;
				end
				else begin
				  Bit_Index <= 0;
				  STATE   <= STOP;
				end
			 end
		  end



		STOP : begin
			 if (Count < CLKS_PER_BIT-1) begin
				Count <= Count + 1;
				STATE     <= STOP;
			 end
			 else begin
				 RX_DV   <= 1'b1;
				 Count 	<= 0;
				 STATE   <= IDLE;
			 end
		  end 


		default : STATE <= IDLE;

	endcase
end    

  
endmodule

