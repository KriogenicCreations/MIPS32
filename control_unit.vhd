----------------------------------------------------------------------------------
-- Engineer: Evan Votta
-- 
-- Design Name: 	Mips32 in VHDL
-- Module Name:   instruction_fetch - Behavioral 
-- Project Name: 	Mips32 in VHDL

-- Description: 	This file is used to generalize the behavior of the control unit.
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
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;


ENTITY control_unit IS
	PORT (
				-- First the inputs
				SIGNAL CLOCK 				: IN STD_LOGIC;
				SIGNAL RESET 				: IN STD_LOGIC;
				SIGNAL opcode 				: IN STD_LOGIC_VECTOR (5 DOWNTO 0);
				SIGNAL mem_read 			: OUT STD_LOGIC;
				SIGNAL mem_to_regs 		: OUT STD_LOGIC;
				SIGNAL reg_destination 	: OUT STD_LOGIC;
				SIGNAL jump 				: OUT STD_LOGIC;
				SIGNAL alu_oper 			: OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
				SIGNAL mem_write 			: OUT STD_LOGIC;
				SIGNAL branch 				: OUT STD_LOGIC;
				SIGNAL branch_ne 			: OUT STD_LOGIC;
				SIGNAL alu_source 		: OUT STD_LOGIC;
				SIGNAL reg_write 			: OUT STD_LOGIC
			);
END control_unit;

ARCHITECTURE Behavioral OF control_unit IS

BEGIN

	-- Declare the insturctions according to opcode.
	
	SW 					<= '1' WHEN Opcode = "101011" ELSE '0'	;	-- Store word
	LW 					<= '1' WHEN Opcode = "100011" ELSE '0'	;	-- Load word
	BEQ 					<= '1' WHEN Opcode = "000100" ELSE '0'	;	-- Branch on equal
	JMP 					<= '1' WHEN Opcode = "000010" ELSE '0'	;	-- Jump
	BNE 					<= '1' WHEN Opcode = "000101" ELSE '0'	;	-- Branch on not equal
	ADDI 					<= '1' WHEN Opcode = "001000" ELSE '0'	;	-- Add immediate
	
	reg_destination 	<= '1' WHEN Opcode = "000000" ELSE '0'	;	-- Register destination, RTYPE
	
	branch 		<= BEQ							;
	branch_ne 	<= BNE							;
	jump 			<= JMP							;
	mem_read 	<= LW								;
	mem_to_regs <= LW								;
	alu_op(1) 	<= reg_destination			;
	alu_op(0) 	<= BEQ OR BNE					;
	mem_write 	<= SW								;
	ali_source 	<= LW OR SW OR ADDI			;
	reg_write 	<= R_format OR LW OR ADDI	;


END Behavioral;