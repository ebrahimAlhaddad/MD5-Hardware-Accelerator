module PE_R1(Clk, Rst_n, message, i_data, i_data_valid, i_dest);

	input [511:0] message;
	input Rst_n;
	input Clk;
	output [1:0] i_dest;
	output [63:0] i_data;
	output i_data_valid ;

	reg flag;
	reg valid;
	reg [63:0] cur_data;
	
	//OUTPUT variables assigned
	assign i_data = cur_data;
	assign i_data_valid = valid;
	assign i_dest = 2'b01;

	//DEBUG VARIABLES
	reg count = 0;

	//ROUND 1 START
	reg [31:0] temp;
	reg [31:0] A_temp, B_temp, C_temp, D_temp;

    reg [31:0] A = 32'h01234567;
    reg [31:0] B = 32'h90abcdef;
    reg [31:0] C = 32'hfedcba98;
    reg [31:0] D = 32'h76543210;

	wire [31:0] M0, M1, M2, M3, M4, M5, M6, M7, M8, M9, M10, M11, M12, M13, M14, M15;

    
    function [31:0] aux_f;
    input [31:0] _b, _c, _d; //changed it because was not sure how it would interact with variables outside funtion
      begin
        aux_f = (_b & _c) | ((~_b) & _d);
      end
    endfunction

    function [31:0] r1_op;
    input [31:0] _a, _b, _c, _d;
    input [31:0] k;
    input [4:0] shift;
    input [31:0] i;
      begin
        r1_op = _b + ((_a + aux_f(_b, _c, _d) + k + i) << shift); //Need to figure out M and T 
      end
    endfunction
	
	always @(posedge Clk, posedge Rst_n)
	  begin
		if (!Rst_n)
		  begin
			flag <= 0;
			valid <= 0;
		  end
		else
		  begin			//FIFO getting full so halting sending too much data with count
			if (!flag && !count) //Need to find a way to make it so only when message changes, it changes, but also do timing based off clock
			  begin		//Need to improve logic: Do I want to go if valid is 0 or 1? What about if there is a new message?
				temp = r1_op(A, B, C, D, M0, 7, 32'hd76aa478);
				A_temp = temp;
				temp = r1_op(D, A_temp, B, C, M1, 12, 32'he8c7b756);
				D_temp = temp;
				temp = r1_op(C, D_temp, A_temp, B, M2, 17, 32'h242070db);
				C_temp = temp;
				temp = r1_op(B, C_temp, D_temp, A_temp, M3, 22, 32'hc1bdceee);
				B_temp = temp;
				temp = r1_op(A_temp, B_temp, C_temp, D_temp, M4, 7, 32'hf57c0faf);
				A_temp = temp;
				temp = r1_op(D_temp, A_temp, B_temp, C_temp, M5, 12, 32'h4787c62a);
				D_temp = temp;
				temp = r1_op(C_temp, D_temp, A_temp, B_temp, M6, 17, 32'ha8304613);
				C_temp = temp;
				temp = r1_op(B_temp, C_temp, D_temp, A_temp, M7, 22, 32'hfd469501);
				B_temp = temp;
				temp = r1_op(A_temp, B_temp, C_temp, D_temp, M8, 7, 32'h698098d8);
				A_temp = temp;
				temp = r1_op(D_temp, A_temp, B_temp, C_temp, M9, 12, 32'h8b44f7af);
				D_temp = temp;
				temp = r1_op(C_temp, D_temp, A_temp, B_temp, M10, 17, 32'hffff5bb1);
				C_temp = temp;
				temp = r1_op(B_temp, C_temp, D_temp, A_temp, M11, 22, 32'h895cd7be);
				B_temp = temp;
				temp = r1_op(A_temp, B_temp, C_temp, D_temp, M12, 7, 32'h6b901122);
				A_temp = temp;		
				temp = r1_op(D_temp, A_temp, B_temp, C_temp, M13, 12, 32'hfd987193);
				D_temp = temp;
				temp = r1_op(C_temp, D_temp, A_temp, B_temp, M14, 17, 32'ha679438e);
				C_temp = temp;
				temp = r1_op(B_temp, C_temp, D_temp, A_temp, M15, 22, 32'h49b40821);
				B_temp = temp;
				cur_data[63:32] <= A_temp;
				cur_data[31:0] <= B_temp;
				A <= A_temp;
				B <= B_temp; //A and B are to be able to debug value
				C <= C_temp;
				D <= D_temp;
				valid <= 1;
				flag <= 1;
			  end
			else if(flag && valid && !count)
		      begin
				cur_data[31:0] <= D;
				cur_data[63:32] <= C;
				flag <= 0;
				count <= 1;
			  end
			else
				valid <= 0;

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

/****************************************************************************************/

module PE_R2(Clk, message, Rst_n, flit_in_1, i_data, i_data_valid, i_dest);

	input [511:0] message;
	input [68:0] flit_in_1;
	input Rst_n;
	input Clk;
	output [63:0] i_data;
	output i_data_valid ;
	output [1:0] i_dest;

	assign i_dest = 2'b11;

	//DATA FLOW AND OUTPUT INTERFACE
	reg [1:0] flag;
	reg send_flag;
	reg valid;
	reg [63:0] cur_data;

	//ASSIGNING OUTPUT DATA
	assign i_data = cur_data;
	assign i_data_valid = valid;	
	
	//DEBUG VARIABLES
	reg count;
	
	
	//ROUND 2 START
	reg [31:0] A, B, C, D;
    reg [31:0] temp;
    reg [31:0] A_temp, B_temp, C_temp, D_temp;
	
	wire [31:0] M0, M1, M2, M3, M4, M5, M6, M7, M8, M9, M10, M11, M12, M13, M14, M15;
    
    function [31:0] aux_g;
    input [31:0] _b, _c, _d;
      begin
        aux_g = (_b & _d) | (_c & (~_d));
      end
    endfunction

    function [31:0] r1_op;
    input [31:0] _a, _b, _c, _d;
    input [31:0] k;
    input [4:0] shift;
    input [31:0] i;
      begin
        r1_op = _b + ((_a + aux_g(_b, _c, _d) + k + i) << shift); 
      end
    endfunction
	
    always @(posedge Clk, posedge Rst_n)
      begin
		if (!Rst_n)
		  begin
			flag <= 2'b00;
			cur_data <= 64'hXXXXXXXXXXXXXXXX;
			valid <= 1'b0;
			temp <= 32'hXXXXXXXX;
			count <= 0;
			send_flag <= 0;
		  end
		else
		  begin
			if(flag == 0 && flit_in_1[68] && !count)
			  begin
				A_temp <= flit_in_1[63:32];
				B_temp <= flit_in_1[31:0];
				flag <= 1;
			  end
			else if(flag == 1 && !valid && flit_in_1[68] && !count)
			  begin
			  	C_temp = flit_in_1[63:32];
				D_temp = flit_in_1[31:0];
				temp = r1_op(A_temp, B_temp, C_temp, D_temp, M1, 5, 32'hf61e2562);
				A_temp = temp;
				temp = r1_op(D_temp, A_temp, B_temp, C_temp, M6, 9, 32'hc040b340);
				D_temp = temp;
				temp = r1_op(C_temp, D_temp, A_temp, B_temp, M11, 14, 32'h265e5a51);
				C_temp = temp;
				temp = r1_op(B_temp, C_temp, D_temp, A_temp, M0, 20, 32'he9b6c7aa);
				B_temp = temp;
				temp = r1_op(A_temp, B_temp, C_temp, D_temp, M4, 7, 32'hd62f105d);
				A_temp = temp;
				temp = r1_op(D_temp, A_temp, B_temp, C_temp, M5, 12, 32'h2441453);
				D_temp = temp;
				temp = r1_op(C_temp, D_temp, A_temp, B_temp, M6, 17, 32'hd8a1e681);
				C_temp = temp;
				temp = r1_op(B_temp, C_temp, D_temp, A_temp, M7, 22, 32'he7d3fbc8);
				B_temp = temp;
				temp = r1_op(A_temp, B_temp, C_temp, D_temp, M8, 7, 32'h21e1cde6);
				A_temp = temp;
				temp = r1_op(D_temp, A_temp, B_temp, C_temp, M9, 12, 32'hc33707d6);
				D_temp = temp;
				temp = r1_op(C_temp, D_temp, A_temp, B_temp, M10, 17, 32'hf4d50d87);
				C_temp = temp;
				temp = r1_op(B_temp, C_temp, D_temp, A_temp, M11, 22, 32'h455a14ed);
				B_temp = temp;
				temp = r1_op(A_temp, B_temp, C_temp, D_temp, M12, 7, 32'ha9e3e905);
				A_temp = temp;		
				temp = r1_op(D_temp, A_temp, B_temp, C_temp, M13, 12, 32'hfcefa3f8);
				D_temp = temp;
				temp = r1_op(C_temp, D_temp, A_temp, B_temp, M14, 17, 32'h676f02d9);
				C_temp = temp;
				temp = r1_op(B_temp, C_temp, D_temp, A_temp, M15, 22, 32'h8d2a4c8a);
				B_temp = temp;
				cur_data[63:32] <= A_temp;	//First send is A and B
				cur_data[31:0] <= B_temp;
				A <= A_temp;
				B <= B_temp;// A and B are debug
				C <= C_temp;
				D <= D_temp;
				valid <= 1;
				flag <= 2;
			  end
			else if(flag == 2 && valid && !send_flag && !count)	//Second send is C and D
			  begin
				cur_data[63:32] <= C;
				cur_data[31:0] <= D;
				send_flag <= 1;
			  end
			else if(flag == 2 && valid && send_flag && !count)	//After second send, reset the flags and valid bit
			  begin
				cur_data[63:0] <= 64'hXXXXXXXXXXXXXXXX;
				send_flag <= 0;
				flag <= 0;
				valid <= 0;
				count <= 1;
			  end
		  end
      end
	  
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

/****************************************************************************************/

module PE_R3(Clk, message, Rst_n, flit_in_1, i_data, i_data_valid, i_dest);

	input [511:0] message;
	input [68:0] flit_in_1;
	input Rst_n;
	input Clk;
	output [63:0] i_data;
	output i_data_valid ;
	output [1:0] i_dest;

	assign i_dest = 2'b10;

	//DATA FLOW AND OUTPUT INTERFACE
	reg [1:0] flag;
	reg send_flag;
	reg valid;
	reg [63:0] cur_data;

	//ASSIGNING OUTPUT DATA
	assign i_data = cur_data;
	assign i_data_valid = valid;	
	
	//DEBUG VARIABLES
	reg count;
	
	//ROUND 3 START
	reg [31:0] A, B, C, D;
    reg [31:0] temp;
    reg [31:0] A_temp, B_temp, C_temp, D_temp;

	wire [31:0] M0, M1, M2, M3, M4, M5, M6, M7, M8, M9, M10, M11, M12, M13, M14, M15;

    function [31:0] aux_h;
    input [31:0] _b, _c, _d; //changed it because was not sure how it would interact with variables outside funtion
      begin
        aux_h = _b ^ _c ^ _d;
      end
    endfunction

    function [31:0] r1_op;
    input [31:0] _a, _b, _c, _d;
    input [31:0] k;
    input [4:0] shift;
    input [31:0] i;
      begin
        r1_op = _b + ((_a + aux_h(_b, _c, _d) + k + i) << shift); //Need to figure out M and T 
      end
    endfunction
    
	always @(posedge Clk, posedge Rst_n)
      begin
		if (!Rst_n)
		  begin
			flag <= 2'b00;
			cur_data <= 64'hXXXXXXXXXXXXXXXX;
			valid <= 1'b0;
			temp <= 32'hXXXXXXXX;
			count <= 0;
			send_flag <= 0;
		  end
		else
		  begin
			if(flag == 0 && flit_in_1[68] && !count)
			  begin
				A_temp <= flit_in_1[63:32];
				B_temp <= flit_in_1[31:0];
				flag <= 1;
			  end
			else if(flag == 1 && !valid && flit_in_1[68] && !count)
			  begin
			  	C_temp = flit_in_1[63:32];
				D_temp = flit_in_1[31:0];
				temp = r1_op(A_temp, B_temp, C_temp, D_temp, M5, 4, 32'hfffa3942);
				A_temp = temp;
				temp = r1_op(D_temp, A_temp, B_temp, C_temp, M8, 11, 32'h8771f681);
				D_temp = temp;
				temp = r1_op(C_temp, D_temp, A_temp, B_temp, M11, 16, 32'h6d9d6122);
				C_temp = temp;
				temp = r1_op(B_temp, C_temp, D_temp, A_temp, M14, 23, 32'hfde5380c);
				B_temp = temp;
				temp = r1_op(A_temp, B_temp, C_temp, D_temp, M1,4, 32'ha4beea44);
				A_temp = temp;
				temp = r1_op(D_temp, A_temp, B_temp, C_temp, M4, 11, 32'h4bdecfa9);
				D_temp = temp;
				temp = r1_op(C_temp, D_temp, A_temp, B_temp, M7, 16, 32'hf6bb4b60);
				C_temp = temp;
				temp = r1_op(B_temp, C_temp, D_temp, A_temp, M10, 23, 32'hbebfbc70);
				B_temp = temp;
				temp = r1_op(A_temp, B_temp, C_temp, D_temp, M13, 4, 32'h289b7ec6);
				A_temp = temp;
				temp = r1_op(D_temp, A_temp, B_temp, C_temp, M0, 11, 32'heaa127fa);
				D_temp = temp;
				temp = r1_op(C_temp, D_temp, A_temp, B_temp, M3, 16, 32'hd4ef3085);
				C_temp = temp;
				temp = r1_op(B_temp, C_temp, D_temp, A_temp, M6, 23, 32'h4881d05);
				B_temp = temp;
				temp = r1_op(A_temp, B_temp, C_temp, D_temp, M9, 4, 32'hd9d4d039);
				A_temp = temp;		
				temp = r1_op(D_temp, A_temp, B_temp, C_temp, M12, 11, 32'he6db99e5);
				D_temp = temp;
				temp = r1_op(C_temp, D_temp, A_temp, B_temp, M15, 16, 32'h1fa27cf8);
				C_temp = temp;
				temp = r1_op(B_temp, C_temp, D_temp, A_temp, M2, 23, 32'hc4ac5665);
				B_temp = temp;
				cur_data[63:32] <= A_temp;	//First send is A and B
				cur_data[31:0] <= B_temp;
				A <= A_temp;
				B <= B_temp;// A and B are debug
				C <= C_temp;
				D <= D_temp;
				valid <= 1;
				flag <= 2;
			  end
			else if(flag == 2 && valid && !send_flag && !count)	//Second send is C and D
			  begin
				cur_data[63:32] <= C;
				cur_data[31:0] <= D;
				send_flag <= 1;
			  end
			else if(flag == 2 && valid && send_flag && !count)	//After second send, reset the flags and valid bit
			  begin
				cur_data[63:0] <= 64'hXXXXXXXXXXXXXXXX;
				send_flag <= 0;
				flag <= 0;
				valid <= 0;
				count <= 1;
			  end
		  end
      end
	  
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
	    
/****************************************************************************************/

module PE_R4(Clk, message, Rst_n, flit_in_1, i_data, i_data_valid, i_dest);

	input [511:0] message;
	input [68:0] flit_in_1;
	input Rst_n;
	input Clk;
	output [63:0] i_data;
	output i_data_valid ;
	output [1:0] i_dest;

	assign i_dest = 2'b00;

	//DATA FLOW AND OUTPUT INTERFACE
	reg [1:0] flag;
	reg send_flag;
	reg valid;
	reg [63:0] cur_data;

	//ASSIGNING OUTPUT DATA
	assign i_data = cur_data;
	assign i_data_valid = valid;	
	
	//DEBUG VARIABLES
	reg count;
	
	//ROUND 3 START
	reg [31:0] A, B, C, D;
    reg [31:0] temp;
    reg [31:0] A_temp, B_temp, C_temp, D_temp;

	wire [31:0] M0, M1, M2, M3, M4, M5, M6, M7, M8, M9, M10, M11, M12, M13, M14, M15;
    
    function [31:0] aux_i;
    input [31:0] _b, _c, _d; //changed it because was not sure how it would interact with variables outside funtion
      begin
        aux_i = _c ^ (_b | (~_d));
      end
    endfunction

    function [31:0] r1_op;
    input [31:0] _a, _b, _c, _d;
    input [31:0] k;
    input [4:0] shift;
    input [31:0] i;
      begin
        r1_op = _b + ((_a + aux_i(_b, _c, _d) + k + i) << shift); //Need to figure out M and T 
      end
    endfunction
    
	always @(posedge Clk, posedge Rst_n)
      begin
		if (!Rst_n)
		  begin
			flag <= 2'b00;
			cur_data <= 64'hXXXXXXXXXXXXXXXX;
			valid <= 1'b0;
			temp <= 32'hXXXXXXXX;
			count <= 0;
			send_flag <= 0;
		  end
		else
		  begin
			if(flag == 0 && flit_in_1[68] && !count)
			  begin
				A_temp <= flit_in_1[63:32];
				B_temp <= flit_in_1[31:0];
				flag <= 1;
			  end
			else if(flag == 1 && !valid && flit_in_1[68] && !count)
			  begin
			  	C_temp = flit_in_1[63:32];
				D_temp = flit_in_1[31:0];
				temp = r1_op(A_temp, B_temp, C_temp, D_temp, M0, 6, 32'hf4292244);
				A_temp = temp;
				temp = r1_op(D_temp, A_temp, B_temp, C_temp, M7, 10, 32'h432aff97);
				D_temp = temp;
				temp = r1_op(C_temp, D_temp, A_temp, B_temp, M14, 15, 32'hab9423a7);
				C_temp = temp;
				temp = r1_op(B_temp, C_temp, D_temp, A_temp, M5, 21, 32'hfc93a039);
				B_temp = temp;
				temp = r1_op(A_temp, B_temp, C_temp, D_temp, M12, 6, 32'h655b59c3);
				A_temp = temp;
				temp = r1_op(D_temp, A_temp, B_temp, C_temp, M3, 10, 32'h8f0ccc92);
				D_temp = temp;
				temp = r1_op(C_temp, D_temp, A_temp, B_temp, M10, 15,32'hffeff47d);
				C_temp = temp;
				temp = r1_op(B_temp, C_temp, D_temp, A_temp, M1, 21, 32'h85845dd1);
				B_temp = temp;
				temp = r1_op(A_temp, B_temp, C_temp, D_temp, M8, 6, 32'h6fa87e4f);
				A_temp = temp;
				temp = r1_op(D_temp, A_temp, B_temp, C_temp, M15, 10, 32'hfe2ce6e0);
				D_temp = temp;
				temp = r1_op(C_temp, D_temp, A_temp, B_temp, M6, 15, 32'ha3014314);
				C_temp = temp;
				temp = r1_op(B_temp, C_temp, D_temp, A_temp, M13, 21, 32'h4e0811a1);
				B_temp = temp;
				temp = r1_op(A_temp, B_temp, C_temp, D_temp, M4, 6, 32'hf7537e82);
				A_temp = temp;		
				temp = r1_op(D_temp, A_temp, B_temp, C_temp, M11, 10, 32'hbd3af235);
				D_temp = temp;
				temp = r1_op(C_temp, D_temp, A_temp, B_temp, M2, 15, 32'h2ad7d2bb);
				C_temp = temp;
				temp = r1_op(B_temp, C_temp, D_temp, A_temp, M9, 21, 32'heb86d391);
				B_temp = temp;
				cur_data[63:32] <= A_temp;	//First send is A and B
				cur_data[31:0] <= B_temp;
				A <= A_temp;
				B <= B_temp;// A and B are debug
				C <= C_temp;
				D <= D_temp;
				valid <= 1;
				flag <= 2;
			  end
			else if(flag == 2 && valid && !send_flag && !count)	//Second send is C and D
			  begin
				cur_data[63:32] <= C;
				cur_data[31:0] <= D;
				send_flag <= 1;
			  end
			else if(flag == 2 && valid && send_flag && !count)	//After second send, reset the flags and valid bit
			  begin
				cur_data[63:0] <= 64'hXXXXXXXXXXXXXXXX;
				send_flag <= 0;
				flag <= 0;
				valid <= 0;
				count <= 1;
			  end
		  end
      end
	  
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
/****************************************************************************************/

