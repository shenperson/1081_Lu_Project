module autoseller(clk, reset, enable_i, money_i, drinktype_i, ready_o, enable_o, change_o, drink_o);

input clk,reset,enable_i;
input [5:0] money_i; 
input [1:0] drinktype_i; 

output reg ready_o;
output reg enable_o;
output reg [5:0] change_o;
output reg [1:0] drink_o;

wire [5:0] drinkcost [0:3];
assign {drinkcost[0],drinkcost[1],drinkcost[2],drinkcost[3]}  = {6'd0,6'd30,6'd20,6'd15};
// sequential
always @(posedge clk or posedge reset) begin

    if (reset) begin
        ready_o <= 1'b1;
        enable_o <= 1'b0;
        change_o <= 6'd0;
        drink_o <= 2'd0;
    end 
    else begin
        if(enable_i) begin
            if(money_i < drinkcost[drinktype_i]) begin
                change_o <= money_i;
                drink_o <= 2'b0;
            end
            else begin
                change_o <= money_i - drinkcost[drinktype_i];
                drink_o <= drinktype_i;
            end
            enable_o <= 1'b1;
            ready_o <= 1'b1;
        end
        else begin
            enable_o <= 1'b0;
            ready_o <= 1'b0;
        end
    end
end

endmodule
