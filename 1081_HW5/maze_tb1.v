`timescale 1ns/10ps

`define CYCLE    10
// modify if need
`define ENDCYCLE 1000

`define MAZE          "./maze1.dat"       
`define GOLDEN_PATH   "./golden_path1.dat" 

// color definition
`define YEL "%c[0;33m",27
`define BLK "%c[0;m",27

module test;

  parameter MAZE_N_PAT = 8;
  parameter OUT_LENGTH = 11;

  reg clk;
  reg reset;
  reg [15:0] row_i;
  reg start_i;
  wire [1:0] action_o;
  wire [5:0] coord_o;

  reg [0:15] maze_mem [0:MAZE_N_PAT];
  reg [5:0] out_mem   [0:OUT_LENGTH-1];
  reg [5:0] out_temp;
  integer i, j, out_f, err;
  integer pat;
  integer path_num;
  integer over;

  maze DUT(
    .clk(clk),
	.reset(reset), 
	.start_i(start_i), 
	.row_i(row_i), 
	.action_o(action_o), 
	.coord_o(coord_o)
  );
  

// -------------------------------------------------------- //
//   Global behavior
// -------------------------------------------------------- //

always #(`CYCLE/2) clk = ~clk;

initial begin
  $readmemb (`MAZE,  maze_mem);
  $readmemb (`GOLDEN_PATH, out_mem);
  $display("\n =================== 2019 Fall HW5 - Maze =================== ");

  clk = 1;
  reset = 0;
  start_i = 0;
  pat = 0;
  path_num = 0;
  over = 0;
  err = 0;    
   
  //reset
  #(`CYCLE*1.5 + 1) reset = 1;
  #(`CYCLE/2) reset = 0;
end

initial begin
  `ifdef SDFSYN
    $sdf_annotate("maze_syn.sdf", DUT);
  `endif
  `ifdef SDFAPR
    $sdf_annotate("maze_APR.sdf", DUT);
  `endif
  `ifdef FSDB
    $fsdbDumpfile("maze.fsdb");	
    $fsdbDumpvars();
	//if you want to dump register array ex. reg [0:15] reg_arr [0:7] use $fsdbDumpvars(0, DUT, "+mda") instead.
    //$fsdbDumpvars(0, DUT, "+mda");
  `endif
end

always@(negedge clk)
begin
  if(action_o === 2'b00) begin
    start_i= 1'b1;   
  end
  else begin
    start_i= 1'b0;   
  end
  if((action_o === 2'b01) && pat<=MAZE_N_PAT) begin  
	//start_i= 1'b1;         
	row_i = maze_mem[pat]; 
	pat = pat + 1;
  end 
  else begin
	//start_i= 1'b0;         
	row_i = 16'b0; 
  end 
end

// Finish
initial begin
  #(`CYCLE*`ENDCYCLE);
  $display(" =================== TIME OUT ======================\n");
  $display("         There are someting wrong in your code...  \n");
  $display("           If you need more simulation time         ");
  $display("  You can try to modify ENDCYCLE in the testbench .\n");
  $display(" =================== TIME OUT ======================\n");
  $finish;
end

always @(negedge clk)
begin
  out_temp = out_mem[path_num];
  if (action_o === 2'b11)
    begin
	  if (coord_o === out_temp)
        $display("At %5d NS", $time, `YEL," Correct!",`BLK, " Step %d : Expect: (%d,%d), Yours (%d,%d)", path_num, out_temp[5:3], out_temp[2:0], coord_o[5:3], coord_o[2:0]);
      else
        begin
          $display("At %5d NS", $time, " Error!   Step %d : Expect: (%d,%d), Yours (%d,%d)", path_num, out_temp[5:3], out_temp[2:0], coord_o[5:3], coord_o[2:0]);
          err = err + 1 ;
        end	  
      path_num = path_num + 1;	            
    end  
  if (path_num === OUT_LENGTH) 
    begin 
	  over = 1;
	end
end

always @(negedge clk)
begin
  if(over === 1) begin
    if(err==0) begin
        $display("\n");
        $display("                   ****************************              ");
        $display("                   **                        **        /|__/|");
        $display("                   **  Congratulations !!    **      / O,O  |");
        $display("                   **                        **    /_____   |");
        $display("                   **  You pass this test!!  **   /^ ^ ^ \\  |");
        $display("                   **                        **  |^ ^ ^ ^ |w|");
        $display("                   ****************************   \\m___m__|_|");
        $display("\n");	
        $finish;
    end
    else begin
        $display("\n");
        $display("                   ****************************              ");
        $display("                   **      *       *         **        /|__/|");
        $display("                   **        *   *           **      / >,<  |");
        $display("                   **          *             **    /_____   |");
        $display("                   **        *   *           **   /^ ^ ^ \\  |");
        $display("                   **      *       *         **  |^ ^ ^ ^ |w|");
        $display("                   ****************************   \\m___m__|_|");
        $display("\n");
        $display("There are %d errors in your results\n", err);	
        $finish;      
    end
  end
end  

endmodule
