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
// parameter [23:0] drinkcost  = {6'd15,6'd20,6'd30,6'd0};
wire [5:0] cost;
assign cost = (enable_i)?drinkcost[drinktype_i]:6'd0;

// sequential
always @(posedge clk or posedge reset) begin
    if (reset) begin
        ready_o <= 1'b1;
    end 
    else begin
        if(enable_i) begin
        if(money_i<cost)begin
            change_o <= money_i;
            drink_o <= 2'b00;
        end
        else begin
            change_o <= money_i-cost;
            drink_o <= drinktype_i;
        end
            // change_o <= (money_i<drinkcost[6*drinktype_i+:6])?money_i:(money_i-drinkcost[6*drinktype_i+:6]);
            // drink_o <= (money_i<drinkcost[6*drinktype_i+:6])?2'b00:drinktype_i;
            enable_o <= 1'b1;
            ready_o <= 1'b1;
        end
        else begin
            enable_o <= 1'b0;
            ready_o <= 1'b1;
        end
    end
end

endmodule
