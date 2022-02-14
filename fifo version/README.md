# FIFO Version

![FIFO Diagram](https://www.fpga4fun.com/images/scope_FIFO.gif)

## Registers

``` v
reg [7:0] data_flash_reg;
always @(posedge clk_flash) data_flash_reg <= data_flash;
```

## The FIFO

``` v
fifo myfifo(.data(data_flash_reg), .wrreq(wrreq), .wrclk(clk_flash), .wrfull(wrfull), .wrempty(wrempty), .q(q_fifo), .rdreq(rdreq), .rdclk(clk), .rdempty(rdempty));
```

## Writing to the FIFO

``` v
reg fillfifo;
always @(posedge clk_flash)
if(~fillfifo)
  fillfifo <= wrempty; // start when empty
else
  fillfifo <= ~wrfull; // stop when full

assign wrreq = fillfifo;
```

## Reading from the FIFO

``` v
wire TxD_start = ~TxD_busy & ~rdempty;
assign rdreq = TxD_start;

async_transmitter async_txd(.clk(clk), .TxD(TxD), .TxD_start(TxD_start), .TxD_busy(TxD_busy), .TxD_data(q_fifo));
```

## Complete Design

```
module oscillo(clk, TxD, clk_flash, data_flash);
input clk;
output TxD;

input clk_flash;
input [7:0] data_flash;

reg [7:0] data_flash_reg; always @(posedge clk_flash) data_flash_reg <= data_flash;

wire [7:0] q_fifo;
fifo myfifo(.data(data_flash_reg), .wrreq(wrreq), .wrclk(clk_flash), .wrfull(wrfull), .wrempty(wrempty), .q(q_fifo), .rdreq(rdreq), .rdclk(clk), .rdempty(rdempty));

// The flash ADC side starts filling the fifo only when it is completely empty,
// and stops when it is full, and then waits until it is completely empty again
reg fillfifo;
always @(posedge clk_flash)
if(~fillfifo)
  fillfifo <= wrempty; // start when empty
else
  fillfifo <= ~wrfull; // stop when full

assign wrreq = fillfifo;

// the manager side sends when the fifo is not empty
wire TxD_busy;
wire TxD_start = ~TxD_busy & ~rdempty;
assign rdreq = TxD_start;

async_transmitter async_txd(.clk(clk), .TxD(TxD), .TxD_start(TxD_start), .TxD_busy(TxD_busy), .TxD_data(q_fifo));

endmodule
```
