`include "parallelcnt7.v"

module parallelcnt15(
    input wire [14:0] in,
    output wire [3:0] out
);
    wire [2:0] tempSum7 [1:0];
    wire [1:0] tempSum [2:0];

    parallelcnt7 u_parallelcnt7_1(
        .in(in[6:0]),
        .out(tempSum7[0])
    );

    parallelcnt7 u_parallelcnt7_2(
        .in(in[13:7]),
        .out(tempSum7[1])
    );

    assign tempSum[0] = in[14] + tempSum7[0][0] + tempSum7[1][0];
    assign tempSum[1] = tempSum[0][1] + tempSum7[0][1] + tempSum7[1][1];
    assign tempSum[2] = tempSum[1][1] + tempSum7[0][2] + tempSum7[1][2];

    assign out = {tempSum[2], tempSum[1][0], tempSum[0][0]};

endmodule
