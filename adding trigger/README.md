# Adding Trigger

## Detecting a Rising Edge
If a sample is above the threshold, but the previous sample was below, trigger!
```
reg Threshold1, Threshold2;
always @(posedge clk_flash) Threshold1 <= (data_flash_reg>=8'h80);
always @(posedge clk_flash) Threshold2 <= Threshold1;

assign Trigger = Threshold1 & ~Threshold2;  // if positive edge, trigger!
```
