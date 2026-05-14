module binary_counter #(
    parameter WIDTH = 6,
    parameter MAX_COUNT = 63
)(
    input                    clk,
    input                    rst_n,
    (* syn_keep = 1 *) output reg [WIDTH-1:0]   count,
    (* syn_keep = 1 *) output reg               sample_en
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count <= {WIDTH{1'b0}};
        sample_en <= 1'b0;
    end else begin
        if (count >= MAX_COUNT) begin
            count <= {WIDTH{1'b0}};
            sample_en <= 1'b1;
        end else begin
            count <= count + 1'b1;
            sample_en <= 1'b0;
        end
    end
end

endmodule

