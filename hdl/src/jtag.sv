// jtag_top
`timescale 1ns / 1ps

module jtag
#(
  parameter integer BIT_WIDTH = 8
)

(
    // reset signal
    input rst_i,

    // select signal from the BSCANE2 unit
    output logic sel_o,

    // received data is exposed on this line
    output logic [BIT_WIDTH-1:0] data_o,
    // whenever the programmer has received enough 
    // bits to fill a word, this is raised
    output logic word_rdy_o,

    // used to acknowledge the word by the receiving end
    // this is for crossing the clock domain from 
    // TCK to whatever is used in the core
    input  logic ack_i,


    // This is raised whenever the JTAG enters a reset state
    output logic reset_o,
    input  logic led
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
  logic [ 7:0] bs_shift_r;
  logic [ 2:0] bs_bit_count_r;
  logic [14:0] bs_addr_r;
  logic [31:0] bs_mem_r;

  // temporaries
  logic [ 7:0] bs_tmp;
  logic [14:0] bs_addr_next;

  // host-side we do not care about any output 
  assign TDO = 0;

  assign bs_tmp = {TDI, bs_shift_r[7:1]};
  assign bs_addr_next = bs_addr_r + 1;

  assign reset_o = RESET;
  assign sel_o = SEL;

  
  always @(posedge TCK) begin
    if (rst_i) begin
      bs_bit_count_r <= 0;
      word_r_o <= 0;
      bs_addr_r <= 0;
      bs_shift_r <= 0;
    end else if (!SEL) begin
      bs_bit_count_r <= 0;
      word_r_o <= 0;
      bs_addr_r <= 0;
      bs_shift_r <= 0;
    end else if (SHIFT && !RESET) begin
      bs_shift_r     <= bs_tmp;  // shift data out
      bs_bit_count_r <= bs_bit_count_r + 1;  // wrapping data_word_width bit counter
      if ((bs_bit_count_r == (BIT_WIDTH - 1)) && !ack_i) begin  // at last bit
        word_r_o            <= 1;
        data_o              <= bs_tmp;  // output the word
        bs_mem_r[bs_addr_r] <= bs_tmp;  // update current address in memory
        bs_shift_r          <= bs_mem_r[bs_addr_next];  // load next address to shift register
        bs_addr_r           <= bs_addr_next;  // update address
      end else if (ack_i) begin
        word_r_o <= 0;  // word has been handled cross domain, move on to next
      end
    end
  end
endmodule
