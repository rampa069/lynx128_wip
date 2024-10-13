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
module cpu
//-------------------------------------------------------------------------------------------------
(
	input  wire       clock,
	input  wire       ne,
	input  wire       pe,
	input  wire       reset,
	output wire       iorq,
	output wire       mreq,
	input  wire       irq,
	output wire       m1,
	output wire       rd,
	output wire       wr,
	output wire[15:0] a,
	input  wire[ 7:0] d,
	output wire[ 7:0] q
);

T80pa Cpu
(
	.CLK    (clock),
	.CEN_p  (pe   ),
	.CEN_n  (ne   ),
	.RESET_n(reset),
	.BUSRQ_n(1'b1 ),
	.WAIT_n (1'b1 ),
	.BUSAK_n(     ),
	.HALT_n (     ),
	.RFSH_n (     ),
	.MREQ_n (mreq ),
	.IORQ_n (iorq ),
	.NMI_n  (1'b1 ),
	.INT_n  (irq  ),
	.M1_n   (m1   ),
	.RD_n   (rd   ),
	.WR_n   (wr   ),
	.A      (a    ),
	.DI     (d    ),
	.DO     (q    ),
	.OUT0   (1'b0 ),
	.REG    (     ),
	.DIRSet (1'b0 ),
	.DIR    (212'd0)
);

//-------------------------------------------------------------------------------------------------
endmodule
//-------------------------------------------------------------------------------------------------
