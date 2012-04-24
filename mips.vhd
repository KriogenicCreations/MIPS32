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
--						Also, I'm used to documenting/commenting in a Javadoc style, I wasn't sure
--						if	there was a sort of standardized or common commenting style in VHDL. I saw
--						something like it in Verilog, but I figured if anything, the commenting
--						style would be more like Ada than C. From what I've read, Verilog is a bit
--						easier to learn, but it is for Software Developers pretending to be Logic
--						Design Engineers. VHDL is more exact, more precise, the engineer has better
--						command of what goes on in the design, so I guess I'm glad we learned VHDL
--						instead of Verilog. I hope you approve of the way I comment, I tried to make
--						it as descriptive as possible.
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


--	Whole processor. Ins, outs, etc.
ENTITY mips IS
	PORT(
			-- First the inputs
			CLOCK 				: IN STD_LOGIC;
			RESET 				: IN STD_LOGIC;
			
			-- Then the outputs
			instr_out 			: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			program_counter 	: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			alu_prod_out 		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			read_data1_out 	: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			read_data2_out 	: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			write_data_out 	: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			write_reg_out 		: OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
			jump_out 			: OUT STD_LOGIC;
			branch_out 			: OUT STD_LOGIC;
			branch_ne_out 		: OUT STD_LOGIC;
			mem_write_out 		: OUT STD_LOGIC;
			reg_write_out 		: OUT STD_LOGIC;
			zero_out 			: OUT STD_LOGIC
		);
END mips;
-- End entity mips


