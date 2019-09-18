`timescale 1ns/10ps

`define CYCLE 10
// modify if need
`define ENDCYCLE  400

`define PATTERN_MONEY  "pattern2_money.dat"
`define PATTERN_TYPE   "pattern2_type.dat"
`define NUM_PATTERN 10
`define NUM_OUT     10
`define GOLDEN_CHANGE  "golden2_change.dat"
`define GOLDEN_TYPE    "golden2_type.dat"

// color definition
`define YEL "%c[0;33m",27
`define BLK "%c[0;m",27

module testbench();

  reg         clk, reset, enable_i;
  reg   [5:0] money_i;
  reg   [1:0] drinktype_i;
  
  wire        ready_o, enable_o;
  wire  [5:0] change_o;
  wire  [1:0] drink_o;  
 
  reg [3:0] cnt;
  reg [3:0] cnt_pattern;
  integer pat;
  integer gold;
  integer err;
  
  reg [5:0] pattern_money [0:15];
  reg [1:0] pattern_type [0:15];
  reg [5:0] golden_change  [0:15];
  reg [1:0] golden_type [0:15];


  autoseller DUT(
    .clk(clk),
	.reset(reset), 
	.enable_i(enable_i), 
	.money_i(money_i), 
	.drinktype_i(drinktype_i), 
	.ready_o(ready_o), 
	.enable_o(enable_o), 
	.change_o(change_o), 
	.drink_o(drink_o)
  );

  
// -------------------------------------------------------- //
//   Global behavior
// -------------------------------------------------------- //

always #(`CYCLE/2) clk = ~clk;

initial begin
  `ifdef FSDB
    $fsdbDumpfile("autoseller.fsdb");
	$fsdbDumpvars();
  `endif

  `ifdef VCD
    $dumpfile("autoseller.vcd");
	$dumpvars();
  `endif
end

//
initial begin
  $readmemh(`PATTERN_MONEY, pattern_money);
  $readmemb(`PATTERN_TYPE, pattern_type);
  $readmemh(`GOLDEN_CHANGE, golden_change);
  $readmemb(`GOLDEN_TYPE, golden_type);
  $display("\n ================ 2014 Spring ICD HW4 - Automatic Selling Machine ================= ");
              
  pat=0;
  gold=0;
  err=0;
  clk =1;
  reset =0; 
  enable_i=0;
  money_i =0;
  drinktype_i=0;
  
  cnt=`NUM_OUT;
  cnt_pattern=`NUM_PATTERN;  
  
  //reset
  #(`CYCLE +3) reset = 1;
  #(`CYCLE/2) reset = 0;
end

// input value
always@(negedge clk)
begin
  #1
  if(ready_o===1 && pat<cnt_pattern) begin	
    enable_i = 1'b1;
    money_i = pattern_money[pat];
	drinktype_i = pattern_type[pat];
	pat = pat+1;
  end 
  else begin
    enable_i = 1'b0;
    money_i = 6'b0;
	drinktype_i = 2'b0;
  end 
end

// Finish
initial begin
  #(`CYCLE*`ENDCYCLE);
  #1;
  if(cnt>0) begin
    $display(" =================== TIME OUT ======================\n");
    $display("         There are someting wrong in your code...  \n");
    $display("           If you need more simulation time         ");
    $display("  You can try to modify ENDCYCLE in the testbench.\n");
    $display(" =================== TIME OUT ======================\n");
  end
  $finish;
end

always@(negedge clk)
begin
  if(cnt==0) begin
    if(err==0) begin
        $display("\n");
        $display("                      ****************************              ");
        $display("                      **                        **        /|__/|");
        $display("                      **  Congratulations !!    **      / O,O  |");
        $display("                      **                        **    /_____   |");
        $display("                      **  You pass this test!!  **   /^ ^ ^ \\  |");
        $display("                      **                        **  |^ ^ ^ ^ |w|");
        $display("                      ****************************   \\m___m__|_|");
        $display("\n");
        $finish;
    end
    else begin
        $display("\n");
        $display("                      ****************************              ");
        $display("                      **      *       *         **        /|__/|");
        $display("                      **        *   *           **      / >,<  |");
        $display("                      **          *             **    /_____   |");
        $display("                      **        *   *           **   /^ ^ ^ \\  |");
        $display("                      **      *       *         **  |^ ^ ^ ^ |w|");
        $display("                      ****************************   \\m___m__|_|");
        $display("\n");
        $display("There are %d errors in your results\n", err);
        $finish;      
    end
  end
  else begin
    if(enable_o===1)
    begin
      cnt = cnt-1;
      if(change_o!==golden_change[gold] || drink_o!==golden_type[gold])
      begin
        //$display("  At %5d NS",$time,`YEL," Error!",`BLK,"   The out_num should be: %3d", golden_num[gold], " Your: %3d", out_num);
        $display("  At %5d NS",$time,`YEL," Error!",`BLK,"   The change, type should be: %3d, %2b", golden_change[gold], golden_type[gold], " Your: %3d, %2b", change_o, drink_o);
		err =err+1;
        gold = gold+1;
      end
      else begin
        //$display("  At %5d NS",$time," Correct! The out_num should be: %3d", golden_num[gold], " Your: %3d", out_num);
		$display("  At %5d NS",$time," Correct! The change, type should be: %3d, %2b", golden_change[gold], golden_type[gold], " Your: %3d, %2b", change_o, drink_o);
        gold = gold+1;
      end
    end
  end
end


endmodule
