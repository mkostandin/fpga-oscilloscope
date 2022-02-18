# Ram Version

## Trigger
```
wire [7:0] RxD_data;
async_receiver async_rxd(.clk(clk), .RxD(RxD), .RxD_data_ready(RxD_data_ready), .RxD_data(RxD_data));
```

## Synchronization
```
reg startAcquisition;
wire AcquisitionStarted;

always @(posedge clk)
if(~startAcquisition)
  startAcquisition <= RxD_data_ready;
else
if(AcquisitionStarted)
  startAcquisition <= 0;
```
#### Synchronizers(Start Acquisition)
```
reg startAcquisition1; always @(posedge clk_flash) startAcquisition1 <= startAcquisition;
reg startAcquisition2; always @(posedge clk_flash) startAcquisition2 <= startAcquisition1;
```
#### Synchronizer(Acquiring)
```
reg Acquiring;
always @(posedge clk_flash)
if(~Acquiring)
  Acquiring <= startAcquisition2;  // start acquiring?
else
if(&wraddress)  // done acquiring?
  Acquiring <= 0;

reg Acquiring1; always @(posedge clk) Acquiring1 <= Acquiring;
reg Acquiring2; always @(posedge clk) Acquiring2 <= Acquiring1;
assign AcquisitionStarted = Acquiring2;
```
## Dual-port RAM
```
ram512 ram_flash(
  .data(data_flash_reg), .wraddress(wraddress), .wren(Acquiring), .wrclock(clk_flash),
  .q(ram_output), .rdaddress(rdaddress), .rden(rden), .rdclock(clk)
);
```
#### Write Address
```
reg [8:0] wraddress;
always @(posedge clk_flash) if(Acquiring) wraddress <= wraddress + 1;
```
#### Read Address
```
reg [8:0] rdaddress;
reg Sending;
wire TxD_busy;

always @(posedge clk)
if(~Sending)
  Sending <= AcquisitionStarted;
else
if(~TxD_busy)
begin
  rdaddress <= rdaddress + 1;
  if(&rdaddress) Sending <= 0;
end
```
#### Send Data to PC
```
wire TxD_start = ~TxD_busy & Sending;
wire rden = TxD_start;

wire [7:0] ram_output;
async_transmitter async_txd(.clk(clk), .TxD(TxD), .TxD_start(TxD_start), .TxD_busy(TxD_busy), .TxD_data(ram_output));
```
