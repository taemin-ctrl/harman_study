module top_module(
    input clk,
    input areset,    // Freshly brainwashed Lemmings walk left.
    input bump_left,
    input bump_right,
    input ground,
    output walk_left,
    output walk_right,
    output aaah ); 
	
    // parameter LEFT=0, RIGHT=1, ...
    localparam LEFT =0, RIGHT = 1, GNDL = 2, GNDR =3;
    reg [1:0] state, next_state;

    always @(*) begin
        // State transition logic
        state = next_state;
    end

    always @(posedge clk, posedge areset) begin
        // State flip-flops with asynchronous reset
        if (areset) begin
        	next_state <= 0;
        end
        else begin
            case(state)
                LEFT: begin
                    if (!ground) next_state <= GNDL;
                    else if (bump_left) next_state <= RIGHT;
                    else next_state <= 0;
                end
                RIGHT: begin
                    if (!ground) next_state <= GNDR;
                    else if (bump_right) next_state <= LEFT;
                    else next_state <= 1;
                end
                GNDL: begin
                    if (ground) begin
                    	next_state <= LEFT;
                    end
                    else begin
                    	next_state <= GNDL;
                    end
                end
                GNDR: begin
                    if (ground) begin
                    	next_state <= RIGHT;
                    end
                    else begin
                    	next_state <= GNDR;
                    end
                end
            endcase
        end
    end

    // Output logic
    assign walk_left = (state == LEFT);
    assign walk_right = (state == RIGHT);
    assign aaah = (state == GNDL) | (state == GNDR);

endmodule