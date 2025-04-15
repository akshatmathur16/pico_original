// This is free and unencumbered software released into the public domain.
//
// Anyone is free to copy, modify, publish, use, compile, sell, or
// distribute this software, either in source code form or as a compiled
// binary, for any purpose, commercial or non-commercial, and by any
// means.

`timescale 1 ns / 1 ps

//AM `ifndef VERILATOR
module testbench #(
	parameter AXI_TEST = 1,
	parameter VERBOSE = 1
);
	reg clk = 1;
	reg resetn = 0;
	wire trap;

  //AM pulled these signals to top to test
  reg [48:0] in_err; //input error signal by rc error signal for rrns
	reg [11:0] in_err1; //AM input error signal for 
	reg [37:0] in_err2;
	reg [37:0] in_err3; //AM input error signal for memory read write

  wire trace_valid;
	wire [35:0] trace_data;
	integer trace_file;


  picorv32_wrapper #(
		.AXI_TEST (AXI_TEST),
		.VERBOSE  (VERBOSE)
	) top (
		.clk(clk),
		.resetn(resetn),
		.trap(trap),
		.trace_valid(trace_valid),
		.trace_data(trace_data),
    .in_err(in_err), //input error signal by rc error signal for rrns
    .in_err1(in_err1), //AM input error signal for 
    .in_err2(in_err2), 
    .in_err3(in_err3) 

	);

	always #5 clk = ~clk;

	initial begin
      repeat (100) @(posedge clk);
      resetn <= 1;

      in_err = 'b0;
      in_err1 = 'h00000001;
      in_err2 = 'b0;
      in_err3 = 'h00000101;
      $display($time,"AM debug in_err1 = %h", in_err1);
      $display($time,"AM debug in_err3 = %h", in_err3);

       repeat (1000) @(posedge clk);

      in_err = 'b0;
      in_err1 = 'h00000000;
      in_err2 = 'b0;
      in_err3 = 'h00000000;
      $display($time,"AM debug in_err1 = %h", in_err1);
      $display($time,"AM debug in_err3 = %h", in_err3);

      repeat (5000) @(posedge clk);

      in_err = 'b0;
      in_err1 = 'h00000010;
      in_err2 = 'b0;
      in_err3 = 'h00010001;
      $display($time,"AM debug in_err1 = %h", in_err1);
      $display($time,"AM debug in_err3 = %h", in_err3);

      repeat (5000) @(posedge clk);

      in_err = 'b0;
      in_err1 = 'h00000000;
      in_err2 = 'b0;
      in_err3 = 'h00000011;
      $display($time,"AM debug in_err1 = %h", in_err1);
      $display($time,"AM debug in_err3 = %h", in_err3);


    
	end

	initial begin
		if ($test$plusargs("vcd")) begin
			$dumpfile("testbench.vcd");
			$dumpvars(0, testbench);
		end
		repeat (50000) @(posedge clk);
		//#10000000;
		$display("TIMEOUT");
		$stop;
	end

  


	initial begin
		if ($test$plusargs("trace")) begin
			trace_file = $fopen("testbench.trace", "w");
			repeat (10) @(posedge clk);
			while (!trap) begin
				@(posedge clk);
				if (trace_valid)
					$fwrite(trace_file, "%x\n", trace_data);
			end
			$fclose(trace_file);
			$display("Finished writing testbench.trace.");
		end
	end


endmodule
//AM `endif

module picorv32_wrapper #(
	parameter AXI_TEST = 0,
	parameter VERBOSE = 0
) (
	input clk,
	input resetn,
	
  //AM
  input  ser_rx,
  output ser_tx,
	
  output trap,
	output trace_valid,
	output [35:0] trace_data,
 
  //AM pulling err signals to top top test
  input [48:0] in_err, //input error signal by rc error signal for rrns
	input [11:0] in_err1, //AM input error signal for 
	input [37:0] in_err2, 
	input [37:0] in_err3 

);
	wire tests_passed;
	reg [31:0] irq = 0;

	reg [15:0] count_cycle = 0;
	always @(posedge clk) count_cycle <= resetn ? count_cycle + 1 : 0;

	always @* begin
		irq = 0;
		irq[4] = &count_cycle[12:0];
		irq[5] = &count_cycle[15:0];
	end

	wire        mem_axi_awvalid;
	wire        mem_axi_awready;
	wire [31:0] mem_axi_awaddr;
	wire [ 2:0] mem_axi_awprot;

	wire        mem_axi_wvalid;
	wire        mem_axi_wready;
	wire [31:0] mem_axi_wdata;
	wire [ 3:0] mem_axi_wstrb;

	wire        mem_axi_bvalid;
	wire        mem_axi_bready;

	wire        mem_axi_arvalid;
	wire        mem_axi_arready;
	wire [31:0] mem_axi_araddr;
	wire [ 2:0] mem_axi_arprot;

	wire        mem_axi_rvalid;
	wire        mem_axi_rready;
	wire [31:0] mem_axi_rdata;

	axi4_memory #(
		.AXI_TEST (AXI_TEST),
		.VERBOSE  (VERBOSE)
	) mem (
		.clk             (clk             ),
		.mem_axi_awvalid (mem_axi_awvalid ),
		.mem_axi_awready (mem_axi_awready ),
		.mem_axi_awaddr  (mem_axi_awaddr  ),
		.mem_axi_awprot  (mem_axi_awprot  ),

		.mem_axi_wvalid  (mem_axi_wvalid  ),
		.mem_axi_wready  (mem_axi_wready  ),
		.mem_axi_wdata   (mem_axi_wdata   ),
		.mem_axi_wstrb   (mem_axi_wstrb   ),

		.mem_axi_bvalid  (mem_axi_bvalid  ),
		.mem_axi_bready  (mem_axi_bready  ),

		.mem_axi_arvalid (mem_axi_arvalid ),
		.mem_axi_arready (mem_axi_arready ),
		.mem_axi_araddr  (mem_axi_araddr  ),
		.mem_axi_arprot  (mem_axi_arprot  ),

		.mem_axi_rvalid  (mem_axi_rvalid  ),
		.mem_axi_rready  (mem_axi_rready  ),
		//AM .mem_axi_rdata   (mem_axi_rdata   ),
		.mem_axi_rdata_decoded (mem_axi_rdata   ),

		.tests_passed    (tests_passed    ),
    .in_err1         (in_err1),
    .in_err3         (in_err3)
	);

