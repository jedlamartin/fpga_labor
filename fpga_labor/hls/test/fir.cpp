/*
 * FIR 32bit input, 16 taps. Program stops after injecting 128 inputs.
 */

#include <stdio.h>

// Uncomment the following to enable more verbosed output for debugging
// #define DEBUG_PRINT

#define INPUTSIZE 128
#define TAPS 16
#define EXPECTED_TOTAL 913040

#include "hls/streaming.hpp"

void FIRFilterStreaming(hls::FIFO<int> &input_fifo,
                        hls::FIFO<int> &output_fifo) {
    #pragma HLS function top pipeline

    int in = input_fifo.read();

    printf("FIRFilterStreaming input: %d\n", in);
    static int previous[TAPS] = {0};
    const int coefficients[TAPS] = {0, 1, 2,  3,  4,  5,  6,  7,
                                    8, 9, 10, 11, 12, 13, 14, 15};

    int j, temp;
    for (j = (TAPS - 1); j >= 1; j -= 1) {
        previous[j] = previous[j - 1];
    }

    previous[0] = in;

    temp = 0;
    for (j = 0; j < TAPS; j++) {
        temp += previous[TAPS - j - 1] * coefficients[j];
#ifdef DEBUG_PRINT
        printf("previous[%d]: %d\n", j, temp);
#endif
    }

    int output = (previous[TAPS - 1] == 0) ? 0 : temp;

    printf("FIRFilterStreaming output: %d\n", output);

    output_fifo.write(output);

}

int test_input_injector() {
    static int i = 1;
    printf("test_input_injector: %d\n", i);
    return i++;
}

int test_output_checker(int in) {
    static int total = 0;
    printf("test_output_checker input: %d\n", in);
    total += in;

    printf("total: %d\n", total);
    return total;
}

int main() {

    int i, output, total = 0;

    hls::FIFO<int> input_fifo(/*depth=*/2);
    hls::FIFO<int> output_fifo(/*depth=*/2);

    for (i = 1; i <= INPUTSIZE; i++) {

        int input = test_input_injector();

        input_fifo << input;

        FIRFilterStreaming(input_fifo, output_fifo);

        output_fifo >> output;

        total = test_output_checker(output);
    }

    printf("Result: %d\n", total);
    if (total == EXPECTED_TOTAL) {
        printf("RESULT: PASS\n");
    } else {
        printf("RESULT: FAIL\n");
    }
    return (total != EXPECTED_TOTAL);
}
