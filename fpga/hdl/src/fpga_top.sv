module fpga_top
  import mem_cfg_pkg::*;
(
    input logic sysclk,

    output logic [3:0] led_r,
    output logic [3:0] led_b,
    output logic [3:0] led,
    input  logic [1:0] sw,
    input  logic [2:0] btn
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
  mem_width_t        width;

  logic       [ 9:0] mem_addr;
  logic       [31:0] mem_data;
  logic              mem_we;

  assign mem_addr = jtag_we ? jtag_write_addr : curr_addr;
  assign mem_data = jtag_we ? {24'b0, jtag_data} : data;
  assign mem_we = jtag_we | we;
  assign mem_width = jtag_we ? BYTE : width;

  interleaved_memory memory (
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

  // interface with the memory via leds (just debugging)
  always_ff @(posedge clk) begin
    if (sw[1]) begin
      led <= {'0, '0, '0, '0};
      curr_addr <= 0;
      button_released <= 1;
      we <= 0;
      data <= 0;
      width <= BYTE;
    end else if (btn[0] && button_released) begin
      curr_addr <= curr_addr + 1;
      button_released <= 0;
      width <= BYTE;
      we <= 0;
      data <= 0;
    end else if (btn[1] && button_released) begin
      curr_addr <= 0;
      button_released <= 0;
      width <= BYTE;
      we <= 0;
      data <= 0;
    end else if (btn[2] && button_released) begin
      width <= WORD;
      data <= 'h0DEFACED;
      we <= 1;
      button_released <= 0;
    end else if (!btn[0] && !btn[1] && !btn[2]) begin
      data <= 0;
      we <= 0;
      //width <= BYTE;
      button_released <= 1;
    end else begin
      led[0] <= mem_addr[0];
      led[1] <= mem_addr[1];
      led[2] <= mem_addr[2];
      led[3] <= jtag_we;
    end
  end

endmodule

