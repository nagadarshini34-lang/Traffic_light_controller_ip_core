# TRAFFIC LIGHT CONTROLLER IP CORE
### Verilog HDL | FSM Design | Vivado Simulation | FPGA Implementation

**Project:** Traffic Light Controller using a Finite State Machine (FSM)  
**Design tool:** Xilinx Vivado  
**Target board reference:** Nexys A7 / Artix-7 (confirm the exact board part before implementation)

---

## 1. Project Overview

This project implements a three-light traffic controller using Verilog HDL. The controller repeatedly operates in this order:

**RED → GREEN → YELLOW → RED**

The design uses:
- A finite state machine (FSM) to select the traffic-light state.
- A clock divider to create one-second timing ticks from the FPGA clock.
- A state timer to control how long each light remains active.
- Active-high output signals for the red, green and yellow LEDs.

### Default hardware timing

The default parameters assume a 100 MHz FPGA clock:

| Parameter | Default value | Meaning |
|---|---:|---|
| `CLK_FREQ` | 100,000,000 | Clock cycles per second |
| `RED_TIME` | 10 | Red duration in seconds |
| `GREEN_TIME` | 10 | Green duration in seconds |
| `YELLOW_TIME` | 3 | Yellow duration in seconds |

The testbench overrides these parameters with smaller values to make simulation faster. The shortened simulation timing is not the real board timing.

---

## 2. Input and Output Signals

| Signal | Direction | Description |
|---|---|---|
| `clock_in` | Input | FPGA system clock |
| `reset_in` | Input | Active-high asynchronous reset |
| `enable_in` | Input | Enables the traffic-light sequence |
| `red_out` | Output | Red LED control |
| `green_out` | Output | Green LED control |
| `yellow_out` | Output | Yellow LED control |

---

## 3. Complete Verilog RTL Code

Save this code as **`traffic_light_controller.v`** in Vivado Design Sources.

```verilog
module traffic_light_controller #(
    parameter integer CLK_FREQ    = 100_000_000,
    parameter integer RED_TIME    = 10,
    parameter integer GREEN_TIME  = 10,
    parameter integer YELLOW_TIME = 3
)(
    input  wire clock_in,
    input  wire reset_in,
    input  wire enable_in,
    output reg  red_out,
    output reg  green_out,
    output reg  yellow_out
);

    // FSM state encoding
    localparam [1:0] RED    = 2'b00;
    localparam [1:0] GREEN  = 2'b01;
    localparam [1:0] YELLOW = 2'b10;

    reg [1:0]  state;
    reg [31:0] divider_count;
    reg [31:0] second_count;
    reg [31:0] state_duration;

    // Clock divider, state timer and FSM register.
    // Sequential updates occur on posedge clock_in.
    always @(posedge clock_in or posedge reset_in) begin
        if (reset_in) begin
            divider_count <= 0;
            second_count  <= 0;
            state         <= RED;
        end
        else if (enable_in) begin
            if (divider_count == CLK_FREQ - 1) begin
                divider_count <= 0;

                if (second_count == state_duration - 1) begin
                    second_count <= 0;

                    case (state)
                        RED:       state <= GREEN;
                        GREEN:     state <= YELLOW;
                        YELLOW:    state <= RED;
                        default:   state <= RED;
                    endcase
                end
                else begin
                    second_count <= second_count + 1;
                end
            end
            else begin
                divider_count <= divider_count + 1;
            end
        end
        else begin
            divider_count <= 0;
        end
    end

    // Select the duration for the current state.
    always @(*) begin
        case (state)
            RED:       state_duration = RED_TIME;
            GREEN:     state_duration = GREEN_TIME;
            YELLOW:    state_duration = YELLOW_TIME;
            default:   state_duration = RED_TIME;
        endcase
    end

    // Active-high output decoder.
    always @(*) begin
        red_out    = (state == RED);
        green_out  = (state == GREEN);
        yellow_out = (state == YELLOW);
    end

endmodule
```

---

