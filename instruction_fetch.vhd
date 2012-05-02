----------------------------------------------------------------------------------
-- Engineer: Evan Votta
-- 
-- Design Name: 	Mips32 in VHDL
-- Module Name:   instruction_fetch - Behavioral 
-- Project Name: 	Mips32 in VHDL

-- Description: 	This file is used to complete the instruction_fetch phase.
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
USE 		IEEE.STD_LOGIC_1164.ALL		;
USE 		IEEE.STD_LOGIC_ARITH.ALL	;
USE 		IEEE.STD_LOGIC_UNSIGNED.ALL;

LIBRARY 	LPM								;
USE		LPM.LMP_COMPONENTS.ALL		;


-- Entity instruction_fetch
ENTITY instruction_fetch IS
	PORT (
				-- First the inputs				
				SIGNAL CLOCK 							: IN STD_LOGIC								;
				SIGNAL RESET 							: IN STD_LOGIC								;
				SIGNAL branch 							: IN STD_LOGIC								;
				SIGNAL branch_ne 						: IN STD_LOGIC								;
				SIGNAL zero 							: IN STD_LOGIC								;
				SIGNAL jump 							: IN STD_LOGIC								;
				SIGNAL jump_addr 						: IN STD_LOGIC_VECTOR(7 DOWNTO 0)	;
				SIGNAL add_sum 						: IN STD_LOGIC_VECTOR(7 DOWNTO 0)	;
				
				-- Then the outputs
				SIGNAL program_counter_out 		: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)	;
				SIGNAL program_counter_incr_out 	: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)	;
				SIGNAL instr 							: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
			);
END instruction_fetch;
-- End instruction_fetch;


-- Start the architecture of the instruction_fetch
ARCHITECTURE Behavioral OF instruction_fetch IS
	SIGNAL program_counter 			: STD_LOGIC_VECTOR (9 DOWNTO 0);
	SIGNAL program_counter_incr 	: STD_LOGIC_VECTOR (9 DOWNTO 0);
	SIGNAL program_counter_next	: STD_LOGIC_VECTOR (7 DOWNTO 0);

	-- Begin mapping
	BEGIN
		
		PORT MAP (
						address => program_counter(9 DOWNTO 2),
						q 		  => instr	
					);
						
		program_counter_out 						<= program_counter (7 DOWNTO 0)			;
		program_counter_incr_out 				<= program_counter_incr (7 DOWNTO 0)	;
		program_counter_incr (9 DOWNTO 2) 	<= program_counter (9 DOWNTO 2) + 1		;
		program_counter_incr (1 DOWNTO 0) 	<= "00"											;

		program_counter_next 					<= Add_result
			WHEN 	((branch = '1') 		AND (zero = '1') AND (branch_ne = '0'))
				OR ((branch_ne = '1') 	AND (zero = '0'))
			ELSE jump_addr 				WHEN (jump = '1')
			ELSE program_counter_incr (9 DOWNTO 2)												;
					
		PROCESS
			BEGIN
				WAIT UNTIL ( CLOCK'EVENT ) AND ( CLOCK = '1' );
				IF RESET = '1' THEN program_counter	<="0000000000"				;
				ELSE program_counter (9 DOWNTO 2) 	<= program_counter_next	;
				END IF;
		END PROCESS;

END Behavioral;