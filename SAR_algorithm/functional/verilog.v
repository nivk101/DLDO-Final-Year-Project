module SAR_algorithm ( 
	input clk,
	input hl,
    input [7:0] vref,  
    input [7:0] vin,   
	//output reg comp,
	output reg gtz = 1'b1,
	output reg [3:0] current_bit = 7,
	//output reg [7:0] abs,
	output wire [7:0] diffabs,
    output reg [7:0] digital_output = 8'b01111111
);
 //initial value of output
    //reg [3:0] current_bit = 7; // Current bit being approximated
	//reg gtz = 1'b1;
	wire [7:0] diff = vin - vref;
	assign diffabs = (diff[7] == 1'b1) ? -diff : diff; //this is the absolute value of diff
	reg starthold = 1; //used to delay the 5th and 6th bits by one clock cycle so that the SAR works as intended 


always @(posedge clk) begin
	//abs = (diff[7] == 1'b1) ? -diff : diff;
	//comp <= 0;
	if (gtz == 1) begin : SAR_algorithm
		// SAR algorithm
		if (starthold == 0) starthold <= 1;
		
		if (diffabs <= 8'd1 && starthold == 1) begin
			gtz = 0;
			//disable SAR_algorithm;
		end

		 else if (vin > vref && gtz == 1 && starthold == 1) begin
			digital_output[current_bit] <= 1; 
			// if output voltage greater than reference, set current bit to low (1 is low for PMOS)
		end
		if (current_bit > 0 && gtz == 1 && starthold == 1) begin 
			current_bit <= current_bit - 1; 
			// Move to next bit
			digital_output[current_bit - 1] <= 0; 
			if (current_bit - 1 == 6 || current_bit - 1 == 5) starthold <= 0;
			// Set next bit to high (0 is high for PMOS)
		end if (current_bit == 0 && gtz == 1 && starthold == 1) begin
			gtz <= 0; 
			// if the current bit is already 0, set the gtz register to 0
		end    
	end
	if (gtz == 0 && diffabs >= 8'd2) begin
		//comp <= 1;
		if (diffabs >= 8'd7) begin 
			// if the output voltage varies greatly from the reference voltage, restart the SAR algorithm
			gtz <= 1;
			current_bit <= 7;
			digital_output <= 8'b01111111;
		end else if (diffabs >= 8'd2) begin 
			// if the output voltage is slightly different from the reference, adjust by counting up or down 
			if (hl == 1) 
				digital_output <= digital_output + 1;
			// hl is a comparator with the output voltage to determine whether to count up or down
			else 
				digital_output <= digital_output - 1;
		end
	end

end

endmodule
