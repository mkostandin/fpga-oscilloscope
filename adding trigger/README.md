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
