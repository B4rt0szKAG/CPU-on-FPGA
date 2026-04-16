module thesis (
	input  clk,
	input  sw0,
	input  rxd,
	output led0,
	output led1
);
	
	uart_rxd reciver (
		.clk(clk),
		.rx(rxd),
		.out(led1)
	);
	
	assign led0 = sw0;

endmodule

module uart_rxd (
	input wire clk,
	input wire rx,
	output reg out
);
	always @(posedge clk) begin
		out <= rx;
	end
	
endmodule