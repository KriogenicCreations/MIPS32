----------------------------------------------------------------------------------
-- Engineer: Evan Votta
-- 
-- Design Name: 	Mips32 in VHDL
-- Module Name:   op_fetch - Behavioral 
-- Project Name: 	Mips32 in VHDL

-- Description: 	This file is used to fetch the operands.
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
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;


-- Start op_fetch entity
ENTITY op_fetch IS
	-- Begin port mapping
	PORT (			
				-- First the inputs
				CLOCK 				: IN STD_LOGIC								;
				RESET 				: IN STD_LOGIC								;
				reg_write 			: IN STD_LOGIC								;
				reg_destination 	: IN STD_LOGIC								;
				mem_to_regs 		: IN STD_LOGIC								;
				instr 				: IN STD_LOGIC_VECTOR (31 DOWNTO 0)	;
				alu_prod 			: IN STD_LOGIC_VECTOR (7 DOWNTO 0)	;
				read_data_0 			: IN STD_LOGIC_VECTOR (7 DOWNTO 0)	;
				
				-- Then the outputs
				sign_ext 			: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)	;
				jump_instr 			: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)	;
				read_data_1 		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)	;
				read_data_2 		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)	;
				write_reg 			: OUT STD_LOGIC_VECTOR (4 DOWNTO 0)
			);
END op_fetch;
-- End port mapping


ARCHITECTURE Behavioral OF op_fetch IS
	-- Start the architecture
	
	-- The array is the register file itself 32 wide.
	TYPE reg_file IS ARRAY (0 TO 31) OF STD_LOGIC_VECTOR (7 DOWNTO 0)	;		-- still don't know how that works, had to look it up.
	
	-- Declare some signals
	SIGNAL reg_array		 	: reg_file								;
	SIGNAL read_reg_addr1 	: STD_LOGIC_VECTOR (4 DOWNTO 0)	;
	SIGNAL read_reg_addr2 	: STD_LOGIC_VECTOR (4 DOWNTO 0)	;
	SIGNAL write_reg_addr 	: STD_LOGIC_VECTOR (4 DOWNTO 0)	;
	SIGNAL write_reg_addr0	: STD_LOGIC_VECTOR (4 DOWNTO 0)	;
	SIGNAL write_reg_addr1	: STD_LOGIC_VECTOR (4 DOWNTO 0)	;
	SIGNAL write_data			: STD_LOGIC_VECTOR (7 DOWNTO 0)	;
	SIGNAL instrs_15_0 		: STD_LOGIC_VECTOR (15 DOWNTO 0)	;
	SIGNAL instrs_25_0 		: STD_LOGIC_VECTOR (25 DOWNTO 0)	;
	-- End declaring the signal
	
	
	-- Begin
	BEGIN	
		-- Set some data
		
		
		-- Get the sections from the opcode, address, instructions, etc.
		read_reg_addr1 	<= instr (25 DOWNTO 21)	;
		read_reg_addr2 	<= instr (20 DOWNTO 16)	;
		write_reg_addr0 	<= instr (20 DOWNTO 16)	;
		write_reg_addr1 	<= instr (15 DOWNTO 11)	;
		instrs_15_0 		<= instr (15 DOWNTO 0)	;
		instrs_25_0 		<= instr (25 DOWNTO 0)	;
		-- Got the sections from opcode.
	
	
		-- Thank God you can declare arrays like this in VHDL, makes code shorter, etc.
		read_data_1 <= reg_array(CONV_INTEGER(read_reg_addr1 (4 DOWNTO 0)));
		read_data_2 <= reg_array(CONV_INTEGER(read_reg_addr2 (4 DOWNTO 0)));
	
	
		-- Now set the data to write, and addresses to write them at.
		write_data <= alu_prod (7 DOWNTO 0)
			WHEN (mem_to_regs = '0')
			ELSE read_data_0;
		
		write_reg_addr <= write_reg_addr1
			WHEN (reg_destination = '1')
			ELSE write_reg_addr0;
	
		-- Set up for sign extend, jump, etc.
		sign_ext 	<= instrs_15_0 (7 DOWNTO 0);
		jump_instr 	<= instrs_25_0 (7 DOWNTO 0);
		write_reg 	<= write_reg_addr				;
		
		
		-- Now start the process
		PROCESS
			BEGIN
				-- Waiting until clock tick event, risen edge.
				WAIT UNTIL ( CLOCK'EVENT ) AND ( CLOCK = '1' );
				
				-- Check to make sure we didn't reset.
				IF (RESET = '1') THEN
					-- If we get to this point, a reset occured, so look through the array of registers
					-- and assign to them the values from the loop (i).
					FOR i IN 0 TO 31 LOOP
						reg_array(i) <= CONV_STD_LOGIC_VECTOR(i,8);
					END LOOP;
					
				ELSIF (reg_write = '1') AND (write_reg_addr /= "0") THEN
					-- If we get to this point, there was no reset, we know to write
					reg_array(CONV_INTEGER(write_reg_addr (4 DOWNTO 0))) <= write_data; 
					-- Still confused as to why this way works and not the switch case way from earlier.
				END IF;
		END PROCESS;
	
END behavioral;