# Adding Trigger

## Detecting a Rising Edge
If a sample is above the threshold, but the previous sample was below, trigger!
```
reg Threshold1, Threshold2;
always @(posedge clk_flash) Threshold1 <= (data_flash_reg>=8'h80);
always @(posedge clk_flash) Threshold2 <= Threshold1;

assign Trigger = Threshold1 & ~Threshold2;  // if positive edge, trigger!
```

## Mid-Display Trigger
One great feature about a digital scope is the ability to see what's going on before the trigger.

How does that work?
The oscilloscope is continuously acquiring. The oscilloscope memory gets overwritten over and over - when we reach the end, we start over at the beginning. But if a trigger happens, the oscilloscope keeps acquiring for half more of its memory depth, and then stops. So it keeps half of its memory with what happened before the trigger, and half of what happened after.

We are using here a 50% or "mid-display trigger" (other popular settings would have been 25% and 75% settings, but that's easy to add later).

The implementation is easy. First we have to keep track of how many bytes have been stored.
```
reg [8:0] samplecount;
```
With a memory depth of 512 bytes, we first make sure to acquire at least 256 bytes, then stop counting but keep acquiring while waiting for a trigger. Once the trigger comes, we start counting again to acquire 256 more bytes, and stop.
```
reg PreTriggerPointReached;
always @(posedge clk_flash) PreTriggerPointReached <= (samplecount==256);
```
The decision logic deals with all these steps:
```
always @(posedge clk_flash)
if(~Acquiring)
begin
  Acquiring <= startAcquisition2;  // start acquiring?
  PreOrPostAcquiring <= startAcquisition2;
end
else
if(&samplecount)  // got 511 bytes? stop acquiring
begin
  Acquiring <= 0;
  AcquiringAndTriggered <= 0;
  PreOrPostAcquiring <= 0;
end
else
if(PreTriggerPointReached)  // 256 bytes acquired already?
begin
  PreOrPostAcquiring <= 0;
end
else
if(~PreOrPostAcquiring)
begin
  AcquiringAndTriggered <= Trigger;  // Trigger? 256 more bytes and we're set
  PreOrPostAcquiring <= Trigger;
  if(Trigger) wraddress_triggerpoint <= wraddress;  // keep track of where the trigger happened
end

always @(posedge clk_flash) if(Acquiring) wraddress <= wraddress + 1;
always @(posedge clk_flash) if(PreOrPostAcquiring) samplecount <= samplecount + 1;

reg Acquiring1; always @(posedge clk) Acquiring1 <= AcquiringAndTriggered;
reg Acquiring2; always @(posedge clk) Acquiring2 <= Acquiring1;
assign AcquisitionStarted = Acquiring2;
```
Notice that we took care of remembering where the trigger happened. That's used to determine the beginning of the sample window in the RAM to send to the PC.
```
reg [8:0] rdaddress, SendCount;
reg Sending;
wire TxD_busy;

always @(posedge clk)
if(~Sending)
begin
  Sending <= AcquisitionStarted;
  if(AcquisitionStarted) rdaddress <= (wraddress_triggerpoint ^ 9'h100);
end
else
if(~TxD_busy)
begin
  rdaddress <= rdaddress + 1;
  SendCount <= SendCount + 1;
  if(&SendCount) Sending <= 0;
end
```
With this design, we finally get a useful oscilloscope. We just need to customize it now.
