
`ifndef XST_SYNTH

`timescale 1ns / 1ps



module CONNECT_testbench_sample();
  parameter HalfClkPeriod = 5;
  localparam ClkPeriod = 2*HalfClkPeriod;

  // non-VC routers still reeserve 1 dummy bit for VC.
  //localparam vc_bits = (`NUM_VCS > 1) ? $clog2(`NUM_VCS) : 1;
  //localparam dest_bits = $clog2(`NUM_USER_RECV_PORTS);
  //localparam flit_port_width = 2 /*valid and tail bits*/+ `FLIT_DATA_WIDTH + dest_bits + vc_bits;
  //localparam credit_port_width = 1 + vc_bits; // 1 valid bit
  localparam test_cycles = 20;

  reg Clk;
  reg Rst_n;
  reg counter = 0;
  reg [511:0] message;

  // input regs
  //reg send_flit [0:`NUM_USER_SEND_PORTS-1]; // enable sending flits
  //reg [flit_port_width-1:0] flit_in [0:`NUM_USER_SEND_PORTS-1]; // send port inputs

  //reg send_credit [0:`NUM_USER_RECV_PORTS-1]; // enable sending credits
  //reg [credit_port_width-1:0] credit_in [0:`NUM_USER_RECV_PORTS-1]; //recv port credits

  // output wires
  //wire [credit_port_width-1:0] credit_out [0:`NUM_USER_SEND_PORTS-1];
  //wire [flit_port_width-1:0] flit_out [0:`NUM_USER_RECV_PORTS-1];

  reg [31:0] cycle;
  //integer i;

  // packet fields
  //reg is_valid;
  //reg is_tail;
  //reg [dest_bits-1:0] dest;
  //reg [vc_bits-1:0]   vc;
  //reg [`FLIT_DATA_WIDTH-1:0] data;

  // Generate Clock
  initial Clk = 0;
  always #(HalfClkPeriod) Clk = ~Clk;

  // Run simulation 
  initial begin 
    cycle = 0;
	message = 512'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
    $display("---- Performing Reset ----");
    Rst_n = 0; // perform reset (active low) 
    #(5*ClkPeriod+HalfClkPeriod); 
    Rst_n = 1; 
    #(HalfClkPeriod);
  end


  // Monitor arriving flits
  always @ (posedge Clk) begin
    cycle <= cycle + 1;
    if(counter == 1) begin // valid flit
        $display("@%3d: End time of process", cycle);
		//$finish;
      end
    end


  top hello(.Clk(Clk), .Rst_n(Rst_n), .message(message));
  // Add your code to handle flow control here (sending receiving credits)

endmodule

`endif
