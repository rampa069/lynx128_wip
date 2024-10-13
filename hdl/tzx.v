//-------------------------------------------------------------------------------------------------
// This file is part of the Lynx 128K implementation by Kyp <kyp069@gmail.com>
// https://github.com/Kyp069/lynx128
//
//  This program is free software; you can redistribute it and/or modify it under the terms 
//  of the GNU General Public License as published by the Free Software Foundation;
//  either version 3 of the License, or (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
//  without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
//  See the GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License along with this program;
//  if not, If not, see <https://www.gnu.org/licenses/>.
//-------------------------------------------------------------------------------------------------
module tzx
//-------------------------------------------------------------------------------------------------
#
(
	parameter MS = 0
)
(
	input  wire       clock,
	input  wire       ce,

	input  wire       start,
	input  wire       stop,
	output wire       busy,
	output wire       tape,

	input  wire       dioEna,
	input  wire[26:0] dioA,
	input  wire[ 7:0] dioD,
	input  wire       dioW,
	input  wire[31:0] dioSize,

	output wire       sramWe,
	inout  wire[15:8] sramDQ,
	output wire[20:0] sramA
);
//-------------------------------------------------------------------------------------------------

wire tzxQ;
reg  tzxM;
wire tzxS;
wire tzxLn;
wire tzxLs;
reg  tzxRs;
reg  tzxAck;
wire tzxReq;
wire tzxS48;
reg[7:0] tzxD;
reg[20:0] tzxA;

reg[20:0] tzxSz;
always @(posedge clock) if(dioEna) tzxSz <= dioSize[20:0];

reg tzxReqd;
always @(posedge clock) tzxReqd <= tzxReq;

reg tzxReqp;
always @(posedge clock) tzxReqp <= tzxReq != tzxReqd;

always @(posedge clock) begin
	tzxRs <= 1'b0;
	if(start) begin
		tzxA <= 1'd0;
		tzxM <= 1'b1;
		tzxRs <= 1'b1;
		tzxAck <= 1'b1;
	end
	if(stop || tzxS || tzxS48 || tzxA == tzxSz) begin
		tzxM <= 1'b0;
		tzxAck <= 1'b0;
	end
	if(tzxReqp) begin
		tzxA <= tzxA+1'd1;
		tzxD <= sramDQ;
		tzxAck <= tzxReq;
	end
end

tzxplayer #(.TZX_MS(MS)) tzxplayer
(
	.clk         (clock  ),
	.ce          (ce     ),
	.restart_tape(tzxRs  ),
	.host_tap_in (tzxD   ),
	.tzx_req     (tzxReq ),
	.tzx_ack     (tzxAck ),
	.loop_start  (tzxLs  ),
	.loop_next   (tzxLn  ),
	.stop        (tzxS   ),
	.stop48k     (tzxS48 ),
	.cass_read   (tape   ),
	.cass_motor  (tzxM   ),
	.cass_running(busy   )
);

assign sramWe = ~dioW;
assign sramDQ = sramWe ? 8'bZ : dioD;
assign sramA = dioEna ? dioA[20:0] : tzxA;

//-------------------------------------------------------------------------------------------------
endmodule
//-------------------------------------------------------------------------------------------------
