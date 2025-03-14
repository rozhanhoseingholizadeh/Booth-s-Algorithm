`timescale 1ns / 1ps

// Clock rate = 50MHz
// baud UART = 9600
// CLKS_PER_BIT = (Frequency of CLK)/(Frequency of UART) = 50M / 9600 = 5208 

module UART_TX 
  #(parameter CLKS_PER_BIT = 5208)
  (
   input       CLK,
   input       TX_DV,
   input [7:0] TX_Byte, 
   output reg  TX_Active = 0,
   output reg  TX_OUT =0,
   output reg  TX_Done =0
   );
 
	parameter IDLE    = 2'b00;
	parameter START 	= 2'b01;
	parameter TRCV 	= 2'b10;
	parameter STOP  	= 2'b11;
  
	reg [1:0] 	STATE =0;
	reg [13:0] 	COUNT =0;
	reg [2:0] 	Bit_Index =0;
	reg [7:0] 	TX_Data_REG =0;


    always @(posedge CLK) begin
      TX_Done <= 1'b1;

      case (STATE)
 


		IDLE : begin
			TX_OUT <= 1'b1;
			COUNT <= 0;
			Bit_Index <= 0;
			TX_Done <= 1'b0;  // Reset TX_Done
			TX_Active <= 1'b0; // Ensure TX_Active is reset

			if (TX_DV == 1'b1 && TX_Active == 1'b0) begin  // Only start if TX_DV is high and we are not already active
				TX_Active <= 1'b1;
				TX_Data_REG <= TX_Byte;
				STATE <= START;
			end
			else begin
				STATE <= IDLE;
			end
		end

 
      START : begin
						TX_OUT <= 1'b0;
						if (COUNT < CLKS_PER_BIT-1) begin
							COUNT 	<= COUNT + 1;
							STATE    <= START;
						end
						else begin
							COUNT 	<= 0;
							STATE   <= TRCV;
						end
					end 
          
      TRCV : begin
						 TX_OUT <= TX_Data_REG[Bit_Index];
						 
						 if (COUNT < CLKS_PER_BIT-1) begin
							COUNT <= COUNT + 1;
							STATE     <= TRCV;
						 end
						 else begin
							COUNT <= 0;
							  if (Bit_Index < 7) begin
							  Bit_Index <= Bit_Index + 1;
							  STATE   	<= TRCV;
							end
							else begin
							  Bit_Index <= 0;
							  STATE   	<= STOP;
							end
						 end 
					end  
      
      
      STOP : begin
						 TX_OUT <= 1'b1;
						 if (COUNT < CLKS_PER_BIT-1) begin
							COUNT 	<= COUNT + 1;
							STATE    <= STOP;
						 end
						 else begin
							TX_Done  	<= 1'b1;
							COUNT 		<= 0;
							STATE    	<= IDLE;
							TX_Active	<= 1'b0;
						 end 
					end 
		  
      
      default :
						STATE <= IDLE;
      
    endcase
end

  
endmodule
