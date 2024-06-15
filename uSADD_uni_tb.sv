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
    logic B;
    logic loadB;
    logic iClr;
    reg out;

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
        .iEn(A),
        .iClr(iClr),
        .sobolseq(sobolseq_tb2)
    );

    uSADD_uni #(
        .BITWIDTH(BITWIDTH)
    ) u_uSADD_uni (
        .iClk(iClk),
        .iRstN(iRstN),
        .A(A),
        .B(B),
        .out(out)
    );

    always #5 iClk = ~iClk;

    initial begin
        $dumpfile("uSADD_uni_tb.vcd"); $dumpvars;

        iClk = 1;
        B = 0;
        A = 0;
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
                A = (rand_a > sobolseq_tb1);
                B = (iB_buff > sobolseq_tb2);
            end
        end

            
        iClr = 1;
        #400;

        $finish;
    end
    
endmodule
