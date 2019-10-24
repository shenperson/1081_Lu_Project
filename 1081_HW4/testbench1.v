`timescale 1ns/10ps

`define CYCLE 10
`define ENDCYCLE  500000
// modify if need

`define PATTERN_DATA  "pattern.dat"
`define GOLDEN_DATA  "golden.dat"
`define CNT 16384

module testbench();

  reg           clk, rst;
  reg           orig_ready;
  reg  [7:0]    orig_data;
  
  wire [13:0]   orig_addr;
  wire          request;

  wire          imgproc_ready;
  wire [7:0]    imgproc_data;
  wire [13:0]   imgproc_addr;
  wire          finish; 

  imgproc DUT(
  .clk(clk),
	.rst(rst), 
	.orig_data(orig_data), 
	.orig_ready(orig_ready), 
	.request(request), 
	.orig_addr(orig_addr), 
	.imgproc_ready(imgproc_ready), 
	.imgproc_addr(imgproc_addr), 
	.imgproc_data(imgproc_data), 
	.finish(finish)
  ); 

  // clock
  initial begin
    clk = 0;
  end
  always #(`CYCLE/2) clk = ~clk;

  initial begin
    //FSDB
    `ifdef FSDB
    $fsdbDumpfile("imgpro.fsdb");
    $fsdbDumpvars();
    `endif
    //VCD
    `ifdef VCD
    $dumpfile("imgpro.vcd");
    $dumpvars();
    `endif
  end

  reg [7:0] pattern [0:16383];
  reg [7:0] golden [0:16383];
  reg [14:0] cnt;
  reg [14:0] err;

  initial begin
    $readmemh(`PATTERN_DATA,pattern);
    $readmemh(`GOLDEN_DATA,golden);
    // for ( cnt=0; cnt<`CNT ; cnt=cnt+1 ) begin
    //   gray_mem[cnt] = 0;
    //   my_mem[cnt] = 0;
    // end
    clk = 1;
    rst = 0;
    err = 0;
    cnt = 16384;
    orig_ready = 0;
    orig_data = 0;
    #(`CYCLE+3) rst = 1;
    #(`CYCLE*2) rst = 0;
  end

  always @(negedge clk) begin
    if(request) begin
      orig_ready = 1;
      orig_data = pattern[orig_addr];
    end
    else begin
      orig_ready = 0;
      orig_data = 0;
    end
  end

  always @(negedge clk) begin
    if(finish) begin
      $display("Total error:",err);
      $display("FINISH");
      $finish;
    end
    else begin
      if(imgproc_ready===1) begin
        cnt = cnt-1;
        if (imgproc_data !== golden[imgproc_addr] ) begin
          $display("ERROR! at ",imgproc_addr,", correct: ",golden[imgproc_addr],", your: ",imgproc_data);
        err = err+ 1 ;
        end
        else begin
          $display("CORRECT! at ",imgproc_addr,", correct: ",golden[imgproc_addr],", your: ",imgproc_data);
        end
      end
    end
  end

  // timeout
  initial begin
    #(`CYCLE*`ENDCYCLE);
    #1;
    if(cnt>0) begin
      $display("TIME OUT");
    end
    $finish;
  end


endmodule
