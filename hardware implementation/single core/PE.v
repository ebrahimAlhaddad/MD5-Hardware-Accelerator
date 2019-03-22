module PE(Clk, Rst_n, message_in, i_data_valid, _B);
	input Rst_n;
	input Clk;
	input [7:0] message_in;
	output i_data_valid;
	output [31:0] _B;
	


	reg valid;
	
	//OUTPUT variables assigned
	assign i_data_valid = valid;


	wire [511:0] message;
	
	genvar i;
	generate
	for(i = 0; i < 512; i = i + 8)
	  begin
		assign message[i] = message_in[0];
		assign message[i+1] = message_in[1];
		assign message[i+2] = message_in[2];
		assign message[i+3] = message_in[3];
		assign message[i+4] = message_in[4];
		assign message[i+5] = message_in[5];
		assign message[i+6] = message_in[6];
		assign message[i+7] = message_in[7];
	  end
	endgenerate
	
	//DEBUG VARIABLES
	reg count = 0;

	//ROUND 1 START
	
	reg [31:0] A_temp, B_temp, C_temp, D_temp;
	
	assign _B = B_temp;

    reg [31:0] A = 32'h01234567;
    reg [31:0] B = 32'h89abcdef;
    reg [31:0] C = 32'hfedcba98;
    reg [31:0] D = 32'h76543210;

	wire [31:0] M0, M1, M2, M3, M4, M5, M6, M7, M8, M9, M10, M11, M12, M13, M14, M15;

    /*****************************************************************************/
    //AUXILLARY FUNCITIONS
	
	function [31:0] aux_f;
    input [31:0] _b, _c, _d; //changed it because was not sure how it would interact with variables outside funtion
      begin
        aux_f = (_b & _c) | ((~_b) & _d);
      end
    endfunction

    function [31:0] aux_g;
    input [31:0] _b, _c, _d;
      begin
        aux_g = (_b & _d) | (_c & (~_d));
      end
    endfunction
    
 	function [31:0] aux_i;
    input [31:0] _b, _c, _d; //changed it because was not sure how it would interact with variables outside funtion
      begin
        aux_i = _c ^ (_b | (~_d));
      end
    endfunction
    
    function [31:0] aux_h;
    input [31:0] _b, _c, _d; //changed it because was not sure how it would interact with variables outside funtion
      begin
        aux_h = _b ^ _c ^ _d;
      end
    endfunction
    
	/*****************************************************************************/
    //OPERATION FUNCITIONS
    
    function [31:0] r1_op;
    input [31:0] _a, _b, _c, _d;
    input [31:0] k;
    input [4:0] shift;
    input [31:0] i;
      begin
		r1_op = _b + (((_a + aux_f(_b, _c, _d) + k + i) << shift) | (((_a + aux_f(_b, _c, _d) + k + i) >> (32 - shift))));
      end
    endfunction
    
        function [31:0] r2_op;
    input [31:0] _a, _b, _c, _d;
    input [31:0] k;
    input [4:0] shift;
    input [31:0] i;
      begin
		r2_op = _b + (((_a + aux_g(_b, _c, _d) + k + i) << shift) | (((_a + aux_g(_b, _c, _d) + k + i) >> (32 - shift))));
      end
    endfunction
    
        function [31:0] r3_op;
    input [31:0] _a, _b, _c, _d;
    input [31:0] k;
    input [4:0] shift;
    input [31:0] i;
      begin
		r3_op = _b + (((_a + aux_h(_b, _c, _d) + k + i) << shift) | (((_a + aux_h(_b, _c, _d) + k + i) >> (32 - shift))));
      end
    endfunction
    
        function [31:0] r4_op;
    input [31:0] _a, _b, _c, _d;
    input [31:0] k;
    input [4:0] shift;
    input [31:0] i;
      begin
		r4_op = _b + (((_a + aux_i(_b, _c, _d) + k + i) << shift) | (((_a + aux_i(_b, _c, _d) + k + i) >> (32 - shift))));
      end
    endfunction
    
	
	always @(posedge Clk, posedge Rst_n)
	  begin
		if (!Rst_n)
		  begin
			valid = 0;
		  end
		else
		  begin			//FIFO getting full so halting sending too much data with count
			if (!count) //Need to find a way to make it so only when message changes, it changes, but also do timing based off clock
			  begin		//Need to improve logic: Do I want to go if valid is 0 or 1? What about if there is a new message?
				A_temp = r1_op(A, B, C, D, M0, 7, 32'hd76aa478);
				D_temp = r1_op(D, A_temp, B, C, M1, 12, 32'he8c7b756);
				C_temp = r1_op(C, D_temp, A_temp, B, M2, 17, 32'h242070db);
				B_temp = r1_op(B, C_temp, D_temp, A_temp, M3, 22, 32'hc1bdceee);
				A_temp = r1_op(A_temp, B_temp, C_temp, D_temp, M4, 7, 32'hf57c0faf);
				D_temp = r1_op(D_temp, A_temp, B_temp, C_temp, M5, 12, 32'h4787c62a);
				C_temp = r1_op(C_temp, D_temp, A_temp, B_temp, M6, 17, 32'ha8304613);
				B_temp = r1_op(B_temp, C_temp, D_temp, A_temp, M7, 22, 32'hfd469501);
				A_temp = r1_op(A_temp, B_temp, C_temp, D_temp, M8, 7, 32'h698098d8);
				D_temp = r1_op(D_temp, A_temp, B_temp, C_temp, M9, 12, 32'h8b44f7af);
				C_temp = r1_op(C_temp, D_temp, A_temp, B_temp, M10, 17, 32'hffff5bb1);
				B_temp = r1_op(B_temp, C_temp, D_temp, A_temp, M11, 22, 32'h895cd7be);
				A_temp = r1_op(A_temp, B_temp, C_temp, D_temp, M12, 7, 32'h6b901122);		
				D_temp = r1_op(D_temp, A_temp, B_temp, C_temp, M13, 12, 32'hfd987193);
				C_temp = r1_op(C_temp, D_temp, A_temp, B_temp, M14, 17, 32'ha679438e);
				B_temp = r1_op(B_temp, C_temp, D_temp, A_temp, M15, 22, 32'h49b40821);
				A_temp = r2_op(A_temp, B_temp, C_temp, D_temp, M1, 5, 32'hf61e2562);
				D_temp = r2_op(D_temp, A_temp, B_temp, C_temp, M6, 9, 32'hc040b340);
				C_temp = r2_op(C_temp, D_temp, A_temp, B_temp, M11, 14, 32'h265e5a51);
				B_temp = r2_op(B_temp, C_temp, D_temp, A_temp, M0, 20, 32'he9b6c7aa);
				A_temp = r2_op(A_temp, B_temp, C_temp, D_temp, M5, 5, 32'hd62f105d);
				D_temp = r2_op(D_temp, A_temp, B_temp, C_temp, M10, 9, 32'h2441453);
				C_temp = r2_op(C_temp, D_temp, A_temp, B_temp, M15, 14, 32'hd8a1e681);
				B_temp = r2_op(B_temp, C_temp, D_temp, A_temp, M4, 20, 32'he7d3fbc8);
				A_temp = r2_op(A_temp, B_temp, C_temp, D_temp, M9, 5, 32'h21e1cde6);
				D_temp = r2_op(D_temp, A_temp, B_temp, C_temp, M14, 9, 32'hc33707d6);
				C_temp = r2_op(C_temp, D_temp, A_temp, B_temp, M3, 14, 32'hf4d50d87);
				B_temp = r2_op(B_temp, C_temp, D_temp, A_temp, M8, 20, 32'h455a14ed);
				A_temp = r2_op(A_temp, B_temp, C_temp, D_temp, M13, 5, 32'ha9e3e905);	
				D_temp = r2_op(D_temp, A_temp, B_temp, C_temp, M2, 9, 32'hfcefa3f8);
				C_temp = r2_op(C_temp, D_temp, A_temp, B_temp, M7, 14, 32'h676f02d9);
				B_temp = r2_op(B_temp, C_temp, D_temp, A_temp, M12, 20, 32'h8d2a4c8a);
				A_temp = r3_op(A_temp, B_temp, C_temp, D_temp, M5, 4, 32'hfffa3942);
				D_temp = r3_op(D_temp, A_temp, B_temp, C_temp, M8, 11, 32'h8771f681);
				C_temp = r3_op(C_temp, D_temp, A_temp, B_temp, M11, 16, 32'h6d9d6122);
				B_temp = r3_op(B_temp, C_temp, D_temp, A_temp, M14, 23, 32'hfde5380c);
				A_temp = r3_op(A_temp, B_temp, C_temp, D_temp, M1,4, 32'ha4beea44);
				D_temp = r3_op(D_temp, A_temp, B_temp, C_temp, M4, 11, 32'h4bdecfa9);
				C_temp = r3_op(C_temp, D_temp, A_temp, B_temp, M7, 16, 32'hf6bb4b60);
				B_temp = r3_op(B_temp, C_temp, D_temp, A_temp, M10, 23, 32'hbebfbc70);
				A_temp = r3_op(A_temp, B_temp, C_temp, D_temp, M13, 4, 32'h289b7ec6);
				D_temp = r3_op(D_temp, A_temp, B_temp, C_temp, M0, 11, 32'heaa127fa);
				C_temp = r3_op(C_temp, D_temp, A_temp, B_temp, M3, 16, 32'hd4ef3085);
				B_temp = r3_op(B_temp, C_temp, D_temp, A_temp, M6, 23, 32'h4881d05);
				A_temp = r3_op(A_temp, B_temp, C_temp, D_temp, M9, 4, 32'hd9d4d039);	
				D_temp = r3_op(D_temp, A_temp, B_temp, C_temp, M12, 11, 32'he6db99e5);
				C_temp = r3_op(C_temp, D_temp, A_temp, B_temp, M15, 16, 32'h1fa27cf8);
				B_temp = r3_op(B_temp, C_temp, D_temp, A_temp, M2, 23, 32'hc4ac5665);
				A_temp = r4_op(A_temp, B_temp, C_temp, D_temp, M0, 6, 32'hf4292244);
				D_temp = r4_op(D_temp, A_temp, B_temp, C_temp, M7, 10, 32'h432aff97);
				C_temp = r4_op(C_temp, D_temp, A_temp, B_temp, M14, 15, 32'hab9423a7);
				B_temp = r4_op(B_temp, C_temp, D_temp, A_temp, M5, 21, 32'hfc93a039);
				A_temp = r4_op(A_temp, B_temp, C_temp, D_temp, M12, 6, 32'h655b59c3);
				D_temp = r4_op(D_temp, A_temp, B_temp, C_temp, M3, 10, 32'h8f0ccc92);
				C_temp = r4_op(C_temp, D_temp, A_temp, B_temp, M10, 15,32'hffeff47d);
				B_temp = r4_op(B_temp, C_temp, D_temp, A_temp, M1, 21, 32'h85845dd1);
				A_temp = r4_op(A_temp, B_temp, C_temp, D_temp, M8, 6, 32'h6fa87e4f);
				D_temp = r4_op(D_temp, A_temp, B_temp, C_temp, M15, 10, 32'hfe2ce6e0);
				C_temp = r4_op(C_temp, D_temp, A_temp, B_temp, M6, 15, 32'ha3014314);
				B_temp = r4_op(B_temp, C_temp, D_temp, A_temp, M13, 21, 32'h4e0811a1);
				A_temp = r4_op(A_temp, B_temp, C_temp, D_temp, M4, 6, 32'hf7537e82);	
				D_temp = r4_op(D_temp, A_temp, B_temp, C_temp, M11, 10, 32'hbd3af235);
				C_temp = r4_op(C_temp, D_temp, A_temp, B_temp, M2, 15, 32'h2ad7d2bb);
				B_temp = r4_op(B_temp, C_temp, D_temp, A_temp, M9, 21, 32'heb86d391);
				count = 1;
				valid = 1;
			  end
			else
				valid = 0;
		end

	end
	//ROUND 1 END
	
	assign M0 =	  message[31:0];
    assign M1 =   message[63:32];
    assign M2 =   message[95:64];
    assign M3 =   message[127:96];
    assign M4 =   message[159:128];
	assign M5 =   message[191:160];
    assign M6 =	  message[223:192];
    assign M7 =   message[255:224];
    assign M8 =   message[287:256];
    assign M9 =   message[319:288];
    assign M10 =   message[351:320];
	assign M11 =   message[383:352];
    assign M12 =   message[415:384];
    assign M13 =   message[447:416];
    assign M14 =   message[479:448];
    assign M15 =   message[511:480];

endmodule