## 4. Complete Verilog Testbench

Save this code as **`traffic_light_tb.v`** in Vivado Simulation Sources. Set `traffic_light_tb` as the simulation top.

```verilog
`timescale 1ns / 1ps

module traffic_light_tb;

    reg clock_in;
    reg reset_in;
    reg enable_in;

    wire red_out;
    wire green_out;
    wire yellow_out;

    // Reduced values make the simulation complete quickly.
    localparam integer PERIOD = 10;

    traffic_light_controller #(
        .CLK_FREQ(PERIOD),
        .RED_TIME(2),
        .GREEN_TIME(2),
        .YELLOW_TIME(1)
    ) dut (
        .clock_in(clock_in),
        .reset_in(reset_in),
        .enable_in(enable_in),
        .red_out(red_out),
        .green_out(green_out),
        .yellow_out(yellow_out)
    );

    // 10 ns clock period.
    // Positive edges occur at 5, 15, 25, 35 ns, and so on.
    initial begin
        clock_in = 1'b0;
    end

    always #5 clock_in = ~clock_in;

    // Apply reset, enable the controller and run the simulation.
    initial begin
        reset_in  = 1'b1;
        enable_in = 1'b0;

        #20;
        reset_in  = 1'b0;
        enable_in = 1'b1;

        #1800;
        $finish;
    end

    // Print signal values in the simulator console.
    initial begin
        $monitor(
            "time=%0t clk=%b reset=%b enable=%b RED=%b GREEN=%b YELLOW=%b",
            $time, clock_in, reset_in, enable_in,
            red_out, green_out, yellow_out
        );
    end

endmodule
```

---

## 5. Expected Simulation Output

The following table describes the expected output for the **testbench parameter values** (`CLK_FREQ=10`, `RED_TIME=2`, `GREEN_TIME=2`, `YELLOW_TIME=1`).

Reset is released at 20 ns. The first active positive clock edge is at 25 ns. The first timing tick occurs after ten enabled positive edges.

| Approximate simulation interval | `red_out` | `green_out` | `yellow_out` | Active signal |
|---|---:|---:|---:|---|
| Reset asserted | 1 | 0 | 0 | RED |
| 20 ns to 215 ns | 1 | 0 | 0 | RED |
| 215 ns to 415 ns | 0 | 1 | 0 | GREEN |
| 415 ns to 515 ns | 0 | 0 | 1 | YELLOW |
| 515 ns to 715 ns | 1 | 0 | 0 | RED |
| 715 ns to 915 ns | 0 | 1 | 0 | GREEN |
| 915 ns to 1015 ns | 0 | 0 | 1 | YELLOW |

The sequence repeats while `enable_in` remains high. Exact transition times are determined by the positive clock edges and the counter values.

### Expected output sequence

```text
RED       GREEN       YELLOW       RED
1 0 0  -> 0 1 0  ->   0 0 1  ->  1 0 0
```

### Expected waveform signal list

Add these signals to the Vivado waveform window:

1. `clock_in`
2. `reset_in`
3. `enable_in`
4. `red_out`
5. `green_out`
6. `yellow_out`

The clock is a 10 ns period signal in this testbench. Its positive edges (`posedge clock_in`) occur at 5 ns, 15 ns, 25 ns, 35 ns, and subsequent 10 ns intervals. The FSM and counters update on these positive edges.

---

## 6. How to Run the Simulation in Vivado

1. Open Xilinx Vivado.
2. Select **Create Project** and create an RTL project.
3. Add `traffic_light_controller.v` under **Design Sources**.
4. Add `traffic_light_tb.v` under **Simulation Sources**.
5. Set `traffic_light_tb` as the simulation top.
6. Select **Run Simulation → Run Behavioral Simulation**.
7. Add `clock_in`, `reset_in`, `enable_in`, `red_out`, `green_out` and `yellow_out` to the waveform.
8. Select **Run All** or run for a suitable simulation duration.
9. Select **Zoom Fit** to view the complete waveform.
10. Check that the outputs follow RED → GREEN → YELLOW → RED.

---

## 7. Expected RTL Architecture

```text
       clock_in     reset_in     enable_in
           |            |            |
           +------------+------------+
                        |
                +----------------+
                | Clock Divider  |
                +----------------+
                        |
                +----------------+
                |  State Timer   |
                +----------------+
                        |
                +----------------+
                |  FSM Register  |
                | RED/GREEN/     |
                | YELLOW         |
                +----------------+
                        |
                +----------------+
                | Output Decoder |
                +----------------+
                   |     |     |
                  RED  GREEN YELLOW
