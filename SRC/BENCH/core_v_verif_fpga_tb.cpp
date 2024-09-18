#include <stdlib.h>
#include <iostream>
#include <boost/format.hpp>
#include <fstream>
#include <string>
#include <vector>
#include <sstream>
#include <ctime>
#include <sys/stat.h>

// #include <cstdlib>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "all_headers.h"

using namespace std;
using namespace boost;

#ifndef MAX_SIM_TIME
#define MAX_SIM_TIME 5000000
#endif


#ifndef CLK_FACTOR
#define CLK_FACTOR 1
#endif

#ifndef CS
#endif


int exit_error_argv(int argc, char** argv) {
    cout <<  endl << "usage: " << argv[0] << " <program_name> " << "[--verif, --save_ref, --trace_signals, --cs_ref]" << endl;
    cout << argv[0] << ": error: unrecognized or invalid arguments";
    for (int j = 0; j < argc; j++) {cout << " " << argv[j];}
    cout << endl;
    exit(EXIT_FAILURE);
    return 0;
}

void argv_analyze(int argc, char** argv, string &program_name, bool &verif_mode, bool &trace_signals_mode, bool &cs_ref_mode) {
    std::vector<std::string> args(argv, argv+argc);

    if (args.size() <= 1) {exit_error_argv(argc, argv);}
    program_name = args[1];
    for (int j = 2; j < args.size(); j++) {
        if (args[j] == "--verif") {verif_mode = true;}
        else if (args[j] == "--save_ref") {verif_mode = false;}
        else if (args[j] == "--trace_signals") {trace_signals_mode = true;}
        else if (args[j] == "--cs_ref") {cs_ref_mode = true;}
        else {exit_error_argv(argc, argv);}
    }
}

vector<vector<string>> read_ref(string ref_path) {
    vector<string> row;
    vector<vector<string>> content;

    string line, word;
    fstream ref_file(ref_path);
    if (ref_file.is_open()) {
        while (getline(ref_file, line)) {
            row.clear();

            stringstream str(line);

            while (getline(str, word, ','))
                row.push_back(word);
            content.push_back(row);
        }
    } else {
        cout << "ERROR: " << ref_path << ": No such file or directory" << endl;
        cout << "Please execute with option --save_ref" << endl;
        exit(EXIT_FAILURE);
    }
    ref_file.close();
    return content;
}

void write_log(ostream &os1, ostream &os2, string str) {
    os1 << str;
    os2 << str;
}

void log_start_simu(ofstream& log_file, string program_name, bool verif_mode, bool trace_signals_mode, bool cs_ref_mode) {
    write_log(cout, log_file,  "\n" + string(19, '-') + " VERILATOR SIMULATION " + string(19, '-') + "\n\n");
    write_log(cout, log_file, "VERILATOR:      Simulation launched...\n");
    write_log(cout, log_file, "PROGRAM:        " + program_name + "\n");
    write_log(cout, log_file, "CLOCK FACTOR:   " + to_string(CLK_FACTOR) + "\n");
#if CS != 0
    write_log(cout, log_file, "CONTROL SIGNALS (" +  to_string(CS) + ") ARE ASSOCIATED TO ENCRYPTION\n");
#endif
    if (verif_mode) {
        write_log(cout, log_file, "MODE:           VERIFICATION of PC/instr\n\n");
    } else {
        write_log(cout, log_file, "MODE:           SAVE REFERENCE of PC/instr\n");
    }
    if (trace_signals_mode) {
        write_log(cout, log_file, "MODE:           SAVE TRACE SIGNALS of diverse PC/instr\n");
    }
    if (cs_ref_mode) {
        write_log(cout, log_file, "MODE:           SAVE CONTROL SIGNALS\n");
    }
    write_log(cout, log_file, "\n" + string(2, '#') + " REPORTED WARNINGS/ERRORS:" + "\n");
}


