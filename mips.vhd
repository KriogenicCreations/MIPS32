----------------------------------------------------------------------------------
-- Engineer: Evan Votta
-- 
-- Design Name: 	Mips32 in VHDL
-- Module Name:   mips - Behavioral 
-- Project Name: 	Mips32 in VHDL

-- Description: 	This file is used to map all of the internal signals to eachother.
--						It was the best way I could figure out how to connect all of the different
--						entities. I just called them all Components of this entitiy, then just
--						assigned signals to eachother. I don't think it is the optimal way to do
--						it, but it was the simplest.
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


--	Whole processor. Ins, outs, etc.
ENTITY mips IS
	PORT(
			-- First the inputs
			CLOCK 				: IN STD_LOGIC								;
			RESET 				: IN STD_LOGIC								;
			
			-- Then the outputs
			instr_out 			: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			program_counter 	: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)	;
			alu_prod_out 		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)	;
			read_data1_out 	: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)	;
			read_data2_out 	: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)	;
			write_data_out 	: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)	;
			write_reg_out 		: OUT STD_LOGIC_VECTOR (4 DOWNTO 0)	;
			jump_out 			: OUT STD_LOGIC							;
			branch_out 			: OUT STD_LOGIC							;
			branch_ne_out 		: OUT STD_LOGIC							;
			mem_write_out 		: OUT STD_LOGIC							;
			reg_write_out 		: OUT STD_LOGIC							;
			zero_out 			: OUT STD_LOGIC
		);
END mips;
-- End entity mips


