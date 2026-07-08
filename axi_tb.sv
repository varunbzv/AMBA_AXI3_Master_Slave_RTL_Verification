//AXI Test Bench
`timescale 1ns/1ps

`define DATA_BITS 32
`define ADDR_BITS 32
`define LEN_BITS  4
`define SIZE_BITS 3


class axi_transaction;

    // Address: 0 to 63 (64 locations)
    randc bit [5:0] addr;

    // Random write data
    rand bit [31:0] data;

    // Keep address word aligned
    constraint addr_c
    {
        addr inside {[0:63]};
    }

endclass


module axi_tb;

//=====================================================
// TESTBENCH SIGNALS
//=====================================================

logic clock;
logic reset_n;

// Master Inputs
logic [`ADDR_BITS-1:0] AWADDR;
logic [`LEN_BITS-1:0]  AWLEN;
logic [`DATA_BITS-1:0] WDATA;
logic [`SIZE_BITS-1:0] AWSIZE;
logic [1:0]            AWBURST;
logic [3:0]            AWCACHE;
logic                  AWVALID;

logic [`ADDR_BITS-1:0] ARADDR;
logic [`LEN_BITS-1:0]  ARLEN;
logic [`SIZE_BITS-1:0] ARSIZE;
logic [1:0]            ARBURST;
logic [3:0]            ARCACHE;
logic                  ARVALID;

// DUT Wires
wire [`ADDR_BITS-1:0] aw_addr, ar_addr;
wire [`LEN_BITS-1:0]  aw_len, ar_len;
wire [`SIZE_BITS-1:0] aw_size, ar_size;
wire [`DATA_BITS-1:0] w_data, r_data;

wire [1:0] aw_burst, ar_burst;
wire [3:0] aw_cache, ar_cache;

wire aw_valid;
wire ar_valid;
wire aw_ready;
wire ar_ready;

