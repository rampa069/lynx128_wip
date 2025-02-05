
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller_rom2 is
generic
	(
		ADDR_WIDTH : integer := 15 -- Specify your actual ROM size to save LEs and unnecessary block RAM usage.
	);
port (
	clk : in std_logic;
	reset_n : in std_logic := '1';
	addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
	q : out std_logic_vector(31 downto 0);
	-- Allow writes - defaults supplied to simplify projects that don't need to write.
	d : in std_logic_vector(31 downto 0) := X"00000000";
	we : in std_logic := '0';
	bytesel : in std_logic_vector(3 downto 0) := "1111"
);
end entity;

architecture rtl of controller_rom2 is

	signal addr1 : integer range 0 to 2**ADDR_WIDTH-1;

	--  build up 2D array to hold the memory
	type word_t is array (0 to 3) of std_logic_vector(7 downto 0);
	type ram_t is array (0 to 2 ** ADDR_WIDTH - 1) of word_t;

	signal ram : ram_t:=
	(

     0 => (x"26",x"4c",x"26",x"4d"),
     1 => (x"1e",x"4f",x"26",x"4b"),
     2 => (x"ed",x"c2",x"4a",x"71"),
     3 => (x"ed",x"c2",x"5a",x"e6"),
     4 => (x"78",x"c7",x"48",x"e6"),
     5 => (x"87",x"dd",x"fe",x"49"),
     6 => (x"73",x"1e",x"4f",x"26"),
     7 => (x"c0",x"4a",x"71",x"1e"),
     8 => (x"d3",x"03",x"aa",x"b7"),
     9 => (x"eb",x"cd",x"c2",x"87"),
    10 => (x"87",x"c4",x"05",x"bf"),
    11 => (x"87",x"c2",x"4b",x"c1"),
    12 => (x"cd",x"c2",x"4b",x"c0"),
    13 => (x"87",x"c4",x"5b",x"ef"),
    14 => (x"5a",x"ef",x"cd",x"c2"),
    15 => (x"bf",x"eb",x"cd",x"c2"),
    16 => (x"c1",x"9a",x"c1",x"4a"),
    17 => (x"ec",x"49",x"a2",x"c0"),
    18 => (x"48",x"fc",x"87",x"e8"),
    19 => (x"bf",x"eb",x"cd",x"c2"),
    20 => (x"87",x"ef",x"fe",x"78"),
    21 => (x"c4",x"4a",x"71",x"1e"),
    22 => (x"49",x"72",x"1e",x"66"),
    23 => (x"26",x"87",x"fd",x"e9"),
    24 => (x"c2",x"1e",x"4f",x"26"),
    25 => (x"49",x"bf",x"eb",x"cd"),
    26 => (x"c2",x"87",x"d7",x"e6"),
    27 => (x"e8",x"48",x"da",x"ed"),
    28 => (x"ed",x"c2",x"78",x"bf"),
    29 => (x"bf",x"ec",x"48",x"d6"),
    30 => (x"da",x"ed",x"c2",x"78"),
    31 => (x"c3",x"49",x"4a",x"bf"),
    32 => (x"b7",x"c8",x"99",x"ff"),
    33 => (x"71",x"48",x"72",x"2a"),
    34 => (x"e2",x"ed",x"c2",x"b0"),
    35 => (x"0e",x"4f",x"26",x"58"),
    36 => (x"5d",x"5c",x"5b",x"5e"),
    37 => (x"ff",x"4b",x"71",x"0e"),
    38 => (x"ed",x"c2",x"87",x"c8"),
    39 => (x"50",x"c0",x"48",x"d5"),
    40 => (x"fd",x"e5",x"49",x"73"),
    41 => (x"4c",x"49",x"70",x"87"),
    42 => (x"ee",x"cb",x"9c",x"c2"),
    43 => (x"87",x"c3",x"cb",x"49"),
    44 => (x"c2",x"4d",x"49",x"70"),
    45 => (x"bf",x"97",x"d5",x"ed"),
    46 => (x"87",x"e2",x"c1",x"05"),
    47 => (x"c2",x"49",x"66",x"d0"),
    48 => (x"99",x"bf",x"de",x"ed"),
    49 => (x"d4",x"87",x"d6",x"05"),
    50 => (x"ed",x"c2",x"49",x"66"),
    51 => (x"05",x"99",x"bf",x"d6"),
    52 => (x"49",x"73",x"87",x"cb"),
    53 => (x"70",x"87",x"cb",x"e5"),
    54 => (x"c1",x"c1",x"02",x"98"),
    55 => (x"fe",x"4c",x"c1",x"87"),
    56 => (x"49",x"75",x"87",x"c0"),
    57 => (x"70",x"87",x"d8",x"ca"),
    58 => (x"87",x"c6",x"02",x"98"),
    59 => (x"48",x"d5",x"ed",x"c2"),
    60 => (x"ed",x"c2",x"50",x"c1"),
    61 => (x"05",x"bf",x"97",x"d5"),
    62 => (x"c2",x"87",x"e3",x"c0"),
    63 => (x"49",x"bf",x"de",x"ed"),
    64 => (x"05",x"99",x"66",x"d0"),
    65 => (x"c2",x"87",x"d6",x"ff"),
    66 => (x"49",x"bf",x"d6",x"ed"),
    67 => (x"05",x"99",x"66",x"d4"),
    68 => (x"73",x"87",x"ca",x"ff"),
    69 => (x"87",x"ca",x"e4",x"49"),
    70 => (x"fe",x"05",x"98",x"70"),
    71 => (x"48",x"74",x"87",x"ff"),
    72 => (x"0e",x"87",x"dc",x"fb"),
    73 => (x"5d",x"5c",x"5b",x"5e"),
    74 => (x"c0",x"86",x"f4",x"0e"),
    75 => (x"bf",x"ec",x"4c",x"4d"),
    76 => (x"48",x"a6",x"c4",x"7e"),
    77 => (x"bf",x"e2",x"ed",x"c2"),
    78 => (x"c0",x"1e",x"c1",x"78"),
    79 => (x"fd",x"49",x"c7",x"1e"),
    80 => (x"86",x"c8",x"87",x"cd"),
    81 => (x"cd",x"02",x"98",x"70"),
    82 => (x"fb",x"49",x"ff",x"87"),
    83 => (x"da",x"c1",x"87",x"cc"),
    84 => (x"87",x"ce",x"e3",x"49"),
    85 => (x"ed",x"c2",x"4d",x"c1"),
    86 => (x"02",x"bf",x"97",x"d5"),
    87 => (x"fe",x"d4",x"87",x"c3"),
    88 => (x"da",x"ed",x"c2",x"87"),
    89 => (x"cd",x"c2",x"4b",x"bf"),
    90 => (x"c0",x"05",x"bf",x"eb"),
    91 => (x"fd",x"c3",x"87",x"e9"),
    92 => (x"87",x"ee",x"e2",x"49"),
    93 => (x"e2",x"49",x"fa",x"c3"),
    94 => (x"49",x"73",x"87",x"e8"),
    95 => (x"71",x"99",x"ff",x"c3"),
    96 => (x"fb",x"49",x"c0",x"1e"),
    97 => (x"49",x"73",x"87",x"ce"),
    98 => (x"71",x"29",x"b7",x"c8"),
    99 => (x"fb",x"49",x"c1",x"1e"),
   100 => (x"86",x"c8",x"87",x"c2"),
   101 => (x"c2",x"87",x"fa",x"c5"),
   102 => (x"4b",x"bf",x"de",x"ed"),
   103 => (x"87",x"dd",x"02",x"9b"),
   104 => (x"bf",x"e7",x"cd",x"c2"),
   105 => (x"87",x"d7",x"c7",x"49"),
   106 => (x"c4",x"05",x"98",x"70"),
   107 => (x"d2",x"4b",x"c0",x"87"),
   108 => (x"49",x"e0",x"c2",x"87"),
   109 => (x"c2",x"87",x"fc",x"c6"),
   110 => (x"c6",x"58",x"eb",x"cd"),
   111 => (x"e7",x"cd",x"c2",x"87"),
   112 => (x"73",x"78",x"c0",x"48"),
   113 => (x"05",x"99",x"c2",x"49"),
   114 => (x"eb",x"c3",x"87",x"cd"),
   115 => (x"87",x"d2",x"e1",x"49"),
   116 => (x"99",x"c2",x"49",x"70"),
   117 => (x"fb",x"87",x"c2",x"02"),
   118 => (x"c1",x"49",x"73",x"4c"),
   119 => (x"87",x"cd",x"05",x"99"),
   120 => (x"e0",x"49",x"f4",x"c3"),
   121 => (x"49",x"70",x"87",x"fc"),
   122 => (x"c2",x"02",x"99",x"c2"),
   123 => (x"73",x"4c",x"fa",x"87"),
   124 => (x"05",x"99",x"c8",x"49"),
   125 => (x"f5",x"c3",x"87",x"cd"),
   126 => (x"87",x"e6",x"e0",x"49"),
   127 => (x"99",x"c2",x"49",x"70"),
   128 => (x"c2",x"87",x"d4",x"02"),
   129 => (x"02",x"bf",x"e6",x"ed"),
   130 => (x"c1",x"48",x"87",x"c9"),
   131 => (x"ea",x"ed",x"c2",x"88"),
   132 => (x"ff",x"87",x"c2",x"58"),
   133 => (x"73",x"4d",x"c1",x"4c"),
   134 => (x"05",x"99",x"c4",x"49"),
   135 => (x"f2",x"c3",x"87",x"ce"),
   136 => (x"fd",x"df",x"ff",x"49"),
   137 => (x"c2",x"49",x"70",x"87"),
   138 => (x"87",x"db",x"02",x"99"),
   139 => (x"bf",x"e6",x"ed",x"c2"),
   140 => (x"b7",x"c7",x"48",x"7e"),
   141 => (x"87",x"cb",x"03",x"a8"),
   142 => (x"80",x"c1",x"48",x"6e"),
   143 => (x"58",x"ea",x"ed",x"c2"),
   144 => (x"fe",x"87",x"c2",x"c0"),
   145 => (x"c3",x"4d",x"c1",x"4c"),
   146 => (x"df",x"ff",x"49",x"fd"),
   147 => (x"49",x"70",x"87",x"d4"),
   148 => (x"d5",x"02",x"99",x"c2"),
   149 => (x"e6",x"ed",x"c2",x"87"),
   150 => (x"c9",x"c0",x"02",x"bf"),
   151 => (x"e6",x"ed",x"c2",x"87"),
   152 => (x"c0",x"78",x"c0",x"48"),
   153 => (x"4c",x"fd",x"87",x"c2"),
   154 => (x"fa",x"c3",x"4d",x"c1"),
   155 => (x"f1",x"de",x"ff",x"49"),
   156 => (x"c2",x"49",x"70",x"87"),
   157 => (x"87",x"d9",x"02",x"99"),
   158 => (x"bf",x"e6",x"ed",x"c2"),
   159 => (x"a8",x"b7",x"c7",x"48"),
   160 => (x"87",x"c9",x"c0",x"03"),
   161 => (x"48",x"e6",x"ed",x"c2"),
   162 => (x"c2",x"c0",x"78",x"c7"),
   163 => (x"c1",x"4c",x"fc",x"87"),
   164 => (x"ac",x"b7",x"c0",x"4d"),
   165 => (x"87",x"d1",x"c0",x"03"),
   166 => (x"c1",x"4a",x"66",x"c4"),
   167 => (x"02",x"6a",x"82",x"d8"),
   168 => (x"6a",x"87",x"c6",x"c0"),
   169 => (x"73",x"49",x"74",x"4b"),
   170 => (x"c3",x"1e",x"c0",x"0f"),
   171 => (x"da",x"c1",x"1e",x"f0"),
   172 => (x"87",x"db",x"f7",x"49"),
   173 => (x"98",x"70",x"86",x"c8"),
   174 => (x"87",x"e2",x"c0",x"02"),
   175 => (x"c2",x"48",x"a6",x"c8"),
   176 => (x"78",x"bf",x"e6",x"ed"),
   177 => (x"cb",x"49",x"66",x"c8"),
   178 => (x"48",x"66",x"c4",x"91"),
   179 => (x"7e",x"70",x"80",x"71"),
   180 => (x"c0",x"02",x"bf",x"6e"),
   181 => (x"bf",x"6e",x"87",x"c8"),
   182 => (x"49",x"66",x"c8",x"4b"),
   183 => (x"9d",x"75",x"0f",x"73"),
   184 => (x"87",x"c8",x"c0",x"02"),
   185 => (x"bf",x"e6",x"ed",x"c2"),
   186 => (x"87",x"c9",x"f3",x"49"),
   187 => (x"bf",x"ef",x"cd",x"c2"),
   188 => (x"87",x"dd",x"c0",x"02"),
   189 => (x"87",x"c7",x"c2",x"49"),
   190 => (x"c0",x"02",x"98",x"70"),
   191 => (x"ed",x"c2",x"87",x"d3"),
   192 => (x"f2",x"49",x"bf",x"e6"),
   193 => (x"49",x"c0",x"87",x"ef"),
   194 => (x"c2",x"87",x"cf",x"f4"),
   195 => (x"c0",x"48",x"ef",x"cd"),
   196 => (x"f3",x"8e",x"f4",x"78"),
   197 => (x"5e",x"0e",x"87",x"e9"),
   198 => (x"0e",x"5d",x"5c",x"5b"),
   199 => (x"c2",x"4c",x"71",x"1e"),
   200 => (x"49",x"bf",x"e2",x"ed"),
   201 => (x"4d",x"a1",x"cd",x"c1"),
   202 => (x"69",x"81",x"d1",x"c1"),
   203 => (x"02",x"9c",x"74",x"7e"),
   204 => (x"a5",x"c4",x"87",x"cf"),
   205 => (x"c2",x"7b",x"74",x"4b"),
   206 => (x"49",x"bf",x"e2",x"ed"),
   207 => (x"6e",x"87",x"c8",x"f3"),
   208 => (x"05",x"9c",x"74",x"7b"),
   209 => (x"4b",x"c0",x"87",x"c4"),
   210 => (x"4b",x"c1",x"87",x"c2"),
   211 => (x"c9",x"f3",x"49",x"73"),
   212 => (x"02",x"66",x"d4",x"87"),
   213 => (x"da",x"49",x"87",x"c7"),
   214 => (x"c2",x"4a",x"70",x"87"),
   215 => (x"c2",x"4a",x"c0",x"87"),
   216 => (x"26",x"5a",x"f3",x"cd"),
   217 => (x"00",x"87",x"d8",x"f2"),
   218 => (x"00",x"00",x"00",x"00"),
   219 => (x"00",x"00",x"00",x"00"),
   220 => (x"1e",x"00",x"00",x"00"),
   221 => (x"c8",x"ff",x"4a",x"71"),
   222 => (x"a1",x"72",x"49",x"bf"),
   223 => (x"1e",x"4f",x"26",x"48"),
   224 => (x"89",x"bf",x"c8",x"ff"),
   225 => (x"c0",x"c0",x"c0",x"c2"),
   226 => (x"01",x"a9",x"c0",x"c0"),
   227 => (x"4a",x"c0",x"87",x"c4"),
   228 => (x"4a",x"c1",x"87",x"c2"),
   229 => (x"4f",x"26",x"48",x"72"),
   230 => (x"5c",x"5b",x"5e",x"0e"),
   231 => (x"4b",x"71",x"0e",x"5d"),
   232 => (x"d0",x"4c",x"d4",x"ff"),
   233 => (x"78",x"c0",x"48",x"66"),
   234 => (x"db",x"ff",x"49",x"d6"),
   235 => (x"ff",x"c3",x"87",x"f4"),
   236 => (x"c3",x"49",x"6c",x"7c"),
   237 => (x"4d",x"71",x"99",x"ff"),
   238 => (x"99",x"f0",x"c3",x"49"),
   239 => (x"05",x"a9",x"e0",x"c1"),
   240 => (x"ff",x"c3",x"87",x"cb"),
   241 => (x"c3",x"48",x"6c",x"7c"),
   242 => (x"08",x"66",x"d0",x"98"),
   243 => (x"7c",x"ff",x"c3",x"78"),
   244 => (x"c8",x"49",x"4a",x"6c"),
   245 => (x"7c",x"ff",x"c3",x"31"),
   246 => (x"b2",x"71",x"4a",x"6c"),
   247 => (x"31",x"c8",x"49",x"72"),
   248 => (x"6c",x"7c",x"ff",x"c3"),
   249 => (x"72",x"b2",x"71",x"4a"),
   250 => (x"c3",x"31",x"c8",x"49"),
   251 => (x"4a",x"6c",x"7c",x"ff"),
   252 => (x"d0",x"ff",x"b2",x"71"),
   253 => (x"78",x"e0",x"c0",x"48"),
   254 => (x"c2",x"02",x"9b",x"73"),
   255 => (x"75",x"7b",x"72",x"87"),
   256 => (x"26",x"4d",x"26",x"48"),
   257 => (x"26",x"4b",x"26",x"4c"),
   258 => (x"4f",x"26",x"1e",x"4f"),
   259 => (x"5c",x"5b",x"5e",x"0e"),
   260 => (x"76",x"86",x"f8",x"0e"),
   261 => (x"49",x"a6",x"c8",x"1e"),
   262 => (x"c4",x"87",x"fd",x"fd"),
   263 => (x"6e",x"4b",x"70",x"86"),
   264 => (x"01",x"a8",x"c0",x"48"),
   265 => (x"73",x"87",x"c6",x"c3"),
   266 => (x"9a",x"f0",x"c3",x"4a"),
   267 => (x"02",x"aa",x"d0",x"c1"),
   268 => (x"e0",x"c1",x"87",x"c7"),
   269 => (x"f4",x"c2",x"05",x"aa"),
   270 => (x"c8",x"49",x"73",x"87"),
   271 => (x"87",x"c3",x"02",x"99"),
   272 => (x"73",x"87",x"c6",x"ff"),
   273 => (x"c2",x"9c",x"c3",x"4c"),
   274 => (x"cd",x"c1",x"05",x"ac"),
   275 => (x"49",x"66",x"c4",x"87"),
   276 => (x"1e",x"71",x"31",x"c9"),
   277 => (x"d4",x"4a",x"66",x"c4"),
   278 => (x"ea",x"ed",x"c2",x"92"),
   279 => (x"fe",x"81",x"72",x"49"),
   280 => (x"c4",x"87",x"c2",x"d5"),
   281 => (x"c0",x"1e",x"49",x"66"),
   282 => (x"d9",x"ff",x"49",x"e3"),
   283 => (x"49",x"d8",x"87",x"d9"),
   284 => (x"87",x"ee",x"d8",x"ff"),
   285 => (x"c2",x"1e",x"c0",x"c8"),
   286 => (x"fd",x"49",x"da",x"dc"),
   287 => (x"ff",x"87",x"d7",x"f1"),
   288 => (x"e0",x"c0",x"48",x"d0"),
   289 => (x"da",x"dc",x"c2",x"78"),
   290 => (x"4a",x"66",x"d0",x"1e"),
   291 => (x"ed",x"c2",x"92",x"d4"),
   292 => (x"81",x"72",x"49",x"ea"),
   293 => (x"87",x"ca",x"d3",x"fe"),
   294 => (x"ac",x"c1",x"86",x"d0"),
   295 => (x"87",x"cd",x"c1",x"05"),
   296 => (x"c9",x"49",x"66",x"c4"),
   297 => (x"c4",x"1e",x"71",x"31"),
   298 => (x"92",x"d4",x"4a",x"66"),
   299 => (x"49",x"ea",x"ed",x"c2"),
   300 => (x"d3",x"fe",x"81",x"72"),
   301 => (x"dc",x"c2",x"87",x"ef"),
   302 => (x"66",x"c8",x"1e",x"da"),
   303 => (x"c2",x"92",x"d4",x"4a"),
   304 => (x"72",x"49",x"ea",x"ed"),
   305 => (x"d6",x"d1",x"fe",x"81"),
   306 => (x"49",x"66",x"c8",x"87"),
   307 => (x"49",x"e3",x"c0",x"1e"),
   308 => (x"87",x"f3",x"d7",x"ff"),
   309 => (x"d7",x"ff",x"49",x"d7"),
   310 => (x"c0",x"c8",x"87",x"c8"),
   311 => (x"da",x"dc",x"c2",x"1e"),
   312 => (x"e0",x"ef",x"fd",x"49"),
   313 => (x"ff",x"86",x"d0",x"87"),
   314 => (x"e0",x"c0",x"48",x"d0"),
   315 => (x"fc",x"8e",x"f8",x"78"),
   316 => (x"5e",x"0e",x"87",x"d1"),
   317 => (x"0e",x"5d",x"5c",x"5b"),
   318 => (x"ff",x"4d",x"71",x"1e"),
   319 => (x"66",x"d4",x"4c",x"d4"),
   320 => (x"b7",x"c3",x"48",x"7e"),
   321 => (x"87",x"c5",x"06",x"a8"),
   322 => (x"e2",x"c1",x"48",x"c0"),
   323 => (x"fe",x"49",x"75",x"87"),
   324 => (x"75",x"87",x"e3",x"e1"),
   325 => (x"4b",x"66",x"c4",x"1e"),
   326 => (x"ed",x"c2",x"93",x"d4"),
   327 => (x"49",x"73",x"83",x"ea"),
   328 => (x"87",x"df",x"cc",x"fe"),
   329 => (x"4b",x"6b",x"83",x"c8"),
   330 => (x"c8",x"48",x"d0",x"ff"),
   331 => (x"7c",x"dd",x"78",x"e1"),
   332 => (x"ff",x"c3",x"49",x"73"),
   333 => (x"73",x"7c",x"71",x"99"),
   334 => (x"29",x"b7",x"c8",x"49"),
   335 => (x"71",x"99",x"ff",x"c3"),
   336 => (x"d0",x"49",x"73",x"7c"),
   337 => (x"ff",x"c3",x"29",x"b7"),
   338 => (x"73",x"7c",x"71",x"99"),
   339 => (x"29",x"b7",x"d8",x"49"),
   340 => (x"7c",x"c0",x"7c",x"71"),
   341 => (x"7c",x"7c",x"7c",x"7c"),
   342 => (x"7c",x"7c",x"7c",x"7c"),
   343 => (x"c0",x"7c",x"7c",x"7c"),
   344 => (x"66",x"c4",x"78",x"e0"),
   345 => (x"ff",x"49",x"dc",x"1e"),
   346 => (x"c8",x"87",x"dc",x"d5"),
   347 => (x"26",x"48",x"73",x"86"),
   348 => (x"0e",x"87",x"ce",x"fa"),
   349 => (x"5d",x"5c",x"5b",x"5e"),
   350 => (x"7e",x"71",x"1e",x"0e"),
   351 => (x"6e",x"4b",x"d4",x"ff"),
   352 => (x"fe",x"ed",x"c2",x"1e"),
   353 => (x"fa",x"ca",x"fe",x"49"),
   354 => (x"70",x"86",x"c4",x"87"),
   355 => (x"c3",x"02",x"9d",x"4d"),
   356 => (x"ee",x"c2",x"87",x"c3"),
   357 => (x"6e",x"4c",x"bf",x"c6"),
   358 => (x"d9",x"df",x"fe",x"49"),
   359 => (x"48",x"d0",x"ff",x"87"),
   360 => (x"c1",x"78",x"c5",x"c8"),
   361 => (x"4a",x"c0",x"7b",x"d6"),
   362 => (x"82",x"c1",x"7b",x"15"),
   363 => (x"aa",x"b7",x"e0",x"c0"),
   364 => (x"ff",x"87",x"f5",x"04"),
   365 => (x"78",x"c4",x"48",x"d0"),
   366 => (x"c1",x"78",x"c5",x"c8"),
   367 => (x"7b",x"c1",x"7b",x"d3"),
   368 => (x"9c",x"74",x"78",x"c4"),
   369 => (x"87",x"fc",x"c1",x"02"),
   370 => (x"7e",x"da",x"dc",x"c2"),
   371 => (x"8c",x"4d",x"c0",x"c8"),
   372 => (x"03",x"ac",x"b7",x"c0"),
   373 => (x"c0",x"c8",x"87",x"c6"),
   374 => (x"4c",x"c0",x"4d",x"a4"),
   375 => (x"97",x"cb",x"e9",x"c2"),
   376 => (x"99",x"d0",x"49",x"bf"),
   377 => (x"c0",x"87",x"d2",x"02"),
   378 => (x"fe",x"ed",x"c2",x"1e"),
   379 => (x"ee",x"cc",x"fe",x"49"),
   380 => (x"70",x"86",x"c4",x"87"),
   381 => (x"ef",x"c0",x"4a",x"49"),
   382 => (x"da",x"dc",x"c2",x"87"),
   383 => (x"fe",x"ed",x"c2",x"1e"),
   384 => (x"da",x"cc",x"fe",x"49"),
   385 => (x"70",x"86",x"c4",x"87"),
   386 => (x"d0",x"ff",x"4a",x"49"),
   387 => (x"78",x"c5",x"c8",x"48"),
   388 => (x"6e",x"7b",x"d4",x"c1"),
   389 => (x"6e",x"7b",x"bf",x"97"),
   390 => (x"70",x"80",x"c1",x"48"),
   391 => (x"05",x"8d",x"c1",x"7e"),
   392 => (x"ff",x"87",x"f0",x"ff"),
   393 => (x"78",x"c4",x"48",x"d0"),
   394 => (x"c5",x"05",x"9a",x"72"),
   395 => (x"c0",x"48",x"c0",x"87"),
   396 => (x"1e",x"c1",x"87",x"e5"),
   397 => (x"49",x"fe",x"ed",x"c2"),
   398 => (x"87",x"c2",x"ca",x"fe"),
   399 => (x"9c",x"74",x"86",x"c4"),
   400 => (x"87",x"c4",x"fe",x"05"),
   401 => (x"c8",x"48",x"d0",x"ff"),
   402 => (x"d3",x"c1",x"78",x"c5"),
   403 => (x"c4",x"7b",x"c0",x"7b"),
   404 => (x"c2",x"48",x"c1",x"78"),
   405 => (x"26",x"48",x"c0",x"87"),
   406 => (x"4c",x"26",x"4d",x"26"),
   407 => (x"4f",x"26",x"4b",x"26"),
   408 => (x"5c",x"5b",x"5e",x"0e"),
   409 => (x"cc",x"4b",x"71",x"0e"),
   410 => (x"87",x"d8",x"02",x"66"),
   411 => (x"8c",x"f0",x"c0",x"4c"),
   412 => (x"74",x"87",x"d8",x"02"),
   413 => (x"02",x"8a",x"c1",x"4a"),
   414 => (x"02",x"8a",x"87",x"d1"),
   415 => (x"02",x"8a",x"87",x"cd"),
   416 => (x"87",x"d7",x"87",x"c9"),
   417 => (x"ea",x"fb",x"49",x"73"),
   418 => (x"74",x"87",x"d0",x"87"),
   419 => (x"f9",x"49",x"c0",x"1e"),
   420 => (x"1e",x"74",x"87",x"e0"),
   421 => (x"d9",x"f9",x"49",x"73"),
   422 => (x"fe",x"86",x"c8",x"87"),
   423 => (x"1e",x"00",x"87",x"fc"),
   424 => (x"bf",x"ed",x"db",x"c2"),
   425 => (x"c2",x"b9",x"c1",x"49"),
   426 => (x"ff",x"59",x"f1",x"db"),
   427 => (x"ff",x"c3",x"48",x"d4"),
   428 => (x"48",x"d0",x"ff",x"78"),
   429 => (x"ff",x"78",x"e1",x"c8"),
   430 => (x"78",x"c1",x"48",x"d4"),
   431 => (x"78",x"71",x"31",x"c4"),
   432 => (x"c0",x"48",x"d0",x"ff"),
   433 => (x"4f",x"26",x"78",x"e0"),
   434 => (x"e1",x"db",x"c2",x"1e"),
   435 => (x"fe",x"ed",x"c2",x"1e"),
   436 => (x"ee",x"c5",x"fe",x"49"),
   437 => (x"70",x"86",x"c4",x"87"),
   438 => (x"87",x"c3",x"02",x"98"),
   439 => (x"26",x"87",x"c0",x"ff"),
   440 => (x"4b",x"35",x"31",x"4f"),
   441 => (x"20",x"20",x"5a",x"48"),
   442 => (x"47",x"46",x"43",x"20"),
   443 => (x"00",x"00",x"00",x"00"),
   444 => (x"00",x"00",x"00",x"00"),
		others => (others => x"00")
	);
	signal q1_local : word_t;

	-- Altera Quartus attributes
	attribute ramstyle: string;
	attribute ramstyle of ram: signal is "no_rw_check";

begin  -- rtl

	addr1 <= to_integer(unsigned(addr(ADDR_WIDTH-1 downto 0)));

	-- Reorganize the read data from the RAM to match the output
	q(7 downto 0) <= q1_local(3);
	q(15 downto 8) <= q1_local(2);
	q(23 downto 16) <= q1_local(1);
	q(31 downto 24) <= q1_local(0);

	process(clk)
	begin
		if(rising_edge(clk)) then 
			if(we = '1') then
				-- edit this code if using other than four bytes per word
				if (bytesel(3) = '1') then
					ram(addr1)(3) <= d(7 downto 0);
				end if;
				if (bytesel(2) = '1') then
					ram(addr1)(2) <= d(15 downto 8);
				end if;
				if (bytesel(1) = '1') then
					ram(addr1)(1) <= d(23 downto 16);
				end if;
				if (bytesel(0) = '1') then
					ram(addr1)(0) <= d(31 downto 24);
				end if;
			end if;
			q1_local <= ram(addr1);
		end if;
	end process;
  
end rtl;

