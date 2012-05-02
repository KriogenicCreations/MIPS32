----------------------------------------------------------------------------------
-- Engineer: Evan Votta
-- 
-- Design Name: 	Mips32 in VHDL
-- Module Name:   op_fetch - Behavioral 
-- Project Name: 	Mips32 in VHDL

-- Description: 	This file is used to execute the instructions.
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
USE 		IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY execute IS
	PORT(
				-- First the inputs
				CLOCK 					: IN STD_LOGIC								;
				RESET 					: IN STD_LOGIC								;
				program_counter_incr : IN STD_LOGIC_VECTOR (7 DOWNTO 0)	;
				function_field 		: IN STD_LOGIC_VECTOR (5 DOWNTO 0)	;
				alu_source 				: IN STD_LOGIC								;
				alu_oper 				: IN STD_LOGIC_VECTOR (1 DOWNTO 0)	;
				read_data_1 			: IN STD_LOGIC_VECTOR (7 DOWNTO 0)	;
				read_data_2 			: IN STD_LOGIC_VECTOR (7 DOWNTO 0)	;
				sign_ext 				: IN STD_LOGIC_VECTOR (7 DOWNTO 0)	;
				jump_instr 				: IN STD_LOGIC_VECTOR (7 DOWNTO 0)	;
						
				-- Then the outputs
				jump_addr 				: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)	;
				alu_prod 				: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)	;
				add_sum 					: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)	;
				zero 						: OUT STD_LOGIC
		);
END execute;

ARCHITECTURE Behavioral OF execute IS
	-- start the architecture

	-- Declare some signals.
	SIGNAL first_input	:	STD_LOGIC_VECTOR (7 DOWNTO 0)	;
	SIGNAL second_input	:	STD_LOGIC_VECTOR (7 DOWNTO 0)	;
	SIGNAL alu_result		: 	STD_LOGIC_VECTOR (7 DOWNTO 0)	;
	SIGNAL jump_add 		: 	STD_LOGIC_VECTOR (7 DOWNTO 0)	;
	SIGNAL branch_add		: 	STD_LOGIC_VECTOR (8 DOWNTO 0)	;
	SIGNAL alu				: 	STD_LOGIC_VECTOR (2 DOWNTO 0)	;	-- come back and change this to 2 bits instead of 3 Evan

	BEGIN
		--begin
		
		-- Inputs
		first_input 	<= read_data_1				;
		second_input 	<= read_data_2
			WHEN 			(alu_source = '0')
			ELSE 			(sign_ext (7 DOWNTO 0))	;
		
		-- Set ALU bits.
		alu(2) 	<= (function_field(1) AND alu_oper(1)) 								OR alu_oper(0)																;
		alu(1) 	<= (NOT function_field(2)) 												OR (NOT alu_oper(1))														;
		alu(0) 	<= (function_field(1) AND function_field(3) AND alu_oper(1)) 	OR(function_field(0) AND function_field(2) AND alu_oper(1))	;
		zero 		<= '1' WHEN (alu_result (7 DOWNTO 0) = "00000000") 				ELSE '0'																		;
		alu_prod <= ("0000000" & alu_result (7)) WHEN alu = "111" 					ELSE alu_result (7 DOWNTO 0)												;
		
		-- Do the rest.
		branch_add 	<= sign_ext (7 DOWNTO 0) + program_counter_incr (7 DOWNTO 2)	;
		add_sum 		<= branch_add (7 DOWNTO 0)													;
		jump_add 	<= jump_instr (7 DOWNTO 0)													;
		jump_addr 	<= jump_add																		;
		
		
		PROCESS (alu, first_input, second_input)
			-- start the process
			BEGIN 
				IF (alu = "000") 		THEN
					alu_prod <= first_input AND second_input;
					
				ELSIF (alu = "001") 	THEN
					alu_prod <= first_input OR second_input;
					
				ELSIF (alu = "010") 	THEN
					alu_prod <= first_input + second_input;
					
				ELSIF (alu = "011") 	THEN
					alu_prod <= "00000000";
					
				ELSIF (alu = "100") 	THEN
					alu_prod <= "00000000";
					
				ELSIF (alu = "101") 	THEN
					alu_prod <= "00000000";
					
				ELSIF (alu = "110") 	THEN
					alu_prod <= first_input - second_input;
					
				ELSIF (alu = "111") 	THEN
					alu_prod <= first_input - second_input;
					
				ELSE
					alu_prod <= "00000000";
					
				END IF;
			END PROCESS;
END Behavioral;