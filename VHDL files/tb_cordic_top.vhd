--Adapted from test bench code by Abhijit Gadad
--Engineer     : Vanessa Su
--Date Created : 11/13/2017
--Name of file : tb_cordic_top.vhd
--Description  : test bench for the cordic_top algorithm unit

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.env.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity tb_cordic_top is
end tb_cordic_top;

architecture tb_cordic_top_arch of tb_cordic_top is
    component cordic_top is
    port(
    clk : in std_logic;
    rst_n : in std_logic;
    en_in : in std_logic  ;
    angle_in : in signed (15 downto 0);
    cosine_out : out signed (15 downto 0);
    sine_out : out signed (15 downto 0);
    out_valid : out std_logic
    );
    end component;
     signal   clk           : std_logic;
     signal   rst_n         : std_logic := '1';
     signal   en            : std_logic := '0';
     signal   angle_in      : signed (15 downto 0);
     signal   data_out_valid: std_logic;
     signal   sin_out      : signed (15 downto 0);
     signal   cos_out      : signed (15 downto 0);
     constant T             : time := 20 ns;
     signal rand_num        : integer := 0;
     file input_file_info   : text;
     file output_file_info  : text;
     signal sin_out_file   : std_logic_vector(15 downto 0) ;
     signal cos_out_file   : std_logic_vector(15 downto 0) ;
     signal cycle_count     : integer := 0;


begin
--Instantiate the design under test
    DUT : cordic_top port map (
    clk => clk,
    rst_n => rst_n,
    en_in => en,
    angle_in => angle_in,
    cosine_out => cos_out,
    sine_out => sin_out,
    out_valid => data_out_valid
    );
   sin_out_file <= std_logic_vector(sin_out);
   cos_out_file <= std_logic_vector(cos_out);
    process
    begin
        clk <= '0';
        wait for T/2;
        clk <= '1';
        wait for T/2;
    end process;

    process
        variable input_line   : line;
        variable output_line  : line;
        variable en_term      : std_logic;
        variable space_char   : character;
        variable angle_term   : std_logic_vector (15 downto 0);

      begin
--open the input and output files
        file_open(input_file_info,"sample_input_cordic_top.txt",read_mode);
        file_open(output_file_info,"sample_output_cordic_top.txt",write_mode);
        write(output_line  ,string'("Sine Value                 "));
        write(output_line  ,string'("Cosine Value"));
        writeline(output_file_info,output_line);
--initialize the driving variables
        angle_in <= to_signed(0, 16);
--reset the system
        rst_n <= '0';
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        cycle_count <= cycle_count + 1;
        --write(output_line,cycle_count);
        --write(output_line,string'("                     "));
        --write(output_line,data_out_valid);
        --write(output_line,string'("           "));
        --if(data_out_valid = '0')then
          --write(output_line,string'("dont care"));
          --write(output_line,string'("                  "));
          --write(output_line,string'("dont care"));
        --else
        if(data_out_valid = '1')then
        write(output_line,sin_out_file);
        write(output_line,string'("           "));
        write(output_line,cos_out_file);
        end if;
        --write(output_line,string'("     "));
        --write(output_line, cycle_count);
        --write(output_line, data_out_valid);
        writeline(output_file_info,output_line);
        --end if;

        wait until falling_edge(clk);
        cycle_count <= cycle_count + 1;
        --write(output_line,cycle_count);
        --write(output_line,string'("                     "));
        --write(output_line,data_out_valid);
        --write(output_line,string'("           "));
        --if(data_out_valid = '0')then
          --write(output_line,string'("dont care"));
          --write(output_line,string'("                  "));
          --write(output_line,string'("dont care"));
        --else
        if(data_out_valid = '1')then
        write(output_line,sin_out_file);
        write(output_line,string'("           "));
        write(output_line,cos_out_file);
        end if;
        --write(output_line,string'("     "));
        --write(output_line, cycle_count);
        --write(output_line, data_out_valid);
        writeline(output_file_info,output_line);
        --end if;

        rst_n <= '1';
--end of reset
--write the first line of the output
        wait until falling_edge(clk);
        cycle_count <= cycle_count + 1;
        --write(output_line,cycle_count);
        --write(output_line,string'("                     "));
        --write(output_line,data_out_valid);
        --write(output_line,string'("           "));
        --if(data_out_valid = '0')then
          --write(output_line,string'("dont care"));
          --write(output_line,string'("                  "));
          --write(output_line,string'("dont care"));
        --else
        if(data_out_valid = '1')then
        write(output_line,sin_out_file);
        write(output_line,string'("           "));
        write(output_line,cos_out_file);
        end if;
        --write(output_line,string'("     "));
        --write(output_line, cycle_count);
        --write(output_line, data_out_valid);
        writeline(output_file_info,output_line);
        --end if;


--loop over the lines and for each line of input, write output into the file

        while not endfile(input_file_info) loop
        readline(input_file_info,input_line);
        read(input_line,en_term);
        read(input_line,space_char);
        read(input_line,angle_term);
        en  <= en_term;
        angle_in <= signed(angle_term);
        --ctrl<=unsigned(ctrl_term);
        --a<=signed(m_term1);
        --b<=signed(m_term2);
        --c<=signed(a_term);

        wait until falling_edge(clk);
        cycle_count <= cycle_count + 1;
        --write(output_line,cycle_count);
        --write(output_line,string'("                     "));
        --write(output_line,data_out_valid);
        --write(output_line,string'("           "));
        --if(data_out_valid = '0')then
          --write(output_line,string'("dont care"));
          --write(output_line,string'("                  "));
          --write(output_line,string'("dont care"));
        --else
        if(data_out_valid = '1')then
        write(output_line,sin_out_file);
        write(output_line,string'("           "));
        write(output_line,cos_out_file);
        end if;
        --write(output_line,string'("     "));
        --write(output_line, cycle_count);
        --write(output_line, data_out_valid);
        writeline(output_file_info,output_line);
        --end if;

        end loop;

        for i in 0 to 14 loop
          wait until falling_edge(clk);
          cycle_count <= cycle_count + 1;
          --write(output_line,cycle_count);
          --write(output_line,string'("                     "));
          --write(output_line,data_out_valid);
          --write(output_line,string'("           "));
          --if(data_out_valid = '0')then
            --write(output_line,string'("dont care"));
            --write(output_line,string'("                  "));
            --write(output_line,string'("dont care"));
          --else
          if(data_out_valid = '1')then
          write(output_line,sin_out_file);
          write(output_line,string'("           "));
          write(output_line,cos_out_file);
          end if;
          --write(output_line,string'("     "));
          --write(output_line, cycle_count);
          --write(output_line, data_out_valid);
          writeline(output_file_info,output_line);
          --end if;
        end loop;

        file_close(input_file_info);
        file_close(output_file_info);
--close the files
        report "Test completed";
        stop(0);

    end process;
end tb_cordic_top_arch;
