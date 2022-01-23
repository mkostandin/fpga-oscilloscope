wire RxD_gap;
async_receiver async_rxd(.clk(clk), .RxD(RxD), .RxD_data_ready(RxD_data_ready), .RxD_data(RxD_data), .RxD_gap(RxD_gap));

reg [1:0] RxD_addr_reg;
always @(posedge clk) if(RxD_gap) RxD_addr_reg <= 0; else if(RxD_data_ready) RxD_addr_reg <= RxD_addr_reg + 1;

// register 0: TriggerThreshold
reg [7:0] TriggerThreshold;
always @(posedge clk) if(RxD_data_ready & (RxD_addr_reg==0)) TriggerThreshold <= RxD_data;

// register 1: "0 0 0 0 HDiv[3] HDiv[2] HDiv[1] HDiv[0]"
reg [3:0] HDiv;
always @(posedge clk) if(RxD_data_ready & (RxD_addr_reg==1)) HDiv <= RxD_data[3:0];

// register 2: "StartAcq TriggerPolarity 0 0 0 0 0 0"
reg TriggerPolarity;
always @(posedge clk) if(RxD_data_ready & (RxD_addr_reg==2)) TriggerPolarity <= RxD_data[6];
wire StartAcq = RxD_data_ready & (RxD_addr_reg==2) & RxD_data[7];
