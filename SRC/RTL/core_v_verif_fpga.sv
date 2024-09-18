`timescale 1ns / 1ps

`ifdef ENCRYPT
`include "macro_def.sv"
`endif

module core_v_verif_fpga
`ifdef ENCRYPT
# (
    parameter HW_PERMUTATION_N = 6
)
`endif
    (
    input logic clk_core_slow_i,
    input logic clk_ascon_fast_i,
    input logic rst_i,
    output logic [7:0] led_o   
);

    localparam INSTR_RDATA_WIDTH      = 32;
    localparam PROGRAM_MEM_ADDR_WIDTH = 17;
    localparam BOOT_ADDR              = 'h80;
    localparam FIFO_DEPTH             = 2; //must be greater or equal to 2 
    localparam int unsigned FIFO_ADDR_DEPTH = (FIFO_DEPTH > 1) ? $clog2(FIFO_DEPTH) : 1;
    localparam PATCH_WIDTH            = 320;

`ifdef ENCRYPT
    localparam PB_ROUNDS              = 6;
    localparam PATCH_MEM_ADDR_WIDTH   = 16;
`endif


    // RESET
`ifdef ENCRYPT
	logic [2:0]   rst_n_cnt_s = 0;
    logic        is_illegal_insn_from_last_rst_s = 0;
`endif
    logic         rst_n;

    // INSTR READ
    logic         instr_req_s;
    reg [31:0]    instr_addr_s/*verilator public*/;
    logic         instr_rvalid_s;
    logic [31:0]  instr_rdata_s/*verilator public*/;
    logic         instr_gnt_s;

    // DATA READ/WRITE
    logic         data_req_s;
    logic [31:0]  data_addr_s;
    logic         data_we_s;
    logic [3:0]   data_be_s;
    logic [31:0]  data_wdata_s;
    logic [31:0]  data_rdata_s;
    logic         data_rvalid_s;
    logic         data_gnt_s;

    // EXIT
    logic         exit_valid_s;
    logic [31:0]  exit_value_s;
    logic [31:0]  exit_value_mem_s;
    logic         exit_valid_mem_s/*verilator public*/;

