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
