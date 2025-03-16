// jtag_top
`timescale 1ns / 1ps

module jtag #(
    parameter integer BIT_WIDTH = 8
) (
    // system clock
    input clk_i,
    // reset signal
    input rst_i,

    output logic we_o,

    output logic [BIT_WIDTH-1:0] data_o,

    output logic [9:0] write_addr_o
);

  // BSCANE2: Boundary-Scan User Instruction
  //          Artix-7
  // Xilinx HDL Language Template, version 2024.2

  BSCANE2 #(
      .JTAG_CHAIN(3)  // Value for USER3 command, 0x22
      // .JTAG_CHAIN(1)  // Value for USER3 command, 0x02
  ) BSCANE2_inst (
      .CAPTURE(CAPTURE),  // 1-bit output: CAPTURE output from TAP controller.
      .DRCK(DRCK),       // 1-bit output: Gated TCK output. When SEL is asserted, DRCK toggles when CAPTURE or
                         // SHIFT are asserted.

      .RESET(RESET),  // 1-bit output: Reset output for TAP controller.
      .RUNTEST(),  // 1-bit output: Output asserted when TAP controller is in Run Test/Idle state.
      .SEL(SEL),  // 1-bit output: USER instruction active output.
      .SHIFT(SHIFT),  // 1-bit output: SHIFT output from TAP controller.
      .TCK(TCK),  // 1-bit output: Test Clock output. Fabric connection to TAP Clock pin.
      .TDI(TDI),  // 1-bit output: Test Data Input (TDI) output from TAP controller.
      .TMS(),  // 1-bit output: Test Mode Select output. Fabric connection to TAP.
      .UPDATE(UPDATE),  // 1-bit output: UPDATE output from TAP controller
      .TDO(TDO)  // 1-bit input: Test Data Output (TDO) input for USER function.
  );

  // End of BSCANE2_inst instantiation

  // clocked registers
  logic [7:0] bs_shift_r;
  logic [2:0] bs_bit_count_r;
  logic [14:0] bs_addr_r;
  logic [31:0] bs_mem_r;

  // temporaries
  logic [7:0] bs_tmp;
  logic [14:0] bs_addr_next;

  /// CDC registers
  // TCK side
  logic [BIT_WIDTH-1:0] jtag_data_r;
  logic jtag_word_rdy_r;

  // System Clock Side
  logic [9:0] write_addr_r;
  logic [BIT_WIDTH-1:0] data_r;
  logic ack_r;


  // host-side we do not care about any output
  assign TDO = 0;

  assign bs_tmp = {TDI, bs_shift_r[7:1]};
  assign bs_addr_next = bs_addr_r + 1;

  assign reset_o = RESET;
  assign sel_o = SEL;


  always @(posedge TCK) begin
    if (rst_i) begin
      bs_bit_count_r <= 0;
      jtag_word_rdy_r <= 0;
      bs_addr_r <= 0;
      bs_shift_r <= 0;
    end else if (!SEL) begin
      bs_bit_count_r <= 0;
      jtag_word_rdy_r <= 0;
      bs_addr_r <= 0;
      bs_shift_r <= 0;
    end else if (SHIFT && !RESET) begin
      bs_shift_r     <= bs_tmp;  // shift data out
      bs_bit_count_r <= bs_bit_count_r + 1;  // wrapping data_word_width bit counter
      if ((bs_bit_count_r == (BIT_WIDTH - 1)) && !ack_r) begin  // at last bit
        jtag_word_rdy_r     <= 1;
        jtag_data_r         <= bs_tmp;  // output the word
        bs_mem_r[bs_addr_r] <= bs_tmp;  // update current address in memory
        bs_shift_r          <= bs_mem_r[bs_addr_next];  // load next address to shift register
        bs_addr_r           <= bs_addr_next;  // update address
      end else if (ack_r) begin
        jtag_word_rdy_r <= 0;  // word has been handled cross domain, move on to next
      end
    end
  end

  assign we_o = ack_r;
  assign write_addr_o = write_addr_r;
  assign data_o = data_r;

  always_ff @(posedge clk_i) begin
    if (rst_i) begin  // reset state
      write_addr_r <= 0;
      ack_r <= 0;
      data_r <= 0;
    end else if (SEL == 0) begin  // jtag inactive
      write_addr_r <= 0;
      data_r <= 0;
    end else begin
      if (jtag_word_rdy_r && !ack_r) begin  // jtag has received a word,
        //we have not handled it yet
        ack_r  <= 1;
        data_r <= jtag_data_r;
      end else if (ack_r && !jtag_word_rdy_r) begin
        // we have handled the word, and jtag has acknowleged it
        ack_r <= 0;
        write_addr_r <= write_addr_r + 1;
      end
    end
  end


endmodule
