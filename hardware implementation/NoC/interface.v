module interface(Clk, Rst_n, i_data, i_data_valid, i_dest, o_flit, o_flit_valid);
input Clk, Rst_n;
input [63:0] i_data;
input i_data_valid;
input [1:0] i_dest;	//we dont need [4:0]i_src bc we not worried about source
output [68:0] o_flit ;
output reg o_flit_valid;

reg [68:0] o_data;
reg [68:0] finish;

assign o_flit = finish;
/*
o_data structure
bit 71 is for valid bit
bit 70 is for is_tails
bits 69-66 is for destination
bit 65 is for VC
bits 64-0 is for data
*/

always @ (posedge Clk, posedge Rst_n)
  begin
	if(!Rst_n)
	  begin
		o_data = 68'hXXXXXXXXXXXXXXXXXX;
		o_flit_valid = 0;
	  end
	else
	  begin
		if(i_data_valid)
		  begin
			o_data[63:0] = i_data;
			o_data[64] = 1;
			o_data[66:65] = i_dest[1:0];
			o_data[67] = 1;
			o_data[68] = 1;
			finish = o_data;
			o_flit_valid = 1;
		  end
		else
			o_flit_valid = 0;
	  end
end
endmodule