`include "parallelcnt.v"

module uSADD_uni #(
    parameter BITWIDTH = 8,
    parameter BINPUT = 2
) (
    input wire iClk,
    input wire iRstN, 
    input wire iA,
    input wire iB,
    output reg oC
);

    reg [BINPUT-1:0] PCout;
    reg [1:0] acc;

    //Used to calculate the output
    parallelcnt u_parallelcnt (
        .iClk(iClk),
        .iRstN(iRstN),
        .iA(iA),
        .iB(iB),
        .oC(PCout)
    );

    //determines if accumulation greater than BINPUT
    //output 1 if accbuff > BINPUT and then resets it back to 0
    always@(posedge iClk or negedge iRstN) begin
        if(~iRstN) begin
            acc <= 0;
        end else begin
            acc <= acc[0] + PCout;
        end
    end

    assign oC = acc[1];


endmodule
