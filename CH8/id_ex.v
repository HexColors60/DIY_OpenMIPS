`include "defines.v"

module id_ex(
    input  wire                      clock,
	input  wire                      reset,
	input  wire[`ALUOpBus]           id_aluop_input,
	input  wire[`ALUSelBus]          id_alusel_input,
	input  wire[`RegisterBus]		 id_instuction_input,
	input  wire[`RegisterBus]        id_reg1_input,
	input  wire[`RegisterBus]        id_reg2_input,
	input  wire[`RegisterAddressBus] id_write_reg_address_input,
	input  wire                      id_write_reg_enable_input,
	
	input  wire[`StopAllBus]         stop_all,

	input  wire                      id_is_in_delay_slot_input,
	input  wire[`RegisterBus]        id_link_address_input,
	input  wire                      id_next_instrcution_in_delay_slot_input,

	input  wire                      flush_input,
	input  wire[`RegisterBus]        id_current_instruction_address,
	input  wire[31:0]				 id_exception_type_input,

	output reg[`ALUOpBus]            ex_aluop_output,
	output reg[`ALUSelBus]           ex_alusel_output,
	output reg[`RegisterBus]		 ex_instruction_output,
	output reg[`RegisterBus]         ex_reg1_output,
	output reg[`RegisterBus]         ex_reg2_output,
	output reg[`RegisterAddressBus]  ex_write_reg_address_output,
	output reg                       ex_write_reg_enable_output,

	output reg                       id_ex_is_in_delay_slot_output,
	output reg[`RegisterBus]		 id_ex_link_address_output,
	output reg                       is_in_delay_slot_output,

	output reg[`RegisterBus]		 ex_current_instruction_address,
	output reg[31:0]				 ex_exception_type_output
);

	always @ (posedge clock) begin
		if (reset == `ResetEnable) begin
			ex_aluop_output <= `EXE_NOP_OP;
			ex_alusel_output <= `EXE_RES_NOP;
			ex_reg1_output <= `ZeroWord;
			ex_reg2_output <= `ZeroWord;
			ex_write_reg_address_output <= `NOPRegisterAddress;
			ex_write_reg_enable_output <= `WriteDisable;
			id_ex_link_address_output <= `ZeroWord;
			id_ex_is_in_delay_slot_output <= `NotInDelaySlot;
			is_in_delay_slot_output <= `NotInDelaySlot;
			ex_instruction_output <= `ZeroWord;
			ex_exception_type_output <= `ZeroWord;
			ex_current_instruction_address <= `ZeroWord;
		end else if (flush_input == 1'b1) begin
			ex_aluop_output <= `EXE_NOP_OP;
			ex_alusel_output <= `EXE_RES_NOP;
			ex_reg1_output <= `ZeroWord;
			ex_reg2_output <= `ZeroWord;
			ex_write_reg_address_output <= `NOPRegisterAddress;
			ex_write_reg_enable_output <= `WriteDisable;
			ex_exception_type_output <= `ZeroWord;
			id_ex_link_address_output <= `ZeroWord;
			ex_current_instruction_address <= `ZeroWord;
			id_ex_is_in_delay_slot_output <= `NotInDelaySlot;
			is_in_delay_slot_output <= `NotInDelaySlot;
			ex_instruction_output <= `ZeroWord;
		end else if (stop_all[2] == `Stop && stop_all[3] == `NoStop) begin
			ex_aluop_output <= `EXE_NOP_OP;
			ex_alusel_output <= `EXE_RES_NOP;
			ex_reg1_output <= `ZeroWord;
			ex_reg2_output <= `ZeroWord;
			ex_write_reg_address_output <= `NOPRegisterAddress;
			ex_write_reg_enable_output <= `WriteDisable;
			id_ex_link_address_output <= `ZeroWord;
			id_ex_is_in_delay_slot_output <= `NotInDelaySlot;
			ex_instruction_output <= `ZeroWord;
			ex_exception_type_output <= `ZeroWord;
			ex_current_instruction_address <= `ZeroWord;
		end else if (stop_all[2] == `NoStop) begin
			ex_aluop_output <= id_aluop_input;
			ex_alusel_output <= id_alusel_input;
			ex_reg1_output <= id_reg1_input;
			ex_reg2_output <= id_reg2_input;
			ex_write_reg_address_output <= id_write_reg_address_input;
			ex_write_reg_enable_output <= id_write_reg_enable_input;
			id_ex_link_address_output <= id_link_address_input;
			id_ex_is_in_delay_slot_output <= id_is_in_delay_slot_input;
			is_in_delay_slot_output <= id_next_instrcution_in_delay_slot_input;
			ex_instruction_output <= id_instuction_input;
			ex_exception_type_output <= id_exception_type_input;
			ex_current_instruction_address <= id_current_instruction_address;
		end
	end

endmodule