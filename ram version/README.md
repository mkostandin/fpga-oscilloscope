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
