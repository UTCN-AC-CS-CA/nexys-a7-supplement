# MIPS - Pipeline

## Analyze the current situation

1. Run the synthesis and make sure to wait until it completes
<img width="239" height="248" alt="image" src="https://github.com/user-attachments/assets/8518afc5-656a-4bac-a3ef-6d85d29ded63" /><img width="191" height="73" alt="image" src="https://github.com/user-attachments/assets/fb6d5a1b-b993-4afa-862a-9059af271c78" />

2. Open Synthesized Design --> Report Timing Summary --> Click OK (default settings are fine)
<img width="938" height="673" alt="image" src="https://github.com/user-attachments/assets/61e1731c-2e6e-41b7-8ce4-e0ebd1c86c5f" />

3. Click on the Design Timing Summary and look for the Worst Negative Slack (WNS)
<img width="1650" height="365" alt="image" src="https://github.com/user-attachments/assets/9309de84-2095-4d9f-be66-6a51fa44270e" />

**The Worst Negative Slack (WNS) is -0.596 ns**

That means the design is failing timing!  
The clock period is 10 ns (100 MHz), WNS of -0.596 ns means the longest combinational path between two registers takes about 10.596 ns to settle, but the next clock edge arrives after only 10 ns.  
The downstream flip-flop may capture data while it's still changing, causing metastability or just plain wrong values.  

On a real board, the design might appear to work sometimes and fail intermittently under temperature, voltage, or process variation, or it might fail immediately. Either way, it's unreliable.  
In simulation, you won't see this problem at all - timing failures only show up in static timing analysis and on actual hardware.  

In this case, the formula for the actual maximum frequency would be 1 / (Target Period time - WNS).  
Since the board operates at a clock speed of **100 MHz** as per the constraints file, this means that in nanoseconds for period time, it would be 10s.  
1 / (10 - (-0.596)) = 1 / 10.596 = 0.094375 GHz or **94.375 MHz**

## Make the necessary updates to the VHDL design sources

## Get rid of the hazards from the test program

## Re-evaluate the results

<img width="1588" height="224" alt="image" src="https://github.com/user-attachments/assets/d68a64f2-d61d-4a13-acc3-80f67bba3630" />

1 / (10 - 2.315) = 1 / 7.768 = 0.13012 GHz or **130.12 MHz**  

That's an increase of **37.8754%** just by reorganizing the structure of the MIPS
