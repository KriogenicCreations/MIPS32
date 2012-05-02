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
	GENERIC ( RDEL, DISDEL : TIME := 10 ns );

  port ( 
  			INPUT     : in STD_LOGIC_VECTOR (31 downto 0);
       ADDRESS   : in STD_LOGIC_VECTOR (31 downto 0);
       MEM_WRITE : in STD_LOGIC;
       CLK       : in STD_LOGIC;
			OUTPUT    : out STD_LOGIC_VECTOR (31 downto 0)
         );

end DATAMEMORY;

architecture BEHAVIORAL of DATAMEMORY is

  type   MEMORY is array (0 to 511) of STD_LOGIC_VECTOR (7 downto 0);
  signal MEM : MEMORY;
  signal OUTS: STD_LOGIC_VECTOR(31 downto 0);

begin

  process ( MEM_WRITE, CLK, ADDRESS, INPUT ) is
  begin
    if FALLING_EDGE(CLK) then
      if MEM_WRITE = '1' then
        MEM(CONV_INTEGER(ADDRESS(8 downto 0))) <= INPUT(31 downto 24);
        MEM(CONV_INTEGER(ADDRESS(8 downto 2) & "01")) <= INPUT(23 downto 16);
        MEM(CONV_INTEGER(ADDRESS(8 downto 2) & "10")) <= INPUT(15 downto 8);
			 MEM(CONV_INTEGER(ADDRESS(8 downto 2) & "11")) <= INPUT(7 downto 0);            
      end if;
    end if;
end process;


OUTS(31 downto 24) <= MEM(CONV_INTEGER(ADDRESS(8 downto 0)));
OUTS(23 downto 16) <= MEM(CONV_INTEGER(ADDRESS(8 downto 2) & "01"));
OUTS(15 downto 8) <= MEM(CONV_INTEGER(ADDRESS(8 downto 2) & "10"));
OUTS(7 downto 0) <= MEM(CONV_INTEGER(ADDRESS(8 downto 2) & "11"));

OUTPUT <= OUTS;

end BEHAVIORAL;