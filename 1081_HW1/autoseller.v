module autoseller(clk, reset, enable_i, money_i, drinktype_i, ready_o, enable_o, change_o, drink_o);

input clk,reset,enable_i;
input [5:0] money_i; 
input [1:0] drinktype_i; 

output reg ready_o;
output reg enable_o;
output reg [5:0] change_o;
output reg [1:0] drink_o;

/// TODO

// drink types
parameter [1:0] drinktype = {2'b00,2'b01,2'b10,2'b11};

// drink cost
parameter [5:0] drinkcost = {6'd0,6'd30,6'd20,6'd15};

// output
reg ready;
reg enable;
reg [5:0] change;
reg [1:0] drink;

// combinational
/*
always @(*) begin
    if (enable_i) begin
        drink = (money_i>=drinkcost[drinktype_i]) ? drinktype_i:2'b00;
        change = (money_i>=drinkcost[drinktype_i]) ? (money_i-drinkcost[drinktype_i]):money_i;
        ready = 1'b1;
    end
    else begin
        ready = 1'b0;
    end
end
*/
always @(*) begin
    if(enable_i) begin
        case (drinktype_i)
            drinktype[0]: begin
                drink = drinktype[0];
                change = money_i;
            end 
            drinktype[1]: begin
                if (money_i>=drinkcost[1]) begin
                    drink = drinktype[1];
                    change = money_i - drinkcost[1];
                end
                else begin
                    drink = drinktype[0];
                    change = money_i;
                end
            end
            drinktype[2]: begin
                if (money_i>=drinkcost[2]) begin
                    drink = drinktype[2];
                    change = money_i - drinkcost[2];
                end
                else begin
                    drink = drinktype[0];
                    change = money_i;
                end
            end
            drinktype[3]: begin
                if (money_i>=drinkcost[3]) begin
                    drink = drinktype[3];
                    change = money_i - drinkcost[3ㄣ];
                end
                else begin
                    drink = drinktype[0];
                    change = money_i;
                end
            end
            default: begin
                drink = drinktype[0];
                change = money_i;
            end 
        endcase
        ready = 1'b1;
    end
    else begin
        // ready = 1'b0;
    end
end

// sequential
always @(posedge clk or posedge reset) begin
    if (reset) begin
        change <= 6'd0;
        enable <= 1'b0;
        drink <= 2'b00;
        ready <= 1'b0;
    end
    else begin
        if(ready) begin
            change_o <= change;
            drink_o <= drink;
            ready_o <= 1'b1;
            enable_o <= 1'b1;
            ready <= 1'b0;
        end

        else begin
            ready <= 1'b0;
            enable_o <= 1'b0;
        end
    end

end

endmodule
