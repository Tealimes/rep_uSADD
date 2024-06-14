`timescale 1ns/1ns
`include "uSADD_uni.v"
`include "sobolrng.v"
`define TESTAMOUNT 10

//used to check errors
class errorCheck;
    function new();
        
    endfunction //new()
endclass 

module uSADD_uni_tb();
    parameter BITWIDTH = 8;
    logic iClk;
    logic iRstN;
    logic A;
    logic [BITWIDTH-1:0] B;
    logic loadB;
    logic iClr;
    logic oB;
    reg [1:0] out;

    //don't touch, used for bitstream generation inside tb
    logic [BITWIDTH-1:0] sobolseq_tb;
    logic [BITWIDTH-1:0] rand_a;

    sobolrng #(
        .BITWIDTH(BITWIDTH)
    ) u_sobolrng_tb (
        .iClk(iClk),
        .iRstN(iRstN),
        .iEn(1),
        .iClr(iClr),
        .sobolseq(sobolseq_tb)
    );

    uSADD_uni #(
        .BITWIDTH(BITWIDTH)
    ) u_uSADD_uni (
        .iClk(iClk),
        .iRstN(iRstN),
        .A(A),
        .B(B),
        .loadB(loadB),
        .iClr(iClr),
        .oB(oB),
        .out(out)
    );

    always #5 iClk = ~iClk;

    initial begin
        $dumpfile("uSADD_uni_tb.vcd"); $dumpvars;

        iClk = 1;
        B = 0;
        A = 0;
        rand_a = 0;
        iRstN = 0;
        iClr = 0;
        loadB = 1;

        #10;
        iRstN = 1;

        //specified cycles of unary bitstreams
        repeat(`TESTAMOUNT) begin
            B = $urandom_range(255);
            rand_a = $urandom_range(255);

            repeat(256) begin
                #10;
                A = (rand_a > sobolseq_tb);
            end
        end

            
        iClr = 1;
        #400;

        $finish;
    end
    
endmodule
