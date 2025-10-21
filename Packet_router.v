`timescale 1ns / 1ps


module Packet_router(
input wire clk,
input wire rst,
input wire packet_valid,
input wire [19:0] Data_packet,
output reg Busy,
output reg port_valid_1,
output reg port_valid_2,
output reg port_valid_3,
output reg port_valid_4,
output reg [15:0] Packet_out_1,
output reg [15:0] Packet_out_2,
output reg [15:0] Packet_out_3,
output reg [15:0] Packet_out_4,
output reg out_valid
    );

    // Enter your Verilog code here 
    localparam IDLE  = 2'd0;
localparam ROUTE = 2'd1;
localparam DONE  = 2'd2;

reg [1:0] state, next_state;


reg        fifo_wr_en;
reg        fifo_rd_en;
wire [19:0] fifo_dout;
wire       fifo_full;
wire       fifo_empty;


FIFO #(
    .DATA_WIDTH(20),
    .DEPTH(32)
) fifo_inst (
    .clk  (clk),
    .rst  (rst),
    .wr_en(fifo_wr_en),
    .rd_en(fifo_rd_en),
    .din  (Data_packet),
    .dout (fifo_dout),
    .full (fifo_full),
    .empty(fifo_empty)
);


reg [3:0]  lat_header;
reg [15:0] lat_payload;


always @(*) begin
   
    fifo_wr_en = (packet_valid && !fifo_full) ? 1'b1 : 1'b0;
end


always @(posedge clk or negedge rst) begin
    if (!rst) begin
        state <= IDLE;
    end else begin
        state <= next_state;
    end
end


always @(*) begin
   
    next_state = state;
    fifo_rd_en = 1'b0;

    
    case (state)
        IDLE: begin
            if (!fifo_empty) begin
                
                fifo_rd_en = 1'b1;
                next_state = ROUTE;
            end else begin
                fifo_rd_en = 1'b0;
                next_state = IDLE;
            end
        end
        ROUTE: begin
           
            next_state = DONE;
        end
        DONE: begin
           
            next_state = IDLE;
        end
        default: next_state = IDLE;
    endcase
end


always @(posedge clk or negedge rst) begin
    if (!rst) begin
       
        Busy         <= 1'b0;
        port_valid_1 <= 1'b0;
        port_valid_2 <= 1'b0;
        port_valid_3 <= 1'b0;
        port_valid_4 <= 1'b0;
        Packet_out_1 <= 16'd0;
        Packet_out_2 <= 16'd0;
        Packet_out_3 <= 16'd0;
        Packet_out_4 <= 16'd0;
        out_valid    <= 1'b0;
        lat_header   <= 4'd0;
        lat_payload  <= 16'd0;
    end else begin
        
        out_valid    <= 1'b0;
        port_valid_1 <= 1'b0;
        port_valid_2 <= 1'b0;
        port_valid_3 <= 1'b0;
        port_valid_4 <= 1'b0;
        Packet_out_1 <= Packet_out_1;
        Packet_out_2 <= Packet_out_2;
        Packet_out_3 <= Packet_out_3;
        Packet_out_4 <= Packet_out_4;
        Busy         <= 1'b0;

        case (state)
            IDLE: begin
               
                Busy <= 1'b0;
                
            end

            ROUTE: begin
               
                lat_header  <= fifo_dout[19:16];
                lat_payload <= fifo_dout[15:0];

                
                case (fifo_dout[1:0])
                    2'b00: begin
                        port_valid_1 <= 1'b1;
                        Packet_out_1 <= fifo_dout[15:0];
                    end
                    2'b01: begin
                        port_valid_2 <= 1'b1;
                        Packet_out_2 <= fifo_dout[15:0];
                    end
                    2'b10: begin
                        port_valid_3 <= 1'b1;
                        Packet_out_3 <= fifo_dout[15:0];
                    end
                    2'b11: begin
                        port_valid_4 <= 1'b1;
                        Packet_out_4 <= fifo_dout[15:0];
                    end
                endcase

                Busy <= 1'b1;
                out_valid <= 1'b0;
            end

            DONE: begin
                
                out_valid <= 1'b1;
                Busy <= 1'b0;

               
                case (lat_header[1:0])
                    2'b00: begin
                        port_valid_1 <= 1'b1;
                        Packet_out_1 <= lat_payload;
                    end
                    2'b01: begin
                        port_valid_2 <= 1'b1;
                        Packet_out_2 <= lat_payload;
                    end
                    2'b10: begin
                        port_valid_3 <= 1'b1;
                        Packet_out_3 <= lat_payload;
                    end
                    2'b11: begin
                        port_valid_4 <= 1'b1;
                        Packet_out_4 <= lat_payload;
                    end
                endcase
            end

            default: begin
                Busy <= 1'b0;
            end
        endcase
    end
end
endmodule







module FIFO #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 16,
    parameter ADDR_WIDTH = $clog2(DEPTH)
)(
    input wire clk,
    input wire rst,
    input wire wr_en,
    input wire rd_en,
    input wire [DATA_WIDTH-1:0] din,
    output reg [DATA_WIDTH-1:0] dout,
    output reg full,
    output reg empty
);

    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    reg [ADDR_WIDTH-1:0] rd_ptr, wr_ptr;
    reg [ADDR_WIDTH:0] count; 

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            wr_ptr <= 0;
        end else if (wr_en && !full) begin
            mem[wr_ptr] <= din;
            wr_ptr <= wr_ptr + 1;
        end
    end

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            rd_ptr <= 0;
            dout <= 0;
        end else if (rd_en && !empty) begin
            dout <= mem[rd_ptr];
            rd_ptr <= rd_ptr + 1;
        end
    end


    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            count <= 0;
        end else begin
            case ({wr_en && !full, rd_en && !empty})
                2'b10: count <= count + 1; 
                2'b01: count <= count - 1; 
                default: count <= count;   
            endcase
        end
    end

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            full <= 0;
            empty <= 1;
        end else begin
            full  <= (count == DEPTH);
            empty <= (count == 0);
        end
    end

endmodule