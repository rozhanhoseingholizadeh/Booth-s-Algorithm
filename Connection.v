`timescale 1ns / 1ps

module Connection
	#(parameter CLKS_PER_BIT = 5208)
	(
	input 	CLK,
	input 	wire 	RX_IN,
	output 	wire 	TX_OUT
	);


	// States
	parameter IDLE 		 = 3'b000;    //0   We send a message to get the numbers
	parameter REC_NUM1	 = 3'b001;    //1
	parameter ASK_NUM2 	 = 3'b010;    //2
	parameter REC_NUM2   = 3'b011;    //3
	parameter PROCESS 	 = 3'b100;    //4
	parameter GET_RESULT = 3'b101;    //5
	parameter TRANSMIT 	 = 3'b110;    //6
	reg [2:0] state 	 = IDLE;  	  //Define different states which what do we do in every step

	reg [3:0] COUNT = 0;   // Counter for diferent purpose


	// UART connections
	reg TX_DV = 0;           // Data validation for put on TX
	reg [7:0] TX_Byte = 0;
	wire TX_Active;            // If TX line is busy or not
	wire TX_Done;
	wire RX_DV;	
	wire [7:0] RX_OUT;


    // Booth connections
    reg [3:0] Multiplier = 0, Multiplicand = 0;   // Register for getting the numbers
    reg Booth_Start = 0;  // Register to understand the activation of "load" signal
    reg [7:0] Booth_OUT_REG = 0;
	wire [7:0] Booth_OUT;
	wire Booth_DV;


	// Messages
    reg [7:0] enterance [0:48];     // "Booth's algorithm: What is your first number? "
    reg [7:0] prompt [0:30];        // "What is your second number? "
    reg [7:0] message [0:17];       // "The result is: "
    reg [6:0] message_index = 0 ;   // counting the index of messages

    initial begin
		enterance[0] = "B";
		enterance[1] = "o";
		enterance[2] = "o";
		enterance[3] = "t";
		enterance[4] = "h";
		enterance[5] = "'";
		enterance[6] = "s";
		enterance[7] = " ";
		enterance[8] = "a";
		enterance[9] = "l";
		enterance[10] = "g";
		enterance[11] = "o";
		enterance[12] = "r";
		enterance[13] = "i";
		enterance[14] = "t";
		enterance[15] = "h";
		enterance[16] = "m";
		enterance[17] = ":";
		enterance[18] = " ";
		enterance[19] = "W";
		enterance[20] = "h";
		enterance[21] = "a";
		enterance[22] = "t";
		enterance[23] = " ";
		enterance[24] = "i";
		enterance[25] = "s";
		enterance[26] = " ";
		enterance[27] = "y";
		enterance[28] = "o";
		enterance[29] = "u";
		enterance[30] = "r";
		enterance[31] = " ";
		enterance[32] = "f";
		enterance[33] = "i";
		enterance[34] = "r";
		enterance[35] = "s";
		enterance[36] = "t";
		enterance[37] = " ";
		enterance[38] = "n";
		enterance[39] = "u";
		enterance[40] = "m";
		enterance[41] = "b";
		enterance[42] = "e";
		enterance[43] = "r";
		enterance[44] = "?";
		enterance[45] = " ";
		enterance[46] = "\r";
		enterance[47] = "\n";
		enterance[48] = " ";

		prompt[0] = "W";
		prompt[1] = "h";
		prompt[2] = "a";
		prompt[3] = "t";
		prompt[4] = " ";
		prompt[5] = "i";
		prompt[6] = "s";
		prompt[7] = " ";
		prompt[8] = "y";
		prompt[9] = "o";
		prompt[10] = "u";
		prompt[11] = "r";
		prompt[12] = " ";
		prompt[13] = "s";
		prompt[14] = "e";
		prompt[15] = "c";
		prompt[16] = "o";
		prompt[17] = "n";
		prompt[18] = "d";
		prompt[19] = " ";
		prompt[20] = "n";
		prompt[21] = "u";
		prompt[22] = "m";
		prompt[23] = "b";
		prompt[24] = "e";
		prompt[25] = "r";
		prompt[26] = "?";
		prompt[27] = " ";
		prompt[28] = "\r";
		prompt[29] = "\n";
		prompt[30] = " ";

		message[0] = "T";
		message[1] = "h";
		message[2] = "e";
		message[3] = " ";
		message[4] = "r";
		message[5] = "e";
		message[6] = "s";
		message[7] = "u";
		message[8] = "l";
		message[9] = "t";
		message[10] = " ";
		message[11] = "i";
		message[12] = "s";
		message[13] = ":";
		message[14] = " ";
		message[15] = "\r";
		message[16] = "\n";
		message[17] = " ";  
    end


	always @ (negedge CLK) begin
		TX_DV <= 1'b0;
		Booth_Start <= 1'b0;

		case(state)  
			
			
			IDLE : begin
				TX_DV <= 1'b0;
				 if(!TX_Active && message_index < 48)begin 
					  TX_Byte <= enterance[message_index];
					  TX_DV <= 1'b1;
					  message_index <= message_index + 1;
					  state <= IDLE;
				 end else if(message_index == 48) begin
							if(TX_Done && TX_Active)begin
								 message_index <= 0;
								 COUNT <= 1'b0;
								 state <= REC_NUM1;
							end
					  end
			end
			

			REC_NUM1 : begin  
			  if(RX_DV == 1'b1 && COUNT < 4 && RX_OUT >= 8'h30 && RX_OUT<= 8'h31)begin
					COUNT <= COUNT + 1;
					if(RX_OUT == 8'h30)begin
						Multiplier <= {Multiplier[2:0], 1'b0};
					end else if(RX_OUT == 8'h31)begin
						Multiplier <= {Multiplier[2:0], 1'b1};
					end
					         
					TX_DV <= 1'b1;
					TX_Byte <= RX_OUT;
			  end 
			  else if(!TX_Active && COUNT > 3)begin
					COUNT <= COUNT + 1;
					if(COUNT == 4)begin
						 TX_DV <= 1'b1;
						 TX_Byte <= "\r";
					end
					if(COUNT == 5)begin
						 TX_DV <= 1'b1;
						 TX_Byte <= "\n";
					end
					if(COUNT == 6)begin
						 COUNT <= 0;
						 TX_DV <= 1'b0;
						 state <= ASK_NUM2;  // important point at changing the state
					end
			  end
			end
			
					 
			ASK_NUM2 : begin
				 if(!TX_Active && message_index < 30)begin 
					  TX_Byte <= prompt[message_index];
					  TX_DV <= 1'b1;
					  message_index <= message_index + 1;
					  state <= ASK_NUM2;
				 end else if(message_index == 30) begin
							if(TX_Done && TX_Active)begin
								 message_index <= 0;
								 COUNT <= 1'b0;
								 state <= REC_NUM2;
							end
					  end
			end
			

			REC_NUM2 : begin  //1
			  if(RX_DV == 1'b1 && COUNT < 4 && RX_OUT >= 8'h30 && RX_OUT<= 8'h31)begin
					COUNT <= COUNT + 1;
					if(RX_OUT == 8'h30)begin
						Multiplicand <= {Multiplicand[2:0], 1'b0};
					end else if(RX_OUT == 8'h31)begin
						Multiplicand <= {Multiplicand[2:0], 1'b1};
					end
					TX_DV <= 1'b1;
					TX_Byte <= RX_OUT;
			  end 
			  else if(!TX_Active && COUNT > 3)begin
					COUNT <= COUNT + 1;
					if(COUNT == 4)begin
						 TX_DV <= 1'b1;
						 TX_Byte <= "\r";
					end
					if(COUNT == 5)begin
						 TX_DV <= 1'b1;
						 TX_Byte <= "\n";
					end
					if(COUNT == 6)begin
						 COUNT <= 0;
						 TX_DV <= 1'b0;
						 Booth_Start <= 1'b1;
						 state <= PROCESS;
					end
			  end
			end
			

			 PROCESS : begin
			 		if(Booth_DV == 1)begin
						Booth_OUT_REG <= Booth_OUT;
						COUNT <= 0;
						state <= GET_RESULT;
					end
			 end
			 


			 GET_RESULT : begin  
				COUNT <= 0;
                    if(!TX_Active && message_index < 17)begin 
					  TX_Byte <= message[message_index];
					  TX_DV <= 1'b1;
					  message_index <= message_index + 1;
					  state <= GET_RESULT;
				 end else if(message_index == 17) begin
							if(TX_Done && TX_Active)begin
								message_index <= 0;
								COUNT <= 1'b0;
								state <= TRANSMIT;
							end
					  end
			end


			TRANSMIT : begin
					if(!TX_Active && COUNT < 8)begin
						if(Booth_OUT_REG[7] == 1'b0)begin
							TX_Byte <= 8'h30;
						end else if(Booth_OUT_REG[7] == 1'b1)begin
							TX_Byte <= 8'h31;
						end
						Booth_OUT_REG <= {Booth_OUT_REG[6:0], 1'b0};
						COUNT <= COUNT + 1;
						TX_DV <= 1'b1;
				  end else if (!TX_Active && COUNT >= 8)begin
						COUNT <= COUNT + 1;
						if(COUNT == 8)begin
							TX_DV <= 1'b1;
							TX_Byte <= "\r";
						end
						if(COUNT == 9)begin
							TX_DV <= 1'b1;
							TX_Byte <= "\n";
						end
						if(COUNT == 10)begin
							COUNT <= 0;
							TX_DV <= 1'b0;
							state <= IDLE;
						end
				  end
			end

			default :
                state <= IDLE;  // When we have unused values, it is necessary to use the default mode
            
        endcase
    end


    UART_TX tx1 (
        .CLK(CLK),
        .TX_DV(TX_DV),
        .TX_Byte(TX_Byte),
		.TX_Active(TX_Active),
        .TX_OUT(TX_OUT),
        .TX_Done(TX_Done)
    );
	 
    UART_RX rx1 (
        .CLK(CLK),
        .RX_IN(RX_IN),
        .RX_DV(RX_DV),
        .RX_OUT(RX_OUT)
    );

    Booth b1 (
        .clk(CLK),
        .load(Booth_Start),
        .Multiplier(Multiplier),
        .Multiplicand(Multiplicand),
        .Product(Booth_OUT),
		.booth_dv(Booth_DV)
    );
     
endmodule

