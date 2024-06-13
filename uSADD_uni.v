`include "parallelcnt15.v"

module uSADD_uni(
    input wire iClk,
    input wire iRstN, 
    input wire [15:0] in,
    output wire out
);

    wire [3:0] inCntLess;
    wire [4:0] tempSum;
    wire [4:0] acc;
    reg [3:0] accBuff;

    parallelcnt15 u_parallelcnt15(
        .in(in[14:0]),
        .out(inCntLess)
    );

    assign tempSum = inCntLess + in[15];

    assign acc = accBuff + tempSum[3:0];

    always@(posedge iClk or negedge iRstN) begin
        if(~iRstN) begin
            accBuff <= 0;
        end else begin
            accBuff <= acc[3:0];
        end
    end

    assign out = tempSum[4] ? tempSum[4] : acc[4];

endmodule
