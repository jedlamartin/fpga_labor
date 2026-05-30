#include "bypass_hw.h" // Now main knows about bypass_hw
#include <iostream>
#include <array>

int main() {
    const unsigned int TEST_SIZE = 128;
    hls::ap_uint<16> tlast_dnum = 64; // Set TLAST to trigger every 64 samples

    // Test data arrays (scalars)
    std::array<din_t, TEST_SIZE> test_l;
    std::array<din_t, TEST_SIZE> test_r;

    // Initialize data
    for(unsigned int i = 0; i < TEST_SIZE; i++) {
        test_l[i] = (din_t)(i * 0.01);
        test_r[i] = (din_t)(i * 0.02);
    }

    // Instantiate the SmartHLS FIFOs for the input channels
    hls::FIFO<din_t> fifo_l;
    hls::FIFO<din_t> fifo_r;
    stream_type res_stream;

    int error_count = 0;

    std::cout << "Starting Bypass Simulation..." << std::endl;

    for(unsigned int i = 0; i < TEST_SIZE; i++) {
        // 1. Push the current scalar samples into the FIFOs
        fifo_l.write(test_l[i]);
        fifo_r.write(test_r[i]);

        // 2. Call the module, passing the FIFO references
        bypass_hw(tlast_dnum, fifo_l, fifo_r, res_stream);

        // Bypass module outputs twice (Left then Right)
        // Read Left
        if (!res_stream.empty()) {
            axis_packet out = res_stream.read();
            if (out.data != (dout_t)test_l[i]) {
                std::cerr << "Left channel mismatch at " << i
                          << " Expected: " << (dout_t)test_l[i]
                          << " Got: " << out.data << std::endl;
                error_count++;
            }
        } else {
            std::cerr << "Error: res_stream empty when expecting Left channel at " << i << std::endl;
            error_count++;
        }

        // Read Right
        if (!res_stream.empty()) {
            axis_packet out = res_stream.read();
            if (out.data != (dout_t)test_r[i]) {
                std::cerr << "Right channel mismatch at " << i
                          << " Expected: " << (dout_t)test_r[i]
                          << " Got: " << out.data << std::endl;
                error_count++;
            }
        } else {
            std::cerr << "Error: res_stream empty when expecting Right channel at " << i << std::endl;
            error_count++;
        }
    }

    if (error_count == 0) {
        std::cout << "SUCCESS: All data passed through the bypass logic correctly." << std::endl;
    } else {
        std::cout << "FAILURE: Found " << error_count << " errors." << std::endl;
    }

    return (error_count == 0) ? 0 : 1;
}
