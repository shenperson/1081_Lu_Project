module autoseller(clk, reset, enable_i, money_i, drinktype_i, ready_o, enable_o, change_o, drink_o);

input clk,reset,enable_i;
input [5:0] money_i; 
input [1:0] drinktype_i; 

output reg ready_o;
output reg enable_o;
output reg [5:0] change_o;
output reg [1:0] drink_o;

/// TODO
wire [5:0] drinkcost [4:0];
assign {drinkcost[0],drinkcost[1],drinkcost[2],drinkcost[3]}  = {6'd0,6'd30,6'd20,6'd15};

parameter IDLE = 2'd0;
parameter MONEY = 2'd1;
parameter ENOUGH = 2'd2;
parameter NOT = 2'd3;

reg [5:0] money;
reg [1:0] drinktype;

reg [1:0] state, n_state;
// output
reg ready;
reg enable;
reg [5:0] change;
reg [1:0] drink;

// combinational
always @(*) begin
    case (state)
        IDLE: begin 
            money = money_i;
            drinktype = drinktype_i;
            enable = 1'b0;
            ready = 1'b0;
            if (enable_i)  n_state = MONEY;
            else n_state = IDLE; 
        end
        MONEY: begin
            enable = 1'b0;
            ready = 1'b0;
            if (money >= drinkcost[drinktype]) begin 
            n_state = ENOUGH;
            end
            else n_state = NOT;
        end
        ENOUGH: begin 
            drink = drinktype;
            change = money - drinkcost[drinktype];
            enable = 1'b1;
            ready = 1'b1;
            n_state = IDLE;
        end
        NOT: begin
            drink = 2'b00;
            change = money;
            enable = 1'b1;
            ready = 1'b1;
            n_state = IDLE;
        end
        default: begin 
            if (enable_i)  n_state = MONEY;
            else n_state = IDLE; 
        end
    endcase
end


// sequential
always @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= IDLE;
        ready_o <= 1'b1;
        enable_o <= 1'b0;
        change_o <= 6'd0;
        drink_o <= 2'd0;
    end 
    else begin
        state <= n_state;
        ready_o <= ready;
        enable_o <= enable;
        drink_o <= drink;
        change_o <= change;
    end
end

endmodule
