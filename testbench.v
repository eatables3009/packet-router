`timescale 1ns / 1ps

module Packet_router_tb;

    // Testbench signals
    reg clk;
    reg rst;
    reg packet_valid;
    reg [19:0] Data_packet;

    wire Busy;
    wire port_valid_1;
    wire port_valid_2;
    wire port_valid_3;
    wire port_valid_4;
    wire [15:0] Packet_out_1;
    wire [15:0] Packet_out_2;
    wire [15:0] Packet_out_3;
    wire [15:0] Packet_out_4;
    wire out_valid;

    // Instantiate the DUT
    Packet_router uut (
        .clk(clk),
        .rst(rst),
        .packet_valid(packet_valid),
        .Data_packet(Data_packet),
        .Busy(Busy),
        .port_valid_1(port_valid_1),
        .port_valid_2(port_valid_2),
        .port_valid_3(port_valid_3),
        .port_valid_4(port_valid_4),
        .Packet_out_1(Packet_out_1),
        .Packet_out_2(Packet_out_2),
        .Packet_out_3(Packet_out_3),
        .Packet_out_4(Packet_out_4),
        .out_valid(out_valid)
    );

    // Clock generation: 10ns period
    always #5 clk = ~clk;

    integer passed;
    integer failed;

    initial begin
        // Initialize
        clk = 0;
        rst = 1;
        packet_valid = 0;
        Data_packet = 20'd0;
        passed = 0;
        failed = 0;
        
        // Reset sequence
        #20 rst = 0;
        #10 rst = 1;
        #10;


        // Test Case 1: Route to Port 1 (Header = 0)
        $display("Test 1: Header=0x0, Data=0xAAAA -> Expected Port 1");
        @(negedge clk);
        packet_valid = 1;
        Data_packet = 20'h0_AAAA;  // Header=0, Data=0xAAAA
        @(negedge clk);
        packet_valid = 0;
        @(posedge out_valid);
        #1;
        if (port_valid_1 && Packet_out_1 == 16'hAAAA) begin
            $display("PASS: Correctly routed to Port 1\n");
            passed = passed + 1;
        end else begin
            $display("FAIL: Routing error\n");
            failed = failed + 1;
        end
        @(negedge clk);

        // Test Case 2: Route to Port 2 (Header = 1)
        $display("Test 2: Header=0x1, Data=0x5555 -> Expected Port 2");
        @(negedge clk);
        packet_valid = 1;
        Data_packet = 20'h1_5555;  // Header=1, Data=0x5555
        @(negedge clk);
        packet_valid = 0;
        @(posedge out_valid);
        #1;
        if (port_valid_2 && Packet_out_2 == 16'h5555) begin
            $display("PASS: Correctly routed to Port 2\n");
            passed = passed + 1;
        end else begin
            $display("FAIL: Routing error\n");
            failed = failed + 1;
        end
        @(negedge clk);

        // Test Case 3: Route to Port 3 (Header = 2)
        $display("Test 3: Header=0x2, Data=0x1234 -> Expected Port 3");
        @(negedge clk);
        packet_valid = 1;
        Data_packet = 20'h2_1234;  // Header=2, Data=0x1234
        @(negedge clk);
        packet_valid = 0;
        @(posedge out_valid);
        #1;
        if (port_valid_3 && Packet_out_3 == 16'h1234) begin
            $display("PASS: Correctly routed to Port 3\n");
            passed = passed + 1;
        end else begin
            $display("FAIL: Routing error\n");
            failed = failed + 1;
        end
        @(negedge clk);

        // Test Case 4: Route to Port 4 (Header = 3)
        $display("Test 4: Header=0x3, Data=0xABCD -> Expected Port 4");
        @(negedge clk);
        packet_valid = 1;
        Data_packet = 20'h3_ABCD;  // Header=3, Data=0xABCD
        @(negedge clk);
        packet_valid = 0;
        @(posedge out_valid);
        #1;
        if (port_valid_4 && Packet_out_4 == 16'hABCD) begin
            $display("PASS: Correctly routed to Port 4\n");
            passed = passed + 1;
        end else begin
            $display("FAIL: Routing error\n");
            failed = failed + 1;
        end
        @(negedge clk);

        // Display results
        $display("===============================");
        $display("Tests Passed: %0d/4", passed);
        $display("Tests Failed: %0d/4", failed);
        $display("===============================\n");
        
        $finish;
    end

    // Generate VCD file for waveform viewing
    initial begin
        $dumpfile("Packet_router_tb.vcd");
        $dumpvars(0, Packet_router_tb);
    end

endmodule