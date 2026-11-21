`timescale 1ns / 1ps

module traffic_light_tb;

    reg clk = 1'b0;
    reg reset = 1'b1;
    reg enable = 1'b1;

    wire red_out;
    wire green_out;
    wire yellow_out;

    // Simulation-only parameters:
    // 4 clock cycles = 1 simulated second.
    // RED = 2 s, GREEN = 3 s, YELLOW = 1 s.
    traffic_light_controller #(
        .CLK_FREQ_HZ(4),
        .RED_SECONDS(2),
        .GREEN_SECONDS(3),
        .YELLOW_SECONDS(1)
    ) dut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .red_out(red_out),
        .green_out(green_out),
        .yellow_out(yellow_out)
    );

    // 10 ns clock period. Rising edges occur at 5, 15, 25... ns.
    always #5 clk = ~clk;

    initial begin
        $dumpfile("traffic_light.vcd");
        $dumpvars(0, traffic_light_tb);

        $display("time  clk reset enable | red green yellow");
        $monitor("%4t   %b    %b     %b    |  %b    %b     %b",
                 $time, clk, reset, enable,
                 red_out, green_out, yellow_out);

        repeat (2) @(posedge clk);
        #1 reset = 1'b0;

        // Run long enough to observe multiple complete cycles.
        repeat (60) @(posedge clk);
        #1;
        $display("Simulation finished.");
        $finish;
    end

    // Check one-hot outputs after reset is released.
    always @(posedge clk) begin
        if (!reset) begin
            if (!((red_out && !green_out && !yellow_out) ||
                  (!red_out && green_out && !yellow_out) ||
                  (!red_out && !green_out && yellow_out))) begin
                $error("Invalid traffic-light output combination at time %0t", $time);
            end
        end
    end

endmodule