-- Start architecture Behavioral
ARCHITECTURE Behavioral OF mips IS

	-- Get the instruction from program memory, FETCH
	COMPONENT instrfetch
		PORT (
					-- First the inputs
					CLOCK 							: IN STD_LOGIC;
					RESET 							: IN STD_LOGIC;
					branch 							: IN STD_LOGIC;
					branch_ne 						: IN STD_LOGIC;
					zero 								: IN STD_LOGIC;
					jump 								: IN STD_LOGIC;
					jump_addr 						: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
					add_sum 							: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
					
					-- Then the outputs
					program_counter_out 			: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
					program_counter_incr_out 	: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
					instr 							: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
				);
	END COMPONENT;
	-- End component instrfetch
	
	
	
	-- Decode the instruction from prog mem., DECODE
	COMPONENT operandfetch
		PORT (
					-- First the inputs
					CLOCK 				: IN STD_LOGIC;
					RESET 				: IN STD_LOGIC;
					reg_write 			: IN STD_LOGIC;
					reg_destination 	: IN STD_LOGIC;
					mem_to_regs 		: IN STD_LOGIC;
					alu_prod 			: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
					read_data 			: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
					instr 				: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
					
					-- Then the outputs
					sign_ext 			: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
					jump_instr 			: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
					read_data_1 		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
					read_data_2 		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
					write_reg 			: OUT STD_LOGIC_VECTOR (4 DOWNTO 0)
				);
	END COMPONENT;
	-- End component operandfetch
	
	
	-- Tell the processor how to behave, DECODE
	COMPONENT controlunit
		PORT (
					Opcode : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
					reg_destination : OUT STD_LOGIC;
					branch : OUT STD_LOGIC;
					branch_ne : OUT STD_LOGIC;
					MemRead : OUT STD_LOGIC;
					mem_to_regs : OUT STD_LOGIC;
					ALU_Op : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
					MemWrite : OUT STD_LOGIC;
					ALUSrc : OUT STD_LOGIC;
					reg_write : OUT STD_LOGIC;
					jump : OUT STD_LOGIC;
					CLOCK, RESET : IN STD_LOGIC
				);
	END COMPONENT;
	
	
	-- Execute the instruction, EXECUTE
	COMPONENT execution
		PORT (
					read_data_1 : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
					read_data_2 : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
					sign_ext : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
					jump_instr : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
					jump_addr : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
					ALUSrc : IN STD_LOGIC;
					zero : OUT STD_LOGIC;
					alu_prod : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
					Funct_field : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
					ALU_Op : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
					add_sum : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
					program_counter_incr : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
					CLOCK, RESET : IN STD_LOGIC
				);
	END COMPONENT;
	
	
	
	COMPONENT datamemory
		PORT (
					read_data : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
					Address : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
					Write_Data : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
					MemRead : IN STD_LOGIC;
					MemWrite : IN STD_LOGIC;
					CLOCK, RESET : IN STD_LOGIC
				);
	END COMPONENT;
	
	
	
	-- Connect signals.
	SIGNAL add_sum : STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL alu_prod : STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL ALU_Op : STD_LOGIC_VECTOR (1 DOWNTO 0);
	SIGNAL ALUSrc : STD_LOGIC;
	SIGNAL branch : STD_LOGIC;
	SIGNAL branch_ne : STD_LOGIC;
	SIGNAL instr : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL jump : STD_LOGIC;
	SIGNAL jump_addr : STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL jump_instr : STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL MemRead : STD_LOGIC;
	SIGNAL mem_to_regs : STD_LOGIC;
	SIGNAL MemWrite : STD_LOGIC;
	SIGNAL program_counter_out : STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL program_counter_incr : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL read_data : STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL read_data_1 : STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL read_data_2 : STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL reg_destination : STD_LOGIC;
	SIGNAL reg_write : STD_LOGIC;
	SIGNAL sign_ext : STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL write_reg : STD_LOGIC_VECTOR (4 DOWNTO 0);
	SIGNAL zero : STD_LOGIC;
	
	
	
	-- Now begin
	BEGIN
		program_counter <= program_counter_Out;
		alu_prod_out <= alu_prod;
		read_data1_out <= read_data_1;
		read_data2_out <= read_data_2;
		write_data_out <= read_data
			WHEN (mem_to_regs = '1')
			ELSE alu_prod;
		write_reg_out <= write_reg;
		instr_out<= instr;
		branch_out <= branch;
		branch_ne_out <= branch_ne;
		zero_out <= zero;
		jump_out <= jump;
		mem_write_out <= MemWrite;
		reg_write_out <= '0'
			WHEN write_reg = "00000"
			ELSE reg_write;
			
			
			
			
		IFE : instrfetch
			PORT MAP (
							program_counter_Out => program_counter_Out,
							instr => instr,
							add_sum => add_sum,
							program_counter_incr_out => program_counter_incr,
							branch => branch,
							branch_ne => branch_ne,
							zero => zero,
							jump => jump,
							jump_addr => jump_addr,
							CLOCK => CLOCK,
							RESET => RESET
						);
						
						
		ID : operandfetch
			PORT MAP (
							read_data_1 => read_data_1,
							read_data_2 => read_data_2,
							write_reg => write_reg,
							reg_write => reg_write,
							reg_destination => reg_destination,
							alu_prod => alu_prod,
							mem_to_regs => mem_to_regs,
							read_data => read_data,
							instr => instr,
							sign_ext => sign_ext,
							jump_instr => jump_instr,
							CLOCK => CLOCK,
							RESET => RESET
						);
		
		
		CTRL : controlunit
			PORT MAP (
							Opcode => instr (31 DOWNTO 26),
							reg_destination => reg_destination,
							jump => jump,
							branch => branch,
							branch_ne => branch_ne,
							MemRead => MemRead,
							mem_to_regs => mem_to_regs,
							ALU_Op => ALU_Op,
							MemWrite => MemWrite,
							ALUSrc => ALUSrc,
							reg_write => reg_write,
							CLOCK => CLOCK,
							RESET => RESET
						);
			
			
		EX : execution
			PORT MAP (
							read_data_1 => read_data_1,
							read_data_2 => read_data_2,
							sign_ext => sign_ext,
							ALUSrc => ALUSrc,
							zero => zero,
							alu_prod => alu_prod,
							Funct_field => instr (5 DOWNTO 0),
							ALU_Op => ALU_Op,
							add_sum => add_sum,
							program_counter_incr => program_counter_incr,
							jump_addr => jump_addr,
							jump_instr => jump_instr,
							CLOCK => CLOCK,RESET => RESET
						);
		
		
		
		MEM : datamemory
			PORT MAP (
							read_data => read_data,
							Address => alu_prod,
							Write_Data => read_data_2,
							MemRead => MemRead,
							MemWrite => MemWrite,
							CLOCK => CLOCK,
							RESET => RESET
						);


end Behavioral;