--Adapted from GPIO_Demo code provided by Digilent
--Engineer     : Vanessa Su
--Date Created : 11/20/2017
--Name of file : ui1.vhd
--Description  : user interface unit version 2 - UART, switches, buttons interface

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.std_logic_unsigned.all;
use work.ui2_pkg.all;

entity ui2 is
    port (
           CLK 			  : in STD_LOGIC;
           SW         : in STD_LOGIC_VECTOR (15 downto 0);
           BTN        : in STD_LOGIC_VECTOR (4 downto 0);
           SSEG_AN 		: out  STD_LOGIC_VECTOR (3 downto 0);
           UART_TXD   : out STD_LOGIC
			   );
end ui2;

architecture ui2_arch of ui2 is

  component cordic_proc is
      generic ( SIZE : integer := 15 ) ;
      port(
            clk    				: in std_logic  ;
            rst_n    			: in std_logic  ;
            en_in         : in std_logic  ;
            angle_in	    : in signed  (SIZE  downto 0);
            sine_out  	  : out signed (SIZE downto 0);
            cosine_out    : out signed (SIZE downto 0);
            out_valid				  : out std_logic
          );
  end component;

  component UART_TX_CTRL
  Port(
  	SEND : in std_logic;
  	DATA : in std_logic_vector(7 downto 0);
  	CLK : in std_logic;
  	READY : out std_logic;
  	UART_TX : out std_logic
  	);
  end component;

  component debouncer
  Generic(
          DEBNC_CLOCKS : integer;
          PORT_WIDTH : integer);
  Port(
  		SIGNAL_I : in std_logic_vector(4 downto 0);
  		CLK_I : in std_logic;
  		SIGNAL_O : out std_logic_vector(4 downto 0)
  		);
  end component;

  type UART_STATE_TYPE is (RST_REG, LD_RDY_STR, SEND_CHAR, RDY_LOW, WAIT_RDY, WAIT_BTN, LD_OUT_STR);
  type CHAR_ARRAY is array (integer range<>) of std_logic_vector (7 downto 0);

  --For initial and reset
  --/nReady!/n/n/r
  constant rdy_str : CHAR_ARRAY(0 to 9) := (X"0A", X"52", X"65", X"61", X"64",
  X"79", X"21", X"0A", X"0A", X"0D");

  --Cosine String, for formatting output
  --Cosine:
  constant cos_str : CHAR_ARRAY(0 to 7) := (X"43", X"6F", X"73", X"69",
  X"6E", X"65", X"3A", X"20");

  --Sine String, for formatting output
  --Sine:
  constant sin_str : CHAR_ARRAY(0 to 5) := (X"53", X"69", X"6E", X"65",
  X"3A", X"20");

  --Error String
  --\n!!\n\r
  constant err_str : CHAR_ARRAY(0 to 4) := (X"0A", X"21", X"21", X"0A", X"0D");

  --Output String, for formatting output
  --\nAngle input:
  constant in_str : CHAR_ARRAY(0 to 13) := (X"0A", X"41", X"6E", X"67", X"6C",
  X"65", X"20", X"69", X"6E", X"70", X"75", X"74", X"3A", X"20");

  constant RESET_CNTR_MAX : std_logic_vector(17 downto 0) := "110000110101000000";-- 100,000,000 * 0.002 = 200,000 = clk cycles per 2 ms
  constant MAX_STR_LEN : integer := 54;
  constant RDY_LEN : integer := 10;
  constant ERR_LEN : integer := 5;
  constant OUT_LEN : integer := 54;

  --Contains the current string being sent over uart.
  signal sendStr : CHAR_ARRAY(0 to (MAX_STR_LEN - 1));

  --Contains the length of the current string being sent over uart.
  signal strEnd : natural;

  --Contains the index of the next character to be sent over uart
  --within the sendStr variable.
  signal strIndex : natural;

  --Used to determine when a button press has occured
  signal btnReg : std_logic_vector (3 downto 0) := "0000";
  signal btnDetect : std_logic;

  --Debounced btn signals used to prevent single button presses
  --from being interpreted as multiple button presses.
  signal btnDeBnc : std_logic_vector(4 downto 0);

  --UART_TX_CTRL control signals
  signal uartRdy : std_logic;
  signal uartSend : std_logic := '0';
  signal uartData : std_logic_vector (7 downto 0):= "00000000";
  signal uartTX : std_logic;

  --Current uart state signal
  signal uartState : UART_STATE_TYPE := RST_REG;

  --this counter counts the amount of time paused in the UART reset state
  signal reset_cntr : std_logic_vector (17 downto 0) := (others=>'0');

  signal send_ang : std_logic;
  signal angle_in : unsigned (14 downto 0);
  signal out_angle : CHAR_ARRAY(0 to 7);
  signal cord_in : signed(15 downto 0);
  signal sin_out : signed(15 downto 0);
  signal cos_out : signed(15 downto 0);
  signal cord_sin_out : signed(15 downto 0);
  signal cord_cos_out : signed(15 downto 0);
  signal out_sin_str : CHAR_ARRAY(0 to 8);
  signal out_cos_str : CHAR_ARRAY(0 to 8);
  signal cordic_valid : std_logic;
  signal cordic_rst : std_logic;


