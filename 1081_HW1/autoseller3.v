module autoseller(clk, reset, enable_i, money_i, drinktype_i, ready_o, enable_o, change_o, drink_o);

input clk,reset,enable_i;
input [5:0] money_i; 
input [1:0] drinktype_i; 

output reg ready_o;
output reg enable_o;
output reg [5:0] change_o;
output reg [1:0] drink_o;

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
            case (drinktype_i)
                2'b00: begin
                    change_o <= money_i;
                    drink_o <= 2'b00;
                    enable_o <= 1'b1;
                    ready_o <= 1'b1;
                end 
                2'b01: begin
                    if(money_i >= 6'd30) begin
                        change_o <= money_i - 6'd30;
                        drink_o <= 2'b01;
                        enable_o <= 1'b1;
                        ready_o <= 1'b1;
                    end
                    else begin
                        change_o <= money_i;
                        drink_o <= 2'b00;
                        enable_o <= 1'b1;
                        ready_o <= 1'b1;
                    end
                end
                2'b10: begin
                    if(money_i >= 6'd20) begin
                        change_o <= money_i - 6'd20;
                        drink_o <= 2'b10;
                        enable_o <= 1'b1;
                        ready_o <= 1'b1;
                    end
                    else begin
                        change_o <= money_i;
                        drink_o <= 2'b00;
                        enable_o <= 1'b1;
                        ready_o <= 1'b1;
                    end
                end
                2'b11: begin
                    if(money_i >= 6'd15) begin
                        change_o <= money_i - 6'd15;
                        drink_o <= 2'b11;
                        enable_o <= 1'b1;
                        ready_o <= 1'b1;
                    end
                    else begin
                        change_o <= money_i;
                        drink_o <= 2'b00;
                        enable_o <= 1'b1;
                        ready_o <= 1'b1;
                    end
                end
                default: begin
                        change_o <= money_i - 6'd30;
                        drink_o <= 2'b01;
                        enable_o <= 1'b1;
                        ready_o <= 1'b1;
                end
            endcase
        end
    end
end

endmodule
