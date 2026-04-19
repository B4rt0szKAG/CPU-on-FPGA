module thesis (
	input  clk,
	input  sw0,
	input  rxd,
	output txd,
	output [7:0] led
);
	
	uart_rxd reciver (
		.clk(clk),
		.rx(rxd),
		.received_message(led)
	);

endmodule

module uart_rxd (
	input  wire clk,
	input  wire rx,
	output reg [7:0]  received_message
);
	localparam WAIT    = 2'b00,
				  START   = 2'b01,
				  RECEIVE = 2'b10,
				  END     = 2'b11;
				  
	localparam clock_frequency = 50000000,
				  baud_rate       = 10000;
	   
	localparam cnt_max = clock_frequency / baud_rate;
	
	reg [1:0]  state = WAIT, new_state;
	reg [2:0]  message_idx;
	reg [12:0] cnt;
	
	always @(posedge clk) begin
		case(state)
			WAIT: begin
				if (rx == 0) begin
					state <= START;
					message_idx <= 0;
					cnt <= 0;
				end
			end
			START: begin
				if (cnt == (cnt_max / 2)) begin
					if (rx == 0) begin
						state <= RECEIVE;
						cnt <= 0;
					end else begin
						state <= WAIT;
					end
				end
				cnt <= cnt + 1;
			end
			RECEIVE: begin
				if (cnt == cnt_max) begin
					received_message[message_idx] <= rx;
					
					if (message_idx == 7) begin
						state <= END;
					end
					
					message_idx <= message_idx + 1;
					cnt <= 0;
				end else begin
					cnt <= cnt + 1;
				end
			end
			END: begin
				if (cnt == cnt_max) begin
					state <= WAIT;
				end else begin
					cnt <= cnt + 1;
				end
			end
		endcase 
	end
endmodule


module uart_txd (
	input  wire     clk,
	input  wire      send,
	input	 wire [7:0] message,	
	output reg      tx
);

	localparam WAIT  = 2'b00,
				  START = 2'b01,
				  SEND  = 2'b10,
				  END   = 2'b11;
				  
	localparam clock_frequency = 50000000,
				  baud_rate       = 10000;
	   
	localparam cnt_max = clock_frequency / baud_rate;
	
	reg [1:0]  state = WAIT, new_state;
	reg [2:0]  message_idx;
	reg [12:0] cnt;
	
	always @(posedge clk) begin
		case(state) 
			WAIT: begin
				if(send == 1) begin
					state <= START;
					cnt <= 0;
					message_idx <= 0;
				end else begin
					tx <= 1;
				end
			end
			START: begin
				if(cnt == cnt_max - 1) begin
					state <= SEND;
					cnt <= 0;
				end else begin
					tx <= 0;
					cnt <= cnt + 1;
				end
			end
			SEND: begin
				if(cnt == cnt_max - 1) begin
					if(message_idx == 7) begin
						state <= END;
						cnt <= 0;
					end else begin
						message_idx <= message_idx + 1;
					end
					
					cnt <= 0;
				end else begin
					cnt <= cnt + 1;
				end
				
				tx <= message[message_idx];

			end
			END: begin
				if(cnt == cnt_max) begin
					state <= WAIT;
				end
				
				tx <= 1;
				cnt <= cnt + 1;
				
			end
			
		endcase
	end

endmodule
