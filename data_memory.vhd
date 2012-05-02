----------------------------------------------------------------------------------
-- Engineer: Evan Votta
-- 
-- Design Name: 	Mips32 in VHDL
-- Module Name:   op_fetch - Behavioral 
-- Project Name: 	Mips32 in VHDL

-- Description: 	This file is used to simulate the data memory.
--
--						As you will notice, I like to capitalize keywords sometimes, a habit I
--						picked up from using SQL.
--
--						I'm used to documenting/commenting in a Javadoc style, I wasn't sure
--						if	there was a sort of standardized or common commenting style in VHDL. I saw
--						something like it in Verilog, but I figured if anything, the commenting
--						style would be more like Ada than C. From what I've read, Verilog is a bit
--						easier to learn, but it is for Software Developers pretending to be Logic
--						Design Engineers. VHDL is more exact, more precise, the engineer has better
--						command of what goes on in the design, so I guess I'm glad we learned VHDL
--						instead of Verilog. I hope you approve of the way I comment, I tried to make
--						it as descriptive as possible.
--
--						I also like to tab some lines out so that they are equal length and broken
--						down into sections, I picked up the habit writing assembly code for PIC16's.
--
----------------------------------------------------------------------------------
LIBRARY 	IEEE								;
	USE 	IEEE.STD_LOGIC_1164.ALL		;
	USE 	IEEE.STD_LOGIC_ARITH.ALL	;
	USE 	IEEE.STD_LOGIC_SIGNED.ALL	;



ENTITY data_memory IS
	GENERIC ( 
					DEL 		: TIME := 10 ns;
					DISDEL 	: TIME := 10 ns
				);

	PORT ( 
				CLOCK	:	IN	STD_LOGIC;
				RESET	:	IN	STD_LOGIC;
				mem_read    : IN STD_LOGIC;
				addr   		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
				mem_write 	: IN STD_LOGIC;
				read_data_0	: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
				write_data	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
        );

END data_memory;

ARCHITECTURE Behavioral OF data_memory IS
	SIGNAL	INPUT : STD_LOGIC_VECTOR (31 DOWNTO 0);

  TYPE   MEMORY IS ARRAY (0 to 511) OF STD_LOGIC_VECTOR (7 DOWNTO 0);
  SIGNAL MEM : MEMORY;
  SIGNAL OUTS: STD_LOGIC_VECTOR (31 DOWNTO 0);

BEGIN

  PROCESS ( mem_write, CLOCK, addr, INPUT ) IS
  BEGIN
    IF FALLING_EDGE(CLOCK) THEN
      IF mem_write = '1' THEN
        MEM(CONV_INTEGER(addr(8 DOWNTO 0))) <= INPUT(31 DOWNTO 24);
        MEM(CONV_INTEGER(addr(8 DOWNTO 2) & "01")) <= INPUT(23 DOWNTO 16);
        MEM(CONV_INTEGER(addr(8 DOWNTO 2) & "10")) <= INPUT(15 DOWNTO 8);
			 MEM(CONV_INTEGER(addr(8 DOWNTO 2) & "11")) <= INPUT(7 DOWNTO 0);            
      END IF;
    END IF;
END PROCESS;


OUTS(31 downto 24) <= MEM(CONV_INTEGER(addr(8 downto 0)));
OUTS(23 downto 16) <= MEM(CONV_INTEGER(addr(8 downto 2) & "01"));
OUTS(15 downto 8) <= MEM(CONV_INTEGER(addr(8 downto 2) & "10"));
OUTS(7 downto 0) <= MEM(CONV_INTEGER(addr(8 downto 2) & "11"));

OUTPUT <= OUTS;

END Behavioral;