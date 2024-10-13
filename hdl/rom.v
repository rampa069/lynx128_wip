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
module rom
//-------------------------------------------------------------------------------------------------
#
(
	parameter KB = 0,
	parameter FN = ""
)
(
	input  wire                      clock,
	input  wire[$clog2(KB*1024)-1:0] a,
	output reg [                7:0] q
);
//-------------------------------------------------------------------------------------------------

reg[7:0] mem[(KB*1024)-1:0];
initial if(FN != "") $readmemh(FN, mem);

wire w = 1'b0;
wire[7:0] d = 8'hFF;

always @(posedge clock) if(w) begin mem[a] <= d; q <= d; end else q <= mem[a];

//-------------------------------------------------------------------------------------------------
endmodule
//-------------------------------------------------------------------------------------------------