```

The state register and counters are sequential elements updated on the positive edge of `clock_in`. The output decoder generates the three active-high lamp outputs based on the current FSM state.

---

## 8. Vivado IP Core Packaging

To package this RTL as a reusable custom IP:

1. Open the RTL project containing `traffic_light_controller.v`.
2. Select **Tools → Create and Package New IP**.
3. Select **Package your current project**.
4. Enter the IP name `Traffic_Light_Controller_IP`.
5. Set the version to `1.0`.
6. Review the ports: `clock_in`, `reset_in`, `enable_in`, `red_out`, `green_out`, `yellow_out`.
7. Select **Review and Package**.
8. Add the packaged IP directory to the project's IP Repository.
9. Open IP Catalog and verify that the custom IP appears.

---

## 9. FPGA Board Implementation

The supplied board reference appears to be a Nexys A7. Verify the exact board revision and FPGA part before implementation.

| Controller signal | Suggested board connection |
|---|---|
| `clock_in` | 100 MHz board clock |
| `reset_in` | User push-button or switch |
| `enable_in` | User switch |
| `red_out` | One user LED |
| `green_out` | One user LED |
| `yellow_out` | One user LED |

### Implementation steps

1. Add the official master XDC file for the exact FPGA board.
2. Map `clock_in` to the board clock and apply the correct clock constraint.
3. Map reset and enable to suitable board inputs.
4. Map the three lamp outputs to three user LEDs.
5. Run **Synthesis**.
6. Run **Implementation**.
7. Review timing and DRC reports.
8. Select **Generate Bitstream**.
9. Open **Hardware Manager**.
10. Connect to the FPGA and select **Program Device**.
11. Test the traffic-light sequence.

**Pin assignment warning:** Do not guess FPGA package pins. Use the official master XDC for the exact board revision. The board reference photo alone is not sufficient to verify package pin locations.

---

## 10. GitHub Repository Checklist

Recommended repository structure:

```text
Traffic-Light-Controller-IP-Core/
│
├── README.md
├── RTL/
│   └── traffic_light_controller.v
├── Simulation/
│   └── traffic_light_tb.v
├── Constraints/
│   └── board_constraints.xdc
├── Documentation/
│   ├── FSM_State_Diagram.pdf
│   └── System_Block_Diagram.pdf
└── Results/
    ├── vivado_waveform.png
    ├── rtl_schematic.png
    ├── ip_block_design.png
    └── fpga_board_output.jpg
```

Upload genuine Vivado simulation and implementation screenshots to the `Results` folder after generating them.

---

## 11. Important Verification Notes

- The RTL and testbench above are the complete source examples for this design.
- The testbench uses reduced timing parameters for faster simulation.
- The default hardware parameters assume a 100 MHz clock.
- `posedge clock_in` is used for sequential state and counter updates.
- The output signals are active-high and one-hot: only one traffic lamp is active in a valid FSM state.
- The expected output table is a predicted simulation result, not a captured simulator log.
- A bitstream must be generated in Vivado for the exact target FPGA before claiming successful hardware implementation.
- Add your own name, register number, institution, actual waveform screenshot and actual board result before final submission.

**Project title:** Traffic Light Controller IP Core using Verilog HDL  
**Tools:** Xilinx Vivado, Verilog HDL, Vivado Simulator  
**Main concept:** Finite State Machine, Clock Divider, Counter and FPGA Implementation
