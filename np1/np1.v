`default_nettype none
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
module np1
//-------------------------------------------------------------------------------------------------
(
	input  wire       clock50,

	output wire[ 1:0] sync,
	output wire[17:0] rgb,

	input  wire       ear,
	output wire[ 1:0] dsg,

	output wire       i2sCk,
	output wire       i2sWs,
	output wire       i2sQ,

	input  wire       ps2kCk,
	input  wire       ps2kD,

	output wire       joyCk,
	output wire       joyLd,
	output wire       joyS,
	input  wire       joyQ,

	output wire       sdcCs,
	output wire       sdcCk,
	output wire       sdcMosi,
	input  wire       sdcMiso,

	output wire       sramUb,
	output wire       sramLb,
	output wire       sramOe,
	output wire       sramWe,
	inout  wire[15:8] sramDQ,
	output wire[20:0] sramA,

	output wire       led,
	output wire       stm
);
//-------------------------------------------------------------------------------------------------

wire clock; // 48 MHz
wire power;

pll pll(clock50, clock, power);

//-------------------------------------------------------------------------------------------------

wire spiCk = sdcCk;
wire spiSs2;
wire spiSs3;
wire spiSs4;
wire spiSsIo;
wire spiMosi;
wire spiMiso;

substitute_mcu #(.sysclk_frequency(480)) controller
(
	.clk          (clock  ),
	.reset_in     (1'b1   ),
	.reset_out    (       ),
	.spi_cs       (sdcCs  ),
	.spi_clk      (sdcCk  ),
	.spi_mosi     (sdcMosi),
	.spi_miso     (sdcMiso),
	.spi_req      (       ),
	.spi_ack      (1'b1   ),
	.spi_ss2      (spiSs2 ),
	.spi_ss3      (spiSs3 ),
	.spi_ss4      (spiSs4 ),
	.spi_srtc     (       ),
	.conf_data0   (spiSsIo),
	.spi_toguest  (spiMosi),
	.spi_fromguest(spiMiso),
	.ps2k_clk_in  (ps2kCk ),
	.ps2k_dat_in  (ps2kD  ),
	.ps2k_clk_out (       ),
	.ps2k_dat_out (       ),
	.ps2m_clk_in  (1'b1   ),
	.ps2m_dat_in  (1'b1   ),
	.ps2m_clk_out (       ),
	.ps2m_dat_out (       ),
	.joy1         (8'hFF  ),
	.joy2         (8'hFF  ),
	.joy3         (8'hFF  ),
	.joy4         (8'hFF  ),
	.rxd          (1'b0   ),
	.txd          (       ),
	.intercept    (       ),
	.buttons      (32'hFFFFFFFF),
	.c64_keys     (64'hFFFFFFFFFFFFFFFF)
);

localparam confStr =
{
	"Lynx128;;",
	"O6,Side,Normal,Inverted;",
	"O7,Layout,Normal,Inverted;",
	"S0,LDFDSK,Load Disk;",
	"F0,TZX,Load TZX;",
	"V,v1.0;"
};

wire uiokCk;
wire uiokD;

wire       sdRd;
wire       sdWr;
wire       sdAck;
wire[31:0] sdLba;
wire[ 8:0] sdA;
wire[ 7:0] sdD;
wire[ 7:0] sdQ;
wire       sdW;
wire       imgM;
wire[63:0] imgSz;

wire[63:0] status;

wire novga;

user_io #(.STRLEN(102), .SD_IMAGES(1)) user_io
(
	.conf_str        (confStr),
	.conf_addr       (       ),
	.conf_chr        (8'd0   ),
	.clk_sys         (clock  ),
	.clk_sd          (clock  ),
	.SPI_CLK         (spiCk  ),
	.SPI_SS_IO       (spiSsIo),
	.SPI_MOSI        (spiMosi),
	.SPI_MISO        (spiMiso),
	.ps2_kbd_clk     (uiokCk ),
	.ps2_kbd_data    (uiokD  ),
	.ps2_kbd_clk_i   (1'b0),
	.ps2_kbd_data_i  (1'b0),
	.ps2_mouse_clk   (),
	.ps2_mouse_data  (),
	.ps2_mouse_clk_i (1'b0),
	.ps2_mouse_data_i(1'b0),
	.sd_rd           (sdRd   ),
	.sd_wr           (sdWr   ),
	.sd_ack          (sdAck  ),
	.sd_ack_conf     (),
	.sd_ack_x        (),
	.sd_lba          (sdLba  ),
    .sd_conf         (),
	.sd_sdhc         (),
	.sd_buff_addr    (sdA    ),
	.sd_din          (sdD    ),
	.sd_din_strobe   (sdW    ),
	.sd_dout         (sdQ    ),
	.sd_dout_strobe  (),
	.img_mounted     (imgM   ),
	.img_size        (imgSz  ),
	.rtc             (),
	.ypbpr           (),
	.status          (status ),
	.buttons         (),
	.switches        (),
	.no_csync        (),
	.core_mod        (),
	.key_pressed     (),
	.key_extended    (),
	.key_code        (),
	.key_strobe      (),
	.kbd_out_data    (8'd0),
	.kbd_out_strobe  (1'b0),
	.mouse_x         (),
	.mouse_y         (),
	.mouse_z         (),
	.mouse_flags     (),
	.mouse_strobe    (),
	.mouse_idx       (),
	.joystick_0      (),
	.joystick_1      (),
	.joystick_2      (),
	.joystick_3      (),
	.joystick_4      (),
	.i2c_start       (),
	.i2c_read        (),
	.i2c_addr        (),
	.i2c_subaddr     (),
	.i2c_dout        (),
	.i2c_din         (8'hFF),
	.i2c_ack         (1'b0 ),
	.i2c_end         (1'b0 ),
	.serial_data     (8'd0),
	.serial_strobe   (1'd0),
	.joystick_analog_0(),
	.joystick_analog_1(),
	.scandoubler_disable(novga)
);

wire[31:0] dioSize;
wire       dioEna;
wire[26:0] dioA;
wire[ 7:0] dioD;
wire       dioW;

data_io	data_io
(
	.clk_sys       (clock  ),
	.SPI_SCK       (spiCk  ),
	.SPI_SS2       (spiSs2 ),
	.SPI_SS4       (spiSs4 ),
	.SPI_DI        (spiMosi),
	.SPI_DO        (spiMiso),
	.clkref_n      (1'b0   ),
	.ioctl_filesize(dioSize),
	.ioctl_download(dioEna ),
	.ioctl_addr    (dioA   ),
	.ioctl_din     (8'd0   ),
	.ioctl_dout    (dioD   ),
	.ioctl_wr      (dioW   ),
	.ioctl_upload  (),
	.ioctl_index   (),
	.ioctl_fileext (),
	.QCSn          (1'b1),
	.QSCK          (1'b1),
	.QDAT          (4'hF),
	.hdd_clk       (1'b0),
	.hdd_cmd_req   (1'b0),
	.hdd_cdda_req  (1'b0),
	.hdd_dat_req   (1'b0),
	.hdd_cdda_wr   (),
	.hdd_status_wr (),
	.hdd_addr      (),
	.hdd_wr        (),
	.hdd_data_out  (),
	.hdd_data_in   (16'd0),
	.hdd_data_rd   (),
	.hdd_data_wr   (),
	.hdd0_ena      (),
	.hdd1_ena      ()
);

//-------------------------------------------------------------------------------------------------

wire      strb;
wire      make;
wire[7:0] code;

ps2k ps2k(clock, uiokCk, uiokD, strb, make, code);

wire[3:0] row;
wire[7:0] col;

keyboard keyboard(clock, strb, make, code, row, col);

reg F6 = 1'b1;
reg F7 = 1'b1;
reg F9 = 1'b1;
always @(posedge clock50) if(strb)
	case(code)
		8'h0B: F6 <= make;
		8'h83: F7 <= make;
		8'h01: F9 <= make;
	endcase

//-------------------------------------------------------------------------------------------------

wire[7:0] joy0;
wire[7:0] joy1;

joystick joystick(clock50, joyCk, joyLd, joyS, joyQ, joy0, joy1);

//-------------------------------------------------------------------------------------------------

wire tzxB;
wire tzxQ;

tzx #(48000) tzx
(
	.clock  (clock  ),
	.ce     (1'b1   ),
	.start  (!F6    ),
	.stop   (!F7    ),
	.busy   (tzxB   ),
	.tape   (tzxQ   ),
	.dioSize(dioSize),
	.dioEna (dioEna ),
	.dioA   (dioA   ),
	.dioD   (dioD   ),
	.dioW   (dioW   ),
	.sramWe (sramWe ),
	.sramDQ (sramDQ ),
	.sramA  (sramA  ) 
);

//-------------------------------------------------------------------------------------------------

wire[9:0] sound;

dsg #(.MSBI(9)) dsg1(clock, reset, sound, dsg[1]);
dsg #(.MSBI(9)) dsg0(clock, reset, sound, dsg[0]);

i2s i2s(clock50, i2sCk, i2sWs, i2sQ, { 1'b0, sound, 5'd0 }, { 1'b0, sound, 5'd0 });

//-------------------------------------------------------------------------------------------------

wire reset = power && F9;

wire hsync;
wire vsync;
wire r;
wire g;
wire b;

wire tape = tzxB ? tzxQ : ~ear;

lynx lynx
(
	.clock  (clock  ),
	.power  (power  ),
	.reset  (reset  ),
	.hsync  (hsync  ),
	.vsync  (vsync  ),
	.r      (r      ),
	.g      (g      ),
	.b      (b      ),
	.tape   (tape   ),
	.sound  (sound  ),
	.row    (row    ),
	.col    (col    ),
	.joy0   (~joy0  ),
	.joy1   (~joy1  ),
	.led    (led    ),

	.sdRd   (sdRd   ),
	.sdWr   (sdWr   ),
	.sdAck  (sdAck  ),
	.sdLba  (sdLba  ),
	.sdA    (sdA    ),
	.sdD    (sdD    ),
	.sdQ    (sdQ    ),
	.sdW    (sdW    ),
	.imgM   (imgM   ),
	.imgSz  (imgSz  ),
	.status (status )
);

//-------------------------------------------------------------------------------------------------

osd #(.OSD_COLOR(3'b010)) osd
(
	.clk_sys(clock  ),
	.ce     (1'b0   ),
	.SPI_SCK(spiCk  ),
	.SPI_SS3(spiSs3 ),
	.SPI_DI (spiMosi),
	.rotate (2'd0   ),
	.HBlank (1'b0   ),
	.VBlank (1'b0   ),
	.HSync  (hsync  ),
	.VSync  (vsync  ),
	.R_in   ({6{r}} ),
	.G_in   ({6{g}} ),
	.B_in   ({6{b}} ),
	.R_out  (rgb[17:12]),
	.G_out  (rgb[11: 6]),
	.B_out  (rgb[ 5: 0])
);

//-------------------------------------------------------------------------------------------------

assign sync = { 1'b1, ~(hsync ^vsync) };
//assign rgb = { {6{r}}, {6{g}}, {6{b}} };

assign sramUb = 1'b0;
assign sramLb = 1'b1;
assign sramOe = 1'b0;

assign led = led;
assign stm = 1'b0;

//-------------------------------------------------------------------------------------------------
endmodule
//-------------------------------------------------------------------------------------------------
