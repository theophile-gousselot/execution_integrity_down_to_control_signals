`timescale 1ns / 1ps

`ifdef ENCRYPT
`include "macro_def.sv"
`endif

module program_mem
#(parameter
    ADDR_WIDTH = 17,
    INSTR_RDATA_WIDTH = 32
) (
    input logic clk_i,
    
    // INSTR READ
    input logic [31:0]      instr_addr_i,
  	input logic             instr_req_i,
  	
    output logic [31:0]     instr_rdata_o,
    output logic            instr_rvalid_o,
    output logic            instr_gnt_o,
    
    // DATA READ/WRITE
    input logic [31:0]      data_addr_i,
    input logic [31:0]      data_wdata_i,
    input logic             data_we_i,
    input logic [3:0]       data_be_i,
  	input logic             data_req_i,
  	
    output logic [31:0]     data_rdata_o,
    output logic            data_rvalid_o,
    output logic            data_gnt_o,

    // EXIT
    output logic            exit_valid_o,
    output logic [31:0]     exit_value_o
);

`ifdef VERILATOR
    string program_path/*verilator public*/;
`endif


    integer i;

    localparam int      MMADDR_EXIT = 32'h2000_0004;
    localparam          bytes = 2**(ADDR_WIDTH-2);

    // INSTRUCTION AND DATA MEMORY (4 RAMs)
    reg [7:0] ram0 [bytes];
    reg [7:0] ram1 [bytes];
    reg [7:0] ram2 [bytes];
    reg [7:0] ram3 [bytes];

    logic [31:0] data_rdata_s = '0;
    logic [31:0] instr_rdata_s = '0;

    logic [ADDR_WIDTH-3:0] instr_addr_s, data_addr_s;


    assign instr_addr_s = instr_addr_i[ADDR_WIDTH-1:2];
    assign data_addr_s = data_addr_i[ADDR_WIDTH-1:2];

    // LOAD PROGRAM IN MEMORY 
    initial begin: load_prog
        for (i=0; i<bytes; i++) begin
            ram0[i] = 8'h0;
            ram1[i] = 8'h0;
            ram2[i] = 8'h0;
            ram3[i] = 8'h0;
        end


`ifdef VERILATOR
`ifdef ENCRYPT
`ifdef CS
	$readmemh({program_path,"_encrypted_cs",`STRINGIFY(`CS),"_0.mem"}, ram0);
	$readmemh({program_path,"_encrypted_cs",`STRINGIFY(`CS),"_1.mem"}, ram1);
	$readmemh({program_path,"_encrypted_cs",`STRINGIFY(`CS),"_2.mem"}, ram2);
	$readmemh({program_path,"_encrypted_cs",`STRINGIFY(`CS),"_3.mem"}, ram3);
`else
	$readmemh({program_path,"_encrypted_0.mem"}, ram0);
	$readmemh({program_path,"_encrypted_1.mem"}, ram1);
	$readmemh({program_path,"_encrypted_2.mem"}, ram2);
	$readmemh({program_path,"_encrypted_3.mem"}, ram3);
`endif
`else
	$readmemh({program_path,"_0.mem"}, ram0);
	$readmemh({program_path,"_1.mem"}, ram1);
	$readmemh({program_path,"_2.mem"}, ram2);
	$readmemh({program_path,"_3.mem"}, ram3);
`endif

`else

`ifdef ENCRYPT
	$readmemh("program_encrypted_0.mem", ram0);
	$readmemh("program_encrypted_1.mem", ram1);
	$readmemh("program_encrypted_2.mem", ram2);
	$readmemh("program_encrypted_3.mem", ram3);
`else
	$readmemh("program_0.mem", ram0);
	$readmemh("program_1.mem", ram1);
	$readmemh("program_2.mem", ram2);
	$readmemh("program_3.mem", ram3);
`endif
`endif
    end


    // DATA READ/WRITE
    always @(posedge clk_i) begin
        data_rdata_s <= 32'h0;

        if (data_req_i) begin
            if (data_we_i) begin
                if (data_be_i[0]) ram0[data_addr_s] <= data_wdata_i[ 7: 0];
                if (data_be_i[1]) ram1[data_addr_s] <= data_wdata_i[15: 8];
                if (data_be_i[2]) ram2[data_addr_s] <= data_wdata_i[23:16];
                if (data_be_i[3]) ram3[data_addr_s] <= data_wdata_i[31:24];
            end

            else begin
                data_rdata_s[7:0] <= ram0[data_addr_s];
                data_rdata_s[15:8] <= ram1[data_addr_s];
                data_rdata_s[23:16] <= ram2[data_addr_s];
                data_rdata_s[31:24] <= ram3[data_addr_s];
            end
        end
        data_rvalid_o <= data_req_i;
    end

    assign data_rdata_o = data_rdata_s;
    assign data_gnt_o = data_req_i; // always granted



    // INSTR READ
    always @(posedge clk_i) begin
        instr_rdata_s[7:0] <= ram0[instr_addr_s];
        instr_rdata_s[15:8] <= ram1[instr_addr_s];
        instr_rdata_s[23:16] <= ram2[instr_addr_s];
        instr_rdata_s[31:24] <= ram3[instr_addr_s];
        
        instr_rvalid_o <= instr_req_i;
    end
    assign instr_rdata_o = (instr_rvalid_o) ? instr_rdata_s : 32'h0;
    assign instr_gnt_o = instr_req_i; // always granted


    // EXIT VALID
    assign exit_valid_o = (data_addr_i == MMADDR_EXIT) ? '1 : '0;
    assign exit_value_o = (data_addr_i == MMADDR_EXIT) ? data_wdata_i : '0;


endmodule
