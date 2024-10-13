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
module i2s
//-------------------------------------------------------------------------------------------------
(
	input  wire       clock,
	output reg        ck,
	output reg        ws,
	output reg        q,
	input  wire[15:0] l,
	input  wire[15:0] r
);
//-------------------------------------------------------------------------------------------------

reg[8:0] ce;
always @(negedge clock) ce <= ce+1'd1;

wire ce4 = &ce[3:0];
wire ce5 = &ce[4:0];
wire ce9a = ce[8] & ce[7] & ce[6] &  ce[5] & ce[4] & ce[3] & ce[2] & ce[1] & ce[0];
wire ce9b = ce[8] & ce[7] & ce[6] & ~ce[5] & ce[4] & ce[3] & ce[2] & ce[1] & ce[0];

reg[14:0] sr;
always @(posedge clock) if(ce9a) { q, sr } <= ws ? r : l; else if(ce5) { q, sr } <= { sr, 1'b0 };
always @(posedge clock) if(ce9b) ws <= ~ws;
always @(posedge clock) if(ce4) ck <= ~ck;

//-------------------------------------------------------------------------------------------------
endmodule
//-------------------------------------------------------------------------------------------------
