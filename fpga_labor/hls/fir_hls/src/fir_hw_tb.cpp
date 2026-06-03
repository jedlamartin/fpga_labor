#include <cmath>
#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <array>

#include "fir_hw.h"

constexpr unsigned int smpl_rd_num = 1;
constexpr unsigned int coeff_size = (1 << (smpl_rd_num - 1)) * 128;

int main(int argc, char* argv[]){
    std::string coeff_file_name = "./src/coefficients/filter_" + std::to_string(coeff_size) + ".fcf";
    std::ifstream coeff_file(coeff_file_name);
    if (!coeff_file.is_open()) {
        std::cerr << "ERROR: Could not open " << coeff_file_name << std::endl;
        return -1;
    }
    std::array<coeff_t, 512> coeff_hw{0};

    std::string line;
    int count = 0;

    while(std::getline(coeff_file, line)){
        std::stringstream ss(line);
        double temp_val;

        if (ss >> temp_val) {
            if (count < 512) {
                coeff_hw[count] = (coeff_t)temp_val;
                count++;
            }
        }
    }

    coeff_file.close();
    std::cout << "Successfully loaded " << count << " coefficients." << std::endl;

    std::array<din_t, coeff_size> input_data;
    input_data.fill(0);
    input_data[0].range(23, 0) = 0x7FFFFF;

    std::array<dout_t, coeff_size> res_l;
    res_l.fill(0);

    hls::FIFO<din_t> fifo_input_l;
    hls::FIFO<din_t> fifo_input_r;
    hls::FIFO<axis_packet> res_stream;

    for(long long unsigned int i = 0; i < input_data.size(); ++i) {
        fifo_input_l.write(input_data[i]);
        fifo_input_r.write(input_data[i]);

        fir_hw((hls::ap_uint<16>)512,
                (hls::ap_uint<8>)smpl_rd_num,
                (hls::ap_uint<16>)(count - 1),
                coeff_hw.data(),
                fifo_input_l,
                fifo_input_r,
                res_stream);

        while (!res_stream.empty()) {
            axis_packet out_val = res_stream.read();
            static bool is_left = true;
            if (is_left) {
                if(i < coeff_size) res_l[i] = out_val.data;
            }
            is_left = !is_left;
        }
    }

    std::cout << "\n--- Comparison: Coeff vs Impulse Response ---" << std::endl;
    int errors = 0;
    for(int i = 0; i < count; i++) {
        double diff = std::abs(coeff_hw[i].to_double() - res_l[i].to_double());

        if (diff > 0.0000001) {
            std::cout << "Mismatch at [" << i << "]: Expected " << coeff_hw[i]
                      << " got " << res_l[i] << " (Diff: " << diff << ")" << std::endl;
            errors++;
        }
    }

    if (errors == 0) {
        std::cout << "SUCCESS: Impulse response matches coefficients exactly!" << std::endl;
    } else {
        std::cout << "FAILURE: Found " << errors << " mismatches." << std::endl;
    }

    return (errors == 0) ? 0 : 1;
}
