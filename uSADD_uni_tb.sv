//By Alexander Peacock
//email: alexpeacock56ten@gmail.com

`include "uSADD_uni.v"
`include "sobolrng.v"
`define TESTAMOUNT 10

//used to check errors
class errorcheck;
    real uResult;
    real eResult;
    real fnum;
    real cntrA;
    real cntrB;
    real fdenom;
    real asum;
    real mse;
    real rmse;
    static int j;

    function new();
        asum = 0;
        cntrA = 0;
        cntrB = 0;
        fnum = 0;
        fdenom = 0;
        j = 0;
    endfunction

    //accumulates to account for bitstreams
    function count(real a, b, outC);
        cntrA = cntrA + a;
        cntrB = cntrB + b;
        fnum = fnum + outC;
        fdenom++;
    endfunction

    //sums the results of a bitstream cycle
    function fSUM();
        j++; //counts current run

        $display("Run %.0f results: ", j); 
        $display("Number of 1s output = %.0f", fnum);
        $display("Bits in bitstream = %.0f", fdenom);
        $display("Number of 1s in A = %.0f", cntrA);
        $display("Number of 1s in B = %.0f", cntrB);
        uResult = (fnum/fdenom);
        eResult = ((cntrA/fdenom) + (cntrB/fdenom)) / 2;

        $display("uResult = %.9f", uResult);
        $display("eResult = %.9f", eResult); 

        asum = asum + ((uResult - eResult) * (uResult - eResult));
        $display("sum: %.9f", asum);
        $display("");

        //resets for next bitstreams
        cntrA = 0;
        cntrB = 0;
        fnum = 0;
        fdenom = 0;
    endfunction

    //mean squared error
    function fMSE();
        $display("Final Results: "); 
        mse = asum / `TESTAMOUNT;
        $display("mse: %.9f", mse);
    endfunction

    //root mean square error
    function fRMSE();
        rmse = $sqrt(mse);
        $display("rmse: %.9f", rmse);
    endfunction

endclass

module uSADD_uni_tb();
    parameter BITWIDTH = 8;
    parameter BINPUT = 2;
    logic iClk;
    logic iRstN;
    logic iA;
    logic iB;
    logic iClr;
    reg oC;

    errorcheck error; //class for error checking

    //used for bitstream generation
    logic [BITWIDTH-1:0] sobolseq_tbA;
    logic [BITWIDTH-1:0] sobolseq_tbB;
    logic [BITWIDTH-1:0] rand_a;
    logic [BITWIDTH-1:0] rand_b;

    // This code is used to delay the expected output
    parameter PPCYCLE = 1;

    // dont change code below
    logic result [PPCYCLE-1:0];
    logic result_expected;
    assign result_expected = oC;

    genvar i;
    generate
        for (i = 1; i < PPCYCLE; i = i + 1) begin
            always@(posedge iClk or negedge iRstN) begin
                if (~iRstN) begin
                    result[i] <= 0;
                end else begin
                    result[i] <= result[i-1];
                end
            end
        end
    endgenerate

    always@(posedge iClk or negedge iRstN) begin
        if (~iRstN) begin
            result[0] <= 0;
        end else begin
            result[0] <= result_expected;
        end
    end
    // end here

    //generates the two stochastic bitstreams
    sobolrng #(
        .BITWIDTH(BITWIDTH)
    ) u_sobolrng_tbA (
        .iClk(iClk),
        .iRstN(iRstN),
        .iEn(1),
        .iClr(iClr),
        .sobolseq(sobolseq_tbA)
    );

    sobolrng #(
        .BITWIDTH(BITWIDTH)
    ) u_sobolrng_tbB (
        .iClk(iClk),
        .iRstN(iRstN),
        .iEn(1),
        .iClr(iClr),
        .sobolseq(sobolseq_tbB)
    );

    uSADD_uni #(
        .BINPUT(BINPUT)
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
        error = new;

        #10;
        iRstN = 1;

        //specified cycles of unary bitstreams
        repeat(`TESTAMOUNT) begin
            rand_b = $urandom_range(255);
            rand_a = $urandom_range(255);

            repeat(256) begin
                #10;
                iA = (rand_a > sobolseq_tbA);
                iB = (rand_b > sobolseq_tbB);
                error.count(iA, iB, result[PPCYCLE-1]);
            end

            error.fSUM();
        end

        //gives final error results
        error.fMSE();
        error.fRMSE();

        iClr = 1;
        iA = 0;
        iB = 0;
        #400;

        $finish;
    end
    
endmodule
