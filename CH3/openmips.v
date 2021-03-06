`include "defines.v"

module openmips(
    input  wire               clock,
	input  wire               reset,
	input  wire[`RegisterBus] rom_data_input,
	output wire[`RegisterBus] rom_address_output,
	output wire               rom_chip_enable
);
	// Fetch
    wire[`AddressBus]         program_counter;
	wire[`AddressBus]         id_program_counter_input;
	wire[`DataBus]            id_instruction_input;
	// Decode
	wire[`ALUOpBus]           id_aluop_output;
	wire[`ALUSelBus]          id_alusel_output;
	wire[`RegisterBus]        id_reg1_output;
	wire[`RegisterBus]        id_reg2_output;
	wire                      id_write_reg_enable_output;
	wire[`RegisterAddressBus] id_write_reg_address_output;
	// Execute
	wire[`ALUOpBus]           ex_aluop_input;
	wire[`ALUSelBus]          ex_alusel_input;

	wire[`RegisterBus]        ex_reg1_input;
	wire[`RegisterBus]        ex_reg2_input;

	wire                      ex_write_reg_enable_intput;
	wire[`RegisterAddressBus] ex_write_reg_address_intput;
	
	wire                      ex_write_reg_enable_output;
	wire[`RegisterAddressBus] ex_write_reg_address_output;
	wire[`RegisterBus]        ex_write_reg_data_output;
	
	wire                      ex_whilo_output;
	wire[`RegisterBus]        ex_hi_output;
	wire[`RegisterBus]        ex_lo_output;

	// Memory
	wire                      mem_whilo_input;
	wire[`RegisterBus]        mem_hi_input;
	wire[`RegisterBus]        mem_lo_input;

	wire                      mem_write_reg_enable_input;
	wire[`RegisterAddressBus] mem_write_reg_address_input;
	wire[`RegisterBus]        mem_write_reg_data_input;
	
	wire                      mem_write_reg_enable_output;
	wire[`RegisterAddressBus] mem_write_reg_address_output;
	wire[`RegisterBus]        mem_write_reg_data_output;

	wire                      mem_whilo_output;
	wire[`RegisterBus]        mem_hi_output;
	wire[`RegisterBus]        mem_lo_output;

	// WriteBack
	wire                      wb_write_reg_enable_intput;
	wire[`RegisterAddressBus] wb_write_reg_address_intput;
	wire[`RegisterBus]        wb_write_reg_data_intput;

	wire[`RegisterBus]        wb_hi_output;
	wire[`RegisterBus]        wb_lo_output;
	wire                      wb_whilo_output;
	
	wire[`RegisterBus]        hi_output;
	wire[`RegisterBus]        lo_output;

	wire                      reg1_read;
	wire                      reg2_read;
	wire[`RegisterBus]        reg1_data;
	wire[`RegisterBus]        reg2_data;
	wire[`RegisterAddressBus] reg1_address;
	wire[`RegisterAddressBus] reg2_address;
	
	pc_reg pc_reg0(
		.clock(clock),
		.reset(reset),
		.program_counter(program_counter),
		.chip_enable(rom_chip_enable)
	);
	
	assign rom_address_output = program_counter;
	
	if_id if_id0(
		.clock(clock), 
		.reset(reset),
		
		.if_program_counter(program_counter),
		.if_instruction(rom_data_input),
		
		.id_program_counter(id_program_counter_input),
		.id_instruction(id_instruction_input)
	);
	
	id id0(
		.reset(reset),
		.program_counter_input(id_program_counter_input),
		.instruction_input(id_instruction_input),
		
		.reg1_data_input(reg1_data),
		.reg2_data_input(reg2_data),
		
		.reg1_read_output(reg1_read),
		.reg2_read_output(reg2_read),

		.reg1_address_output(reg1_address),
		.reg2_address_output(reg2_address),

		.ex_write_reg_enable_intput(ex_write_reg_enable_output),
		.ex_write_reg_data_input(ex_write_reg_data_output),
		.ex_write_reg_address_intput(ex_write_reg_address_output),

		.mem_write_reg_enable_input(mem_write_reg_enable_output),
		.mem_write_reg_data_input(mem_write_reg_data_output),
		.mem_write_reg_address_input(mem_write_reg_address_output),
		

		.aluop_output(id_aluop_output),
		.alusel_output(id_alusel_output),
		.reg1_output(id_reg1_output),
		.reg2_output(id_reg2_output),
		.write_reg_address_output(id_write_reg_address_output),
		.write_reg_enable_output(id_write_reg_enable_output)
		
	);
	
	regfile regfile1(
		.clock(clock),
		.reset(reset),

		.write_enable(wb_write_reg_enable_intput),
		.write_address(wb_write_reg_address_intput),
		.write_data(wb_write_reg_data_intput),

		.read_enable1(reg1_read),
		.read_address1(reg1_address),
		.read_data1(reg1_data),

		.read_enable2(reg2_read),
		.read_address2(reg2_address),
		.read_data2(reg2_data)
	);
	
	id_ex id_ex0(
		.clock(clock),
		.reset(reset),

		.id_aluop_input(id_aluop_output),
		.id_alusel_input(id_alusel_output),
		.id_reg1_input(id_reg1_output),
		.id_reg2_input(id_reg2_output),
		.id_write_reg_address_input(id_write_reg_address_output),
		.id_write_reg_enable_input(id_write_reg_enable_output),
		
		.ex_aluop_output(ex_aluop_input),
		.ex_alusel_output(ex_alusel_input),
		.ex_reg1_output(ex_reg1_input),
		.ex_reg2_output(ex_reg2_input),
		.ex_write_reg_address_output(ex_write_reg_address_intput),
		.ex_write_reg_enable_output(ex_write_reg_enable_intput)
	);
	 
	ex ex0(
		.reset(reset),

		.aluop_input(ex_aluop_input),
		.alusel_input(ex_alusel_input),
		
		.reg1_input(ex_reg1_input),
		.reg2_input(ex_reg2_input),

		.write_reg_address_input(ex_write_reg_address_intput),
		.write_reg_enable_input(ex_write_reg_enable_intput),

		.write_reg_address_output(ex_write_reg_address_output),
		.write_reg_enable_output(ex_write_reg_enable_output),
		.write_reg_data_output(ex_write_reg_data_output),

		.hi_input(hi_output),
		.lo_input(lo_output),

		.wb_whilo_input(wb_whilo_output),
		.wb_hi_input(wb_hi_output),
		.wb_lo_input(wb_lo_output),

		.mem_whilo_input(mem_whilo_output),
		.mem_hi_input(mem_hi_output),
		.mem_lo_input(mem_lo_output),

		.whilo_output(ex_whilo_output),
		.hi_output(ex_hi_output),
		.lo_output(ex_lo_output)
	);
	
	ex_mem ex_mem0(
		.clock(clock),
		.reset(reset),

		.ex_write_reg_address_intput(ex_write_reg_address_output),
		.ex_write_reg_enable_intput(ex_write_reg_enable_output),
		.ex_write_reg_data_intput(ex_write_reg_data_output),

		.ex_whilo_input(ex_whilo_output),
		.ex_hi_input(ex_hi_output),
		.ex_lo_input(ex_lo_output),

		.mem_write_reg_address_output(mem_write_reg_address_input),
		.mem_write_reg_enable_output(mem_write_reg_enable_input),
		.mem_write_reg_data_output(mem_write_reg_data_input),

		.mem_whilo_output(mem_whilo_input),
		.mem_hi_output(mem_hi_input),
		.mem_lo_output(mem_lo_input)
	);
	
	
	mem mem0(
		.reset(reset),

		.write_reg_address_input(mem_write_reg_address_input),
		.write_reg_enable_input(mem_write_reg_enable_input),
		.write_reg_data_input(mem_write_reg_data_input),

		.whilo_input(mem_whilo_input),
		.hi_input(mem_hi_input),
		.lo_input(mem_lo_input),

		.write_reg_address_output(mem_write_reg_address_output),
		.write_reg_enable_output(mem_write_reg_enable_output),
		.write_reg_data_output(mem_write_reg_data_output),

		.whilo_output(mem_whilo_output),
		.hi_output(mem_hi_output),
		.lo_output(mem_lo_output)

	);
	
	mem_wb mem_wb0(
		.clock(clock),
		.reset(reset),

		.mem_write_reg_address_input(mem_write_reg_address_output),
		.mem_write_reg_enable_input(mem_write_reg_enable_output),
		.mem_write_reg_data_input(mem_write_reg_data_output),

		.mem_whilo_input(mem_whilo_output),
		.mem_hi_input(mem_hi_output),
		.mem_lo_input(mem_lo_output),

		.wb_write_reg_address_output(wb_write_reg_address_intput),
		.wb_write_reg_enable_output(wb_write_reg_enable_intput),
		.wb_write_reg_data_output(wb_write_reg_data_intput),

		.wb_whilo_output(wb_whilo_output),
		.wb_hi_output(wb_hi_output),
		.wb_lo_output(wb_lo_output)
	);

	hilo_reg hilo_reg0(
		.clock(clock),
		.reset(reset),

		.write_enable(wb_whilo_output),
		.hi_input(wb_hi_output),
		.lo_input(wb_lo_output),

		.hi_output(hi_output),
		.lo_output(lo_output)
	);
	 
endmodule