wire w_ready;
wire w_valid;
wire w_last;
wire [`DATA_BITS/8-1:0] w_strb;

wire r_ready;
wire r_valid;
wire r_last;

wire b_ready;
wire b_valid;

wire [1:0] b_resp;
wire [1:0] r_resp;

//=====================================================
//=====================================================
// SCOREBOARD
//=====================================================

logic [31:0] expected_mem [0:255];

logic [31:0] read_data;

// Transaction object
axi_transaction tr;

integer total_test  = 0;
integer pass_test   = 0;
integer fail_test   = 0;

//=====================================================
// CLOCK
//=====================================================

initial
begin
    clock = 0;
    forever #5 clock = ~clock;
end

//=====================================================
// RESET
//=====================================================

task reset;

begin

    reset_n = 0;

    AWVALID = 0;
    ARVALID = 0;

    AWADDR  = 0;
    ARADDR  = 0;

    AWLEN   = 0;
    ARLEN   = 0;

    AWSIZE  = 0;
    ARSIZE  = 0;

    AWBURST = 0;
    ARBURST = 0;

    AWCACHE = 0;
    ARCACHE = 0;

    WDATA   = 0;

    repeat(4) @(posedge clock);

    reset_n = 1;

    $display("\n=================================");
    $display("RESET RELEASED");
    $display("=================================\n");

end

endtask

// WRITE TASK

task automatic axi_write
(
    input [31:0] addr,
    input [31:0] data
);

begin

    AWADDR  = addr;
    AWLEN   = 0;
    AWSIZE  = 3'b010; 
    AWBURST = 2'b00;
    AWCACHE = 4'b0000;

    WDATA   = data;

    AWVALID = 1;

    wait(aw_ready && aw_valid);

    @(posedge clock);

    AWVALID = 0;

    wait(b_valid && b_ready);

    @(posedge clock);

    expected_mem[addr>>2] = data;

    $display("[%0t] WRITE PASS  ADDR=%h DATA=%h",
                $time,addr,data);

end

endtask;

//=====================================================
// READ TASK
//=====================================================

task automatic axi_read
(
    input [31:0] addr,
    output [31:0] data
);

begin

    ARADDR  = addr;
    ARLEN   = 0;
    ARSIZE  = 3'b010;
    ARBURST = 2'b00;
    ARCACHE = 4'b0000;

    ARVALID = 1;

    wait(ar_ready && ar_valid);
    
    @(posedge clock);

    ARVALID = 0;

    wait(r_valid && r_ready);

    data = r_data;

    @(posedge clock);

    $display("[%0t] READ  PASS  ADDR=%h DATA=%h",
                $time,addr,data);

end

endtask;


//=====================================================
// SELF CHECK TASK
//=====================================================

task automatic check_transaction
(
    input [31:0] addr
);

begin

    total_test++;

    axi_read(addr, read_data);

    if(read_data === expected_mem[addr>>2])
    begin
        pass_test++;

        $display("PASS : ADDR=%h EXPECTED=%h RECEIVED=%h",
                  addr,
                  expected_mem[addr>>2],
                  read_data);
    end
    else
    begin
        fail_test++;

        $display("FAIL : ADDR=%h EXPECTED=%h RECEIVED=%h",
                  addr,
                  expected_mem[addr>>2],
                  read_data);
    end

    $display("");

end

endtask


//=====================================================
// SIGNAL MONITOR
//=====================================================

initial
begin

$display("--------------------------------------------------------------------------------------");
$display("TIME\tAWVALID\tAWREADY\tARVALID\tARREADY\tWVALID\tRVALID\tBVALID");
$display("--------------------------------------------------------------------------------------");

$monitor("%0t\t%b\t%b\t%b\t%b\t%b\t%b\t%b",
         $time,
         aw_valid,
         aw_ready,
         ar_valid,
         ar_ready,
         w_valid,
         r_valid,
         b_valid);

end


//=====================================================
// RANDOM VARIABLES
//=====================================================

integer i;

logic [31:0] rand_addr;
logic [31:0] rand_data;


//=====================================================
// MAIN VERIFICATION PROGRAM
//=====================================================
initial
begin

    reset();

    tr = new();

    //-------------------------------------------------
    // Directed Test Cases
    //-------------------------------------------------

    axi_write(32'h00000000,32'h11111111);
    check_transaction(32'h00000000);

    axi_write(32'h00000004,32'h22222222);
    check_transaction(32'h00000004);

    axi_write(32'h00000008,32'h33333333);
    check_transaction(32'h00000008);

    axi_write(32'h0000000C,32'h44444444);
    check_transaction(32'h0000000C);

    axi_write(32'h00000010,32'h55555555);
    check_transaction(32'h00000010);

    //-------------------------------------------------
    // Different Data Patterns
    //-------------------------------------------------

    axi_write(32'h00000014,32'hFFFFFFFF);
    check_transaction(32'h00000014);

    axi_write(32'h00000018,32'h00000000);
    check_transaction(32'h00000018);

    axi_write(32'h0000001C,32'hAAAAAAAA);
    check_transaction(32'h0000001C);

    axi_write(32'h00000020,32'h55555555);
    check_transaction(32'h00000020);

    axi_write(32'h00000024,32'h12345678);
    check_transaction(32'h00000024);

    //-------------------------------------------------
    // Overwrite Test
    //-------------------------------------------------

    axi_write(32'h00000004,32'h87654321);
    check_transaction(32'h00000004);

    //-------------------------------------------------
    // Sequential Writes
    //-------------------------------------------------

    axi_write(32'h00000028,32'h11112222);
    axi_write(32'h0000002C,32'h33334444);
    axi_write(32'h00000030,32'h55556666);

    check_transaction(32'h00000028);
    check_transaction(32'h0000002C);
    check_transaction(32'h00000030);

    //-------------------------------------------------
    // Random Verification
    //-------------------------------------------------

    $display("");
    $display("==================================");
    $display("STARTING RANDOM VERIFICATION");
    $display("==================================");

    
    repeat(64)
    begin

    assert(tr.randomize());

    rand_addr = tr.addr << 2;
    rand_data = tr.data;

    axi_write(rand_addr, rand_data);
    check_transaction(rand_addr);

    end

    
    // Summary
    

    $display("");
    $display("===========================================");
    $display("       AXI3 VERIFICATION SUMMARY");
    $display("===========================================");

    $display("TOTAL TESTS  = %0d",total_test);
    $display("PASSED TESTS = %0d",pass_test);
    $display("FAILED TESTS = %0d",fail_test);

    if(fail_test==0)
        $display("RESULT : ALL TESTS PASSED");
    else
        $display("RESULT : SOME TESTS FAILED");

    $display("===========================================");

    #20;

    $finish;

end


// DUT Instantiation
axi_master axi_m (
    .aclk(clock),
    .areset_n(reset_n),

    // WRITE ADDRESS CHANNEL
    .aw_ready(aw_ready),
    .aw_addr(aw_addr),
    .aw_len(aw_len),
    .aw_size(aw_size),
    .aw_burst(aw_burst),
    .aw_cache(aw_cache),
    .aw_valid(aw_valid),

    // WRITE DATA CHANNEL
    .w_ready(w_ready),
    .w_data(w_data),
    .w_valid(w_valid),
    .w_last(w_last),
    .w_strb(w_strb),

    // WRITE RESPONSE
    .b_valid(b_valid),
    .b_ready(b_ready),
    .b_resp(b_resp),

    // READ ADDRESS CHANNEL
    .ar_ready(ar_ready),
    .ar_addr(ar_addr),
    .ar_len(ar_len),
    .ar_size(ar_size),
    .ar_burst(ar_burst),
    .ar_cache(ar_cache),
    .ar_valid(ar_valid),

    // READ DATA CHANNEL
    .r_ready(r_ready),
    .r_data(r_data),
    .r_valid(r_valid),
    .r_last(r_last),
    .r_resp(r_resp),

    // TB Driven Inputs
    .AWADDR(AWADDR),
    .AWLEN(AWLEN),
    .WDATA(WDATA),
    .AWSIZE(AWSIZE),
    .AWBURST(AWBURST),
    .AWCACHE(AWCACHE),
    .AWVALID(AWVALID),
    .ARADDR(ARADDR),
    .ARLEN(ARLEN),
    .ARSIZE(ARSIZE),
    .ARBURST(ARBURST),
    .ARCACHE(ARCACHE),
    .ARVALID(ARVALID)
);

axi_slave axi_s (
    .aclk(clock),
    .areset_n(reset_n),

    // WRITE ADDRESS CHANNEL
    .aw_ready(aw_ready),
    .aw_addr(aw_addr),
    .aw_len(aw_len),
    .aw_size(aw_size),
    .aw_burst(aw_burst),
    .aw_cache(aw_cache),
    .aw_valid(aw_valid),
    
    // WRITE DATA CHANNEL		    
    .w_ready(w_ready),
    .w_data(w_data),
    .w_valid(w_valid),
    .w_last(w_last),
    .w_strb(w_strb),

    // WRITE RESPONSE
    .b_valid(b_valid),
    .b_ready(b_ready),
    .b_resp(b_resp),

    // READ ADDRESS CHANNEL
    .ar_ready(ar_ready),
    .ar_addr(ar_addr),
    .ar_len(ar_len),
    .ar_size(ar_size),
    .ar_burst(ar_burst),
    .ar_cache(ar_cache),
    .ar_valid(ar_valid),

    // READ DATA CHANNEL
    .r_ready(r_ready),
    .r_data(r_data),
    .r_valid(r_valid),
    .r_last(r_last),
    .r_resp(r_resp)
);
endmodule
