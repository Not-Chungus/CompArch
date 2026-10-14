`timescale 1ns/1ps

module testbench;

    // ============================================================
    // Parameters
    // ============================================================
    parameter CLK_PERIOD = 10;
    parameter MAX_CYCLES = 200;

    // ============================================================
    // DUT signals
    // ============================================================
    logic clk;
    logic rst_n;

    // ============================================================
    // Test selection
    // ============================================================
    string test_name;
    string test_mem;

    integer cycle_count;


    // ============================================================
    // DUT
    // ============================================================
    MIPS_single_cycle DUT (
        .clk   (clk),
        .rst_n (rst_n)
    );


    // ============================================================
    // Clock generation
    // ============================================================
    initial begin
        clk = 1'b0;

        forever #(CLK_PERIOD/2)
            clk = ~clk;
    end


    // ============================================================
    // Test selection
    // Example:
    // make run TEST=Test1
    // produces:
    // ../tests/Test1/Test1.mem
    // ============================================================

    initial begin

        if (!$value$plusargs("TEST=%s", test_name)) begin
            test_name = "Test1";

            $display(
                "[TB] No +TEST specified. Defaulting to %s",
                test_name
            );
        end

        test_mem = {
            "../tests/",
            test_name,
            "/",
            test_name,
            ".mem"
        };

        $display("");
        $display("==============================================");
        $display("      MIPS SINGLE-CYCLE PROCESSOR TEST");
        $display("==============================================");
        $display(" Test name   : %s", test_name);
        $display(" Program file: %s", test_mem);
        $display("==============================================");
        $display("");

    end


    // ============================================================
    // Load Instruction Memory
    // ============================================================

    initial begin

        // Wait until test_name/test_mem have been constructed
        #1;

        $display("[TB] Loading instruction memory from: %s",test_mem);
        $readmemh(test_mem,DUT.Instr_mem.mem);
        $display("[TB] Instruction memory loaded.");

    end


    // ============================================================
    // Reset
    // ============================================================

    initial begin

        rst_n = 1'b0;
        // Hold reset for two clock cycles
        repeat (2)
            @(posedge clk);

        @(negedge clk);
        rst_n = 1'b1;

        $display("[TB] Reset released at time %0t",$time);
    end


    // ============================================================
    // Cycle counter
    // ============================================================

    initial begin
        cycle_count = 0;
    end

    always @(posedge clk) begin

        if (!rst_n) begin
            cycle_count <= 0;
        end
        else begin
            cycle_count <= cycle_count + 1;
        end

    end


    // ============================================================
    // Processor Monitor
    // ============================================================
    
    always @(negedge clk) begin

        if (rst_n) begin

            $display(
                "[Cycle %0d] PC=%08h  INST=%08h  ALU_Result=%08h",
                cycle_count,
                DUT.pc,
                DUT.instruction,
                DUT.alu_result
            );

        end

    end


    // ============================================================
    // Register Write Monitor
    // ============================================================

    always @(negedge clk) begin

        if (rst_n && DUT.reg_write) begin

            $display(
                "          REG WRITE : R[%0d] <= %08h",
                DUT.reg_to_write_to,
                DUT.Reg_WData
            );

        end

    end


    // ============================================================
    // Memory Write Monitor
    // ============================================================

    always @(negedge clk) begin

        if (rst_n && DUT.mem_write) begin

            $display(
                "          MEM WRITE : MEM[%08h] <= %08h",
                DUT.alu_result,
                DUT.rt_data
            );

        end

    end


    // ============================================================
    // Branch Monitor
    // ============================================================

    always @(negedge clk) begin

        if (rst_n && DUT.branch) begin

            if (DUT.zero_flag) begin

                $display(
                    "          BRANCH TAKEN -> %08h",
                    DUT.pc_branch
                );

            end
            else begin

                $display(
                    "          BRANCH NOT TAKEN"
                );

            end

        end

    end


    // ============================================================
    // Jump Monitor
    // ============================================================

    always @(negedge clk) begin

        if (rst_n && DUT.jump) begin

            $display(
                "          JUMP -> %08h",
                DUT.pc_next
            );

        end

    end


    // ============================================================
    // Timeout Protection
    //
    // Prevent simulation from running forever.
    // ============================================================

    initial begin

        wait(rst_n == 1'b1);

        repeat (MAX_CYCLES)
            @(posedge clk);

        $display("");
        $display("==============================================");
        if(DUT.Reg_file.register_file[16][15:0] == 16'hD08E)
        $display(" TEST PASSED");
        else
        $display(" TEST FAILED");
        $display("==============================================");

        $stop;

    end



endmodule