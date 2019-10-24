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

parameter IDLE = 1'd0;
// parameter WAIT = 2'd1;
parameter SELL = 1'd1;

reg [5:0] money;
reg [1:0] drinktype;

reg state, n_state;
// output
reg enable;
reg [5:0] change;
reg [1:0] drink;

// combinational
always @(*) begin
    case (state)
        IDLE: begin 
            enable = 1'b0;
            money = money_i;
            drinktype = drinktype_i;
            n_state = enable_i ? SELL : IDLE;
        end
        // WAIT: begin
        //     enable = 1'b0;
        //     n_state = enable_i ? SELL : WAIT;
        // end
        SELL: begin
            enable = 1'b1;
            change = (money<drinkcost[drinktype])?money:(money-drinkcost[drinktype]);
            drink = (money<drinkcost[drinktype])?2'b00:drinktype;
            n_state = IDLE;
        end
        default: begin 
            n_state = IDLE; 
            enable = 1'b0;
        end
    endcase
end


// sequential
always @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= IDLE;
        ready_o <= 1'b1;
        // enable_o <= 1'b0;
        // change_o <= 6'd0;
        // drink_o <= 2'd0;
    end 
    else begin
        state <= n_state;
        ready_o <= enable;
        enable_o <= enable;
        change_o <= change;
        drink_o <= drink;
    end
end

endmodule
