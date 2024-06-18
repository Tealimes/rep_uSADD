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
    static int i;

    function new();
        asum = 0;
        i = 0;
    endfunction

    function addi(real A, B, denom, num);
        cntrA = A;
        cntrB = B;
        fdenom = denom;
        fnum = num;
        i++;
    endfunction 

    function fSUM();
        $display("Run %.0f results: ", i); 
        uResult = (fnum/fdenom);
        eResult = ((cntrA/fdenom) + (cntrB/fdenom)) / 2;

        $display("uResult = %.9f", uResult);
        $display("eResult = %.9f", eResult); 

        asum = asum + ((uResult - eResult) * (uResult - eResult));
        $display("sum: %.9f", asum);
    endfunction

    function fMSE();
        $display("Final Results: "); 
        mse = asum / `TESTAMOUNT;
        $display("mse: %.9f", mse);
    endfunction

    function fRMSE();
        rmse = $sqrt(mse);
        $display("rmse: %.9f", rmse);
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

    errorcheck error; //class for error checking
    real num; //counts output's 1s
    real cntA; //counts As
    real cntB; //counts Bs
    real denom; //denominator

    //calculates end result
    always@(posedge iClk or negedge iRstN) begin
        if(~iRstN) begin
            num <= 0;
        end else begin
            if(~iClr) begin 
                num <= num + oC;
            end else begin
                num <= 0;
            end
        end
    end

    //calculates denominator
    always@(posedge iClk or negedge iRstN) begin
        if(~iRstN) begin
            denom <= 0;
        end else begin
            if(~iClr) begin 
                denom <= denom + 1;
            end else begin
                denom <= 0;
            end
        end
    end

    //Counts 1 in As and Bs
    always@(posedge iClk or negedge iRstN) begin
        if(~iRstN) begin
            cntA <= 0;
        end else begin
            if(~iClr) begin 
                cntA <= cntA + iA;
            end else begin 
                cntA <= 0;
            end
        end
    end

    //takes output of B from uMUL.v
    always@(posedge iClk or negedge iRstN) begin
        if(~iRstN) begin
            cntB <= 0;
        end else begin
            if(~iClr) begin 
                    cntB <= cntB + iB;
            end else begin 
                cntB <= 0;
            end
        end
    end


    //used for bitstream generation
    logic [BITWIDTH-1:0] sobolseq_tbA;
    logic [BITWIDTH-1:0] sobolseq_tbB;
    logic [BITWIDTH-1:0] rand_a;
    logic [BITWIDTH-1:0] rand_b;

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
    ) u_sobolrng_tbB (
        .iClk(iClk),
        .iRstN(iRstN),
        .iEn(1),
        .iClr(iClr),
        .sobolseq(sobolseq_tbB)
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
        error = new;

        #10;
        iRstN = 1;

        //specified cycles of unary bitstreams
        repeat(`TESTAMOUNT) begin
            num = 0;
            denom = 0;
            cntA = 0;
            cntB = 0;
            rand_b = $urandom_range(255);
            rand_a = $urandom_range(255);

            repeat(256) begin
                #10;
                iA = (rand_a > sobolseq_tbA);
                iB = (iB_buff > sobolseq_tbB);
            end

            error.addi(cntA, cntB, denom, num);
            error.fSUM();
        end

        error.fMSE();
        error.fRMSE();

        iClr = 1;
        iA = 0;
        iB = 0;
        #400;

        $finish;
    end
    
endmodule
