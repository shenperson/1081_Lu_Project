module imgproc(clk,rst,orig_data,orig_ready,request,orig_addr,imgproc_ready,imgproc_addr,imgproc_data,finish);

input           clk, rst;

input [7:0]     orig_data;
input           orig_ready;

output          request;
output [13:0]   orig_addr;

output          imgproc_ready;
output [13:0]   imgproc_addr;
output [7:0]    imgproc_data;
output          finish;

// parameter declaration
parameter IDLE      = 2'd0;
parameter READ      = 2'd1;
parameter DONE      = 2'd2;

// reg / wire declaration

reg         imgproc_ready,next_imgproc_ready;
reg         request,next_request;
reg [1:0]   state , next_state;
reg [7:0]   row_count,next_row_count;
reg [7:0]   col_count,next_col_count;
reg [7:0]   imgproc_data,next_imgproc_data;
reg         finish, next_finish;
reg [13:0]  imgproc_addr,next_imgproc_addr;

assign orig_addr = {row_count,col_count[6:0] };
// combinational part
always@(*)begin
    next_col_count = col_count;
    next_row_count = row_count;
    next_state = state;
    next_imgproc_addr = imgproc_addr;
    next_finish = finish;
    next_imgproc_ready = 0;
    next_imgproc_data = 0;
    next_request = 0;
    case(state)
        IDLE: begin
            next_state = READ;
            next_request = 1;
            next_imgproc_ready = 0;
        end
        READ: begin
            if(row_count[7]==1) begin
                next_state = DONE;
                next_finish = 1;
            end
            else if(orig_ready) begin
                next_imgproc_ready = 1;
                next_imgproc_data = orig_data[7:1]+orig_data[0];
                next_request = 1;
                next_col_count = col_count[6:0]+7'd1;
                next_row_count = row_count+col_count[7];
                next_imgproc_addr = orig_addr;
            end
        end
    endcase
end

// sequential part
always@(posedge clk or posedge rst)begin
    if(rst) begin
        row_count   <= 0;
        col_count   <= 0;
        request     <= 0;
        imgproc_ready  <= 0;
        state       <= 0;
        imgproc_data   <= 0;
        finish      <= 0;
        imgproc_addr   <= 0;
    end
    else begin
        row_count   <= next_row_count;
        col_count   <= next_col_count;
        request     <= next_request;
        imgproc_ready  <= next_imgproc_ready;
        state <= next_state;
        imgproc_data   <= 0;
        finish      <= next_finish;
        imgproc_addr   <= next_imgproc_addr;
    end
end

endmodule

