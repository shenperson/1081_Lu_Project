`define SIZE 64
`define MASK 16'b0000000000001111
`define MASK2 16'b0000000000000111

// action_o definition
`define ACT_IDLE 2'b00 
`define ACT_INPUT 2'b01 
`define ACT_CAL 2'b10 
`define ACT_OUTPUT 2'b11

// state definition
`define IDLE 2'd0
`define INPUT 2'd1
`define BFS 2'd2
`define OUTPUT 2'd3

// map definition
`define START 2'b10
`define WALL 2'b01
`define ROAD 2'b00
`define END 2'b11  // frontier

// direction definition
`define UP 2'b00
`define DOWN 2'b01
`define LEFT 2'b10
`define RIGHT 2'b11

module maze(clk, reset, start_i, row_i, action_o, coord_o);
    

    input clk,reset, start_i;
    input [15:0] row_i;

    output reg [1:0] action_o;
    output reg [5:0] coord_o;

    reg [1:0] map [`SIZE-1:0];
    reg [1:0] direction [`SIZE-1:0];
    reg [1:0] state;
    reg [5:0] cnt;
    // reg [3:0] start_x, start_y, end_x, end_y;
    reg [5:0] START, END;
    reg [7:0] i;

 
    // sequential
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            state <= `IDLE;
            action_o <= `ACT_IDLE;
        end
        else begin
            case (state)
                `IDLE: begin
                   state <= start_i ? `INPUT : `IDLE;
                   action_o <= start_i ? `ACT_INPUT : `ACT_IDLE;
                   cnt <= 1'b0;
                   coord_o <= 6'b0; 
                end
                `INPUT: begin
                    if(cnt!=8) begin
                        for(i = 0; i != 8; i = i + 1) begin
                            map[cnt + (i << 3)] <= row_i >> (14 - (i << 1)); 
                        end
                        // $display(map[cnt]);
                        
                    end
                    else begin
                        // START <= ((row_i[16:14]) << 3) + (row_i >> 8 & `MASK);
                        // END <= ((row_i >> 4 & `MASK) << 3) + (row_i & `MASK);
                        START <= ((row_i[15:12]) << 3) + (row_i[11:8]);
                        END <= ((row_i[7:4]) << 3) + (row_i[3:0]);
                        state <= `BFS;
                        action_o <= `ACT_CAL;
                    end
                    cnt <= cnt + 1;
                end
                `BFS: begin
                    for (i = 0; i != 64; i = i + 1) begin
                        if(map[i] == `END) begin
                            // right
                            if(i < 56) begin
                                if(map[i+8] == `ROAD) begin
                                    map[i+8] <= `END;
                                    direction[i+8] = `LEFT;
                                end
                                if(map[i+8] == `START) begin
                                    direction[i+8] <= `LEFT;
                                    state <= `OUTPUT;
                                    action_o <= `ACT_OUTPUT;
                                    coord_o  <= START;
                                end
                            end
                            // left
                            if(i > 7) begin
                                if(map[i-8] == `ROAD) begin
                                    map[i-8] <= `END;
                                    direction[i-8] = `RIGHT;
                                end
                                if(map[i-8] == `START) begin
                                    direction[i-8] <= `RIGHT;
                                    state <= `OUTPUT;
                                    action_o <= `ACT_OUTPUT;
                                    coord_o  <= START;
                                end
                            end
                            // UP
                            if(i[3:0] != 0) begin
                                if(map[i-1] == `ROAD) begin
                                    map[i-1] <= `END;
                                    direction[i-1] = `DOWN;
                                end
                                if(map[i-1] == `START) begin
                                    direction[i-1] <= `DOWN;
                                    state <= `OUTPUT;
                                    action_o <= `ACT_OUTPUT;
                                    coord_o  <= START;
                                end
                            end
                            // DOWN
                            if(i[3:0] != 7) begin
                                if(map[i+1] == `ROAD) begin
                                    map[i+1] <= `END;
                                    direction[i+1] = `UP;
                                end
                                if(map[i+1] == `START) begin
                                    direction[i+1] <= `UP;
                                    state <= `OUTPUT;
                                    action_o <= `ACT_OUTPUT;
                                    coord_o  <= START;
                                end
                            end
                            map[i] <= `WALL;
                        end
                    end
                end
                `OUTPUT: begin
                    
                    if(coord_o != END) begin
                        if(direction[coord_o] == `UP) begin
                            coord_o <= coord_o - 1;
                        end
                        else if(direction[coord_o] == `DOWN) begin
                            coord_o <= coord_o + 1;
                        end
                        else if(direction[coord_o] == `LEFT) begin
                            coord_o <= coord_o - 8;
                        end
                        else if(direction[coord_o] == `RIGHT) begin
                            coord_o <= coord_o + 8;
                        end
                    end
                    else begin
                        action_o <= `ACT_IDLE;
                    end
                end
                default: begin
                    
                end
            endcase
        end
    end
endmodule
