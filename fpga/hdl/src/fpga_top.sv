module fpga_top (
    input logic sysclk,

    output logic [3:0] led_r,
    output logic [3:0] led_b,
    output logic [3:0] led,
    input logic [1:0] sw,
    input logic [1:0] btn
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

  logic [7:0] mem_dout;

  logic [9:0] read_addr;

  logic [9:0] mem_addr;

  assign mem_addr = jtag_we ? jtag_write_addr : read_addr;

  logic [7:0] jtag_data_r;

  hippo_memory memory (
      .clk_i(clk),
      .rst_i(sw[1]),

      .addr_i(mem_addr),
      .we_i  (jtag_we),

      .data_i(jtag_data),

      .data_o(mem_dout)
  );

  logic button_released;

  assign led_r = mem_dout[3:0];
  assign led_b = mem_dout[7:4];

  // interface with the memory via leds (just debugging)
  always_ff @(posedge clk) begin
    if (sw[1]) begin
      led <= {'0, '0, '0, '0};
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
    end else begin
        led[0] <= mem_addr[0];
        led[1] <= mem_addr[1];
        led[2] <= mem_addr[2];
        led[3] <= jtag_we;
    end
  end

endmodule

