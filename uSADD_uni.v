//By Alexander Peacock
//email: alexpeacock56ten@gmail.com

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

    wire [BINPUT-1:0] PCout;
    reg [1:0] acc;

    //Used to calculate the output
    parallelcnt u_parallelcnt (
        .iClk(iClk),
        .iRstN(iRstN),
        .iA(iA),
        .iB(iB),
        .oC(PCout)
    );

    //constantly accumulates it's own LSB with the PCout
    always@(posedge iClk or negedge iRstN) begin
        if(~iRstN) begin
            acc <= 0;
        end else begin
            acc <= acc[0] + PCout;
        end
    end

    //outputs the MSB of the accumulator 
    assign oC = acc[1];


endmodule