`ifdef RISCV_FORMAL
	wire        rvfi_valid;
	wire [63:0] rvfi_order;
	wire [31:0] rvfi_insn;
	wire        rvfi_trap;
	wire        rvfi_halt;
	wire        rvfi_intr;
	wire [4:0]  rvfi_rs1_addr;
	wire [4:0]  rvfi_rs2_addr;
	wire [31:0] rvfi_rs1_rdata;
	wire [31:0] rvfi_rs2_rdata;
	wire [4:0]  rvfi_rd_addr;
	wire [31:0] rvfi_rd_wdata;
	wire [31:0] rvfi_pc_rdata;
	wire [31:0] rvfi_pc_wdata;
	wire [31:0] rvfi_mem_addr;
	wire [3:0]  rvfi_mem_rmask;
	wire [3:0]  rvfi_mem_wmask;
	wire [31:0] rvfi_mem_rdata;
	wire [31:0] rvfi_mem_wdata;
`endif



	wire        simpleuart_reg_dat_wait;
	wire [31:0] simpleuart_reg_dat_do;
  wire mem_valid;
	wire        simpleuart_reg_div_sel = mem_valid && (mem_axi_awaddr == 32'h 0200_0004 || mem_axi_araddr == 32'h 0200_0004);
	wire [31:0] simpleuart_reg_div_do;
	wire [3:0] mem_wstrb;
	wire        simpleuart_reg_dat_sel = mem_valid && (mem_axi_awaddr == 32'h 0200_0008);



  simpleuart simpleuart (
      .clk         (clk         ),
      .resetn      (resetn      ),

      .ser_tx      (ser_tx      ),
      .ser_rx      (ser_rx      ),

      .reg_div_we  (simpleuart_reg_div_sel ? mem_axi_wstrb : 4'b0000),
      .reg_div_di  (mem_axi_wdata),
      .reg_div_do  (simpleuart_reg_div_do),

      .reg_dat_we  (simpleuart_reg_dat_sel ? mem_axi_wstrb[0] : 1'b0),
      .reg_dat_re  (simpleuart_reg_dat_sel && !mem_axi_wstrb),
      .reg_dat_di  (mem_axi_wdata),
      .reg_dat_do  (simpleuart_reg_dat_do),
      .reg_dat_wait(simpleuart_reg_dat_wait)
  );








	picorv32_axi #(
`ifndef SYNTH_TEST
`ifdef SP_TEST
		.ENABLE_REGS_DUALPORT(0),
`endif
`ifdef COMPRESSED_ISA
		.COMPRESSED_ISA(1),
`endif
		.ENABLE_MUL(1),
		.ENABLE_DIV(1),
		.ENABLE_IRQ(1),
		.ENABLE_TRACE(1)
`endif
	) uut (
		.clk            (clk            ),
		.resetn         (resetn         ),
		.trap           (trap           ),
		.mem_axi_awvalid(mem_axi_awvalid),
		.mem_axi_awready(mem_axi_awready),
		.mem_axi_awaddr (mem_axi_awaddr ),
		.mem_axi_awprot (mem_axi_awprot ),
		.mem_axi_wvalid (mem_axi_wvalid ),
		.mem_axi_wready (mem_axi_wready ),
		.mem_axi_wdata  (mem_axi_wdata  ),
		.mem_axi_wstrb  (mem_axi_wstrb  ),
		.mem_axi_bvalid (mem_axi_bvalid ),
		.mem_axi_bready (mem_axi_bready ),
		.mem_axi_arvalid(mem_axi_arvalid),
		.mem_axi_arready(mem_axi_arready),
		.mem_axi_araddr (mem_axi_araddr ),
		.mem_axi_arprot (mem_axi_arprot ),
		.mem_axi_rvalid (mem_axi_rvalid ),
		.mem_axi_rready (mem_axi_rready ),
		.mem_axi_rdata  (mem_axi_rdata  ),
		.irq            (irq            ),
`ifdef RISCV_FORMAL
		.rvfi_valid     (rvfi_valid     ),
		.rvfi_order     (rvfi_order     ),
		.rvfi_insn      (rvfi_insn      ),
		.rvfi_trap      (rvfi_trap      ),
		.rvfi_halt      (rvfi_halt      ),
		.rvfi_intr      (rvfi_intr      ),
		.rvfi_rs1_addr  (rvfi_rs1_addr  ),
		.rvfi_rs2_addr  (rvfi_rs2_addr  ),
		.rvfi_rs1_rdata (rvfi_rs1_rdata ),
		.rvfi_rs2_rdata (rvfi_rs2_rdata ),
		.rvfi_rd_addr   (rvfi_rd_addr   ),
		.rvfi_rd_wdata  (rvfi_rd_wdata  ),
		.rvfi_pc_rdata  (rvfi_pc_rdata  ),
		.rvfi_pc_wdata  (rvfi_pc_wdata  ),
		.rvfi_mem_addr  (rvfi_mem_addr  ),
		.rvfi_mem_rmask (rvfi_mem_rmask ),
		.rvfi_mem_wmask (rvfi_mem_wmask ),
		.rvfi_mem_rdata (rvfi_mem_rdata ),
		.rvfi_mem_wdata (rvfi_mem_wdata ),
`endif
		.trace_valid    (trace_valid    ),
		.trace_data     (trace_data     ),
    
    .in_err(in_err), //input error signal by rc error signal for rrns
    .in_err1(in_err1), //AM input error signal for 
    .in_err2(in_err2),
    .mem_wstrb(mem_wstrb),
    .mem_valid(mem_valid)

	);

`ifdef RISCV_FORMAL
	picorv32_rvfimon rvfi_monitor (
		.clock          (clk           ),
		.reset          (!resetn       ),
		.rvfi_valid     (rvfi_valid    ),
		.rvfi_order     (rvfi_order    ),
		.rvfi_insn      (rvfi_insn     ),
		.rvfi_trap      (rvfi_trap     ),
		.rvfi_halt      (rvfi_halt     ),
		.rvfi_intr      (rvfi_intr     ),
		.rvfi_rs1_addr  (rvfi_rs1_addr ),
		.rvfi_rs2_addr  (rvfi_rs2_addr ),
		.rvfi_rs1_rdata (rvfi_rs1_rdata),
		.rvfi_rs2_rdata (rvfi_rs2_rdata),
		.rvfi_rd_addr   (rvfi_rd_addr  ),
		.rvfi_rd_wdata  (rvfi_rd_wdata ),
		.rvfi_pc_rdata  (rvfi_pc_rdata ),
		.rvfi_pc_wdata  (rvfi_pc_wdata ),
		.rvfi_mem_addr  (rvfi_mem_addr ),
		.rvfi_mem_rmask (rvfi_mem_rmask),
		.rvfi_mem_wmask (rvfi_mem_wmask),
		.rvfi_mem_rdata (rvfi_mem_rdata),
		.rvfi_mem_wdata (rvfi_mem_wdata)
	);
`endif

	//AM reg [1023:0] firmware_file;
	//AM initial begin
	//AM 	if (!$value$plusargs("firmware=%s", firmware_file))
	//AM 		firmware_file = "firmware/firmware.hex";
	//AM 	$readmemh(firmware_file, mem.memory);
	//AM end

	integer cycle_counter;
	always @(posedge clk) begin
		cycle_counter <= resetn ? cycle_counter + 1 : 0;
		if (resetn && trap) begin
`ifndef VERILATOR
			repeat (10) @(posedge clk);
`endif
			$display("TRAP after %1d clock cycles", cycle_counter);
			if (tests_passed) begin
				$display("ALL TESTS PASSED.");
				$finish;
			end else begin
				$display("ERROR!");
				if ($test$plusargs("noerror"))
					$finish;
				$stop;
			end
		end
	end
endmodule





module axi4_memory #(
	parameter AXI_TEST = 0,
	parameter VERBOSE = 0
) (
	/* verilator lint_off MULTIDRIVEN */

	input             clk,
	input             mem_axi_awvalid,
	output reg        mem_axi_awready,
	input      [31:0] mem_axi_awaddr,
	input      [ 2:0] mem_axi_awprot,

	input             mem_axi_wvalid,
	output reg        mem_axi_wready,
	input      [31:0] mem_axi_wdata, //AM write data to memory
	input      [ 3:0] mem_axi_wstrb,

	output reg        mem_axi_bvalid,
	input             mem_axi_bready,

	input             mem_axi_arvalid,
	output reg        mem_axi_arready,
	input      [31:0] mem_axi_araddr,
	input      [ 2:0] mem_axi_arprot,

	output reg        mem_axi_rvalid,
	input             mem_axi_rready,
	//AM output reg [31:0] mem_axi_rdata, // AM read data from memory
	output [31:0] mem_axi_rdata_decoded, // AM read data from memory

	output reg        tests_passed,
  input   [11:0]    in_err1,
  input   [37:0]    in_err3
);
	//AM reg [31:0]   memory [0:128*1024/4-1] /* verilator public */;

  //AM (* ram_style = "block" *)	reg [31:0]   memory [0:15000] /* verilator public */;
  (* ram_style = "block" *)	reg [31:0]   memory [0:150] /* verilator public */;
	
  reg verbose;
	initial verbose = $test$plusargs("verbose") || VERBOSE;

	reg axi_test;
	initial axi_test = $test$plusargs("axi_test") || AXI_TEST;

  //AM
  reg negedge_arready;
  reg posedge_arready;

  //AM
  reg negedge_awready;
  reg posedge_awready;

	initial begin
		mem_axi_awready = 0;
    negedge_awready = 0;
    posedge_awready = 0;
		mem_axi_wready = 0;
		mem_axi_bvalid = 0;
		mem_axi_arready = 0;
    negedge_arready = 0;
    posedge_arready = 0;
		mem_axi_rvalid = 0;
		tests_passed = 0;
	end

	reg [1023:0] firmware_file;
	initial begin
			firmware_file = "firmware/firmware.hex";
      $readmemh(firmware_file,memory);
	end



	reg [63:0] xorshift64_state = 64'd88172645463325252;

	task xorshift64_next;
		begin
			// see page 4 of Marsaglia, George (July 2003). "Xorshift RNGs". Journal of Statistical Software 8 (14).
			xorshift64_state = xorshift64_state ^ (xorshift64_state << 13);
			xorshift64_state = xorshift64_state ^ (xorshift64_state >>  7);
			xorshift64_state = xorshift64_state ^ (xorshift64_state << 17);
		end
	endtask

	reg [2:0] fast_axi_transaction = ~0;
	reg [4:0] async_axi_transaction = ~0;
	reg [4:0] delay_axi_transaction = 0;

	always @(posedge clk) begin
		if (axi_test) begin
				xorshift64_next;
				{fast_axi_transaction, async_axi_transaction, delay_axi_transaction} <= xorshift64_state;
		end
	end


	wire [37:0] mem_axi_wdata_encoded; //AM encoded data from hammingcode to be written in memory 

  hammingcodegenerator1 write_port_hamming (mem_axi_wdata, mem_axi_wdata_encoded);


 

	reg latched_raddr_en = 0;
	reg latched_waddr_en = 0;
	reg latched_wdata_en = 0;

	reg fast_raddr = 0;
	reg fast_waddr = 0;
	reg fast_wdata = 0;

	reg [31:0] latched_raddr;
	reg [31:0] latched_waddr;
	reg [31:0] latched_wdata;
	wire [37:0] latched_wdata_encoded;
	wire [31:0] latched_wdata_decoded;
	reg [ 3:0] latched_wstrb;
	reg        latched_rinsn;

  //AM Signals for Read port Hamming code

  wire [37:0] mem_axi_rdata_encoded;
	wire [37:0] mem_axi_rdata_encoded_error;
	reg [31:0] mem_axi_rdata; 


	task handle_axi_arvalid; begin
		mem_axi_arready <= 1;
		latched_raddr = mem_axi_araddr;
		latched_rinsn = mem_axi_arprot[2];
		latched_raddr_en = 1;
		fast_raddr <= 1;
	end endtask

  task handle_axi_awvalid;
      begin
          $display($time,"AM debug inside handle_axi_awvalid");
          mem_axi_awready <= 1;
          latched_waddr = mem_axi_awaddr;
          latched_waddr_en = 1;
          fast_waddr <= 1;
      end
  endtask

	task handle_axi_wvalid; begin
		mem_axi_wready <= 1;
    latched_wdata = latched_wdata_decoded;
		latched_wstrb = mem_axi_wstrb;
		latched_wdata_en = 1;
		fast_wdata <= 1;
	end endtask

	task handle_axi_rvalid; begin
		if (verbose)
			$display("RD: ADDR=%08x DATA=%08x%s", latched_raddr, memory[latched_raddr >> 2], latched_rinsn ? " INSN" : "");
		if (latched_raddr < 128*1024) begin
			mem_axi_rdata <= memory[latched_raddr >> 2];
			mem_axi_rvalid <= 1;
			latched_raddr_en = 0;
		end else begin
			$display($time,"handle_axi_rvalid OUT-OF-BOUNDS MEMORY READ FROM %08x", latched_raddr);
			$finish;
		end
	end endtask

	task handle_axi_bvalid; begin
      $display($time,"AM debug inside handle_axi_bvalid");
		if (verbose)
			$display("WR: ADDR=%08x DATA=%08x STRB=%04b", latched_waddr, latched_wdata, latched_wstrb);
		if (latched_waddr < 128*1024) begin
			if (latched_wstrb[0]) memory[latched_waddr >> 2][ 7: 0] <= latched_wdata[ 7: 0];
			if (latched_wstrb[1]) memory[latched_waddr >> 2][15: 8] <= latched_wdata[15: 8];
			if (latched_wstrb[2]) memory[latched_waddr >> 2][23:16] <= latched_wdata[23:16];
			if (latched_wstrb[3]) memory[latched_waddr >> 2][31:24] <= latched_wdata[31:24];
		end else
		if (latched_waddr == 32'h1000_0000) begin
			if (verbose) begin
				if (32 <= latched_wdata && latched_wdata < 128)
					$display("OUT: '%c'", latched_wdata[7:0]);
				else
					$display("OUT: %3d", latched_wdata);
			end else begin
				$write("%c", latched_wdata[7:0]);
`ifndef VERILATOR
				$fflush();
`endif
			end
		end else
		if (latched_waddr == 32'h2000_0000) begin
			if (latched_wdata == 123456789)
				tests_passed = 1;
		end else begin
			$display($time,"handle_axi_bvalid OUT-OF-BOUNDS MEMORY WRITE TO %08x", latched_waddr);
			$finish;
		end
		mem_axi_bvalid <= 1;
		latched_waddr_en = 0;
		latched_wdata_en = 0;
	end endtask

  assign latched_wdata_encoded = mem_axi_wdata_encoded ^ in_err3;
  //AMassign latched_wdata_encoded = mem_axi_wdata_encoded;
  
  operandrecovery1 write_port_recover (latched_wdata_encoded, latched_wdata_decoded);

   hammingcodegenerator1 read_port_hamming(mem_axi_rdata, mem_axi_rdata_encoded);
   
   assign mem_axi_rdata_encoded_error = mem_axi_rdata_encoded ^ in_err3;
   //AMassign mem_axi_rdata_encoded_error = mem_axi_rdata_encoded ;
   operandrecovery1 read_port_recover (mem_axi_rdata_encoded_error, mem_axi_rdata_decoded);
   //AM operandrecovery1 read_port_recover (mem_axi_rdata_encoded, mem_axi_rdata_decoded);


	always @(negedge clk)
  begin
		if (mem_axi_arvalid && !(latched_raddr_en || fast_raddr) && async_axi_transaction[0]) handle_axi_arvalid;
		
    if (mem_axi_awvalid && !(latched_waddr_en || fast_waddr) && async_axi_transaction[1]) handle_axi_awvalid;
		if (mem_axi_wvalid  && !(latched_wdata_en || fast_wdata) && async_axi_transaction[2]) handle_axi_wvalid;
		

		
    if (!mem_axi_rvalid && latched_raddr_en && async_axi_transaction[3]) handle_axi_rvalid;
    //AM not requried as of now if (!mem_axi_rvalid && latched_raddr_en && async_axi_transaction[3])
    //AM not requried as of now     handle_axi_rvalid;
    //AM not requried as of now else if(simpleuart_reg_div_sel)
    //AM not requried as of now     mem_axi_rdata <= simpleuart_reg_div_do;
    //AM not requried as of now else if(simpleuart_reg_dat_sel)
    //AM not requried as of now     mem_axi_rdata <= simpleuart_reg_dat_do;
    //AM not requried as of now else
    //AM not requried as of now     mem_axi_rdata <= 32'b0;
		
    if (!mem_axi_bvalid && latched_waddr_en && latched_wdata_en && async_axi_transaction[4]) handle_axi_bvalid;
	end


	always @(posedge clk)
  begin
      mem_axi_arready <= 0;
      mem_axi_awready <= 0;
      mem_axi_wready <= 0;


      fast_raddr <= 0;
      fast_waddr <= 0;
      fast_wdata <= 0;

      if (mem_axi_rvalid && mem_axi_rready) begin
          mem_axi_rvalid <= 0;
      end

      if (mem_axi_bvalid && mem_axi_bready) begin
          mem_axi_bvalid <= 0;
      end

      if (mem_axi_arvalid && mem_axi_arready && !fast_raddr) begin
          latched_raddr = mem_axi_araddr;
          latched_rinsn = mem_axi_arprot[2];
          latched_raddr_en = 1;
      end

      if (mem_axi_awvalid && mem_axi_awready && !fast_waddr) begin
          latched_waddr = mem_axi_awaddr;
          latched_waddr_en = 1;
      end

      if (mem_axi_wvalid && mem_axi_wready && !fast_wdata) begin
          $display($time,"AM debug in posedge if block");
          //AM latched_wdata = mem_axi_wdata;
      latched_wdata = latched_wdata_decoded;
      latched_wstrb = mem_axi_wstrb;
      latched_wdata_en = 1;
  end

  if (mem_axi_arvalid && !(latched_raddr_en || fast_raddr) && !delay_axi_transaction[0]) handle_axi_arvalid;


  if (mem_axi_awvalid && !(latched_waddr_en || fast_waddr) && !delay_axi_transaction[1]) handle_axi_awvalid;


  if (mem_axi_wvalid  && !(latched_wdata_en || fast_wdata) && !delay_axi_transaction[2]) handle_axi_wvalid;

  if (!mem_axi_rvalid && latched_raddr_en && !delay_axi_transaction[3]) handle_axi_rvalid;

  //AM not required as of now if (!mem_axi_rvalid && latched_raddr_en && !delay_axi_transaction[3])
    //AM not required as of now     handle_axi_rvalid;
    //AM not required as of now else if(simpleuart_reg_div_sel)
    //AM not required as of now     mem_axi_rdata <= simpleuart_reg_div_do;
    //AM not required as of now else if(simpleuart_reg_dat_sel)
    //AM not required as of now     mem_axi_rdata <= simpleuart_reg_dat_do;
    //AM not required as of now else
    //AM not required as of now     mem_axi_rdata <= 32'b0;





    if (!mem_axi_bvalid && latched_waddr_en && latched_wdata_en && !delay_axi_transaction[4])
    begin
        handle_axi_bvalid;
        $display($time,"AM debug handle_axi_bvalid called posedge block");
    end 
end
endmodule

//AM module axi4_memory #(
//AM 	parameter AXI_TEST = 0,
//AM 	parameter VERBOSE = 0
//AM ) (
//AM 	/* verilator lint_off MULTIDRIVEN */
//AM 
//AM 	input             clk,
//AM 	input             mem_axi_awvalid,
//AM 	output reg        mem_axi_awready,
//AM 	input      [31:0] mem_axi_awaddr,
//AM 	input      [ 2:0] mem_axi_awprot,
//AM 
//AM 	input             mem_axi_wvalid,
//AM 	output reg        mem_axi_wready,
//AM 	input      [31:0] mem_axi_wdata, //AM write data to memory
//AM 	input      [ 3:0] mem_axi_wstrb,
//AM 
//AM 	output reg        mem_axi_bvalid,
//AM 	input             mem_axi_bready,
//AM 
//AM 	input             mem_axi_arvalid,
//AM 	output reg        mem_axi_arready,
//AM 	input      [31:0] mem_axi_araddr,
//AM 	input      [ 2:0] mem_axi_arprot,
//AM 
//AM 	output reg        mem_axi_rvalid,
//AM 	input             mem_axi_rready,
//AM 	//AM output reg [31:0] mem_axi_rdata, // AM read data from memory
//AM 	output [31:0] mem_axi_rdata_decoded, // AM read data from memory
//AM 
//AM 	output reg        tests_passed,
//AM   input   [11:0]    in_err1,
//AM   input   [37:0]    in_err3
//AM );
//AM 	//AM reg [31:0]   memory [0:128*1024/4-1] /* verilator public */;
//AM 
//AM   //AM (* ram_style = "block" *)	reg [31:0]   memory [0:15000] /* verilator public */;
//AM   (* ram_style = "block" *)	reg [31:0]   memory [0:150] /* verilator public */;
//AM 	
//AM   reg verbose;
//AM 	initial verbose = $test$plusargs("verbose") || VERBOSE;
//AM 
//AM 	reg axi_test;
//AM 	initial axi_test = $test$plusargs("axi_test") || AXI_TEST;
//AM 
//AM 	initial begin
//AM 		mem_axi_awready = 0;
//AM 		mem_axi_wready = 0;
//AM 		mem_axi_bvalid = 0;
//AM 		mem_axi_arready = 0;
//AM 		mem_axi_rvalid = 0;
//AM 		tests_passed = 0;
//AM 	end
//AM 
//AM 	reg [1023:0] firmware_file;
//AM 	initial begin
//AM 			firmware_file = "firmware/firmware.hex";
//AM       $readmemh(firmware_file,memory);
//AM 	end
//AM 
//AM 
//AM 
//AM 	reg [63:0] xorshift64_state = 64'd88172645463325252;
//AM 
//AM 	task xorshift64_next;
//AM 		begin
//AM 			// see page 4 of Marsaglia, George (July 2003). "Xorshift RNGs". Journal of Statistical Software 8 (14).
//AM 			xorshift64_state = xorshift64_state ^ (xorshift64_state << 13);
//AM 			xorshift64_state = xorshift64_state ^ (xorshift64_state >>  7);
//AM 			xorshift64_state = xorshift64_state ^ (xorshift64_state << 17);
//AM 		end
//AM 	endtask
//AM 
//AM 	reg [2:0] fast_axi_transaction = ~0;
//AM 	reg [4:0] async_axi_transaction = ~0;
//AM 	reg [4:0] delay_axi_transaction = 0;
//AM 
//AM 	always @(posedge clk) begin
//AM 		if (axi_test) begin
//AM 				xorshift64_next;
//AM 				{fast_axi_transaction, async_axi_transaction, delay_axi_transaction} <= xorshift64_state;
//AM 		end
//AM 	end
//AM 
//AM 
//AM 	wire [37:0] mem_axi_wdata_encoded; //AM encoded data from hammingcode to be written in memory 
//AM 
//AM   hammingcodegenerator1 write_port_hamming (mem_axi_wdata, mem_axi_wdata_encoded);
//AM 
//AM 
//AM  
//AM 
//AM 	reg latched_raddr_en = 0;
//AM 	reg latched_waddr_en = 0;
//AM 	reg latched_wdata_en = 0;
//AM 
//AM 	reg fast_raddr = 0;
//AM 	reg fast_waddr = 0;
//AM 	reg fast_wdata = 0;
//AM 
//AM 	reg [31:0] latched_raddr;
//AM 	reg [31:0] latched_waddr;
//AM 	reg [31:0] latched_wdata;
//AM 	wire [37:0] latched_wdata_encoded;
//AM 	wire [31:0] latched_wdata_decoded;
//AM 	reg [ 3:0] latched_wstrb;
//AM 	reg        latched_rinsn;
//AM 
//AM   //AM Signals for Read port Hamming code
//AM 
//AM   wire [37:0] mem_axi_rdata_encoded;
//AM 	wire [37:0] mem_axi_rdata_encoded_error;
//AM 	reg [31:0] mem_axi_rdata; 
//AM 
//AM 
//AM 	task handle_axi_arvalid; begin
//AM 		mem_axi_arready <= 1;
//AM 		latched_raddr = mem_axi_araddr;
//AM 		latched_rinsn = mem_axi_arprot[2];
//AM 		latched_raddr_en = 1;
//AM 		fast_raddr <= 1;
//AM 	end endtask
//AM 
//AM   task handle_axi_awvalid;
//AM       begin
//AM           $display($time,"AM debug inside handle_axi_awvalid");
//AM           mem_axi_awready <= 1;
//AM           latched_waddr = mem_axi_awaddr;
//AM           latched_waddr_en = 1;
//AM           fast_waddr <= 1;
//AM       end
//AM   endtask
//AM 
//AM 	task handle_axi_wvalid; begin
//AM 		mem_axi_wready <= 1;
//AM 		//AM latched_wdata = mem_axi_wdata;
//AM 	  //AM latched_wdata_encoded = mem_axi_wdata_encoded;
//AM     latched_wdata = latched_wdata_decoded;
//AM 		latched_wstrb = mem_axi_wstrb;
//AM 		latched_wdata_en = 1;
//AM 		fast_wdata <= 1;
//AM 	end endtask
//AM 
//AM 	task handle_axi_rvalid; begin
//AM 		if (verbose)
//AM 			$display("RD: ADDR=%08x DATA=%08x%s", latched_raddr, memory[latched_raddr >> 2], latched_rinsn ? " INSN" : "");
//AM 		if (latched_raddr < 128*1024) begin
//AM 			mem_axi_rdata <= memory[latched_raddr >> 2];
//AM 			mem_axi_rvalid <= 1;
//AM 			latched_raddr_en = 0;
//AM 		end else begin
//AM 			$display($time,"handle_axi_rvalid OUT-OF-BOUNDS MEMORY READ FROM %08x", latched_raddr);
//AM 			$finish;
//AM 		end
//AM 	end endtask
//AM 
//AM 	task handle_axi_bvalid; begin
//AM       $display($time,"AM debug inside handle_axi_bvalid");
//AM 		if (verbose)
//AM 			$display("WR: ADDR=%08x DATA=%08x STRB=%04b", latched_waddr, latched_wdata, latched_wstrb);
//AM 		if (latched_waddr < 128*1024) begin
//AM 			if (latched_wstrb[0]) memory[latched_waddr >> 2][ 7: 0] <= latched_wdata[ 7: 0];
//AM 			if (latched_wstrb[1]) memory[latched_waddr >> 2][15: 8] <= latched_wdata[15: 8];
//AM 			if (latched_wstrb[2]) memory[latched_waddr >> 2][23:16] <= latched_wdata[23:16];
//AM 			if (latched_wstrb[3]) memory[latched_waddr >> 2][31:24] <= latched_wdata[31:24];
//AM 		end else
//AM 		if (latched_waddr == 32'h1000_0000) begin
//AM 			if (verbose) begin
//AM 				if (32 <= latched_wdata && latched_wdata < 128)
//AM 					$display("OUT: '%c'", latched_wdata[7:0]);
//AM 				else
//AM 					$display("OUT: %3d", latched_wdata);
//AM 			end else begin
//AM 				$write("%c", latched_wdata[7:0]);
//AM `ifndef VERILATOR
//AM 				$fflush();
//AM `endif
//AM 			end
//AM 		end else
//AM 		if (latched_waddr == 32'h2000_0000) begin
//AM 			if (latched_wdata == 123456789)
//AM 				tests_passed = 1;
//AM 		end else begin
//AM 			$display($time,"handle_axi_bvalid OUT-OF-BOUNDS MEMORY WRITE TO %08x", latched_waddr);
//AM 			$finish;
//AM 		end
//AM 		mem_axi_bvalid <= 1;
//AM 		latched_waddr_en = 0;
//AM 		latched_wdata_en = 0;
//AM 	end endtask
//AM 
//AM   assign latched_wdata_encoded = mem_axi_wdata_encoded ^ in_err3;
//AM   //AMassign latched_wdata_encoded = mem_axi_wdata_encoded;
//AM   
//AM   operandrecovery1 write_port_recover (latched_wdata_encoded, latched_wdata_decoded);
//AM 
//AM   hammingcodegenerator1 read_port_hamming(mem_axi_rdata, mem_axi_rdata_encoded);
//AM    
//AM    assign mem_axi_rdata_encoded_error = mem_axi_rdata_encoded ^ in_err3;
//AM    //AMassign mem_axi_rdata_encoded_error = mem_axi_rdata_encoded ;
//AM    operandrecovery1 read_port_recover (mem_axi_rdata_encoded_error, mem_axi_rdata_decoded);
//AM    //AM operandrecovery1 read_port_recover (mem_axi_rdata_encoded, mem_axi_rdata_decoded);
//AM 
//AM 
//AM 	always @(negedge clk) begin
//AM 		if (mem_axi_arvalid && !(latched_raddr_en || fast_raddr) && async_axi_transaction[0]) handle_axi_arvalid;
//AM 		if (mem_axi_awvalid && !(latched_waddr_en || fast_waddr) && async_axi_transaction[1]) handle_axi_awvalid;
//AM 		if (mem_axi_wvalid  && !(latched_wdata_en || fast_wdata) && async_axi_transaction[2]) handle_axi_wvalid;
//AM 		if (!mem_axi_rvalid && latched_raddr_en && async_axi_transaction[3]) handle_axi_rvalid;
//AM 		if (!mem_axi_bvalid && latched_waddr_en && latched_wdata_en && async_axi_transaction[4]) handle_axi_bvalid;
//AM 	end
//AM 
//AM 	always @(posedge clk) begin
//AM 		mem_axi_arready <= 0;
//AM 		mem_axi_awready <= 0;
//AM 		mem_axi_wready <= 0;
//AM 
//AM 		fast_raddr <= 0;
//AM 		fast_waddr <= 0;
//AM 		fast_wdata <= 0;
//AM 
//AM 		if (mem_axi_rvalid && mem_axi_rready) begin
//AM 			mem_axi_rvalid <= 0;
//AM 		end
//AM 
//AM 		if (mem_axi_bvalid && mem_axi_bready) begin
//AM 			mem_axi_bvalid <= 0;
//AM 		end
//AM 
//AM 		if (mem_axi_arvalid && mem_axi_arready && !fast_raddr) begin
//AM 			latched_raddr = mem_axi_araddr;
//AM 			latched_rinsn = mem_axi_arprot[2];
//AM 			latched_raddr_en = 1;
//AM 		end
//AM 
//AM 		if (mem_axi_awvalid && mem_axi_awready && !fast_waddr) begin
//AM 			latched_waddr = mem_axi_awaddr;
//AM 			latched_waddr_en = 1;
//AM 		end
//AM 
//AM 		if (mem_axi_wvalid && mem_axi_wready && !fast_wdata) begin
//AM         $display($time,"AM debug in posedge if block");
//AM 			latched_wdata = mem_axi_wdata;
//AM 			latched_wstrb = mem_axi_wstrb;
//AM 			latched_wdata_en = 1;
//AM 		end
//AM 
//AM 		if (mem_axi_arvalid && !(latched_raddr_en || fast_raddr) && !delay_axi_transaction[0]) handle_axi_arvalid;
//AM 		if (mem_axi_awvalid && !(latched_waddr_en || fast_waddr) && !delay_axi_transaction[1]) handle_axi_awvalid;
//AM 		if (mem_axi_wvalid  && !(latched_wdata_en || fast_wdata) && !delay_axi_transaction[2]) handle_axi_wvalid;
//AM 
//AM 		if (!mem_axi_rvalid && latched_raddr_en && !delay_axi_transaction[3]) handle_axi_rvalid;
//AM 		if (!mem_axi_bvalid && latched_waddr_en && latched_wdata_en && !delay_axi_transaction[4])
//AM         begin
//AM             handle_axi_bvalid;
//AM             $display($time,"AM debug handle_axi_bvalid called posedge block");
//AM         end 
//AM 	end
//AM endmodule


//AM module axi4_memory #(
//AM 	parameter AXI_TEST = 0,
//AM 	parameter VERBOSE = 0
//AM ) (
//AM 	/* verilator lint_off MULTIDRIVEN */
//AM 
//AM 	input             clk,
//AM 	input             mem_axi_awvalid,
//AM 	//AM output reg        mem_axi_awready,
//AM 	output        mem_axi_awready,
//AM 	input      [31:0] mem_axi_awaddr,
//AM 	input      [ 2:0] mem_axi_awprot,
//AM 
//AM 	input             mem_axi_wvalid,
//AM 	output reg        mem_axi_wready,
//AM 	input      [31:0] mem_axi_wdata, //AM write data to memory
//AM 	input      [ 3:0] mem_axi_wstrb,
//AM 
//AM 	output reg        mem_axi_bvalid,
//AM 	input             mem_axi_bready,
//AM 
//AM 	input             mem_axi_arvalid,
//AM 	//AM output reg        mem_axi_arready,
//AM   output            mem_axi_arready,
//AM 	input      [31:0] mem_axi_araddr,
//AM 	input      [ 2:0] mem_axi_arprot,
//AM 
//AM 	output reg        mem_axi_rvalid,
//AM 	input             mem_axi_rready,
//AM 	//AM output reg [31:0] mem_axi_rdata, // AM read data from memory
//AM 	output [31:0] mem_axi_rdata_decoded, // AM read data from memory
//AM 
//AM 	output reg        tests_passed,
//AM   input   [11:0]    in_err1,
//AM   input   [37:0]    in_err3
//AM );
//AM 	//AM reg [31:0]   memory [0:128*1024/4-1] /* verilator public */;
//AM 
//AM   //AM (* ram_style = "block" *)	reg [31:0]   memory [0:15000] /* verilator public */;
//AM   (* ram_style = "block" *)	reg [31:0]   memory [0:150] /* verilator public */;
//AM 	
//AM   reg verbose;
//AM 	initial verbose = $test$plusargs("verbose") || VERBOSE;
//AM 
//AM 	reg axi_test;
//AM 	initial axi_test = $test$plusargs("axi_test") || AXI_TEST;
//AM 
//AM   //AM
//AM   reg negedge_arready;
//AM   reg posedge_arready;
//AM 
//AM   //AM
//AM   reg negedge_awready;
//AM   reg posedge_awready;
//AM 
//AM 	initial begin
//AM 		//AM mem_axi_awready = 0;
//AM     negedge_awready = 0;
//AM     posedge_awready = 0;
//AM 		mem_axi_wready = 0;
//AM 		mem_axi_bvalid = 0;
//AM 		//AM mem_axi_arready = 0;
//AM     negedge_arready = 0;
//AM     posedge_arready = 0;
//AM 		mem_axi_rvalid = 0;
//AM 		tests_passed = 0;
//AM 	end
//AM 
//AM 	reg [1023:0] firmware_file;
//AM 	initial begin
//AM 			firmware_file = "firmware/firmware.hex";
//AM       $readmemh(firmware_file,memory);
//AM 	end
//AM 
//AM 
//AM 
//AM 	reg [63:0] xorshift64_state = 64'd88172645463325252;
//AM 
//AM 	task xorshift64_next;
//AM 		begin
//AM 			// see page 4 of Marsaglia, George (July 2003). "Xorshift RNGs". Journal of Statistical Software 8 (14).
//AM 			xorshift64_state = xorshift64_state ^ (xorshift64_state << 13);
//AM 			xorshift64_state = xorshift64_state ^ (xorshift64_state >>  7);
//AM 			xorshift64_state = xorshift64_state ^ (xorshift64_state << 17);
//AM 		end
//AM 	endtask
//AM 
//AM 	reg [2:0] fast_axi_transaction = ~0;
//AM 	reg [4:0] async_axi_transaction = ~0;
//AM 	reg [4:0] delay_axi_transaction = 0;
//AM 
//AM 	always @(posedge clk) begin
//AM 		if (axi_test) begin
//AM 				xorshift64_next;
//AM 				{fast_axi_transaction, async_axi_transaction, delay_axi_transaction} <= xorshift64_state;
//AM 		end
//AM 	end
//AM 
//AM 
//AM 	wire [37:0] mem_axi_wdata_encoded; //AM encoded data from hammingcode to be written in memory 
//AM 
//AM   hammingcodegenerator1 write_port_hamming (mem_axi_wdata, mem_axi_wdata_encoded);
//AM 
//AM 
//AM  
//AM 
//AM 	reg latched_raddr_en = 0;
//AM 	reg latched_waddr_en = 0;
//AM 	reg latched_wdata_en = 0;
//AM 
//AM 	reg fast_raddr = 0;
//AM 	reg fast_waddr = 0;
//AM 	reg fast_wdata = 0;
//AM 
//AM 	reg [31:0] latched_raddr;
//AM 	reg [31:0] latched_waddr;
//AM 	reg [31:0] latched_wdata;
//AM 	wire [37:0] latched_wdata_encoded;
//AM 	wire [31:0] latched_wdata_decoded;
//AM 	reg [ 3:0] latched_wstrb;
//AM 	reg        latched_rinsn;
//AM 
//AM   //AM Signals for Read port Hamming code
//AM 
//AM   wire [37:0] mem_axi_rdata_encoded;
//AM 	wire [37:0] mem_axi_rdata_encoded_error;
//AM 	reg [31:0] mem_axi_rdata; 
//AM 
//AM 
//AM 	task handle_axi_arvalid; begin
//AM 		//AM mem_axi_arready <= 1;
//AM 		latched_raddr = mem_axi_araddr;
//AM 		latched_rinsn = mem_axi_arprot[2];
//AM 		latched_raddr_en = 1;
//AM 		fast_raddr <= 1;
//AM 	end endtask
//AM 
//AM   task handle_axi_awvalid;
//AM       begin
//AM           $display($time,"AM debug inside handle_axi_awvalid");
//AM           //AM mem_axi_awready <= 1;
//AM           latched_waddr = mem_axi_awaddr;
//AM           latched_waddr_en = 1;
//AM           fast_waddr <= 1;
//AM       end
//AM   endtask
//AM 
//AM 	task handle_axi_wvalid; begin
//AM 		mem_axi_wready <= 1;
//AM     latched_wdata = latched_wdata_decoded;
//AM 		latched_wstrb = mem_axi_wstrb;
//AM 		latched_wdata_en = 1;
//AM 		fast_wdata <= 1;
//AM 	end endtask
//AM 
//AM 	task handle_axi_rvalid; begin
//AM 		if (verbose)
//AM 			$display("RD: ADDR=%08x DATA=%08x%s", latched_raddr, memory[latched_raddr >> 2], latched_rinsn ? " INSN" : "");
//AM 		if (latched_raddr < 128*1024) begin
//AM 			mem_axi_rdata <= memory[latched_raddr >> 2];
//AM 			mem_axi_rvalid <= 1;
//AM 			latched_raddr_en = 0;
//AM 		end else begin
//AM 			$display($time,"handle_axi_rvalid OUT-OF-BOUNDS MEMORY READ FROM %08x", latched_raddr);
//AM 			$finish;
//AM 		end
//AM 	end endtask
//AM 
//AM 	task handle_axi_bvalid; begin
//AM       $display($time,"AM debug inside handle_axi_bvalid");
//AM 		if (verbose)
//AM 			$display("WR: ADDR=%08x DATA=%08x STRB=%04b", latched_waddr, latched_wdata, latched_wstrb);
//AM 		if (latched_waddr < 128*1024) begin
//AM 			if (latched_wstrb[0]) memory[latched_waddr >> 2][ 7: 0] <= latched_wdata[ 7: 0];
//AM 			if (latched_wstrb[1]) memory[latched_waddr >> 2][15: 8] <= latched_wdata[15: 8];
//AM 			if (latched_wstrb[2]) memory[latched_waddr >> 2][23:16] <= latched_wdata[23:16];
//AM 			if (latched_wstrb[3]) memory[latched_waddr >> 2][31:24] <= latched_wdata[31:24];
//AM 		end else
//AM 		if (latched_waddr == 32'h1000_0000) begin
//AM 			if (verbose) begin
//AM 				if (32 <= latched_wdata && latched_wdata < 128)
//AM 					$display("OUT: '%c'", latched_wdata[7:0]);
//AM 				else
//AM 					$display("OUT: %3d", latched_wdata);
//AM 			end else begin
//AM 				$write("%c", latched_wdata[7:0]);
//AM `ifndef VERILATOR
//AM 				$fflush();
//AM `endif
//AM 			end
//AM 		end else
//AM 		if (latched_waddr == 32'h2000_0000) begin
//AM 			if (latched_wdata == 123456789)
//AM 				tests_passed = 1;
//AM 		end else begin
//AM 			$display($time,"handle_axi_bvalid OUT-OF-BOUNDS MEMORY WRITE TO %08x", latched_waddr);
//AM 			$finish;
//AM 		end
//AM 		mem_axi_bvalid <= 1;
//AM 		latched_waddr_en = 0;
//AM 		latched_wdata_en = 0;
//AM 	end endtask
//AM 
//AM   assign latched_wdata_encoded = mem_axi_wdata_encoded ^ in_err3;
//AM   //AMassign latched_wdata_encoded = mem_axi_wdata_encoded;
//AM   
//AM   operandrecovery1 write_port_recover (latched_wdata_encoded, latched_wdata_decoded);
//AM 
//AM    hammingcodegenerator1 read_port_hamming(mem_axi_rdata, mem_axi_rdata_encoded);
//AM    
//AM    assign mem_axi_rdata_encoded_error = mem_axi_rdata_encoded ^ in_err3;
//AM    //AMassign mem_axi_rdata_encoded_error = mem_axi_rdata_encoded ;
//AM    operandrecovery1 read_port_recover (mem_axi_rdata_encoded_error, mem_axi_rdata_decoded);
//AM    //AM operandrecovery1 read_port_recover (mem_axi_rdata_encoded, mem_axi_rdata_decoded);
//AM    //
//AM 
//AM    //AM
//AM     assign mem_axi_arready = (mem_axi_arvalid && !(latched_raddr_en || fast_raddr) && async_axi_transaction[0]) ? negedge_arready:(mem_axi_arvalid && !(latched_raddr_en || fast_raddr) && !delay_axi_transaction[0]) ? posedge_arready: mem_axi_arready  ; 
//AM  
//AM     assign mem_axi_awready = (mem_axi_wvalid  && !(latched_wdata_en || fast_wdata) && async_axi_transaction[2]) ? negedge_awready : (mem_axi_awvalid && !(latched_waddr_en || fast_waddr) && !delay_axi_transaction[1]) ? posedge_awready:mem_axi_awready ;
//AM  
//AM //AM   always @(*)
//AM //AM   begin
//AM //AM       if(mem_axi_arvalid && !(latched_raddr_en || fast_raddr) && async_axi_transaction[0])
//AM //AM       begin
//AM //AM           mem_axi_arready = negedge_arready;
//AM //AM       end
//AM //AM       else if (mem_axi_arvalid && !(latched_raddr_en || fast_raddr) && !delay_axi_transaction[0])
//AM //AM       begin
//AM //AM           mem_axi_arready = posedge_arready;
//AM //AM       end
//AM //AM       else
//AM //AM       begin
//AM //AM           mem_axi_arready = 0;
//AM //AM       end
//AM //AM
//AM //AM       if(mem_axi_wvalid  && !(latched_wdata_en || fast_wdata) && async_axi_transaction[2])
//AM //AM       begin
//AM //AM           mem_axi_awready = negedge_awready;
//AM //AM       end
//AM //AM       else if(mem_axi_awvalid && !(latched_waddr_en || fast_waddr) && !delay_axi_transaction[1])
//AM //AM       begin
//AM //AM           mem_axi_awready = posedge_awready;
//AM //AM       end
//AM //AM       else
//AM //AM       begin
//AM //AM           mem_axi_awready = 0;
//AM //AM       end
//AM //AM   end
//AM 
//AM 	always @(negedge clk) begin
//AM 		if (mem_axi_arvalid && !(latched_raddr_en || fast_raddr) && async_axi_transaction[0]) handle_axi_arvalid;
//AM     //AM 
//AM 		if (mem_axi_arvalid && !(latched_raddr_en || fast_raddr) && async_axi_transaction[0]) negedge_arready <= 'b1;
//AM 		
//AM     if (mem_axi_awvalid && !(latched_waddr_en || fast_waddr) && async_axi_transaction[1]) handle_axi_awvalid;
//AM 		if (mem_axi_wvalid  && !(latched_wdata_en || fast_wdata) && async_axi_transaction[2]) handle_axi_wvalid;
//AM 		
//AM 
//AM     //AM
//AM     if (mem_axi_wvalid  && !(latched_wdata_en || fast_wdata) && async_axi_transaction[2]) negedge_awready <= 'b1;
//AM 		
//AM     if (!mem_axi_rvalid && latched_raddr_en && async_axi_transaction[3]) handle_axi_rvalid;
//AM 		if (!mem_axi_bvalid && latched_waddr_en && latched_wdata_en && async_axi_transaction[4]) handle_axi_bvalid;
//AM 	end
//AM 
//AM 
//AM 	always @(posedge clk) begin
//AM 		//AM mem_axi_arready <= 0;
//AM 		posedge_arready <= 0;
//AM 		//AM mem_axi_awready <= 0;
//AM     posedge_awready <= 0;
//AM 		mem_axi_wready <= 0;
//AM 
//AM 
//AM 		fast_raddr <= 0;
//AM 		fast_waddr <= 0;
//AM 		fast_wdata <= 0;
//AM 
//AM 		if (mem_axi_rvalid && mem_axi_rready) begin
//AM 			mem_axi_rvalid <= 0;
//AM 		end
//AM 
//AM 		if (mem_axi_bvalid && mem_axi_bready) begin
//AM 			mem_axi_bvalid <= 0;
//AM 		end
//AM 
//AM 		if (mem_axi_arvalid && mem_axi_arready && !fast_raddr) begin
//AM 			latched_raddr = mem_axi_araddr;
//AM 			latched_rinsn = mem_axi_arprot[2];
//AM 			latched_raddr_en = 1;
//AM 		end
//AM 
//AM 		if (mem_axi_awvalid && mem_axi_awready && !fast_waddr) begin
//AM 			latched_waddr = mem_axi_awaddr;
//AM 			latched_waddr_en = 1;
//AM 		end
//AM 
//AM 		if (mem_axi_wvalid && mem_axi_wready && !fast_wdata) begin
//AM         $display($time,"AM debug in posedge if block");
//AM 			//AM latched_wdata = mem_axi_wdata;
//AM 			latched_wdata = latched_wdata_decoded;
//AM 			latched_wstrb = mem_axi_wstrb;
//AM 			latched_wdata_en = 1;
//AM 		end
//AM 
//AM 		if (mem_axi_arvalid && !(latched_raddr_en || fast_raddr) && !delay_axi_transaction[0]) handle_axi_arvalid;
//AM     //AM 
//AM 		if (mem_axi_arvalid && !(latched_raddr_en || fast_raddr) && !delay_axi_transaction[0]) posedge_arready <= 'b1;
//AM 		
//AM     if (mem_axi_awvalid && !(latched_waddr_en || fast_waddr) && !delay_axi_transaction[1]) handle_axi_awvalid;
//AM     
//AM 
//AM     //AM
//AM     if (mem_axi_awvalid && !(latched_waddr_en || fast_waddr) && !delay_axi_transaction[1]) posedge_awready <= 'b1;
//AM 		
//AM     if (mem_axi_wvalid  && !(latched_wdata_en || fast_wdata) && !delay_axi_transaction[2]) handle_axi_wvalid;
//AM 
//AM 		if (!mem_axi_rvalid && latched_raddr_en && !delay_axi_transaction[3]) handle_axi_rvalid;
//AM 		if (!mem_axi_bvalid && latched_waddr_en && latched_wdata_en && !delay_axi_transaction[4])
//AM         begin
//AM             handle_axi_bvalid;
//AM             $display($time,"AM debug handle_axi_bvalid called posedge block");
//AM         end 
//AM 	end
//AM endmodule

