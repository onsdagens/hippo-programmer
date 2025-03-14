module fpga_top (
    input logic sysclk,

    output logic [3:0] led,
    output logic [3:0] led_r,
    output logic [3:0] led_g,
    output logic [3:0] led_b,

    input logic [3:0] sw,
    input logic [3:0] btn
);

  logic clk;
  logic locked;
  clk_wiz_0 clk_gen (
      .clk_in1 (sysclk),
      .clk_out1(clk),

      .reset(sw[0]),
      .locked
  );

  logic jtag_sel;
  logic [7:0] jtag_data;
  logic [9:0] jtag_write_addr;

  logic jtag_ack;
  logic jtag_reset;
  logic jtag_word_ready;
  // assign led_g = {1'b0, 1'b0, 1'b0, 1'b0};
  // assign led   = {0, 0, 0, 0};
  jtag jtag (
      //.clk_i(clk),
      .rst_i(sw[1]),

      .sel_o(jtag_sel),

      .data_o  (jtag_data),
      .word_rdy_o(jtag_word_ready),
      // .write_addr_o(jtag_write_addr),

      .ack_i(jtag_ack),

      .reset_o(jtag_reset),
      .led(led[1])
  );

  logic [7:0] mem_dout;

  logic [9:0] read_addr;

  logic [9:0] mem_addr;

  assign mem_addr = jtag_ack ? jtag_write_addr : read_addr;
  //assign mem_we   = jtag_sel;

  hippo_memory memory (
      .clk_i(clk),
      .rst_i(sw[1]),

      .addr_i(mem_addr),
      .we_i  (jtag_ack),

      .data_i(jtag_data_r),

      .data_o(mem_dout)
  );


  //logic jtag_word_ready;
  //logic word_ready_r, word_ready_xing_r;
  logic [7:0] jtag_data_r;
  logic button_released;

  assign led_r = mem_dout[3:0];
  assign led_b = mem_dout[7:4];
  //assign led_g = mem_addr[3:0];
  // handle jtag input
  always_ff @(posedge clk) begin
    if (sw[1]) begin  // reset state
      jtag_write_addr <= 0;
      jtag_ack <= 0;
      jtag_data_r <= 0;
      led[0] <= 0;
      //led[1] <= 0;
      led[2] <= 0;
      led[3] <= 0;
    end else if (jtag_sel == 0) begin  // jtag inactive
      jtag_write_addr <= 0;
      jtag_data_r <= 0;
    end else begin
      if (jtag_word_ready && !jtag_ack) begin  // jtag has received a word,
        //we have not handled it yet
        jtag_ack <= 1;
        led[3] <= 1;
        jtag_data_r <= jtag_data;
      end else if (jtag_ack && !jtag_word_ready) begin  // we have handled the word, and jtag has acknowleged it
        jtag_ack <= 0;
        led[2] <= 1;
        jtag_write_addr <= jtag_write_addr + 1;
      end
    end
  end

  // interface with the memory via leds (just debugging)
  always_ff @(posedge clk) begin
    if (sw[1]) begin
      read_addr <= 0;
      button_released <= 1;
    end else if (btn[0] && button_released) begin
      read_addr <= read_addr + 1;
      button_released <= 0;
    end else if (btn[1] && button_released) begin
      read_addr <= 0;
      button_released <= 0;
    end else if (!btn[0] && !btn[1]) begin
      button_released <= 1;
    end
  end

endmodule

