`timescale 1ns / 1ps

module traffic_light_controller #(
    parameter integer CLK_FREQ_HZ = 100_000_000,
    parameter integer RED_SECONDS = 5,
    parameter integer GREEN_SECONDS = 5,
    parameter integer YELLOW_SECONDS = 2
)(
    input  wire clk,
    input  wire reset,       // synchronous, active-high
    input  wire enable,
    output reg  red_out,
    output reg  green_out,
    output reg  yellow_out
);

    localparam [1:0] RED    = 2'b00;
    localparam [1:0] GREEN  = 2'b01;
    localparam [1:0] YELLOW = 2'b10;

    reg [1:0] state;
    reg [31:0] clk_count;
    reg [31:0] second_count;

    always @(posedge clk) begin
        if (reset) begin
            state        <= RED;
            clk_count    <= 0;
            second_count <= 0;
        end else if (enable) begin
            if (clk_count == CLK_FREQ_HZ - 1) begin
                clk_count <= 0;

                case (state)
                    RED: begin
                        if (second_count == RED_SECONDS - 1) begin
                            state        <= GREEN;
                            second_count <= 0;
                        end else begin
                            second_count <= second_count + 1;
                        end
                    end

                    GREEN: begin
                        if (second_count == GREEN_SECONDS - 1) begin
                            state        <= YELLOW;
                            second_count <= 0;
                        end else begin
                            second_count <= second_count + 1;
                        end
                    end

                    YELLOW: begin
                        if (second_count == YELLOW_SECONDS - 1) begin
                            state        <= RED;
                            second_count <= 0;
                        end else begin
                            second_count <= second_count + 1;
                        end
                    end

                    default: begin
                        state        <= RED;
                        clk_count    <= 0;
                        second_count <= 0;
                    end
                endcase
            end else begin
                clk_count <= clk_count + 1;
            end
        end
    end

    // Moore outputs: one light is active in each valid state.
    always @(*) begin
        red_out    = 1'b0;
        green_out  = 1'b0;
        yellow_out = 1'b0;

        case (state)
            RED:    red_out    = 1'b1;
            GREEN:  green_out  = 1'b1;
            YELLOW: yellow_out = 1'b1;
            default: red_out   = 1'b1;
        endcase
    end

endmodule
