`timescale 1ns/1ns
`include "uSADD_uni.v"

module uSADD_uni_tb();
    logic iClk;
    logic iRstN;
    logic [15:0] in;
    logic out;

    uSADD_uni u_uSADD_uni(
        .iClk(iClk),
        .iRstN(iRstN),
        .in(in),
        .out(out)
    );

    always #5 iClk = ~iClk;

    initial begin
        $dumpfile("uSADD_uni_tb.vcd"); $dumpvars;

        iClk = 1;
        iRstN = 0;

        in = 16'b1111111111111111;

        #15;
        iRstN = 1;

        #20;
        in = 16'b1111111100000000;

        #100;
        in = 16'b1111000000000000;

        #100;
        in = 16'b1111000000000000;
        
        #100;
        $finish;
    end
    
endmodule