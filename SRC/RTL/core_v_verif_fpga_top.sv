`timescale 1ns / 1ps

module core_v_verif_fpga_top
`ifdef ENCRYPT
    # (
        parameter HW_PERMUTATION_N = `HW_PERMUTATION_N 
    )
`endif
    (
        input logic         clk_nexys_board_i,
        input logic         rst_sw_i,
        output logic [7:0]  led_o
    );

    // Extra clk_outs set toe to avoid Error on unsued MMCM output clks in post-impl timing simu
    (* dont_touch = "yes" *) logic           clk_out3;
    (* dont_touch = "yes" *) logic           clk_out4;
    (* dont_touch = "yes" *) logic           clk_out5;
    (* dont_touch = "yes" *) logic           clk_out6;
    (* dont_touch = "yes" *) logic           clk_out7;

    logic           clk_core_slow_s;
    logic           clk_ascon_fast_s;
    logic           mmcm_clks_locked_s;
    logic           rst_s;
    logic           rst_synch_s = 0;

    logic [3:0]     rst_cnt_s = 15;

    // RESET DISABLE WHEN MMCM READY
    assign rst_s = !(!rst_sw_i & mmcm_clks_locked_s);
    always_ff @(posedge clk_core_slow_s, posedge rst_s) begin
        if (rst_s) begin
            rst_cnt_s <= 4'b1111;
            rst_synch_s <= 1'b1;
        end else begin
            if (rst_cnt_s == 0) begin
                rst_synch_s <= 1'b0;
            end else begin
                rst_cnt_s <= rst_cnt_s - 4'b1;
                rst_synch_s <= 1'b1;
            end
        end
    end


    // CLOCK WIZARD: MMCM
    clk_wiz_0 clk_wiz_0_i
    (
        .clk_nexys_board_i(clk_nexys_board_i),
        .clk_core_slow_o(clk_core_slow_s),
        .clk_ascon_fast_o(clk_ascon_fast_s),
        .clk_out3(clk_out3),     // output clk_out3 (enable to avoid Error on unused MMCM output clks in post-impl timing simu)
        .clk_out4(clk_out4),     // output clk_out4 (enable to avoid Error on unused MMCM output clks in post-impl timing simu)
        .clk_out5(clk_out5),     // output clk_out5 (enable to avoid Error on unused MMCM output clks in post-impl timing simu)
        .clk_out6(clk_out6),     // output clk_out6 (enable to avoid Error on unused MMCM output clks in post-impl timing simu)
        .clk_out7(clk_out7),     // output clk_out7 (enable to avoid Error on unused MMCM output clks in post-impl timing simu)
        .reset(rst_sw_i), // input reset
        .mmcm_clks_locked_o(mmcm_clks_locked_s));



    core_v_verif_fpga #(
`ifdef ENCRYPT
        .HW_PERMUTATION_N(HW_PERMUTATION_N)
`endif
	) core_v_verif_fpga_i (
        .clk_core_slow_i(clk_core_slow_s),
        .clk_ascon_fast_i(clk_ascon_fast_s),
        .rst_i(rst_synch_s),
        .led_o(led_o)
    );
endmodule
