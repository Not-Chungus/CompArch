`timescale 1ns/1ps

module testbench;

    // ============================================================
    // Parameters
    // ============================================================
    parameter CLK_PERIOD = 10;
    parameter MAX_CYCLES = 200; // Maximum cycles PER test

    // ============================================================
    // DUT signals and test tracking
    // ============================================================
    logic clk;
    logic rst_n;
    integer cycle_count;
    integer passed_tests;
    integer failed_tests;
    integer first_test;
    integer last_test;
    integer selected_test;
    string test_selection;

    // ============================================================
    // DUT
    // ============================================================
    MIPS_single_cycle DUT (
        .clk   (clk),
        .rst_n (rst_n),
        .out_led()
    );

    // ============================================================
    // Clock generation
    // ============================================================
    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // ============================================================
    // Run one program to PASS/FAIL or per-test timeout
    // ============================================================
    task automatic run_test(input integer test_number);
        string test_name;
        string test_mem;
        integer file_handle;
        integer i;
        integer cycles;
        bit done;
        bit passed;
        begin
            test_name = $sformatf("Test%0d", test_number);

            // The supplied programs use these exact filenames.
            case (test_number)
                1: test_mem = "../tests/Test1/Test1.mem";
                2: test_mem = "../tests/Test2/Test2.mem";
                3: test_mem = "../tests/Test3/Test3_v3.mem";
                4: test_mem = "../tests/Test4/Test4_v2.mem";
                5: test_mem = "../tests/Test5/Test5.mem";
                6: test_mem = "../tests/Test6/Test6_mul_div_v2.mem";
                default: $fatal(1, "[TB] Invalid test number: %0d", test_number);
            endcase

            $display("\n==============================================");
            $display("[TB] STARTING %s @ t = %0t", test_name,$time);
            $display("[TB] Program: %s", test_mem);
            $display("==============================================");

            // Reset the PC. Other DUT state has no reset port, so
            // the TB explicitly clears it below while clk is low.
            rst_n = 1'b0;
            repeat (2) @(posedge clk);
            @(negedge clk);

            // Clear state *after* reset clock edges, since reg_file,
            // data RAM, HI and LO do not have reset gating.
            for (i = 0; i < 32; i = i + 1)
                DUT.Reg_file.register_file[i] = 32'b0;
            for (i = 0; i < 256; i = i + 1)
                DUT.Data_mem.mem[i] = 8'b0;
            DUT.hi = 32'b0;
            DUT.lo = 32'b0;

            // Clear unused instruction memory to avoid stale bytes
            // from the previous test, then load this test's program.
            for (i = 0; i < 2048; i = i + 1)
                DUT.Instr_mem.mem[i] = 8'b0;

            file_handle = $fopen(test_mem, "r");
            if (file_handle == 0)
                $fatal(1, "[TB] Cannot open program: %s", test_mem);
            $fclose(file_handle);
            $readmemh(test_mem, DUT.Instr_mem.mem);
            $display("[TB] Instruction memory loaded.");

            // Begin execution on the NEXT rising clock edge.
            cycle_count = 0;
            rst_n = 1'b1;
            done = 1'b0;
            passed = 1'b0;

            for (cycles = 1; cycles <= MAX_CYCLES && !done; cycles = cycles + 1) begin
                @(negedge clk); // See register writes after NBA updates

                // Test1..Test6 signal PASS/FAIL in $s0 (register 16).
                // ADDI/ADDIU sign-extend D08E / DEAD, so check 16 LSBs.
                if (DUT.Reg_file.register_file[16][15:0] === 16'hD08E) begin
                    passed = 1'b1;
                    done = 1'b1;
                end
                else if (DUT.Reg_file.register_file[16][15:0] === 16'hDEAD) begin
                    done = 1'b1;
                end
            end

            if (passed) begin
                passed_tests = passed_tests + 1;
                $display("[TB] %s PASSED after %0d cycles (R16=%08h)",
                         test_name, cycles - 1, DUT.Reg_file.register_file[16]);
            end
            else begin
                failed_tests = failed_tests + 1;
                if (done)
                    $display("[TB] %s FAILED: program reached ERROR (R16=%08h)",
                             test_name, DUT.Reg_file.register_file[16]);
                else
                    $display("[TB] %s FAILED: timeout after %0d cycles (R16=%08h)",
                             test_name, MAX_CYCLES, DUT.Reg_file.register_file[16]);
            end
        end
    endtask

    // ============================================================
    // Test selection: default ALL, or +TEST=Test1..Test6
    // ============================================================
    initial begin
        rst_n = 1'b0;
        cycle_count = 0;
        passed_tests = 0;
        failed_tests = 0;
        first_test = 1;
        last_test = 6;

        if ($value$plusargs("TEST=%s", test_selection)) begin
            if (test_selection != "ALL" && test_selection != "all") begin
                if (($sscanf(test_selection, "Test%d", selected_test) != 1) ||
                    (selected_test < 1) || (selected_test > 6))
                    $fatal(1, "[TB] Use +TEST=ALL or +TEST=Test1..Test6");
                first_test = selected_test;
                last_test  = selected_test;
            end
        end

        $display("[TB] Running tests %0d through %0d", first_test, last_test);
        for (integer test_number = first_test;
             test_number <= last_test; test_number = test_number + 1) begin
            run_test(test_number);
        end

        $display("\n==============================================");
        $display("             FINAL TEST SUMMARY");
        $display("       PASSED: %0d     FAILED: %0d", passed_tests, failed_tests);
        $display("==============================================");
        if (failed_tests != 0)
            $fatal(1, "[TB] Some tests failed.");
        $finish;
    end

    // ============================================================
    // Processor monitor: sample just BEFORE active rising edge
    // so register and memory write controls describe that edge.
    // All signal names below exist in the supplied TOP.sv.
    // ============================================================
    always @(posedge clk) begin
        if (rst_n) begin
            cycle_count <= cycle_count + 1;
            $display("[Cycle %0d] PC=%08h INST=%08h ALU_Result=%08h",
                     cycle_count + 1, DUT.pc, DUT.instruction, DUT.alu_result);

            if (DUT.reg_write && DUT.reg_to_write_to != 5'd0)
                $display("           REG WRITE: R[%0d] <= %08h",
                         DUT.reg_to_write_to, DUT.Reg_WData);

            if (DUT.mem_write)
                $display("           MEM WRITE: MEM[%08h] <= %08h",
                         DUT.alu_result, DUT.rt);

            if (DUT.pc_src == 2'b01)
                $display("           BRANCH TAKEN -> %08h  @%0t", DUT.pc_next,$time);

            if (DUT.pc_src == 2'b10 || DUT.pc_src == 2'b11)
                $display("           JUMP -> %08h  @%0t", DUT.pc_next,$time);
        end
        else begin
            cycle_count <= 0;
        end
    end

endmodule
