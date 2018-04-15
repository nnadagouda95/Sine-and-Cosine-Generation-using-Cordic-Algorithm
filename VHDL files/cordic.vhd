library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cordic is
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
end cordic ;

architecture cordic_arch of cordic is

   type memory is array (0 to SIZE-2) of signed(SIZE downto 0);
   type result is array (0 to SIZE-1) of signed(SIZE downto 0);
   type angle_diff is array (0 to SIZE-1) of signed(SIZE downto 0);
   type sign is array (0 to SIZE-2) of std_logic;
   type enable is array (0 to 14) of std_logic;

   signal atan_table 			: memory;
   signal X, Y 				: result;
   signal X_shift, Y_shift		: memory;
   signal Z 				: angle_diff;
   signal X_init, Y_init, Z_init	: signed(SIZE downto 0);
   signal Z_sign	 		: sign;
   signal en_sig  			: enable;

   begin

   --arctan table
   process (clk, rst_n) is
   begin
	if(rst_n = '0')then
	   atan_table(0)  <= (others=>'0'); -- 45.000 degrees -> atan(2^0)
	   atan_table(1)  <= (others=>'0'); -- 26.565 degrees -> atan(2^-1)
	   atan_table(2)  <= (others=>'0'); -- 14.036 degrees -> atan(2^-2)
	   atan_table(3)  <= (others=>'0'); -- atan(2^-3)
	   atan_table(4)  <= (others=>'0');
	   atan_table(5)  <= (others=>'0');
	   atan_table(6)  <= (others=>'0');
	   atan_table(7)  <= (others=>'0');
	   atan_table(8)  <= (others=>'0');
	   atan_table(9)  <= (others=>'0');
	   atan_table(10) <= (others=>'0');
	   atan_table(11) <= (others=>'0');
	   atan_table(12) <= (others=>'0');
	   atan_table(13) <= (others=>'0');
	else if(rising_edge(clk))then
           atan_table(0)  <= "0010000000000000"; -- 45.000 degrees -> atan(2^0)
	   atan_table(1)  <= "0001001011100100"; -- 26.565 degrees -> atan(2^-1)
	   atan_table(2)  <= "0000100111111011"; -- 14.036 degrees -> atan(2^-2)
	   atan_table(3)  <= "0000010100010001"; -- atan(2^-3)
	   atan_table(4)  <= "0000001010001011";
	   atan_table(5)  <= "0000000101000101";
	   atan_table(6)  <= "0000000010100010";
	   atan_table(7)  <= "0000000001010001";
	   atan_table(8)  <= "0000000000101000";
	   atan_table(9)  <= "0000000000010100";
	   atan_table(10) <= "0000000000001010";
	   atan_table(11) <= "0000000000000101";
	   atan_table(12) <= "0000000000000010";
	   atan_table(13) <= "0000000000000001";
	end if;
	end if;
   end process;


   process (clk,rst_n) is
   begin
       if(rst_n = '0')then
           out_valid <= '0';
           for k in 0 to 14 loop
               en_sig(k) <= '0';
           end loop;
       elsif(rising_edge(clk))then
               for k in 1 to 14 loop
                   en_sig(k) <= en_sig(k-1);
               end loop;
               en_sig(0) <= en_in;
               out_valid <= en_sig(14);
       end if;
   end process;

   process (clk) is
   begin
	if (rst_n = '0') then
	     X_init <= (others=>'0');
	     Y_init <= (others=>'0');
	     Z_init <= (others=>'0');
        elsif(rising_edge(clk))then
         if(en_in = '1')then
	     X_init <= "0100110110111000";
	     Y_init <= "0000000000000000";
	     Z_init <= angle;
	  end if;
         end if;
   end process;


   process (X,Y,Z) is
   begin
	for i in 0 to (SIZE-2) loop
            X_shift(i) 	<= shift_right(X(i), i);
 	    Y_shift(i) 	<= shift_right(Y(i), i);
            Z_sign(i) <= Z(i)(SIZE);
    	end loop;
   end process;


    --stages 0 to SIZE-2
   process (clk, rst_n) is
   begin
	if (rst_n = '0') then
	    for i in 0 to (SIZE-1) loop
                X(i) 	<= (others=>'0');
	        Y(i) 	<= (others=>'0');
        	Z(i) 	<= (others=>'0');
    	    end loop;
    elsif(rising_edge(clk))then
	     X(0) <= X_init;
	     Y(0) <= Y_init;
	     Z(0) <= Z_init;
     		for i in 0 to (SIZE-2) loop
              	    if (Z_sign(i) = '1') then
             		X(i+1) <= signed(X(i) + shift_right(Y(i), i));
             		Y(i+1) <= signed(Y(i) - shift_right(X(i), i));
             		Z(i+1) <= signed(Z(i) + atan_table(i));
	 	    else
	     		X(i+1) <= signed(X(i) - shift_right(Y(i), i));
             		Y(i+1) <= signed(Y(i) + shift_right(X(i), i));
             		Z(i+1) <= signed(Z(i) - atan_table(i));
         	    end if;
	        end loop;
     end if;
   end process;


   --output
   cosine <= X(SIZE-1);
   sine   <= Y(SIZE-1);

end cordic_arch;
