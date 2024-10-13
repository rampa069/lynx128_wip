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
module lynx
//-------------------------------------------------------------------------------------------------
(
	input  wire      clock,
	input  wire      power,
	input  wire      reset,

	output wire      hsync,
	output wire      vsync,
	output wire      r,
	output wire      g,
	output wire      b,

	input  wire      tape,
	output wire[9:0] sound,

	output wire[3:0] row,
	input  wire[7:0] col,

	input  wire[7:0] joy0,
	input  wire[7:0] joy1,

	output wire      led,

	output wire       sdRd,
	output wire       sdWr,
	input  wire       sdAck,
	output wire[31:0] sdLba,
	input  wire[ 8:0] sdA,
	output wire[ 7:0] sdD,
	input  wire[ 7:0] sdQ,
	input  wire       sdW,
	input  wire       imgM,
	input  wire[63:0] imgSz,
	input  wire[63:0] status
);
//-------------------------------------------------------------------------------------------------

reg[5:0] ce;
always @(negedge clock, negedge power) if(!power) ce <= 1'd0; else if(ne1M0) ce <= 1'd0; else ce <= ce+1'd1;

//wire ne12M = ce[1:0] == 3;
wire pe12M = ce[1:0] == 1;

wire ne6M0 = ce[2:0] == 7;
wire pe6M0 = ce[2:0] == 3;

wire ne1M0 = ce == 47;
wire pe1M0 = ce == 23;

reg[4:0] ce15;
always @(negedge clock, negedge power) if(!power) ce15 <= 1'd0; else ce15 <= ce15+1'd1;

//wire ne1M5 = ce15 == 31;
wire pe1M5 = ce15 == 15;

//-------------------------------------------------------------------------------------------------

wire iorq;
wire mreq;
wire irq = ~cursor;
wire m1;
wire rd;
wire wr;

wire[15:0] a;
wire[ 7:0] d;
wire[ 7:0] q;

cpu cpu
(
	.clock  (clock  ),
	.ne     (ne6M0  ),
	.pe     (pe6M0  ),
	.reset  (reset  ),
	.iorq   (iorq   ),
	.mreq   (mreq   ),
	.irq    (irq    ),
	.m1     (m1     ),
	.rd     (rd     ),
	.wr     (wr     ),
	.a      (a      ),
	.d      (d      ),
	.q      (q      )
);

wire cpuce = pe6M0;

//-------------------------------------------------------------------------------------------------

reg[7:0] reg80;
wire wr80 = !iorq && !wr && !a[6] && a[2:1] == 2'b00;
always @(negedge reset, posedge  clock) if(!reset) reg80 <= 1'd0; else if(cpuce) if(wr80) reg80 <= q;

//-------------------------------------------------------------------------------------------------

reg[7:0] reg82;
wire wr7F = !iorq && !wr && !a[6] && a[2:1] == 2'b01;
always @(negedge reset, posedge clock) if(!reset) reg82 <= 1'd0; else if(cpuce) if(wr7F) reg82 <= q;

//-------------------------------------------------------------------------------------------------

reg[5:0] reg84;
wire wr84 = !iorq && !wr && !a[6] && a[2:1] == 2'b10;
always @(posedge clock) if(cpuce) if(wr84) reg84 <= q[5:0];

//-------------------------------------------------------------------------------------------------

wire[7:0] romQ;
rom #(24, "../rom/rom.hex") rom(clock, a[14:0], romQ);

//-------------------------------------------------------------------------------------------------

wire[7:0] ramQ;
ram #(64) ram(clock, a, q, ramQ, !mreq && !wr && !reg82[7]);

//-------------------------------------------------------------------------------------------------

wire[15:0] vmmA1 = { vduA, crtcMa[11:6], crtcRa[1:0], crtcMa[5:0] };
wire[ 7:0] vmmQ1;
wire[ 7:0] vmmQ2;

dprs #(64) vmm(clock, vmmA1, vmmQ1, a, q, vmmQ2, !mreq && !wr && reg82[6] && reg80[5]);

//-------------------------------------------------------------------------------------------------

