//-------------------------------------------------------------------------------------------------
// This file is part of the Lynx 48K/96K/96Kscorpion implementation by Kyp <kyp069@gmail.com>
// https://github.com/Kyp069/lynx
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
module dprs
//-------------------------------------------------------------------------------------------------
#
(
	parameter KB = 0,
	parameter FN = ""
)
(
	input  wire                      clock,
	input  wire[$clog2(KB*1024)-1:0] a1,
	output reg [                7:0] q1,
	input  wire[$clog2(KB*1024)-1:0] a2,
	input  wire[                7:0] d2,
	output reg [                7:0] q2,
	input  wire                      w2
);
//-------------------------------------------------------------------------------------------------

reg[7:0] mem[0:(KB*1024)-1];
initial if(FN != "") $readmemh(FN, mem, 0);

wire w1 = 1'b0;
wire[7:0] d1 = 8'hFF;

always @(posedge clock) if(w1) begin mem[a1] <= d1; q1 <= d1; end else q1 <= mem[a1];
always @(posedge clock) if(w2) begin mem[a2] <= d2; q2 <= d2; end else q2 <= mem[a2];

//-------------------------------------------------------------------------------------------------
endmodule
//-------------------------------------------------------------------------------------------------
