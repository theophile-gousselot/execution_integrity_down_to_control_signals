`timescale 1ns / 1ps

module core_v_verif_fpga_tb ();
	logic              clk_nexys_board_s = 0;
	logic              rst_sw_s;
	logic [7:0]        led_s;

	//logic              enable_verif_illegal_instr_s;
    
    int unsigned       maxcycles_int = 20000000;
    int unsigned       clk_nexys_board_cyc_cnt_int = 0;
    int unsigned       clk_core_slow_cyc_cnt_int = 0;
    int unsigned       stop_sim_cnt = 20;
 
    // CLOCK GENERATOR
    always
    begin
        #5 clk_nexys_board_s = 0;
        #5 clk_nexys_board_s = 1;
    end

    always_ff @(posedge core_v_verif_fpga_top_i.clk_core_slow_s) begin
        if (core_v_verif_fpga_top_i.rst_synch_s == 1'b0) begin
            clk_core_slow_cyc_cnt_int <= clk_core_slow_cyc_cnt_int + 1;
        end else begin
            clk_core_slow_cyc_cnt_int <= 0;
        end
    end


    // RESET GENERATOR
    assign rst_sw_s = (clk_nexys_board_cyc_cnt_int > 500) ? 1'b0 : 1'b1;


    // SIMULATION TIME OUT
    always_ff @(posedge clk_nexys_board_s) begin
        clk_nexys_board_cyc_cnt_int <= clk_nexys_board_cyc_cnt_int + 1;
        if (clk_nexys_board_cyc_cnt_int >= maxcycles_int) begin
			$display("%m @ %0t ps / %0d cycles: MAXIMUM CYCLE LIMIT", $time, clk_nexys_board_cyc_cnt_int);
            $finish;
		end
    end


    // SIMULATION END
    //assign enable_verif_illegal_instr_s = (clk_core_slow_cyc_cnt_int > 6) ? 1'b1 : 1'b0;
    always_ff @(posedge clk_nexys_board_s) begin
        if (led_s[5]) begin
            stop_sim_cnt = stop_sim_cnt - 1;
            if (stop_sim_cnt == 0) begin 
                $display("%m @ %0t ps / %0d cycles: EXIT ILLEGAL INSN DECODE", $time, clk_nexys_board_cyc_cnt_int);
                $finish;
            end
		end else begin
            if (led_s[6]) begin
                stop_sim_cnt = stop_sim_cnt - 1;
                if (stop_sim_cnt == 0) begin 
                    $display("%m @ %0t ps / %0d cycles: EXIT VALID EXECUTION", $time, clk_nexys_board_cyc_cnt_int);
                    $finish;
                end
            end
		end
    end
    
    // DUT
    core_v_verif_fpga_top core_v_verif_fpga_top_i (
        .clk_nexys_board_i(clk_nexys_board_s),
        .rst_sw_i(rst_sw_s),
        .led_o(led_s)
    );

endmodule
