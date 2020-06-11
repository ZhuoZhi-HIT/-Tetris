`include "definitions.vh"

module complete_row(
    input wire                                   clk,
    input wire                                   pause,
    input wire [(`BLOCKS_WIDE*`BLOCKS_HIGH)-1:0] fallen_pieces,
    output reg [`BITS_Y_POS-1:0]                 row,
    output wire                                  enabled
    );

    initial begin
        row = 0;
    end

	 //第row行全为1，则选取出来
     assign enabled = &fallen_pieces[row*`BLOCKS_WIDE +: `BLOCKS_WIDE];

     // Increment the row under test when the clock goes high
	 //如果row到顶了，则清零，否则逐行加一
     always @ (posedge clk) begin
         if (!pause) begin
             if (row == `BLOCKS_HIGH - 1) begin
                 row <= 0;
             end else begin
                 row <= row + 1;
             end
         end
     end

endmodule
