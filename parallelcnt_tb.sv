`include "parallelcnt.v"

module parallelcnt_tb ();
    parameter BINPUT = 2;

    logic iClk;
    logic iRstN;
    logic A;
    logic B;
    logic [BINPUT-1:0] out;


    parallelcnt u_parallelcnt(
        .iClk(iClk),
        .iRstN(iRstN),
        .A(A),
        .B(B),
        .out(out)
    );

    always #5 iClk = ~iClk;

    initial begin
        $dumpfile("parallelcnt.vcd"); $dumpvars;

        iRstN = 0;
        iClk = 1;
        A = 0;
        B = 0;

        #15;
        iRstN = 1;
        A = 0;
        B = 1;

        #10;
        A = 1;
        B = 1;

        #10;
        A = 0;
        B = 0;
        #10;

        $finish;
    end


endmodule