`ifdef ENCRYPT
    // Control Signals: core to ascon_datapath
	logic        fifo_push_s;
	logic        fifo_pop_s;
	logic [FIFO_ADDR_DEPTH-1:0]  fifo_read_pointer_s;
	logic [FIFO_ADDR_DEPTH-1:0]  fifo_write_pointer_s;
	logic        instr_valid_if_s;
	logic        if_valid_s;
	logic        id_valid_s;
	logic        lsu_data_misaligned_s;
	logic        mult_multicycle_s;
    logic        aligner_update_state_s;

    logic        illegal_insn_dec_s;

    // Control Signals: core to ascon_fsm
	logic [1:0]  ctrl_transfer_insn_in_id_s;
	logic        branch_in_ex_s;
	logic        branch_decision_s;
	logic        pc_set_s;

    logic [31:0] prefetch_instr_rdata_cipher_s;
/* verilator lint_off UNOPTFLAT */
    logic [31:0] ascon_instr_rdata_plain_s;
/* verilator lint_on UNOPTFLAT */

    // Control Signals: core to ascon_fsm
    logic [PATCH_MEM_ADDR_WIDTH-1:0] patch_addr_s;
    logic [PATCH_WIDTH + 2*`CS_WB_WIDTH + `CS_EX_WIDTH - 1:0]          patch_s;
`ifdef CS
    logic [`CS_WIDTH-1:0] cs_vector_s;
`endif
//`ifdef CS_EX
//    logic dec_alu_en_s;
//`endif
`endif


    // RESET
    assign rst_n = !rst_i;

    // LEDs
`ifdef ENCRYPT
    always_ff @(posedge clk_core_slow_i, negedge rst_n) begin
        if (rst_n == 1'b0) begin
			rst_n_cnt_s <= 3'b0;
			is_illegal_insn_from_last_rst_s  <= 1'b0;
        end else begin
            if (rst_n_cnt_s < 3'h7) begin
				rst_n_cnt_s <= rst_n_cnt_s + 1;
				is_illegal_insn_from_last_rst_s  <= 1'b0;
			end
            if (rst_n_cnt_s == 3'h7) begin
				if (illegal_insn_dec_s == 1'b1) begin
					is_illegal_insn_from_last_rst_s  <= 1'b1;
				end
			end
        end
    end
`endif

`ifdef ENCRYPT
    assign led_o[3:0] = instr_addr_s[15:12] ^ instr_addr_s[11:8] ^ instr_addr_s[7:4] ^ {instr_addr_s[3:2], 2'b00};
    assign led_o[4] = 1'h0;
    assign led_o[5] = (is_illegal_insn_from_last_rst_s) ? 1'b1 : 1'b0;
`else
    assign led_o[4:0] = 5'h0;
    assign led_o[5] = 1'b0; 
`endif
    assign led_o[6] = (exit_valid_s) ?  1'b1 : 1'b0;
    assign led_o[7] = (rst_n) ? 1'b0 : 1'b1;


    // EXIT
    assign exit_value_s = exit_value_mem_s;
    always_ff @(posedge clk_core_slow_i, negedge rst_n) begin
        if (rst_n == 1'b0) begin
            exit_valid_s <= 1'b0;
        end else begin
            if (exit_valid_mem_s) begin
                exit_valid_s <= 1'b1;
            end
        end
    end




    ////////////////////////////////
    //    ____ ___  ____  _____   //
    //   / ___/ _ \|  _ \| ____|  //
    //  | |  | | | | |_) |  _|    //
    //  | |__| |_| |  _ <| |___   //
    //   \____\___/|_| \_\_____|  //
    //                            //
    ////////////////////////////////

    cv32e40p_core #(
        .FIFO_DEPTH       (FIFO_DEPTH),
        .FIFO_ADDR_DEPTH  (FIFO_ADDR_DEPTH),
        .PULP_XPULP       (0),
        .PULP_CLUSTER     (0),
        .FPU              (0),
        .PULP_ZFINX       (0),
        .NUM_MHPMCOUNTERS (1)
    ) cv32e40p_core_i (
        .clk_i                      (clk_core_slow_i),
        .rst_ni                     (rst_n),

`ifdef ENCRYPT
        .fifo_push_o                (fifo_push_s),
        .fifo_pop_o                 (fifo_pop_s),
        .fifo_read_pointer_o        (fifo_read_pointer_s),
        .fifo_write_pointer_o       (fifo_write_pointer_s),
        .instr_valid_if_o           (instr_valid_if_s),
        .if_valid_o                 (if_valid_s),
        .id_valid_o                 (id_valid_s),
        .lsu_data_misaligned_o      (lsu_data_misaligned_s),
        .mult_multicycle_o          (mult_multicycle_s),
	    .aligner_update_state_o     (aligner_update_state_s),

        .illegal_insn_dec_o         (illegal_insn_dec_s),

        .ctrl_transfer_insn_in_id_o (ctrl_transfer_insn_in_id_s),
        .branch_in_ex_o             (branch_in_ex_s),
        .branch_decision_o          (branch_decision_s),
        .pc_set_o                   (pc_set_s),

	    .prefetch_instr_rdata_cipher_o(prefetch_instr_rdata_cipher_s),
	    .ascon_instr_rdata_plain_i(ascon_instr_rdata_plain_s),
`endif

`ifdef CS
        .cs_vector_o                (cs_vector_s),
`endif
//`ifdef CS_EX
//	    .dec_alu_en_o               (dec_alu_en_s),
//`endif

        .pulp_clock_en_i            ('1),
        .scan_cg_en_i               ('0),

        .boot_addr_i                (BOOT_ADDR),
        .mtvec_addr_i               (32'h0),
        .dm_halt_addr_i             (32'h1A11_0800),
        .hart_id_i                  (32'h0000_0000),
        .dm_exception_addr_i        (32'h0),

        .instr_req_o                (instr_req_s),
        .instr_gnt_i                (instr_gnt_s),
        .instr_rvalid_i             (instr_rvalid_s),
        .instr_addr_o               (instr_addr_s),
        .instr_rdata_i              (instr_rdata_s),

        .data_req_o                 (data_req_s),
        .data_gnt_i                 (data_gnt_s),
        .data_rvalid_i              (data_rvalid_s),
        .data_we_o                  (data_we_s),
        .data_be_o                  (data_be_s),
        .data_addr_o                (data_addr_s),
        .data_wdata_o               (data_wdata_s),
        .data_rdata_i               (data_rdata_s),

        .apu_req_o                  (),
        .apu_gnt_i                  (1'b0),
        .apu_operands_o             (),
        .apu_op_o                   (),
        .apu_flags_o                (),
        .apu_rvalid_i               (1'b0),
        .apu_result_i               ({32{1'b0}}),
        .apu_flags_i                ({5{1'b0}}), // APU_NUSFLAGS_CPU

        .irq_i                      ({32{1'b0}}),
        .irq_ack_o                  (),
        .irq_id_o                   (),

        .debug_req_i                (1'b0),
        .debug_havereset_o          (),
        .debug_running_o            (),
        .debug_halted_o             (),

        .fetch_enable_i             (1'b1),
        .core_sleep_o               ()
    );
    // TODO: extract illegal_instr


`ifdef ENCRYPT
    ascon_decryption #(
        .FIFO_DEPTH             (FIFO_DEPTH),
        .FIFO_ADDR_DEPTH        (FIFO_ADDR_DEPTH),
        .PATCH_WIDTH            (PATCH_WIDTH),
        .PATCH_MEM_ADDR_WIDTH   (PATCH_MEM_ADDR_WIDTH),
        .PB_ROUNDS              (PB_ROUNDS),
        .HW_PERMUTATION_N       (HW_PERMUTATION_N)
    ) ascon_decryption_i (
        .clk_core_slow_i            (clk_core_slow_i),
        .clk_ascon_fast_i           (clk_ascon_fast_i),
        .rst_ni                     (rst_n),

`ifdef CS
        .cs_vector_i                (cs_vector_s),
`endif
//`ifdef CS_EX
//        .dec_alu_en_i               (dec_alu_en_s),
//`endif

        .fifo_push_i                (fifo_push_s),
        .fifo_pop_i                 (fifo_pop_s),
        .fifo_read_pointer_i        (fifo_read_pointer_s),
        .fifo_write_pointer_i       (fifo_write_pointer_s),
        .instr_valid_if_i           (instr_valid_if_s),
        .if_valid_i                 (if_valid_s),
        .id_valid_i                 (id_valid_s),
        .lsu_data_misaligned_i      (lsu_data_misaligned_s),
        .mult_multicycle_i          (mult_multicycle_s),
	    .aligner_update_state_i     (aligner_update_state_s),


        .ctrl_transfer_insn_in_id_i (ctrl_transfer_insn_in_id_s),
        .branch_in_ex_i             (branch_in_ex_s),
        .branch_decision_i          (branch_decision_s),
        .pc_set_i                   (pc_set_s),

        .patch_i                    (patch_s),
        .patch_addr_o               (patch_addr_s),

        .instr_addr_i               (instr_addr_s[PATCH_MEM_ADDR_WIDTH-1:0]),
        .instr_rdata_cipher_i       (prefetch_instr_rdata_cipher_s),
        .instr_rdata_plain_o        (ascon_instr_rdata_plain_s)
    );
`endif


    program_mem #(
        .ADDR_WIDTH        (PROGRAM_MEM_ADDR_WIDTH),
        .INSTR_RDATA_WIDTH (INSTR_RDATA_WIDTH)
    ) program_mem_i (
        .clk_i             (clk_core_slow_i),

        // INSTR READ
        .instr_addr_i      (instr_addr_s),
        .instr_req_i       (instr_req_s),

        .instr_rdata_o     (instr_rdata_s),
        .instr_rvalid_o    (instr_rvalid_s),
        .instr_gnt_o       (instr_gnt_s),

        // DATA READ/WRITE
        .data_addr_i       (data_addr_s),
        .data_wdata_i      (data_wdata_s),
        .data_we_i         (data_we_s),
        .data_be_i         (data_be_s),
        .data_req_i        (data_req_s),

        .data_rdata_o      (data_rdata_s),
        .data_rvalid_o     (data_rvalid_s),
        .data_gnt_o        (data_gnt_s),

        // EXIT
        .exit_value_o      (exit_value_mem_s),
        .exit_valid_o      (exit_valid_mem_s)
    );




`ifdef ENCRYPT
    patch_mem #(
        .ADDR_WIDTH   (PATCH_MEM_ADDR_WIDTH),
        .PATCH_WIDTH  (PATCH_WIDTH + 2*`CS_WB_WIDTH + `CS_EX_WIDTH )
    ) patch_mem_i (
        .clk_i        (clk_core_slow_i),
        .patch_addr_i (patch_addr_s),
        .patch_o      (patch_s)
    );
`endif

endmodule