wire crtcCs = !(!iorq && !wr && !a[6] && a[2:1] == 2'b11);
wire crtcRs = a[0];
wire crtcRw = wr;
wire crtcDe;
wire cursor;

wire[13:0] crtcMa;
wire[ 4:0] crtcRa;
wire[ 7:0] crtcQ;

UM6845R crtc
(
	.TYPE   (1'b0   ),
	.CLOCK  (clock  ),
	.CLKEN  (pe1M5  ),
	.nRESET (reset  ),
	.ENABLE (1'b1   ),
	.nCS    (crtcCs ),
	.R_nW   (crtcRw ),
	.RS     (crtcRs ),
	.DI     (q      ),
	.DO     (crtcQ  ),
	.HSYNC  (hsync  ),
	.VSYNC  (vsync  ),
	.DE     (crtcDe ),
	.FIELD  (       ),
	.CURSOR (cursor ),
	.MA     (crtcMa ),
	.RA     (crtcRa )
);

//-------------------------------------------------------------------------------------------------

wire      altg = reg80[4];
wire[1:0] vduA;
//wire[7:0] vduD = !reg80[5] ? vmmQ1 : 8'h00;

wire[2:0] rgb;

video video
(
	.clock  (clock  ),
	.hsync  (hsync  ),
	.ce     (pe12M  ),
	.de     (crtcDe ),
	.altg   (altg   ),
	.a      (vduA   ),
	.d      (vmmQ1  ),
	.r      (rgb[2] ),
	.g      (rgb[1] ),
	.b      (rgb[0] )
);

//-------------------------------------------------------------------------------------------------

assign d
	= !mreq && !reg82[3] && a[15:13] <= 2 ? romQ
	: !mreq && !reg82[3] && a[15:13] == 7 && !reg58[4] ? dosQ
	: !mreq && !reg82[2] ? ramQ
	: !mreq &&  reg82[1] ? vmmQ2
	: !iorq && !a[6] && a[2:1] == 2'b11 ? crtcQ
	: !iorq && !a[6] && a[2:1] == 2'b01 ? { 5'b00000, tape, 2'b00 }
	: !iorq && !a[6] && a[2:1] == 2'b00 ? col
	: !iorq && a[6:0] == 8'h7A ? joy0
	: !iorq && a[6:0] == 8'h7B ? joy1
	: !iorq && m1 && a[6:2] == 5'b10100 ? fdcQ
	: 8'hFF;

assign row = a[11:8];

assign sound = { 2'b00, {6{ tape }} } + { 2'b00, reg84 };

assign led = ~fdcSide;

//-------------------------------------------------------------------------------------------------

wire[7:0] dosQ;
rom #(8, "../rom/dosrom.hex") r07(clock, a[12:0], dosQ);

reg[4:0] reg58;
wire wr58 = !iorq && m1 && a[6:0] == 7'h58;
always @(posedge clock, negedge reset) if(!reset) reg58 <= 1'd0; else if(cpuce) if(wr58) reg58 <= q[4:0];

reg imgMp;
always @(posedge clock) imgMp <= imgM;

reg fdcDisk;
always @(posedge clock) if(imgM && !imgMp) fdcDisk <= |imgSz;

reg[2:0] fdcWc;
always @(posedge clock, negedge reset)
	if(!reset) fdcWc <= 3'b100;
	 else if(cpuce)
	 	if(fdcW) fdcWc <= 1'd0;
	 	else if(!fdcWc[2]) fdcWc <= fdcWc+1'd1;

wire      fdcR = !iorq && m1 && a[6:2] == 5'b10100;
wire      fdcW = !iorq && m1 && a[6:2] == 5'b10101;
wire[1:0] fdcA = a[1:0];
wire[7:0] fdcD = q;
wire[7:0] fdcQ;
wire      fdcSel = !reg58[3] && reg58[1:0] == 0;
wire      fdcRdy = fdcSel && fdcDisk;
wire      fdcSide = reg58[2] ^ status[6];
wire      fdcBusy;
wire      fdcPrep;

wire[31:0] debug;

wd17xx #(.MODEL(3), .CLK_EN(1000)) wd1793
(
	.clk_sys            (clock  ), // input  wire       // sys clock
	.ce                 (pe1M0  ), // input  wire       // ce at CPU clock rate
	.reset              (~reset ), // input  wire       // async reset
	.io_en              (1'b1   ), // input  wire
	.rd                 (fdcR   ), // input  wire       // i/o read
	.wr                 (fdcWc[1]), // input  wire      // i/o write
	.addr               (fdcA   ), // input  wire[ 1:0] // i/o port addr
	.din                (fdcD   ), // input  wire[ 7:0] // i/o data in
	.dout               (fdcQ   ), // output wire[ 7:0] // i/o data out
	.drq                (       ), // output wire       // DMA request
	.intrq              (       ), // output wire
	.busy               (fdcBusy), // output wire
	.wp                 (1'b0   ), // input  wire       // write protect
	.size_code          (3'd4   ), // input  wire[ 2:0]
	.layout             (status[7]), // input  wire     // 0 = Track-Side-Sector, 1 - Side-Track-Sector
	.side               (fdcSide), // input  wire
	.ready              (fdcRdy ), // input  wire
	.ready_n            (       ), // output wire
	.prepare            (fdcPrep), // output wire
	.disk_change_n      (       ), // output wire
	.disk_change_reset_n(1'b0   ), // input  wire
	.sd_rd              (sdRd   ), // output reg 
	.sd_wr              (sdWr   ), // output reg 
	.sd_ack             (sdAck  ), // input  wire
	.sd_lba             (sdLba  ), // output wire[31:0]
	.sd_buff_addr       (sdA    ), // input  wire[ 8:0]
	.sd_buff_din        (sdD    ), // output wire[ 7:0]
	.sd_buff_dout       (sdQ    ), // input  wire[ 7:0]
	.sd_buff_wr         (sdW    ), // input  wire
	.img_mounted        (imgM   ), // input  wire           // signaling that new image has been mounted
	.img_size           (imgSz[20:0]), // input  wire[19:0] // size of image in bytes. 1MB MAX!
	. debug             (debug  )
);

wire[3:0] dbgde, dbgpix;
digit2 #(80, 40) dbg0(clock, pe12M, hsync, vsync, debug[ 7: 0], dbgpix[0], dbgde[0]); // track
digit2 #(80, 50) dbg1(clock, pe12M, hsync, vsync, debug[15: 8], dbgpix[1], dbgde[1]); // sector
digit2 #(80, 60) dbg2(clock, pe12M, hsync, vsync, debug[23:16], dbgpix[2], dbgde[2]); // status
digit2 #(80, 70) dbg3(clock, pe12M, hsync, vsync, debug[31:24], dbgpix[3], dbgde[3]); // data

assign { r, g, b } = |dbgde ? {3{ |dbgpix }} : rgb;

//-------------------------------------------------------------------------------------------------
endmodule
//-------------------------------------------------------------------------------------------------
