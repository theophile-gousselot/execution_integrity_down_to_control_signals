`timescale 1ns / 1ps

`include "macro_def.sv"

module ascon_datapath
    import cv32e40p_pkg::*;
    import ascon_pack::*;      
#(
    parameter FIFO_DEPTH = 2,
    parameter FIFO_ADDR_DEPTH = 1,
    parameter PATCH_WIDTH = 320,
    parameter PATCH_MEM_ADDR_WIDTH = 16,
    parameter PB_ROUNDS = 6,
    parameter HW_PERMUTATION_N = 6
) (
    input logic                             clk_core_slow_i,
    input logic                             clk_ascon_fast_i,
    input logic                             rst_ni,

`ifdef CS
    input logic [`CS_WIDTH-1:0]              cs_vector_i,
`endif


    input logic                             fifo_push_i,
    input logic                             fifo_pop_i,
    input logic [FIFO_ADDR_DEPTH-1:0]       fifo_read_pointer_i,
	input logic [FIFO_ADDR_DEPTH-1:0]       fifo_write_pointer_i,
    input logic                             instr_valid_if_i,
    input logic                             if_valid_i,
    input logic                             id_valid_i,
    input logic                             lsu_data_misaligned_i,
    input logic                             mult_multicycle_i,
	input logic                             aligner_update_state_i,

    input logic                             sel_state_init_i,
    input logic  [1:0]                      sel_patch_i,
    input logic                             sel_addr_redirected_i,
    input logic                             sel_previous_instr_addr_en_i,
    input logic                             clk_ascon_fast_cnt_init_i,
    input logic                             clk_ascon_fast_cnt_en_i,
`ifdef CS_PATCH
    input logic                             apply_patch_cs_i,
    input logic                             en_apply_patch_cs_destplus8_i,
`endif
    input logic                             apply_patch_i,

    input logic [PATCH_WIDTH + 2*`CS_WB_WIDTH + `CS_EX_WIDTH-1:0] patch_i,

    output logic [PATCH_MEM_ADDR_WIDTH-1:0] patch_addr_o,

    output logic                            redirection_in_id_o,

    input  logic [PATCH_MEM_ADDR_WIDTH-1:0] instr_addr_i,
    input  logic [31:0]                     instr_rdata_cipher_i,
    output logic [31:0]                     instr_rdata_plain_o
);
    
    // DECLARATION
    localparam CLK_FACTOR = PB_ROUNDS / HW_PERMUTATION_N;

    logic [PATCH_WIDTH + 2*`CS_WB_WIDTH + `CS_EX_WIDTH-1:0]          patch_of_instr_in_if_reg_s = '0;
    logic [PATCH_WIDTH + 2*`CS_WB_WIDTH + `CS_EX_WIDTH-1:0]          patch_of_instr_in_id_reg_s = '0;
    logic [PATCH_WIDTH + 2*`CS_WB_WIDTH + `CS_EX_WIDTH-1:0]          patch_of_instr_in_ex_reg_s = '0;

    logic [PATCH_WIDTH-1:0]          patch_to_ascon_s;

`ifdef CS
    logic [63:0]          patch_s0_cs_to_ascon_s;
`endif


`ifdef CS_CYCPLUS1
    logic [63:0]          patch_s0_cs_ex_to_ascon_s;
    logic [`CS_WB_WIDTH + `CS_EX_WIDTH-1:0]          patch_cs_cycplus1_reg;
    logic [`CS_WB_WIDTH + `CS_EX_WIDTH-1:0]          patch_cs_cycplus1_s;
    logic                            apply_patch_cs_cycplus1_s;
