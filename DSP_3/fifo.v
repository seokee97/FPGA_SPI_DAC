`timescale 1ns / 1ps
module fifo(
    input wire clk,
    input wire rst,
    input wire write_en,
    input wire read_en,
    input wire [9:0] data_in,
    output reg [9:0] data_out,
    output reg full,
    output reg empty
);
    parameter DEPTH = 16;
    reg [9:0] buffer[DEPTH-1:0];
    reg [4:0] w_ptr = 0;  // Write pointer
    reg [4:0] r_ptr = 0;  // Read pointer
    reg [5:0] count = 0;  // Count of items in the FIFO

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            w_ptr <= 0;
            r_ptr <= 0;
            count <= 0;
            empty <= 1;
            full <= 0;
        end else begin
            // Writing to FIFO
            if (write_en && !full) begin
                buffer[w_ptr] <= data_in;
                if (w_ptr == DEPTH-1) begin
                    w_ptr <= 0;  // Wrap around
                end else begin
                    w_ptr <= w_ptr + 1;
                end
                count <= count + 1;
                empty <= 0;  // FIFO is not empty when we write
            end

            // Reading from FIFO
            if (read_en && !empty) begin
                data_out <= buffer[r_ptr];
                if (r_ptr == DEPTH-1) begin
                    r_ptr <= 0;  // Wrap around
                end else begin
                    r_ptr <= r_ptr + 1;
                end
                count <= count - 1;
                if (count == 1) begin
                    empty <= 1;  // Set empty if this is the last read
                end
            end

            // Full condition
            full <= (count == DEPTH);

            // Empty condition is already handled in the read section
        end
    end
endmodule