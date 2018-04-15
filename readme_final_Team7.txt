--Team 7
--Cordic Algorithm for Sine, Cosine Generation


Files:

--Design Files
1. cordic_proc.vhd - interface between the cordic algorithm module and IO processing
2. cordic.vhd - cordic algorithm module
3. Basys3_Master.xdc - constraints file for the design
4. ui2.vhd - integration file between interface and cordic algorithm, includes IO processing
5. ui2_pkg.vhd - contains some functions used in the ui2 integration

--Files utilized from Digilent GPIO demo project
1. debouncer.vhd - debounces input from on-board buttons
2. UART_TX_CTRL.vhd - transmits a byte character over UART, altered for 115200 baud rate

--Verification Files
1. tb_cordic_top.vhd - cordic testbench
2. sample_input_cordic_top.txt - reference input
3. output_reference180.txt - reference output
4. sample_output_cordic_top.txt - generated output

--Verification Reference Files (MATLAB, Python)
1. dec2twos_mod.m - file generates two’s complement forms of inputs as required
2. reference_file_generator.m - file to generate the output reference values
3. input_reference_generator.m - file to generate input file containing angle values
4. file_compare.py - file to compare reference and vhdl-generated outputs and compute the error


Notes on interpreting the inputs, outputs and any other results:

-- User input is from the switches and buttons on the Basys3 board. The center
   button is pushed when resetting the program. When the appropriate number of
   switches is flipped, to prompt an output from the cordic algorithm to the
   computer terminal, any of the other buttons can be pressed. The number of
   switches that are on are counted and multiplied by 22.5, so all inputs are
   an increment of 22.5 degrees.

-- Range of input angles(in degrees) to the interface and IO processing: 0 to 360
   The actual value passed is the angle times 10 in order to get a simplified
   format for both cordic input and display output processing. This value is
   an unsigned 15-bit value to leave a bit open for signed conversion later.
   eg: 45 degrees would be represented in data as 450: 000 0001 1100 0010

-- Range of input angles(in degrees) to the cordic algorithm: -180 to 180
   The cordic algorithm requires that the angles be converted to this format
   due to the limitations of the algorithm implemented. This valus is a signed
   16-bit value.
   eg: 270 degrees would be represented as -90 degrees: 1111 1111 1010 0110

-- Further formatting is done for the expected input to the cordic module.
   The input to the cordic algorithm is a 16-bit form of 2's complement representation of the angle.
   This form is obtained by dividing the angle by 360 and subsequently multiplying it
   with 2^(16) and then converting it to binary in 2’s complement form.
   eg: 45 would be represented as 8192: 0010 0000 0000 0000
       while -45 would be -8192: 1110 0000 0000 0000

-- The output is a 16-bit form of the 2's complement representation of the answer, such that
   it is in a quantized form (since the sine/cosine values range only from -1 to +1 all values
   are represented such that 0000 0000 0000 0000 represents 0, 1000 0000 0000 0000
   represents -1 and 0111 1111 1111 1111 represents +1 (0.999...)
   eg: 0.7071 is represented as 23168: 0101 1010 1000 0000

-- The sine and cosine output is interpreted by the output display processing by
   dividing the output by 2^15 and then multiplying by 10000 in order to get a
   simplified format for display output processing. That number is then fed into
   the binary to decimal converter that gives the number in digit form. Then the
   digits are converted to hex characters to be sent, in combination with other
   characters for user friendly formatting, to the computer terminal through the
   UART interface. Output sine and cosine values are of the form 0.XXXX

-- UART interface to a computer terminal is set to operate at a 115200 baud rate.
