library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cordic_proc is
    generic ( SIZE : integer := 15 ) ;
    port(
          clk    				  : in std_logic  ;
          rst_n    				  : in std_logic  ;
          en_in          			  : in std_logic  ;
          angle_in	        		  : in signed  (SIZE  downto 0);
          cosine_out   				  : out signed (SIZE downto 0);
          sine_out				  : out signed (SIZE downto 0);
	  out_valid				  : out std_logic
        );
end cordic_proc ;

architecture cordic_top_arch of cordic_proc is

    component cordic
        generic ( SIZE : integer := 15 ) ;
		port(
          clk    				  : in std_logic  ;
          rst_n    				  : in std_logic  ;
          en_in          			  : in std_logic  ;
          angle	        			  : in signed  (SIZE  downto 0);
          cosine   				  : out signed (SIZE downto 0);
          sine		   			  : out signed (SIZE downto 0);
	  out_valid				  : out std_logic
        );
    end component;

     type quad_array is array (0 to 15) of signed(1 downto 0);

     signal angle, cosine, sine         : signed   ( 15  downto 0);
     signal quadrant			: signed (1 downto 0);
     signal quadrant_result		: quad_array;

begin

    inst : cordic generic map (SIZE => 15)
          	 port map  (clk       => clk  ,
							rst_n     => rst_n  ,
							en_in     => en_in,
							angle	  => angle   ,
							cosine    => cosine	,
							sine	  => sine,
							out_valid => out_valid
							);

   process (angle_in) is
   begin
     quadrant <= angle_in(15 downto 14);
   end process;

   process (clk,rst_n) is
   begin
       if(rst_n = '0')then
           for k in 0 to 15 loop
               quadrant_result(k) <= (others=>'0');
           end loop;
       elsif(rising_edge(clk))then
               for k in 1 to 15 loop
                   quadrant_result(k) <= quadrant_result(k-1);
               end loop;
               quadrant_result(0) <= quadrant;
       end if;
   end process;


    with quadrant select
        angle <= angle_in              	        when "00",
	         "00" & angle_in(13 downto 0)   when "01",
                 "11" & angle_in(13 downto 0)   when "10",
                 angle_in                       when others;

    with quadrant_result(15) select
        cosine_out <= cosine              	when "00",
	              -sine           		when "01",
                      sine			when "10",
                      cosine                    when others;

    with quadrant_result(15) select
        sine_out <=   sine              	when "00",
	              cosine           		when "01",
                      -cosine			when "10",
                      sine                      when others;

end cordic_top_arch;
