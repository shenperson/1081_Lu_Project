`define SIZE 64
`define MASK 16'b0000000000001111

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
    reg [1:0] state, n_state;
    reg [5:0] cnt, n_cnt;
    reg [1:0] n_action;
    reg [5:0] n_coord;
    // reg [3:0] start_x, start_y, end_x, end_y;
    reg [5:0] START, END;
    reg [7:0] i;

    // combinational
    always @(*) begin
        case (state)
            `IDLE: begin
                n_state = start_i ? `INPUT : `IDLE;
                n_action = start_i ? `ACT_INPUT : `ACT_IDLE;
                n_cnt = 1'b0;
                n_coord = 6'b0;
            end
            `INPUT:begin
                if(cnt!=8) begin
                    for(i = 0; i != 8; i = i + 1) begin
                        map[cnt+i*8] = row_i >> (14-i-i);
                    end
                end
                else begin
                    START = (row_i >> 12) * 8 + (row_i >> 8 & `MASK);
                    END = (row_i >> 4 & `MASK) * 8 + (row_i & `MASK);
                end
                n_cnt = cnt + 1;
                n_state = (cnt == 8) ? `BFS : `INPUT;
                n_action = (cnt == 8) ? `ACT_CAL : `ACT_INPUT;
            end
            `BFS:begin
                for(i = 0; i != 64;i = i + 1) begin
                    if(map[i]==`END) begin
                        // right
                        if(i < 56) begin
                            if(map[i+8] == `ROAD) begin
                                map[i+8] = `END;
                                direction[i+8] = `LEFT;
                            end
                            if(map[i+8] == `START) begin
                                direction[i+8] = `LEFT;
                                n_state = `OUTPUT;
                                n_action = `ACT_OUTPUT;
                                n_coord = START;
                            end
                        end
                        // left
                        if(i > 7) begin
                            if(map[i-8] == `ROAD) begin
                                map[i-8] = `END;
                                direction[i-8] = `RIGHT;
                            end
                            if(map[i-8] == `START) begin
                                direction[i-8] = `RIGHT;
                                n_state = `OUTPUT;
                                n_action = `ACT_OUTPUT;
                                n_coord = START;
                            end
                        end
                        // UP
                        if(i % 8 != 0) begin
                            if(map[i-1] == `ROAD) begin
                                map[i-1] = `END;
                                direction[i-1] = `DOWN;
                            end
                            if(map[i-1] == `START) begin
                                direction[i-1] = `DOWN;
                                n_state = `OUTPUT;
                                n_action = `ACT_OUTPUT;
                                n_coord = START;
                            end
                        end
                        // DOWN
                        if(i % 8 != 7) begin
                            if(map[i+1] == `ROAD) begin
                                map[i+1] = `END;
                                direction[i+1] = `UP;
                            end
                            if(map[i+1] == `START) begin
                                direction[i+1] = `UP;
                                n_state = `OUTPUT;
                                n_action = `ACT_OUTPUT;
                                n_coord = START;
                            end
                        end
                        map[i] = `WALL;
                    end
                end
            end
            `OUTPUT: begin
                if(coord_o != END) begin
                    if (direction[coord_o] == `UP) begin
                            n_coord = coord_o - 1;
                    end
                    else if (direction[coord_o] == `DOWN) begin
                            n_coord = coord_o + 1;
                    end
                    else if (direction[coord_o] == `LEFT) begin
                            n_coord = coord_o - 8;
                    end
                    else if (direction[coord_o] == `RIGHT) begin
                            n_coord = coord_o + 8;
                    end
                end
                else begin
                    
                end
            end
            default: begin
                
            end
        endcase
    end

    // sequential
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            state <= `IDLE;
            action_o <= `ACT_IDLE;
        end
        else begin
            state <= n_state;
            action_o <= n_action;
            cnt <= n_cnt;
        end
    end
endmodule
