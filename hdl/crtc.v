//-------------------------------------------------------------------------------------------------
module crtc
//-------------------------------------------------------------------------------------------------
(
	input  wire       clock,
	input  wire       ce,

	input  wire       reset,
	input  wire       cs,
	input  wire       rs,
	input  wire       rw,
	input  wire[ 7:0] d,
	output reg [ 7:0] q,

	output wire       de,
	output wire       hs,
	output wire       vs,

	input  wire       lpstb,
	output wire       cursor,

	output wire[13:0] ma,
	output wire[ 4:0] ra
);
//-------------------------------------------------------------------------------------------------

reg[4:0] ar;
always @(posedge clock) if(ce) if(!cs && !rs && !rw) ar <= d[4:0];

//-------------------------------------------------------------------------------------------------

reg[7:0] r0 = 8'd64-1;
reg[7:0] r1 = 8'd40;
reg[7:0] r2 = 8'd50-1;
reg[3:0] r3 = 8'd08;
always @(posedge clock) if(ce)
	if(!cs && rs && !rw)
		case(ar)
			0: r0 <= d;
			1: r1 <= d;
			2: r2 <= d;
			3: r3 <= d[3:0];
		endcase

reg[7:0] hc;
wire hcreset = hc >= r0;
always @(posedge clock, negedge reset)
	if(!reset) hc <= 1'd0;
	else if(ce) if(hcreset) hc <= 1'd0; else hc <= hc+1'd1;

wire hd = hc < r1;
assign hs = hc > r2 && hc < r2+r3+1;

//-------------------------------------------------------------------------------------------------

reg[6:0] r4 = 7'd39-1;
reg[4:0] r5 = 5'd8-1;
reg[6:0] r6 = 7'd30;
reg[6:0] r7 = 8'd32;
always @(posedge clock) if(ce)
	if(!cs && rs && !rw)
		case(ar)
			4: r4 <= d[6:0];
			5: r5 <= d[4:0];
			6: r6 <= d[6:0];
			7: r7 <= d[6:0];
		endcase

reg[4:0] lc;
wire lcreset = lc >= r5;
always @(posedge clock, negedge reset)
	if(!reset) lc <= 1'd0;
	else if(ce) if(hcreset) if(lcreset) lc <= 1'd0; else lc <= lc+1'd1;

reg[6:0] vc;
wire vcreset = vc >= r4;
always @(posedge clock, negedge reset)
	if(!reset) vc <= 1'd0;
	else if(ce) if(hcreset) if(vcreset) vc <= 1'd0; else if(lcreset) vc <= vc+1'd1;

wire vd = vc < r6;
assign vs = vc > r6 && vc < r6+16;

//-------------------------------------------------------------------------------------------------

always @(*) begin
	q = 8'hFF;
	if(!rs) q = { 3'b000, ar };
end

//-------------------------------------------------------------------------------------------------
endmodule
//-------------------------------------------------------------------------------------------------
