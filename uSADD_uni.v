`include "parallelcnt.v"

module uSADD_uni #(
    parameter BITWIDTH = 8,
    parameter BINPUT = 2
) (
    input wire iClk,
    input wire iRstN, 
    input wire A,
    input wire B,
    output reg out
);

    reg [BINPUT-1:0] tempSum;
    reg [2:0] accBuff;
    reg [2:0] cnt;

    //Used to calculate the output
    parallelcnt u_parallelcnt (
        .iClk(iClk),
        .iRstN(iRstN),
        .A(A),
        .B(B),
        .out(tempSum)
    );

    //determines if accumulation greater than BINPUT
    //output 1 if accbuff > BINPUT and then resets it back to 0
    always@(posedge iClk or negedge iRstN) begin
        if(~iRstN) begin
            accBuff <= 0;
        end else begin
            if((accBuff + tempSum) >= BINPUT) begin
                accBuff <= 0;
            end else begin
                accBuff <= accBuff + tempSum;
            end
        end
    end

    assign out = ((accBuff + tempSum) >= BINPUT) ? 1'b1 : 1'b0;


endmodule