`endif

`ifdef CS_CYCPLUS2
    logic [63:0]          patch_s0_cs_wb_to_ascon_s;
    logic                            apply_patch_cs_cycplus2_s;
    logic [`CS_WB_WIDTH-1:0]                           patch_cs_cycplus2_reg_reg;
    logic [`CS_WB_WIDTH-1:0]                           patch_cs_cycplus2_reg;
    logic [`CS_WB_WIDTH-1:0]                           patch_cs_cycplus2_s;
`endif

    logic [31:0]                     instr_rdata_plain_s;

    logic [PATCH_MEM_ADDR_WIDTH-1:0] instr_addr_fifo_s;
    logic [PATCH_MEM_ADDR_WIDTH-1:0] instr_addr_fifo_reg_s;
    logic [PATCH_MEM_ADDR_WIDTH-1:0] instr_addr_s;

    logic [PATCH_MEM_ADDR_WIDTH-1:0] addr_redirected_s; //todo use parameter...

    logic [FIFO_DEPTH-1:0][PATCH_MEM_ADDR_WIDTH-1:0]     mem_n, mem_q;

    logic [2:0]                      clk_ascon_fast_cnt_reg_s = 3'b0;

    logic                            sel_state_reg_fast_s;
    logic sel_previous_instr_addr_s;
    logic sel_prev_s;
    logic sel_prev_stop_s;
    logic sel_prev_reg_s;
    logic fetch_instr_is_disc_s;
    logic match_addr_redirected_s;
    logic invalid_addr_redirection_s;


    // State
    state_t state_init;
    state_t state_null;

    state_t state_not_patched;
    state_t state_patched;
`ifdef CS
    state_t state_patch2cs;
    state_t state_cs2cipher;
`else
    state_t state_patch2cipher;
`endif
    state_t state_cipher2mux_fast;
    state_t state_mux_fast2perm;
    state_t state_perm2reg;
    state_t state_reg2mux_state_init;
    state_t state_reg_fast2mux_fast;



    // CONSTANT
    // state_init ( pA(IV|K|N) + 0*|K + 0*|1 )
    assign state_init[0] = 64'h32def87181d97180;
    assign state_init[1] = 64'h5e08195f024d70a5;
    assign state_init[2] = 64'h470c5742d5b5e50e;
    assign state_init[3] = 64'hc9c0ab2425b50d55;
    assign state_init[4] = 64'h8dc8253a813db70c;

    assign state_null[0] = 64'h0;
    assign state_null[1] = 64'h0;
    assign state_null[2] = 64'h0;
    assign state_null[3] = 64'h0;
    assign state_null[4] = 64'h0;

    

    // FIFO
    always_comb begin : fifo_read_write
        instr_addr_fifo_s = instr_addr_i;
        mem_n             = mem_q;

        if (fifo_push_i) begin
        mem_n[fifo_write_pointer_i] = instr_addr_i;
        end 

        if (fifo_pop_i) begin
        instr_addr_fifo_s = mem_q[fifo_read_pointer_i];
        end
    end : fifo_read_write

    always_ff @(posedge clk_core_slow_i, negedge rst_ni) begin : fifo_synchronous_write
        if (!rst_ni) begin
            mem_q <= '0;
        end else begin
            mem_q <= mem_n;
        end
    end : fifo_synchronous_write

    always_ff @(posedge clk_core_slow_i, negedge rst_ni) begin : instr_addr_fifo_reg 
        if (!rst_ni) begin
            instr_addr_fifo_reg_s <= '0;
        end else begin
            instr_addr_fifo_reg_s <= instr_addr_fifo_s;
        end
    end : instr_addr_fifo_reg 

    
    // Patch address generation
    assign instr_addr_s = (sel_previous_instr_addr_s) ? instr_addr_fifo_reg_s : instr_addr_fifo_s;
    assign patch_addr_o = (sel_addr_redirected_i) ? addr_redirected_s : instr_addr_s;



    // Get redirected address and check there is a match!
    always_comb begin : redirection
        addr_redirected_s = '0;
        match_addr_redirected_s = '1;
        case (instr_addr_i[PATCH_MEM_ADDR_WIDTH-1:2])
            patch_of_instr_in_id_reg_s[307:294]:  addr_redirected_s = {patch_of_instr_in_id_reg_s[293:280], 2'b0};
            patch_of_instr_in_id_reg_s[279:266]:  addr_redirected_s = {patch_of_instr_in_id_reg_s[265:252], 2'b0};
            patch_of_instr_in_id_reg_s[251:238]:  addr_redirected_s = {patch_of_instr_in_id_reg_s[237:224], 2'b0};
            patch_of_instr_in_id_reg_s[223:210]:  addr_redirected_s = {patch_of_instr_in_id_reg_s[209:196], 2'b0};
            patch_of_instr_in_id_reg_s[195:182]:  addr_redirected_s = {patch_of_instr_in_id_reg_s[181:168], 2'b0};
            patch_of_instr_in_id_reg_s[167:154]:  addr_redirected_s = {patch_of_instr_in_id_reg_s[153:140], 2'b0};
            patch_of_instr_in_id_reg_s[139:126]:  addr_redirected_s = {patch_of_instr_in_id_reg_s[125:112], 2'b0};
            patch_of_instr_in_id_reg_s[111:98]:   addr_redirected_s = {patch_of_instr_in_id_reg_s[97:84], 2'b0};
            patch_of_instr_in_id_reg_s[83:70]:    addr_redirected_s = {patch_of_instr_in_id_reg_s[69:56], 2'b0};
            patch_of_instr_in_id_reg_s[55:42]:    addr_redirected_s = {patch_of_instr_in_id_reg_s[41:28], 2'b0};
            patch_of_instr_in_id_reg_s[27:14]:    addr_redirected_s = {patch_of_instr_in_id_reg_s[13:0], 2'b0};
            default: match_addr_redirected_s = '0;
        endcase
    end : redirection

    assign invalid_addr_redirection_s = (sel_addr_redirected_i && !match_addr_redirected_s) ? 1'b1 : 1'b0;

    // Signal to FSM
    assign redirection_in_id_o = (patch_of_instr_in_id_reg_s[319:308] == 12'hfff) ? 1'b1 : 1'b0;

    // Signal for post redirection managment
    always_comb begin : is_fetch_instr_a_disc
        unique case (instr_rdata_plain_o[6:0])
            OPCODE_JAL, OPCODE_JALR, OPCODE_BRANCH: begin 
                fetch_instr_is_disc_s = '1;
            end

            default: begin
                fetch_instr_is_disc_s = '0;
            end
        endcase
    end : is_fetch_instr_a_disc


    // When there is a 'jalr redirection', at the cycle when the destination is know, the Patch(JALR->DEST) is
    // read at the redirected address. In case of DEST is a BRANCH/JAL (=> fetch_instr_is_disc=1) the associated
    // patch must be read at address @DEST, at the following cycle. The FSM enables to read previous addr (=> 
    // sel_previous_instr_addr_en_i=1). Until instructions in Fetch are discontinuities, the previous instr must
    // be read at the first cycle (=> sel_prev_s=1) at the other cycles (=> sel_prev_reg_s=1).
    assign sel_prev_s = sel_previous_instr_addr_en_i & fetch_instr_is_disc_s;
    assign sel_prev_stop_s = fetch_instr_is_disc_s;
    assign sel_previous_instr_addr_s = (sel_previous_instr_addr_en_i) ? sel_prev_s : (sel_prev_reg_s & sel_prev_stop_s);

    always_ff @(posedge clk_core_slow_i, negedge rst_ni) begin : sel_prev_reg
        if (!rst_ni) begin
            sel_prev_reg_s <= '0;
        end else begin
            if (fetch_instr_is_disc_s) begin
                if ( sel_previous_instr_addr_en_i) begin
                    sel_prev_reg_s <= '1;
                end
            end else begin
                sel_prev_reg_s <= '0;
            end
        end
    end : sel_prev_reg




    always_ff @(posedge clk_core_slow_i, negedge rst_ni) begin : patch_registers
        if (!rst_ni) begin
            patch_of_instr_in_if_reg_s <= '0;
            patch_of_instr_in_id_reg_s <= '0;
            patch_of_instr_in_ex_reg_s <= '0;
        end else begin
            if (aligner_update_state_i) begin
                patch_of_instr_in_if_reg_s <= patch_i;
            end

            if (if_valid_i && instr_valid_if_i) begin
                if (sel_previous_instr_addr_s) begin
                    patch_of_instr_in_id_reg_s <= patch_i;
                end else begin
                    patch_of_instr_in_id_reg_s <= patch_of_instr_in_if_reg_s;
                end
            end
            if ((if_valid_i && instr_valid_if_i)) begin  // id-valid && !data-misaligned && !mult-multicycle-i
                patch_of_instr_in_ex_reg_s <= patch_of_instr_in_id_reg_s;
            end
        end
    end : patch_registers

    always_comb begin : patch_to_ascon_generation
        case (sel_patch_i)
            PATCH_NULL: patch_to_ascon_s = '0;
            PATCH_IF: patch_to_ascon_s = patch_of_instr_in_if_reg_s[319:0];
            PATCH_ID: patch_to_ascon_s = patch_of_instr_in_id_reg_s[319:0];
            PATCH_EX: patch_to_ascon_s = patch_of_instr_in_ex_reg_s[319:0];
        endcase
    end : patch_to_ascon_generation


    assign state_not_patched = (sel_state_init_i) ? state_init : state_reg2mux_state_init;



`ifdef CS_CYCPLUS1
    always_comb begin : patch_cs_cycplus1_generation
        case (sel_patch_i)
            PATCH_NULL: patch_cs_cycplus1_s = '0;
            PATCH_IF: patch_cs_cycplus1_s = patch_of_instr_in_if_reg_s[PATCH_WIDTH+`CS_WB_WIDTH + `CS_EX_WIDTH-1:PATCH_WIDTH];
            PATCH_ID: patch_cs_cycplus1_s = patch_of_instr_in_id_reg_s[PATCH_WIDTH+`CS_WB_WIDTH + `CS_EX_WIDTH-1:PATCH_WIDTH];
            PATCH_EX: patch_cs_cycplus1_s = patch_of_instr_in_ex_reg_s[PATCH_WIDTH+`CS_WB_WIDTH + `CS_EX_WIDTH-1:PATCH_WIDTH];
        endcase
    end : patch_cs_cycplus1_generation
`endif

`ifdef CS_CYCPLUS2
    always_comb begin : patch_cs_cycplus2_generation
        case (sel_patch_i)
            PATCH_NULL: patch_cs_cycplus2_s = '0;
            PATCH_IF: patch_cs_cycplus2_s = patch_of_instr_in_if_reg_s[PATCH_WIDTH+2*`CS_WB_WIDTH + `CS_EX_WIDTH-1:PATCH_WIDTH+`CS_WB_WIDTH + `CS_EX_WIDTH];
            PATCH_ID: patch_cs_cycplus2_s = patch_of_instr_in_id_reg_s[PATCH_WIDTH+2*`CS_WB_WIDTH + `CS_EX_WIDTH-1:PATCH_WIDTH+`CS_WB_WIDTH + `CS_EX_WIDTH];
            PATCH_EX: patch_cs_cycplus2_s = patch_of_instr_in_ex_reg_s[PATCH_WIDTH+2*`CS_WB_WIDTH + `CS_EX_WIDTH-1:PATCH_WIDTH+`CS_WB_WIDTH + `CS_EX_WIDTH];
        endcase
    end : patch_cs_cycplus2_generation
`endif


`ifdef CS_CYCPLUS1
    always_ff @(posedge clk_core_slow_i, negedge rst_ni) begin : patch_cs_ex
        if (!rst_ni) begin
            patch_cs_cycplus1_reg <= '0;
        end else begin
            if (apply_patch_cs_cycplus1_s == 1'b1) begin
                patch_cs_cycplus1_reg <= patch_cs_cycplus1_reg;
            end else begin
                patch_cs_cycplus1_reg <= patch_cs_cycplus1_s;
            end
        end
    end : patch_cs_ex
`endif

`ifdef CS_CYCPLUS2
    always_ff @(posedge clk_core_slow_i, negedge rst_ni) begin : patch_cs_wb
        if (!rst_ni) begin
            patch_cs_cycplus2_reg <= '0;
        end else begin
            patch_cs_cycplus2_reg_reg <= patch_cs_cycplus2_reg;
            patch_cs_cycplus2_reg <= patch_cs_cycplus2_s;
        end
    end : patch_cs_wb
`endif

`ifdef CS_CYCPLUS1
    assign apply_patch_cs_cycplus1_s = apply_patch_cs_i;
`endif

`ifdef CS_CYCPLUS2
    always_ff @(posedge clk_core_slow_i, negedge rst_ni) begin : apply_patch_cs_wb
        if (!rst_ni) begin
            apply_patch_cs_cycplus2_s <= '0;
        end else begin
            apply_patch_cs_cycplus2_s <= apply_patch_cs_i;
        end
    end : apply_patch_cs_wb
`endif




`ifdef CS_CYCPLUS1
    always_comb begin : patch_s0_cs_ex_to_ascon_s_generation
        if (apply_patch_cs_cycplus1_s) begin
            patch_s0_cs_ex_to_ascon_s[63:`CS_WB_WIDTH + `CS_EX_WIDTH+`CS_ID_WIDTH] = '0;
            patch_s0_cs_ex_to_ascon_s[`CS_WB_WIDTH + `CS_EX_WIDTH+`CS_ID_WIDTH-1:`CS_ID_WIDTH] = patch_cs_cycplus1_reg;
        end else begin
            patch_s0_cs_ex_to_ascon_s[63:`CS_ID_WIDTH] = '0;
        end
`ifdef CS_ID
        patch_s0_cs_ex_to_ascon_s[`CS_ID_WIDTH-1:0] = '0;
`endif
    end : patch_s0_cs_ex_to_ascon_s_generation
`endif


`ifdef CS_CYCPLUS2
    always_comb begin : patch_s0_cs_wb_to_ascon_s_generation
        if (apply_patch_cs_cycplus2_s) begin
            patch_s0_cs_wb_to_ascon_s[63:`CS_WB_WIDTH + `CS_EX_WIDTH+`CS_ID_WIDTH] = '0;
            patch_s0_cs_wb_to_ascon_s[`CS_WB_WIDTH + `CS_EX_WIDTH+`CS_ID_WIDTH-1:`CS_EX_WIDTH+`CS_ID_WIDTH] = patch_cs_cycplus2_reg_reg;
`ifdef CS_EX
            patch_s0_cs_wb_to_ascon_s[`CS_EX_WIDTH+`CS_ID_WIDTH-1:`CS_ID_WIDTH] = '0;
`endif
        end else begin
            patch_s0_cs_wb_to_ascon_s[63:`CS_ID_WIDTH] = '0;
        end
`ifdef CS_ID
        patch_s0_cs_wb_to_ascon_s[`CS_ID_WIDTH-1:0] = '0;
`endif
    end : patch_s0_cs_wb_to_ascon_s_generation
`endif


`ifdef CS_CYCPLUS2
`ifdef CS_CYCPLUS1
    assign patch_s0_cs_to_ascon_s = patch_s0_cs_ex_to_ascon_s ^ patch_s0_cs_wb_to_ascon_s;
`else
    assign patch_s0_cs_to_ascon_s = patch_s0_cs_wb_to_ascon_s;
`endif
`else
`ifdef CS_CYCPLUS1
    assign patch_s0_cs_to_ascon_s = patch_s0_cs_ex_to_ascon_s;
`endif
`endif



`ifdef CS
    assign state_patched[0] = state_not_patched[0] ^ patch_to_ascon_s[319:256] ^ patch_s0_cs_to_ascon_s;
`else
    assign state_patched[0] = state_not_patched[0] ^ patch_to_ascon_s[319:256];
`endif
    assign state_patched[1] = state_not_patched[1] ^ patch_to_ascon_s[255:192];
    assign state_patched[2] = state_not_patched[2] ^ patch_to_ascon_s[191:128];
    assign state_patched[3] = state_not_patched[3] ^ patch_to_ascon_s[127:64];
    assign state_patched[4] = state_not_patched[4] ^ patch_to_ascon_s[63:0];



`ifdef CS
`ifdef CS_CYCPLUS1
`ifdef CS_CYCPLUS2
    assign state_patch2cs = (apply_patch_i || apply_patch_cs_cycplus1_s || apply_patch_cs_cycplus2_s) ? state_patched : state_not_patched;
`else
    assign state_patch2cs = (apply_patch_i || apply_patch_cs_cycplus1_s) ? state_patched : state_not_patched;
`endif
`else
    assign state_patch2cs = (apply_patch_i) ? state_patched : state_not_patched;
`endif
    assign state_cs2cipher[4:1] = state_patch2cs[4:1];
    assign state_cs2cipher[0] = {state_patch2cs[0][63:`CS_WIDTH], state_patch2cs[0][`CS_WIDTH-1:0] ^ cs_vector_i} ;

    assign instr_rdata_plain_s = state_cs2cipher[0][63:32] ^ instr_rdata_cipher_i;
    assign instr_rdata_plain_o = (if_valid_i) ? instr_rdata_plain_s : 32'h0;
    
    assign state_cipher2mux_fast[4:1] = state_cs2cipher[4:1];
    assign state_cipher2mux_fast[0] = {instr_rdata_cipher_i, state_cs2cipher[0][31:0]};
`else
    assign state_patch2cipher = (apply_patch_i) ? state_patched : state_not_patched;

    assign instr_rdata_plain_s = state_patch2cipher[0][63:32] ^ instr_rdata_cipher_i;
    assign instr_rdata_plain_o = (if_valid_i) ? instr_rdata_plain_s : 32'h0;
    
    assign state_cipher2mux_fast[4:1] = state_patch2cipher[4:1];
    assign state_cipher2mux_fast[0] = {instr_rdata_cipher_i, state_patch2cipher[0][31:0]};
`endif



    always_ff @(posedge clk_ascon_fast_i, negedge rst_ni) begin : clk_ascon_fast_cnt_reg
        if (!rst_ni) begin
            clk_ascon_fast_cnt_reg_s <= 3'b0;
        end else begin
            if (clk_ascon_fast_cnt_init_i) begin
                clk_ascon_fast_cnt_reg_s <= 3'b0;
            end else begin
                if (clk_ascon_fast_cnt_en_i) begin
                    if (clk_ascon_fast_cnt_reg_s == 3'(CLK_FACTOR-1)) begin
                        clk_ascon_fast_cnt_reg_s <= 3'b0;
                    end else begin
                        clk_ascon_fast_cnt_reg_s <= clk_ascon_fast_cnt_reg_s + 1;
                    end
                end
            end
        end
    end : clk_ascon_fast_cnt_reg

    assign sel_state_reg_fast_s = (clk_ascon_fast_cnt_reg_s == '0) ? 1'b0 : 1'b1;
    assign state_mux_fast2perm = (sel_state_reg_fast_s) ? state_reg_fast2mux_fast : state_cipher2mux_fast;
    

    permutation_n
    #(
        .HW_PERMUTATION_N (HW_PERMUTATION_N),
        .CLK_FACTOR       (CLK_FACTOR)
    ) permutation_n_0 (
        .state_i       (state_mux_fast2perm),
        .round_index_i (clk_ascon_fast_cnt_reg_s),
        .state_o       (state_perm2reg)
    );


    always_ff @(posedge clk_ascon_fast_i, negedge rst_ni) begin : reg_fast2mux_fast
        if (!rst_ni) begin
            state_reg_fast2mux_fast  <= state_init;
        end else begin
            if (if_valid_i && instr_valid_if_i) begin
                state_reg_fast2mux_fast  <= state_perm2reg;
            end
        end
    end : reg_fast2mux_fast

    always_ff @(posedge clk_core_slow_i, negedge rst_ni) begin : reg2mux_state_init
        if (!rst_ni) begin
            state_reg2mux_state_init <= state_init;
        end else begin
            if (if_valid_i && instr_valid_if_i) begin
                state_reg2mux_state_init <= state_perm2reg;
            end
        end
    end : reg2mux_state_init
endmodule