void log_end_simu(ofstream& log_file, bool verif_mode, bool trace_signals_mode, bool cs_ref_mode, int64_t sim_time, int error_n, int first_error_sample_n, string ref_path, string trace_signals_path, string cs_path, string vcd_path, string reason_stop) {
    write_log(cout, log_file, "\n" + string(2, '#') + " SIMULATION ENDING:\n");
    write_log(cout, log_file, "REASON:         " + reason_stop + "\n");

    if (verif_mode) {
        if (error_n == 0) {
            write_log(cout, log_file, "VERIFICATION:   TEST SUCCESS(Expected PC/instruction at every cycle)\n");
        } else {
            write_log(cout, log_file, "VERIFICATION:   TEST FAILURE(" + to_string(error_n) + " errors");
            write_log(cout, log_file, ", first error appeard at " + to_string(first_error_sample_n) + " cycles)\n");
        }
    }

    write_log(cout, log_file, "\nsim_time:       " + to_string(sim_time) + "\n");
    if (!verif_mode) {
        write_log(cout, log_file, "PC and instruction references are saved in: " + ref_path + "\n");
    }
    if (trace_signals_mode) {
        write_log(cout, log_file, "TRACE SIGNALS of diverse PC/instr are saved in: " + trace_signals_path + "\n");
    }
    if (cs_ref_mode) {
        write_log(cout, log_file, "CONTROL SIGNALS are saved in: " + cs_path + "\n");
    }
#ifdef VCD
    if (access(vcd_path.c_str(), F_OK) != -1) {
        write_log(cout, log_file, "Waveform is saved in: " + vcd_path + "\n");
    } else {
        write_log(cout, log_file, "Failed to save waveform in: " + vcd_path + ": No such file or directory" + "\n");
    }
#endif
    write_log(cout, log_file, string(60, '-') + "\n");
}


void log_start_overview(bool verif_mode, bool trace_signals_mode, string program_name) {
    struct stat sb;
    if (stat("OBJ", &sb) != 0) {mkdir("OBJ", S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH);}
    if (stat("OBJ/LOG", &sb) != 0) {mkdir("OBJ/LOG", S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH);}

    ifstream overview_log_infile("OBJ/LOG/overview.log");
    bool insert_log_header = !overview_log_infile.good();
    overview_log_infile.close();

    ofstream overview_log_file;
    overview_log_file.open("OBJ/LOG/overview.log", ios_base::app);
    if (insert_log_header) {
        overview_log_file << "|   PROGRAM_NAME   |    ENCRYPT    | CF|   MODE   |    TEST   | REASON END. |  SIM_TIME  | FIRST ERR. |       TIMESTAMP         \n";
    }
    overview_log_file << format("|%=18i") % program_name;
#ifdef ENCRYPT
#if defined(CS)
    string encrypt_with_cs = "instr+cs" + to_string(CS);
    overview_log_file << format("|%=15i") % encrypt_with_cs;
#else
    overview_log_file << format("|%=15i") % "instr";
#endif
    overview_log_file << format("|%=3i") % CLK_FACTOR;
#else
    overview_log_file << format("|%=15i") % "";
    overview_log_file << format("|%=3i") % "";
#endif
    if (verif_mode) {
        overview_log_file << format("|%=10i") % "VERIF";
    } else {
        if (trace_signals_mode) {
            overview_log_file << format("|%=10i") % "SAVE/TRACE";
        } else {
            overview_log_file << format("|%=10i") % "SAVE_REF";
        }
    }

    overview_log_file.close();

}

void log_end_overview(bool verif_mode, string program_name, vluint64_t sim_time, int error_n, int first_error_sample_n, string reason_stop) {
    ofstream overview_log_file;
    overview_log_file.open("OBJ/LOG/overview.log", ios_base::app);
    time_t result = time(nullptr);
    if (verif_mode) {
        if (error_n == 0) {
            overview_log_file << format("|%=11i") % "SUCCESS";
        } else {
            overview_log_file << format("|%=11i") % "FAILURE";
        }
    } else {
        overview_log_file << format("|%=11i") % "";
    }
    overview_log_file << format("|%=13i") % reason_stop;

    overview_log_file << format("|%11i ") % sim_time;
    if (error_n == 0) {
        overview_log_file << format("|%11i ") % "";
    } else {
        overview_log_file << format("|%11i ") % first_error_sample_n;
    }
    overview_log_file << "| " <<  asctime(localtime(&result));
    overview_log_file.close();

}


