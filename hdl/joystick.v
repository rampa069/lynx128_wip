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
module joystick
//-------------------------------------------------------------------------------------------------
(
	input  wire       clock,

	output reg        joyCk,
	output reg        joyLd,
	output wire       joyS,
	input  wire       joyQ,

	output reg [ 7:0] joy1,
	output reg [ 7:0] joy2
);
//-------------------------------------------------------------------------------------------------

reg[5:0] cc;
wire ce = cc == 49;
always @(posedge clock) if(ce) cc <= 1'd0; else cc <= cc+1'd1;

//-------------------------------------------------------------------------------------------------

initial joy1 = 8'h00;
initial joy2 = 8'h00;
initial joyCk = 1'b0;

reg[15:0] sr = 16'hFFFF;

always @(posedge clock) if(ce)
	if(joyS)
		if(sr[15:14] == 2'b00) begin
			joyCk <= 1'b0;
			joyLd <= 1'b0;
			sr <= 16'hFFFF;
			joy1 <= { 2'b00, sr[ 5], sr[ 4], sr[0], sr[1], sr[ 2], sr[ 3] };
			joy2 <= { 2'b00, sr[13], sr[12], sr[8], sr[9], sr[10], sr[11] };
		end
		else begin
			joyCk <= ~joyCk;
			if(!joyLd) joyLd <= 1'b1;
			if(joyCk) sr <= { sr[14:0], ~joyQ };
		end

//-------------------------------------------------------------------------------------------------

assign joyS = 1'b1;

//-------------------------------------------------------------------------------------------------
endmodule
//-------------------------------------------------------------------------------------------------
