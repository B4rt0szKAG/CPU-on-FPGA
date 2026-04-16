module thesis (
	input sw0,
	output led0,
	output led1
);
	assign led0 = sw0;
	assign led1 = !sw0;

endmodule