module parallelcnt (
    input wire iClk,
    input wire iRstN,
    input wire iA,
    input wire iB,
    output reg [1:0] oC
);

    always@(posedge iClk or negedge iRstN) begin
        oC <= iA + iB;
    end 

endmodule
