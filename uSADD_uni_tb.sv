`timescale 1ns/1ns
`include "uSADD_uni.v"
`include "sobolrng.v"
`define TESTAMOUNT 10

//used to check errors
class errorCheck;
    real uResult;
    real eResult;
    real calcNum;
    real cntA;
    real cntB;
    real denom;
    real sum;
    real iMSE;
    real iRMSE;

    function new(real As, Bs, denom, calcNum);
        cntA = As;
        cntB = Bs;
        denom = denom;
        calcNum = calcNum;


        
    endfunction //new()

    function mse();

    endfunction

    function rmse();

    endfunction
endclass 

module uSADD_uni_tb();
    parameter BITWIDTH = 8;
    logic iClk;
    logic iRstN;
    logic iA;
    logic iB;
    logic loadB;
    logic iClr;
    reg oC;

    //don't touch, used for bitstream generation inside tb
    logic [BITWIDTH-1:0] sobolseq_tb1;
    logic [BITWIDTH-1:0] sobolseq_tb2;
    logic [BITWIDTH-1:0] rand_a;
    logic [BITWIDTH-1:0] rand_b;

    //generates the two stochastic bitstreams
    sobolrng #(
        .BITWIDTH(BITWIDTH)
    ) u_sobolrng_tb1 (
        .iClk(iClk),
        .iRstN(iRstN),
        .iEn(1),
        .iClr(iClr),
        .sobolseq(sobolseq_tb1)
    );

    reg [BITWIDTH-1:0] iB_buff;

    always@(posedge iClk or negedge iRstN) begin
        if(~iRstN) begin
            iB_buff <= 0;
        end else begin
            if(loadB) begin
                iB_buff <= rand_b;
            end else begin
                iB_buff <= iB_buff;
            end
            
        end
    end

    sobolrng #(
        .BITWIDTH(BITWIDTH)
    ) u_sobolrng_tb2 (
        .iClk(iClk),
        .iRstN(iRstN),
        .iEn(1),
        .iClr(iClr),
        .sobolseq(sobolseq_tb2)
    );

    uSADD_uni #(
        .BITWIDTH(BITWIDTH)
    ) u_uSADD_uni (
        .iClk(iClk),
        .iRstN(iRstN),
        .iA(iA),
        .iB(iB),
        .oC(oC)
    );

    always #5 iClk = ~iClk;

    initial begin
        $dumpfile("uSADD_uni_tb.vcd"); $dumpvars;

        iClk = 1;
        iB = 0;
        iA = 0;
        rand_a = 0;
        rand_b = 0;
        iRstN = 0;
        iClr = 0;
        loadB = 1;

        #10;
        iRstN = 1;

        //specified cycles of unary bitstreams
        repeat(`TESTAMOUNT) begin
            rand_b = $urandom_range(255);
            rand_a = $urandom_range(255);

            repeat(256) begin
                #10;
                iA = (rand_a > sobolseq_tb1);
                iB = (iB_buff > sobolseq_tb2);
            end
        end

            
        iClr = 1;
        iA = 0;
        iB = 0;
        #400;

        $finish;
    end
    
endmodule
