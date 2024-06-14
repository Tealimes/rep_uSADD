`include "sobolrng.v"
`include "parallelcnt.v"

module uSADD_uni #(
    parameter BITWIDTH = 8,
    parameter BINPUT = 2
) (
    input wire iClk,
    input wire iRstN, 
    input wire A,
    input wire [BITWIDTH - 1: 0] B,
    input wire loadB,
    input wire iClr,
    output reg oB,
    output reg [BINPUT-1:0] out
);

    reg [BINPUT-1:0] tempSum;
    reg acc;
    reg accBuff;
    reg bitB; //value of B's current cycle

    //used for bitstream generation
    reg [BITWIDTH-1:0] iB_buff; //to store a value in block so reg
    wire [BITWIDTH-1:0] sobolseq;

    always@(posedge iClk or negedge iRstN) begin
        if(~iRstN) begin
            iB_buff <= 0;
        end else begin
            if(loadB) begin
                iB_buff <= B;
            end else begin
                iB_buff <= iB_buff;
            end
            
        end
    end

    sobolrng #(
        .BITWIDTH(BITWIDTH)
    ) u_sobolrng (
        .iClk(iClk),
        .iRstN(iRstN),
        .iEn(A), 
        .iClr(iClr),
        .sobolseq(sobolseq)
    );

    always@(*) begin
        oB <= (iB_buff > sobolseq);
    end

    assign bitB = (iB_buff > sobolseq);

    //Used to calculate the output
    parallelcnt u_parallelcnt (
        .iClk(iClk),
        .iRstN(iRstN),
        .A(A),
        .B(bitB),
        .out(tempSum)
    );

    //determines if accumulation greater than BINPUT
    //output 1 if accbuff > BINPUT and then resets it back to 0
    always@(posedge iClk or negedge iRstN) begin
        if(~iRstN) begin
            accBuff <= 0;
        end else begin
            if(accBuff > BINPUT) begin
                accBuff <= 0;
            end else begin
                accBuff <= accBuff + tempSum;
            end
        end
    end

    always@(posedge iClk or negedge iRstN) begin
        if(accBuff > BINPUT) begin
            acc <= 1;
        end else begin 
            acc <= 0;
        end
    end

    always@(*) begin
        out <= acc;
    end

endmodule