-- Start architecture Behavioral
ARCHITECTURE Behavioral OF mips IS

	-- Get the instruction from program memory, FETCH
	COMPONENT instruction_fetch
		PORT (
					-- First the inputs
					CLOCK 							: IN STD_LOGIC								;
					RESET 							: IN STD_LOGIC								;
					branch 							: IN STD_LOGIC								;
					branch_ne 						: IN STD_LOGIC								;
					zero 								: IN STD_LOGIC								;
					jump 								: IN STD_LOGIC								;
					jump_addr 						: IN STD_LOGIC_VECTOR(7 DOWNTO 0)	;
					add_sum 							: IN STD_LOGIC_VECTOR(7 DOWNTO 0)	;
					
					-- Then the outputs
					program_counter_out 			: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)	;
					program_counter_incr_out 	: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)	;
					instr 							: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
				);
	END COMPONENT;
	-- End component instruction_fetch
	
	
	-- Tell the processor how to behave, DECODE
	COMPONENT control_unit
		PORT (
					-- First the inputs
					CLOCK 				: IN STD_LOGIC								;
					RESET 				: IN STD_LOGIC								;
					opcode 				: IN STD_LOGIC_VECTOR (5 DOWNTO 0)	;
					
					-- Then the outputs
					alu_oper 			: OUT STD_LOGIC_VECTOR (1 DOWNTO 0)	;
					alu_source 			: OUT STD_LOGIC							;
					reg_destination 	: OUT STD_LOGIC							;
					reg_write 			: OUT STD_LOGIC; --dif comp.
					branch 				: OUT STD_LOGIC							;
					branch_ne 			: OUT STD_LOGIC							;
					mem_read 			: OUT STD_LOGIC							;
					mem_to_regs 		: OUT STD_LOGIC							;
					mem_write 			: OUT STD_LOGIC							;
					jump 					: OUT STD_LOGIC
				);
	END COMPONENT;
	-- End component control unit
	
	
	
	-- Decode the instruction from prog mem., DECODE
	COMPONENT op_fetch
		PORT (
					-- First the inputs
					CLOCK 				: IN STD_LOGIC								;
					RESET 				: IN STD_LOGIC								;
					reg_write 			: IN STD_LOGIC								;
					reg_destination 	: IN STD_LOGIC								;
					mem_to_regs 		: IN STD_LOGIC								;
					alu_prod 			: IN STD_LOGIC_VECTOR (7 DOWNTO 0)	;
					read_data 			: IN STD_LOGIC_VECTOR (7 DOWNTO 0)	;
					instr 				: IN STD_LOGIC_VECTOR (31 DOWNTO 0)	;
					
					-- Then the outputs
					sign_ext 			: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)	;
					jump_instr 			: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)	;
					read_data_1 		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)	;
					read_data_2 		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)	;
					write_reg 			: OUT STD_LOGIC_VECTOR (4 DOWNTO 0)
				);
	END COMPONENT;
	-- End component op_fetch
	
	
	
	-- Execute the instruction, EXECUTE
	COMPONENT execute
		PORT (
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
	END COMPONENT;
	-- End component execute
	
	
	-- Other components
	
	-- The data memory
	COMPONENT data_memory
		PORT (
					-- First the inputs
					CLOCK 		: IN STD_LOGIC								;
					RESET 		: IN STD_LOGIC								;
					addr 			: IN STD_LOGIC_VECTOR (7 DOWNTO 0)	;
					write_data 	: IN STD_LOGIC_VECTOR (7 DOWNTO 0)	;
					mem_read 	: IN STD_LOGIC								;
					mem_write 	: IN STD_LOGIC								;
					
					-- Next the outputs (only one here)
					read_data 	: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
				);
	END COMPONENT;
	-- End component data_memory
	
	
	
	-- Declare the signals.
	SIGNAL program_counter_out 	: STD_LOGIC_VECTOR (7 DOWNTO 0)	;
	SIGNAL program_counter_incr 	: STD_LOGIC_VECTOR (7 DOWNTO 0)	;
	SIGNAL instr 						: STD_LOGIC_VECTOR (31 DOWNTO 0)	;
	SIGNAL sign_ext 					: STD_LOGIC_VECTOR (7 DOWNTO 0)	;
	-------
	SIGNAL add_sum 					: STD_LOGIC_VECTOR (7 DOWNTO 0)	;
	-------
	SIGNAL alu_prod 					: STD_LOGIC_VECTOR (7 DOWNTO 0)	;
	SIGNAL alu_oper 					: STD_LOGIC_VECTOR (1 DOWNTO 0)	;
	SIGNAL alu_source 				: STD_LOGIC								;
	-------
	SIGNAL branch 						: STD_LOGIC								;
	SIGNAL branch_ne 					: STD_LOGIC								;
	-------
	SIGNAL mem_read 					: STD_LOGIC								;
	SIGNAL mem_to_regs 				: STD_LOGIC								;
	SIGNAL mem_write 					: STD_LOGIC								;
	-------
	SIGNAL read_data 					: STD_LOGIC_VECTOR (7 DOWNTO 0)	;
	SIGNAL read_data_1 				: STD_LOGIC_VECTOR (7 DOWNTO 0)	;
	SIGNAL read_data_2 				: STD_LOGIC_VECTOR (7 DOWNTO 0)	;
	-------
	SIGNAL jump 						: STD_LOGIC								;
	SIGNAL jump_addr 					: STD_LOGIC_VECTOR (7 DOWNTO 0)	;
	SIGNAL jump_instr 				: STD_LOGIC_VECTOR (7 DOWNTO 0)	;
	-------
	SIGNAL reg_destination 			: STD_LOGIC								;
	SIGNAL reg_write 					: STD_LOGIC								;
	-------
	SIGNAL write_reg 					: STD_LOGIC_VECTOR (4 DOWNTO 0)	;
	-------
	SIGNAL zero 						: STD_LOGIC								;
	-- End signal declarations.
	
	
	
	-- Now begin mapping internals, etc.
	BEGIN
		-- Initial
		program_counter 	<= program_counter_out	;
		alu_prod_out 		<= alu_prod					;
		read_data1_out 	<= read_data_1				;
		read_data2_out 	<= read_data_2				;
		write_data_out 	<= read_data
			WHEN (mem_to_regs = '1')
			ELSE alu_prod									;
		write_reg_out 		<= write_reg				;
		instr_out			<= instr						;
		branch_out 			<= branch					;
		branch_ne_out 		<= branch_ne				;
		mem_write_out 		<= mem_write				;
		reg_write_out 		<= '0'
			WHEN write_reg = "00000"
			ELSE reg_write									;
		jump_out 			<= jump						;
		zero_out 			<= zero						;
		-- End initial
			
			
			
		-- FETCH stage.
		-- instruction_fetch
		IFE : instruction_fetch
			PORT MAP (
							CLOCK 							=> CLOCK						,
							RESET 							=> RESET						,
							program_counter_out 			=> program_counter_out	,
							instr 							=> instr						,
							add_sum 							=> add_sum					,
							program_counter_incr_out 	=> program_counter_incr	,
							branch 							=> branch					,
							branch_ne 						=> branch_ne				,
							zero 								=> zero						,
							jump 								=> jump						,
							jump_addr 						=> jump_addr
						);
		-- End instruction_fetch
		-- End FETCH stage.
		
		
		-- DECODE stage.
		-- control_unit
		CTRL : control_unit
			PORT MAP (
							CLOCK 				=> CLOCK						,
							RESET 				=> RESET						,
							opcode 				=> instr (31 DOWNTO 26)	,
							mem_read 			=> mem_read					,
							mem_to_regs 		=> mem_to_regs				,
							reg_destination 	=> reg_destination		,
							jump 					=> jump						,
							alu_oper 			=> alu_oper					,
							mem_write 			=> mem_write				,
							alu_source 			=> alu_source				,
							branch 				=> branch					,
							branch_ne 			=> branch_ne				,
							reg_write 			=> reg_write
						);
		-- End control_unit
						
						
		-- op_fetch
		ID : op_fetch
			PORT MAP (
							CLOCK 				=> CLOCK					,
							RESET 				=> RESET					,
							read_data_1 		=> read_data_1			,
							read_data_2 		=> read_data_2			,
							write_reg 			=> write_reg			,
							reg_write 			=> reg_write			,
							reg_destination 	=> reg_destination	,
							alu_prod 			=> alu_prod				,
							mem_to_regs 		=> mem_to_regs			,
							read_data 			=> read_data			,
							instr 				=> instr					,
							sign_ext 			=> sign_ext				,
							jump_instr 			=> jump_instr
						);
		-- End op_fetch
		-- End DECODE stage
					
			
		-- EXECUTE stage
		-- execute
		EX : execute
			PORT MAP (
							CLOCK 						=> CLOCK						,
							RESET 						=> RESET						,
							read_data_1 				=> read_data_1				,
							read_data_2 				=> read_data_2				,
							sign_ext 					=> sign_ext					,
							alu_source 					=> alu_source				,
							zero 							=> zero						,
							alu_prod 					=> alu_prod					,
							function_field 			=> instr (5 DOWNTO 0)	,
							alu_oper 					=> alu_oper					,
							add_sum 						=> add_sum					,
							program_counter_incr 	=> program_counter_incr	,
							jump_addr 					=> jump_addr				,
							jump_instr 					=> jump_instr
						);
		-- end execute
		-- end EXECUTE stage
		
		
		-- data_memory
		MEM : data_memory
			PORT MAP (
							CLOCK 		=> CLOCK			,
							RESET 		=> RESET			,
							read_data 	=> read_data	,
							addr 			=> alu_prod		,
							write_data 	=> read_data_2	,
							mem_read 	=> mem_read		,
							mem_write 	=> mem_write
						);
		-- end data_memory


end Behavioral;