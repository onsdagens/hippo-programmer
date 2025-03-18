module fpga_top
  import mem_cfg_pkg::*;
(
    input logic sysclk,

    output logic [3:0] led_r,
    output logic [3:0] led_b,
    output logic [3:0] led,
    input  logic [1:0] sw,
    input  logic [3:0] btn
);

  logic clk;
  logic locked;

  clk_wiz_0 clk_gen (
      .clk_in1 (sysclk),
      .clk_out1(clk),

      .reset(sw[0]),
      .locked
  );


  logic [7:0] jtag_data;
  logic [9:0] jtag_write_addr;
  logic jtag_we;


  jtag jtag (
      .clk_i(clk),
      .rst_i(sw[1]),

      .we_o(jtag_we),

      .data_o(jtag_data),

      .write_addr_o(jtag_write_addr)
  );

  logic       [31:0] mem_dout;

  logic       [ 9:0] curr_addr;
  logic       [31:0] data;
  logic              we;
  mem_width_t        if_width;

  logic       [ 9:0] mem_addr;
  logic       [31:0] mem_data;
  logic              mem_we;
  // funny bug here, comment this line out and watch the type inference on line 57 break down :)
  mem_width_t        mem_width;

  assign mem_addr = jtag_we ? jtag_write_addr : curr_addr;
  assign mem_data = jtag_we ? {24'b0, jtag_data} : data;
  assign mem_we = jtag_we | we;
  assign mem_width = jtag_we ? BYTE : if_width;

  interleaved_memory #() memory (
      .clk_i(clk),
      .rst_i(sw[1]),
      .width_i(mem_width),
      .sign_extend_i('0),
      .addr_i(mem_addr),
      .write_enable_i(mem_we),
      .data_i(mem_data),
      .data_o(mem_dout)
  );

  logic button_released;

  assign led_r = jtag_we ? '0 : mem_dout[3:0];
  assign led_b = jtag_we ? '0 : mem_dout[7:4];
  assign led   = jtag_we ? '0 : curr_addr[3:0];
  // interface with the memory via leds (just debugging)
  always_ff @(posedge clk) begin
    if (sw[1]) begin
      curr_addr <= 0;
      button_released <= 1;
      we <= 0;
      data <= 'h0;
      if_width <= BYTE;
    end else if (btn[0] && button_released) begin
      curr_addr <= mem_addr + 1;
      button_released <= 0;
    end else if (btn[1] && button_released) begin
      curr_addr <= 0;
      button_released <= 0;
    end else if (btn[2] && button_released) begin
      data <= 'h000000A7;
      if_width <= BYTE;
      we <= 1;
      button_released <= 0;
    end else if (btn[3] && button_released) begin
      data <= 'h0DEFACED;
      if_width <= WORD;
      we <= 1;
      button_released <= 0;
    end else if (!btn[0] && !btn[1] && !btn[2] && !btn[3]) begin
      button_released <= 1;
      we <= 0;
      data <= 0;
      if_width <= BYTE;
    end
  end

endmodule