begin
  SSEG_AN <= "1111"; --prevents seven seg display from floating, turns off

  ----------------------------------------------------------
  ------              Button Control                 -------
  ----------------------------------------------------------
  --Buttons are debounced and their rising edges are detected
  --to trigger UART messages


  --Debounces btn signals
  Inst_btn_debounce: debouncer
      generic map(
          DEBNC_CLOCKS => (2**16),
          PORT_WIDTH => 5)
      port map(
  		SIGNAL_I => BTN,
  		CLK_I => CLK,
  		SIGNAL_O => btnDeBnc
  	);

  --Registers the debounced button signals, for edge detection.
  btn_reg_process : process (CLK)
  begin
  	if (rising_edge(CLK)) then
  		btnReg <= btnDeBnc(3 downto 0);
  	end if;
  end process;

  --btnDetect goes high for a single clock cycle when a btn press is
  --detected. This triggers a UART message to begin being sent.
  btnDetect <= '1' when ((btnReg(0)='0' and btnDeBnc(0)='1') or
  								(btnReg(1)='0' and btnDeBnc(1)='1') or
  								(btnReg(2)='0' and btnDeBnc(2)='1') or
  								(btnReg(3)='0' and btnDeBnc(3)='1')  ) else
  				  '0';

 sw_interface : process (CLK)
 variable count : std_logic_vector (7 downto 0) := (others => '0');
 constant incr : unsigned (7 downto 0) := to_unsigned(225, 8);
 begin
   count := count_sw(SW);
   angle_in <= resize(incr * unsigned(count), 15);
 end process;


  ----------------------------------------------------------
  ------              UART Control                   -------
  ----------------------------------------------------------
  --Messages are sent on reset and when a button is pressed.

  --This counter holds the UART state machine in reset for ~2 milliseconds. This
  --will complete transmission of any byte that may have been initiated during
  --FPGA configuration due to the UART_TX line being pulled low, preventing a
  --frame shift error from occuring during the first message.
  process(CLK)
  begin
    if (rising_edge(CLK)) then
      if ((reset_cntr = RESET_CNTR_MAX) or (uartState /= RST_REG)) then
        reset_cntr <= (others=>'0');
      else
        reset_cntr <= reset_cntr + 1;
      end if;
    end if;
  end process;

  --Next Uart state logic (states described above)
  next_uartState_process : process (CLK)
  begin
  	if (rising_edge(CLK)) then
  		if (btnDeBnc(4) = '1') then
  			uartState <= RST_REG;
  		else
  			case uartState is
  			when RST_REG =>
          if (reset_cntr = RESET_CNTR_MAX) then
            uartState <= LD_RDY_STR;
          end if;
  			when LD_RDY_STR =>
  				uartState <= SEND_CHAR;
  			when SEND_CHAR =>
  				uartState <= RDY_LOW;
  			when RDY_LOW =>
  				uartState <= WAIT_RDY;
  			when WAIT_RDY =>
  				if (uartRdy = '1') then
  					if (strIndex = strEnd) then
  						uartState <= WAIT_BTN;
  					else
  						uartState <= SEND_CHAR;
  					end if;
  				end if;
  			when WAIT_BTN =>
  				if (btnDetect = '1') then
  					uartState <= LD_OUT_STR;
  				end if;
        when LD_OUT_STR =>
    			  uartState <= SEND_CHAR;
  			when others=> --should never be reached
  				uartState <= RST_REG;
  			end case;
  		end if ;
  	end if;
  end process;

  --Loads the sendStr and strEnd signals when a LD state is
  --is reached.
  string_load_process : process (CLK)
  begin
  	if (rising_edge(CLK)) then
  		if (uartState = LD_RDY_STR) then
  			sendStr(0 to (RDY_LEN-1)) <= rdy_str;
  			strEnd <= RDY_LEN;
  		elsif (uartState = LD_OUT_STR) then
  			sendStr(0 to (OUT_LEN-1)) <= in_str & out_angle & sin_str & out_sin_str & cos_str & out_cos_str;
  			strEnd <= OUT_LEN;
  		end if;
  	end if;
  end process;

  cordic_input : process (CLK)
  variable angle_out : signed (15 downto 0);
  variable adj_ang : integer;
  variable disp_ang : signed (15 downto 0);
  variable bcd_num : std_logic_vector (15 downto 0);
  variable bcd : std_logic_vector (19 downto 0);
  begin
    if (rising_edge(CLK)) then
      if angle_in > to_unsigned(1800, 15) then
        adj_ang := (2**16)*(to_integer(angle_in) - 3600)/3600;
        disp_ang := to_signed(to_integer(angle_in) - 3600, 16);
        angle_out := to_signed(adj_ang, 16);
        bcd_num := std_logic_vector(not disp_ang + 1);
        bcd := binary_to_bcd(bcd_num);
      else
        adj_ang := (2**16)*to_integer(angle_in)/3600;
        disp_ang := signed('0' & angle_in);
        angle_out := to_signed(adj_ang, 16);
        bcd_num := std_logic_vector(disp_ang);
        bcd := binary_to_bcd(bcd_num);
      end if;
      if disp_ang(15) = '1' then
        out_angle(0) <= X"2D"; -- - (minus sign)
      else
        out_angle(0) <= X"2B"; -- + (plus sign)
      end if;
      out_angle(1) <= to_hexchar(bcd(15 downto 12));
      out_angle(2) <= to_hexchar(bcd(11 downto 8));
      out_angle(3) <= to_hexchar(bcd(7 downto 4));
      out_angle(4) <= X"2E"; --. (period)
      out_angle(5) <= to_hexchar(bcd(3 downto 0));
      out_angle(6) <= X"0A"; --\n
      out_angle(7) <= X"0D"; --\r
      cord_in <= angle_out;
    end if;
  end process;

  sine_output : process (CLK)
  variable conv_num : integer;
  variable bcd_num : std_logic_vector (15 downto 0);
  variable bcd : std_logic_vector (19 downto 0);
  begin
    if (rising_edge(CLK)) then
      if cordic_valid = '1' then
        cord_sin_out <= sin_out;
        conv_num := (10000 * to_integer(cord_sin_out))/(2**15);
        if cord_sin_out(15) = '1' then
          out_sin_str(0) <= X"2D"; -- - (minus sign)
          bcd_num := std_logic_vector(not to_signed(conv_num, 16) + 1);
          bcd := binary_to_bcd(bcd_num);
        else
          out_sin_str(0) <= X"2B"; -- + (plus sign)
          bcd_num := std_logic_vector(to_signed(conv_num, 16));
          bcd := binary_to_bcd(bcd_num);
        end if;
        out_sin_str(1) <= X"30"; --0
        out_sin_str(2) <= X"2E"; --. (period)
        out_sin_str(3) <= to_hexchar(bcd(15 downto 12));
        out_sin_str(4) <= to_hexchar(bcd(11 downto 8));
        out_sin_str(5) <= to_hexchar(bcd(7 downto 4));
        out_sin_str(6) <= to_hexchar(bcd(3 downto 0));
        out_sin_str(7) <= X"0A"; --\n
        out_sin_str(8) <= X"0D"; --\r
      end if;
    end if;
  end process;

  cosine_output : process (CLK)
  variable conv_num : integer;
  variable bcd_num : std_logic_vector (15 downto 0);
  variable bcd : std_logic_vector (19 downto 0);
  begin
    if (rising_edge(CLK)) then
      if cordic_valid = '1' then
        cord_cos_out <= cos_out;
        conv_num := (10000 * to_integer(cord_cos_out))/(2**15);
        if cord_cos_out(15) = '1' then
          out_cos_str(0) <= X"2D"; -- - (minus sign)
          bcd_num := std_logic_vector(not to_signed(conv_num, 16) + 1);
          bcd := binary_to_bcd(bcd_num);
        else
          out_cos_str(0) <= X"2B"; -- + (plus sign)
          bcd_num := std_logic_vector(to_signed(conv_num, 16));
          bcd := binary_to_bcd(bcd_num);
        end if;
        out_cos_str(1) <= X"30"; --0
        out_cos_str(2) <= X"2E"; --. (period)
        out_cos_str(3) <= to_hexchar(bcd(15 downto 12));
        out_cos_str(4) <= to_hexchar(bcd(11 downto 8));
        out_cos_str(5) <= to_hexchar(bcd(7 downto 4));
        out_cos_str(6) <= to_hexchar(bcd(3 downto 0));
        out_cos_str(7) <= X"0A"; --\n
        out_cos_str(8) <= X"0D"; --\r
      end if;
    end if;
  end process;
  --Conrols the strIndex signal so that it contains the index
  --of the next character that needs to be sent over uart
  char_count_process : process (CLK)
  begin
  	if (rising_edge(CLK)) then
  		if (uartState = LD_RDY_STR or uartState = LD_OUT_STR) then
  			strIndex <= 0;
  		elsif (uartState = SEND_CHAR) then
  			strIndex <= strIndex + 1;
  		end if;
  	end if;
  end process;

  --Controls the UART_TX_CTRL signals
  char_load_process : process (CLK)
  begin
  	if (rising_edge(CLK)) then
  		if (uartState = SEND_CHAR) then
  			uartSend <= '1';
  			uartData <= sendStr(strIndex);
  		else
  			uartSend <= '0';
  		end if;
  	end if;
  end process;

  --Component used to send a byte of data over a UART line.
  Inst_UART_TX_CTRL: UART_TX_CTRL port map(
  		SEND => uartSend,
  		DATA => uartData,
  		CLK => CLK,
  		READY => uartRdy,
  		UART_TX => uartTX
  	);

  UART_TXD <= uartTX;

  cordic_rst <= not(btnDeBnc(4));

  cordic : cordic_proc
  generic map( SIZE => 15 )
  port map(
        clk => CLK,
        rst_n => cordic_rst,
        en_in => '1',
        angle_in => cord_in,
        sine_out => sin_out,
        cosine_out => cos_out,
        out_valid => cordic_valid
      );

end ui2_arch;