void write_ref(ostream &os1, Vcore_v_verif_fpga *dut) {
    os1 << hex << dut->core_v_verif_fpga->cv32e40p_core_i->if_stage_i->pc_id_o << ",";
    os1 << hex << dut->core_v_verif_fpga->cv32e40p_core_i->if_stage_i->instr_rdata_id_o << "\n";
}


void write_cs(ostream &os1,  Vcore_v_verif_fpga *dut) {
	os1 << hex << dut->core_v_verif_fpga->cv32e40p_core_i->instr_addr_o << ",";
	os1 << hex << dut->core_v_verif_fpga->cv32e40p_core_i->pc_if << ",";
	os1 << hex << dut->core_v_verif_fpga->cv32e40p_core_i->pc_id << ",";
	os1 << hex << dut->core_v_verif_fpga->cv32e40p_core_i->pc_ex << ",";
	os1 << hex << dut->core_v_verif_fpga->cv32e40p_core_i->instr_rdata_i << ",";
	os1 << hex << dut->core_v_verif_fpga->cv32e40p_core_i->instr_rdata_id << ",";
	os1 << hex << dut->core_v_verif_fpga->cv32e40p_core_i->id_stage_i->decoder_i->alu_en + 0 << ",";
	os1 << hex << dut->core_v_verif_fpga->cv32e40p_core_i->id_stage_i->decoder_i->alu_operator_o + 0 << ",";
	//os1 << hex << dut->core_v_verif_fpga->cv32e40p_core_i->ex_stage_i->alu_i->enable_i + 0 << ",";
    //os1 << hex << dut->core_v_verif_fpga->cv32e40p_core_i->ex_stage_i->alu_i->operator_i + 0;
	os1 << endl;
}


void write_trace_signals(ostream &os1, Vcore_v_verif_fpga *dut) {
	os1 << hex << dut->core_v_verif_fpga->cv32e40p_core_i->instr_addr_o << ",";
	os1 << hex << dut->core_v_verif_fpga->cv32e40p_core_i->pc_if << ",";
	os1 << hex << dut->core_v_verif_fpga->cv32e40p_core_i->pc_id << ",";
	os1 << hex << dut->core_v_verif_fpga->cv32e40p_core_i->instr_rdata_i << ",";
	os1 << hex << dut->core_v_verif_fpga->cv32e40p_core_i->instr_rdata_id << ",";
	if (dut->core_v_verif_fpga->cv32e40p_core_i->mhpmevent_jump == 1) {
        os1 << "1" << endl;
    } else {
        os1 << "0" << endl;
    }
}


void compare_ref(ofstream& log_file, int &sample_index, int64_t pc_id, int64_t instr_id, Vcore_v_verif_fpga *dut, vluint64_t sim_time, int &first_error_sample_n, int &error_n, bool &stop_sim, string &reason_stop) {
    
    // COMPARE PC_ID
    if (pc_id != dut->core_v_verif_fpga->cv32e40p_core_i->if_stage_i->pc_id_o) {
        if (first_error_sample_n == -1) {first_error_sample_n = sim_time;}
        stop_sim = true;
        reason_stop = "REF ERROR";
        error_n++;
        ostringstream pc_id_expec_stream, pc_id_receiv_stream;
        pc_id_expec_stream << hex << pc_id;
        pc_id_receiv_stream << hex << dut->core_v_verif_fpga->cv32e40p_core_i->if_stage_i->pc_id_o; 
        write_log(cout, log_file, "ERROR(t=" + to_string(sim_time) + ") Expected PC= " + pc_id_expec_stream.str() + " Received= ");
        write_log(cout, log_file, pc_id_receiv_stream.str() + "\n");
    }

    // COMPARE INSTRUCTION_IF
    if (instr_id != dut->core_v_verif_fpga->cv32e40p_core_i->if_stage_i->instr_rdata_id_o) {
        if (first_error_sample_n == -1) {first_error_sample_n = sim_time;}
        stop_sim = true;
        reason_stop = "REF ERROR";
        error_n++;
        ostringstream instr_id_expec_stream, instr_id_receiv_stream;
        instr_id_expec_stream << hex << instr_id;
        instr_id_receiv_stream << hex << dut->core_v_verif_fpga->cv32e40p_core_i->if_stage_i->instr_rdata_id_o; 
        write_log(cout, log_file, "ERROR(t=" + to_string(sim_time) + ") Expected Instruction= " + instr_id_expec_stream.str() + " Received= ");
        write_log(cout, log_file, instr_id_receiv_stream.str() + "\n");
    }
    sample_index++;
}

