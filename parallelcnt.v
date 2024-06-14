module parallelcnt (
    input wire iClk,
    input wire iRstN,
    input wire A,
    input wire B,
    output reg [1:0] out
);

    always@(posedge iClk or negedge iRstN) begin
        out <= A + B;
    end 

endmodule
