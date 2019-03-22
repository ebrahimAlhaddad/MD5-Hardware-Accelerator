module top(Clk, message, Rst_n);
input Rst_n;
input Clk;
input [511:0] message;

//wire [69:0] 

//PE wires
wire [63:0] i_data_R1, i_data_R2, i_data_R3, i_data_R4;
wire i_data_valid_R1, i_data_valid_R2, i_data_valid_R3, i_data_valid_R4;
wire [1:0]  i_dest_R1, i_dest_R2, i_dest_R3, i_dest_R4;

//INTERFACE wires
wire [68:0]  o_flit_R1, o_flit_R2, o_flit_R3, o_flit_R4;
wire o_flit_valid_R1, o_flit_valid_R2, o_flit_valid_R3, o_flit_valid_R4;
wire [1:0] a, b, c, d;
wire [1:0] aa, bb, cc, dd;

//NETWORK wires
wire [68:0] recv_ports_0_getFlit, recv_ports_1_getFlit, recv_ports_2_getFlit, recv_ports_3_getFlit;



//Instantiate Processing Element  
PE_R1 R1(.Clk(Clk), .Rst_n(Rst_n), .message(message), .i_data(i_data_R1), .i_data_valid(i_data_valid_R1), .i_dest(i_dest_R1));
PE_R2 R2(.Clk(Clk), .Rst_n(Rst_n), .message(message), .flit_in_1(recv_ports_1_getFlit), .i_data(i_data_R2), .i_data_valid(i_data_valid_R2), .i_dest(i_dest_R2));
PE_R3 R3(.Clk(Clk), .Rst_n(Rst_n), .message(message), .flit_in_1(recv_ports_3_getFlit), .i_data(i_data_R3), .i_data_valid(i_data_valid_R3), .i_dest(i_dest_R3));
PE_R4 R4(.Clk(Clk), .Rst_n(Rst_n), .message(message), .flit_in_1(recv_ports_2_getFlit), .i_data(i_data_R4), .i_data_valid(i_data_valid_R4), .i_dest(i_dest_R4));
//PE_fin fin(.Clk(Clk), .Rst_n(Rst_n), .flit_in_1(recv_ports_3_getFlit)
			   
//Instantiate Interface			   
interface R1_i (.Clk(Clk), .Rst_n(Rst_n), .i_data(i_data_R1), .i_data_valid(i_data_valid_R1), .i_dest(i_dest_R1), .o_flit(o_flit_R1),.o_flit_valid(o_flit_valid_R1));
interface R2_i (.Clk(Clk), .Rst_n(Rst_n), .i_data(i_data_R2), .i_data_valid(i_data_valid_R2), .i_dest(i_dest_R2), .o_flit(o_flit_R2),.o_flit_valid(o_flit_valid_R2));
interface R3_i (.Clk(Clk), .Rst_n(Rst_n), .i_data(i_data_R3), .i_data_valid(i_data_valid_R3), .i_dest(i_dest_R3), .o_flit(o_flit_R3),.o_flit_valid(o_flit_valid_R3));
interface R4_i (.Clk(Clk), .Rst_n(Rst_n), .i_data(i_data_R4), .i_data_valid(i_data_valid_R4), .i_dest(i_dest_R4), .o_flit(o_flit_R4),.o_flit_valid(o_flit_valid_R4));

//Instantiate NoC
mkNetwork dut
  (.CLK(Clk)
   ,.RST_N(Rst_n)

   ,.send_ports_0_putFlit_flit_in(o_flit_R1)   //Data to send from Processing Element to Port 0
   ,.EN_send_ports_0_putFlit(o_flit_valid_R1)      //Enable to send data from Processing Element      

   ,.EN_send_ports_0_getCredits(1'b1) // drain credits  Enables PE to recieve acknowledgement
   ,.send_ports_0_getCredits(aa)     //Send ack to ack

   ,.send_ports_1_putFlit_flit_in(o_flit_R2) //PORT1
   ,.EN_send_ports_1_putFlit(o_flit_valid_R2)

   ,.EN_send_ports_1_getCredits(1'b1) 
   ,.send_ports_1_getCredits(bb)

   ,.send_ports_2_putFlit_flit_in(o_flit_R4) //PORT2
   ,.EN_send_ports_2_putFlit(o_flit_valid_R4)

   ,.EN_send_ports_2_getCredits(1'b1)
   ,.send_ports_2_getCredits(cc)
   
   ,.send_ports_3_putFlit_flit_in(o_flit_R3) //PORT3
   ,.EN_send_ports_3_putFlit(o_flit_valid_R3)

   ,.EN_send_ports_3_getCredits(1'b1) 
   ,.send_ports_3_getCredits(dd)
    
   
   //receive ports

   ,.EN_recv_ports_0_getFlit(1'b1) 
   ,.recv_ports_0_getFlit(recv_ports_0_getFlit)

   ,.recv_ports_0_putCredits_cr_in(2'b0)
   ,.EN_recv_ports_0_putCredits(1'b1)

   ,.EN_recv_ports_1_getFlit(1'b1) // drain flits
   ,.recv_ports_1_getFlit(recv_ports_1_getFlit)

   ,.recv_ports_1_putCredits_cr_in(2'b0)
   ,.EN_recv_ports_1_putCredits(1'b1)

   ,.EN_recv_ports_2_getFlit(1'b1) 
   ,.recv_ports_2_getFlit(recv_ports_2_getFlit)

   ,.recv_ports_2_putCredits_cr_in(2'b0)
   ,.EN_recv_ports_2_putCredits(1'b1)

   ,.EN_recv_ports_3_getFlit(1'b1) // drain flits
   ,.recv_ports_3_getFlit(recv_ports_3_getFlit)

   ,.recv_ports_3_putCredits_cr_in(2'b0)
   ,.EN_recv_ports_3_putCredits(1'b1)

    ,.recv_ports_info_0_getRecvPortID(a)

	,.recv_ports_info_1_getRecvPortID(b)

	,.recv_ports_info_2_getRecvPortID(c)

	,.recv_ports_info_3_getRecvPortID(d)

   
   );


   
   
endmodule