void check_ref_size(ofstream& log_file, int sample_index, int ref_samples_n, string ref_path) {
    if (sample_index >= ref_samples_n) {
        write_log(cout, log_file, "Error: " + ref_path + " contains only ");
        write_log(cout, log_file, to_string(ref_samples_n) + " samples. Please reduce MAX_SIM_TIME.");
        exit(EXIT_FAILURE);
    }
}

int main(int argc, char** argv, char** env) {
    string program_name, program_path, vcd_path, ref_path, log_path, trace_signals_path, cs_path;
    bool verif_mode = true;
    bool trace_signals_mode = false;
    bool cs_ref_mode = false;
    argv_analyze(argc, argv, program_name, verif_mode, trace_signals_mode, cs_ref_mode);

#ifdef ENCRYPT
#if defined(CS)
    vcd_path = "OBJ/PROGRAMS/" + program_name + "/SIM/VCD/program_encrypted_cf" + to_string(CLK_FACTOR) + "_cs" +to_string(CS) + ".vcd";
#else
    vcd_path = "OBJ/PROGRAMS/" + program_name + "/SIM/VCD/program_encrypted_cf" + to_string(CLK_FACTOR) + ".vcd";
#endif
#else
    vcd_path = "OBJ/PROGRAMS/" + program_name + "/SIM/VCD/program.vcd";
#endif

    cs_path =  "OBJ/PROGRAMS/" + program_name + "/SIM/REF/ref_cs.csv";
    ref_path = "OBJ/PROGRAMS/" + program_name + "/SIM/REF/ref_decode_pc_instr_patch.csv";
    program_path = "OBJ/PROGRAMS/" + program_name + "/PROGRAM_COMPILED/program";

    if (verif_mode) {
#ifdef ENCRYPT
#if defined(CS)
        log_path = "OBJ/PROGRAMS/" + program_name + "/SIM/LOG/program_encrypted_cf" + to_string(CLK_FACTOR) + "_cs" + to_string(CS) + "_verif.log";
#else
        log_path = "OBJ/PROGRAMS/" + program_name + "/SIM/LOG/program_encrypted_cf" + to_string(CLK_FACTOR) + "_verif.log";
#endif
#else
        log_path = "OBJ/PROGRAMS/" + program_name + "/SIM/LOG/program_verif.log";
#endif
    } else {
        log_path = "OBJ/PROGRAMS/" + program_name + "/SIM/LOG/program_save_ref.log";
    }

    ofstream trace_signal_file;
    if (trace_signals_mode) {
#ifdef ENCRYPT
        cout << "Error: JALR_DEST macro cannot be used with ENCRYPT macro\n";
        exit(EXIT_FAILURE);
#endif
        trace_signals_path =  "OBJ/PROGRAMS/" + program_name + "/SIM/REF/program_trace_signals.csv";
        trace_signal_file.open(trace_signals_path);
    }

    ofstream cs_file;
    if (cs_ref_mode) {
        cs_file.open(cs_path);
    }

    // Open REF PC/instr file
    vector<vector<string>> content;
    ofstream log_file;
    log_file.open(log_path);
    ofstream ref_file;
    if (verif_mode) {
        content = read_ref(ref_path);
    } else {
        ref_file.open(ref_path);
    }
    int ref_samples_n = content.size();

    log_start_simu(log_file, program_name, verif_mode, trace_signals_mode, cs_ref_mode); 
    log_start_overview(verif_mode, trace_signals_mode, program_name);


    // Variables
    vluint64_t sim_time = 0;
    bool stop_sim = false;
    string reason_stop = "no reason";
    int stop_sim_cnt = 20;
    int sample_index = 0;
    int error_n = 0;
    int first_error_sample_n = -1;
    int64_t pc_id;
    int64_t instr_id;
    int clk_ascon_fast_cnt = 0;

    // DUT Instanciation
    Vcore_v_verif_fpga *dut = new Vcore_v_verif_fpga;

    // VCD Generation
#ifdef VCD
    Verilated::traceEverOn(true);
    VerilatedVcdC *m_trace = new VerilatedVcdC;
    dut->trace(m_trace, 5);
    m_trace->open(vcd_path.c_str());
#endif

    // DUT input ports initialization
    dut->rst_i = 1;
    dut->clk_core_slow_i = 0;
    dut->clk_ascon_fast_i = 0;
    dut->core_v_verif_fpga->program_mem_i->program_path = program_path;
#ifdef ENCRYPT
    dut->core_v_verif_fpga->patch_mem_i->program_path = program_path;
#endif
    
    // SIMULATION 
    while (sim_time < MAX_SIM_TIME && stop_sim_cnt != 0) {

        // DISABLE RESET
        if (sim_time > 20*CLK_FACTOR) {
            dut->rst_i = 0;
        }
        
        // CLOCK EDGE
        if (clk_ascon_fast_cnt == 0) {
            dut->clk_core_slow_i ^= 1;
        } else if (clk_ascon_fast_cnt == CLK_FACTOR) {
            dut->clk_core_slow_i ^= 1;
        }

        dut->clk_ascon_fast_i ^= 1;

        // EVALUATE THE MODEL (as top level IOs change)
        dut->eval();

        // PROGRAM EXECUTION SUCCESS
        if (stop_sim) {
            stop_sim_cnt--;
        }
        if (clk_ascon_fast_cnt == CLK_FACTOR) {
            if (dut->core_v_verif_fpga->exit_valid_mem_s == 1) {
                reason_stop = "VALID EXEC";
                stop_sim = true;
            }

            // REF (PC/instr) Verification or Saving
            if (verif_mode) {
                check_ref_size(log_file, sample_index, ref_samples_n, ref_path);
                pc_id = stol(content[sample_index][0], nullptr, 16);
                instr_id = stol(content[sample_index][1], nullptr, 16);
                compare_ref(log_file, sample_index, pc_id, instr_id, dut, sim_time, first_error_sample_n, error_n, stop_sim, reason_stop);
            } else {
                write_ref(ref_file, dut);
            }

            if (cs_ref_mode) {
                write_cs(cs_file, dut);
            }

            if (trace_signals_mode) {
                write_trace_signals(trace_signal_file, dut);
            }
        }

        // VCD DUMPING of SIGNALS
#ifdef VCD
            m_trace->dump(sim_time);
#endif

        // sim_time_incr
        sim_time++;
        clk_ascon_fast_cnt++;
        if (clk_ascon_fast_cnt == 2*CLK_FACTOR) {
            clk_ascon_fast_cnt = 0;
        }
    }
    if (sim_time == MAX_SIM_TIME) {
        reason_stop = "TIMEOUT";
    }

    log_end_simu(log_file, verif_mode, trace_signals_mode, cs_ref_mode, sim_time, error_n, first_error_sample_n, ref_path, trace_signals_path, cs_path, vcd_path, reason_stop);
    log_file.close(); // LOG FILE
    log_end_overview(verif_mode, program_name, sim_time, error_n, first_error_sample_n, reason_stop);
#ifdef VCD
        m_trace->close(); // VCD FILE
#endif
    if (cs_ref_mode) {
        cs_file.close();
    }
    ref_file.close(); // REF FILE

    if (trace_signals_mode) {
        trace_signal_file.close();
    }
    delete dut;
    exit(EXIT_SUCCESS);
}
