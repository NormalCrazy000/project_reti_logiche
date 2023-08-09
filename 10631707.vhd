----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.08.2023 22:57:43
-- Design Name: 
-- Module Name: project_reti_logiche - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity project_reti_logiche is
    port (
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_start : in std_logic;
        i_w : in std_logic;
        
        o_z0 : out std_logic_vector(7 downto 0);
        o_z1 : out std_logic_vector(7 downto 0);
        o_z2 : out std_logic_vector(7 downto 0);
        o_z3 : out std_logic_vector(7 downto 0);
        o_done : out std_logic;
        
        o_mem_addr : out std_logic_vector(15 downto 0);
        i_mem_data : in std_logic_vector(7 downto 0);
        o_mem_we : out std_logic;
        o_mem_en : out std_logic
);

end project_reti_logiche;

architecture Behavioral of project_reti_logiche is
component datapath is
    Port ( 
           i_clk : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           r_select : in std_logic;
           r1_reset: in std_logic;
           r2_reset: in std_logic;
           r1_load: in std_logic;
           r2_load: in std_logic;
           load: in std_logic;
           o_mem_addr : out std_logic_vector(15 downto 0);
           i_mem_data : in std_logic_vector(7 downto 0);
           i_w : in std_logic;
           o_z0 : out std_logic_vector(7 downto 0);
           o_z1 : out std_logic_vector(7 downto 0);
           o_z2 : out std_logic_vector(7 downto 0);
           o_z3 : out std_logic_vector(7 downto 0);
           appoggio_o_done : in std_logic
           );
end component;
signal r_select : std_logic;
signal r1_reset:  std_logic;
signal r2_reset:  std_logic;
signal r1_load:  std_logic;
signal r2_load:  std_logic;
signal load:  std_logic;
signal appoggio_o_done : std_logic;
type S is (S1,S2,S3,S4,S5,S6,S7,S8);
signal cur_state, next_state : S;
begin
DATAPATH0: datapath port map(
           i_clk,
           i_rst,
           r_select,
           r1_reset,
           r2_reset,
           r1_load,
           r2_load,
           load,
           o_mem_addr,
           i_mem_data,
           i_w,
           o_z0,
           o_z1,
           o_z2,
           o_z3,
           appoggio_o_done
           );
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            cur_state <= S1;
        elsif i_clk'event and i_clk = '1' then
            cur_state <= next_state;
        end if;
    end process;
    
    
    process(cur_state, i_start)
    begin
        next_state <= cur_state;
        case cur_state is
            when S1 =>
                if i_start = '1' then
                    next_state <= S2;
                end if;
            when S2 =>
                if i_start = '1' then
                    next_state <= S3;
                end if;
            when S3 =>
                if i_start = '1' then
                    next_state <= S4;
                elsif i_start = '0' then
                    next_state <= S5;
                end if;
            when S4 =>
                if i_start = '0' then
                    next_state <= S5;
                end if;
            when S5 =>
                next_state <= S6;
            when S6 =>
                next_state <= S7;
            when S7 =>
                next_state <= S8;
           when S8 =>
                next_state <= S1;
        end case;
    end process; 
     process(cur_state)
    begin
        r1_load <= '0';
        r_select <= '0';
        r1_reset <= '0';
        r2_load <= '0';
        r2_reset <= '0';
        o_mem_we <= '0';
        o_mem_en <= '0';
        o_done <= '0';
        appoggio_o_done <= '0';
        load <= '0';
        
        
        case cur_state is
            when S1 =>
            r1_reset <= '1';
               r2_reset <= '1';
            when S2 =>
               
               r2_load <= '1';
             
            when S3 =>
             r2_load <= '1';
            when S4 =>
                r1_load <= '1';
                r_select <= '1';
            when S5 =>
                o_mem_en <= '1';
            when S6 =>
            o_mem_en <= '0';
            when S7 =>
              
               load <= '1';
            when S8 =>
                o_done <= '1';
                appoggio_o_done <= '1';
                load <= '0';
        end case;
    end process;    
           
end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--TODO
entity datapath is
    Port ( 
           i_clk : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           r_select : in std_logic;
           r1_reset: in std_logic;
           r2_reset: in std_logic;
           r1_load: in std_logic;
           r2_load: in std_logic;
           load: in std_logic;
           o_mem_addr : out std_logic_vector(15 downto 0);
           i_mem_data : in std_logic_vector(7 downto 0);
        
           i_w : in std_logic;
           o_z0 : out std_logic_vector(7 downto 0);
           o_z1 : out std_logic_vector(7 downto 0);
           o_z2 : out std_logic_vector(7 downto 0);
           o_z3 : out std_logic_vector(7 downto 0);
           appoggio_o_done : in std_logic
           );
end datapath;

architecture Behavioral of datapath is
signal i_reg_indirizzo: std_logic;
signal i_reg_canale: std_logic;
signal o_reg_canale:  std_logic_vector(1 downto 0);
signal i_scelta_canale: std_logic_vector(3 downto 0);
signal i_modalita: std_logic_vector(3 downto 0);

signal i_valoreZ0 : std_logic_vector(7 downto 0);
signal i_valoreZ1 : std_logic_vector(7 downto 0);
signal i_valoreZ2 : std_logic_vector(7 downto 0);
signal i_valoreZ3 : std_logic_vector(7 downto 0);
signal o_reg_Z0 : std_logic_vector(7 downto 0);
signal o_reg_Z1 : std_logic_vector(7 downto 0);
signal o_reg_Z2 : std_logic_vector(7 downto 0);
signal o_reg_Z3 : std_logic_vector(7 downto 0);
signal appoggio_o_mem_addr : std_logic_vector(15 downto 0);
signal appoggio_o_reg_canale : std_logic_vector(1 downto 0);
signal cazzo: std_logic_vector(3 downto 0);
signal w_out: std_logic;
begin

--registro W
process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            w_out <= '0';
        elsif i_clk'event and i_clk = '1' then
          w_out <= i_w;
    end if;
  end process;

--Mux r_select
with r_select select
        i_reg_indirizzo <= '0' when '0',
                            w_out when '1',
                            'X' when others;
with r_select select
        i_reg_canale <=     w_out when '0',
                            '0' when '1',
                            'X' when others;
  
--Regstro scorrimento indirzzo    
process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_mem_addr <= "0000000000000000";
            appoggio_o_mem_addr <= "0000000000000000";
        elsif i_clk'event and i_clk = '1' then
            if(r1_load = '1') then
                appoggio_o_mem_addr <= appoggio_o_mem_addr(14 downto 0) & i_reg_indirizzo ;
               o_mem_addr(15) <= appoggio_o_mem_addr(14);
                o_mem_addr(14) <= appoggio_o_mem_addr(13);
                o_mem_addr(13) <= appoggio_o_mem_addr(12);
                o_mem_addr(12) <= appoggio_o_mem_addr(11);
                o_mem_addr(11) <= appoggio_o_mem_addr(10);
                o_mem_addr(10) <= appoggio_o_mem_addr(9);
                o_mem_addr(9) <= appoggio_o_mem_addr(8);
                o_mem_addr(8) <= appoggio_o_mem_addr(7);
                o_mem_addr(7) <= appoggio_o_mem_addr(6);
                o_mem_addr(6) <= appoggio_o_mem_addr(5);
                o_mem_addr(5) <= appoggio_o_mem_addr(4);
                o_mem_addr(4) <= appoggio_o_mem_addr(3);
                o_mem_addr(3) <= appoggio_o_mem_addr(2);
                o_mem_addr(2) <= appoggio_o_mem_addr(1);
                o_mem_addr(1) <= appoggio_o_mem_addr(0);
                o_mem_addr(0) <= i_reg_indirizzo;
            elsif (r1_reset = '1')then
            -----TODO
                o_mem_addr <= "0000000000000000";
                appoggio_o_mem_addr <= "0000000000000000";
        end if;
    end if;
  end process;      
  --TODO
  --Regstro scorrimento canale    
process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_reg_canale <= "00";
            appoggio_o_reg_canale <= "00";
            cazzo <= "0001";
        elsif i_clk'event and i_clk = '1' then
            if(r2_load = '1') then
              o_reg_canale <= o_reg_canale(0) & i_reg_canale ;
--              if(i_reg_canale = '0') then
--              cazzo <= "0000";
--              elsif(i_reg_canale = '1')then
--              cazzo <= "1111";
--              end if;
--              if(cazzo = "0001") then
--                cazzo <= "0010";
--              elsif(cazzo = "0010") then
--              cazzo <= "0100";
--              elsif(cazzo = "0100") then
--              cazzo <= "1000";
--              elsif(cazzo = "1000") then
--              cazzo <= "0001";
--              end if;

            elsif (r1_reset = '1')then
            -----TODO
                 o_reg_canale <= "00";
                 appoggio_o_reg_canale <= "00";
                 cazzo <= "0001";
        end if;
    end if;
  end process;
--Mux load
with o_reg_canale select
        i_scelta_canale <= "1000" when "00",
                           "0100" when "01",
                           "0010" when "10",
                           "0001" when "11",
                           "XXXX" when others;    
--Mux registro
with load select
        i_modalita <= "0000" when '0',
                      i_scelta_canale when '1',
                      "XXXX" when others;   
--Mux valore
with o_reg_canale select
        i_valoreZ0 <= i_mem_data when "00",
                      "00000000" when "01",
                      "00000000" when "10",
                      "00000000" when "11",
                      "XXXXXXXX" when others;                    
with o_reg_canale select
        i_valoreZ1 <= "00000000" when "00",
                      i_mem_data when "01",
                      "00000000" when "10",
                      "00000000" when "11",
                      "XXXXXXXX" when others;                                                                                             
with o_reg_canale select
        i_valoreZ2 <= "00000000" when "00",
                      "00000000" when "01",
                      i_mem_data when "10",
                      "00000000" when "11",
                      "XXXXXXXX" when others;                    
with o_reg_canale select
        i_valoreZ3 <= "00000000" when "00",
                      "00000000" when "01",
                      "00000000" when "10",
                      i_mem_data when "11",
                      "XXXXXXXX" when others;                    
--Regstro Z0 
process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_reg_Z0 <= "00000000";
        elsif i_clk'event and i_clk = '1' then
            if(i_modalita = "1000") then
               o_reg_Z0 <= i_valoreZ0;
        end if;
    end if;
  end process;  
  --Regstro Z1 
process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_reg_Z1 <= "00000000";
        elsif i_clk'event and i_clk = '1' then
            if(i_modalita = "0100") then
               o_reg_Z1 <= i_valoreZ1;
        end if;
    end if;
  end process;                                         
--Regstro Z2
process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_reg_Z2 <= "00000000";
        elsif i_clk'event and i_clk = '1' then
            if(i_modalita = "0010") then
               o_reg_Z2 <= i_valoreZ2;
        end if;
    end if;
  end process;  
  --Regstro Z3
process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_reg_Z3 <= "00000000";
        elsif i_clk'event and i_clk = '1' then
            if(i_modalita = "0001") then
               o_reg_Z3 <= i_valoreZ3;
        end if;
    end if;
  end process;
  --Mux Z0
with appoggio_o_done select
        o_z0 <= "00000000" when '0',
                o_reg_Z0 when '1',
                "XXXXXXXX" when others;   
 --Mux Z1
with appoggio_o_done select
        o_z1 <= "00000000" when '0',
                o_reg_Z1 when '1',
                "XXXXXXXX" when others;        
 --Mux Z2
with appoggio_o_done select
        o_z2 <= "00000000" when '0',
                o_reg_Z2 when '1',
                "XXXXXXXX" when others; 
--Mux Z3
with appoggio_o_done select
        o_z3 <= "00000000" when '0',
                o_reg_Z3 when '1',
                "XXXXXXXX" when others;                                                    
--    '''process(i_clk, i_rst)
--    begin
--        if(i_rst = '1') then
--            o_reg1 <= "00000000";
--        elsif i_clk'event and i_clk = '1' then
--            if(r1_load = '1') then
--                o_reg1 <= i_data;
--            end if;
--        end if;
--    end process;
    
--    sum <= ("00000000" & o_reg1) + o_reg2;
    
--    with r2_sel select
--        mux_reg2 <= "0000000000000000" when '0',
--                    sum when '1',
--                    "XXXXXXXXXXXXXXXX" when others;
    
--    process(i_clk, i_rst)
--    begin
--        if(i_rst = '1') then
--            o_reg2 <= "0000000000000000";
--        elsif i_clk'event and i_clk = '1' then
--            if(r2_load = '1') then
--                o_reg2 <= mux_reg2;
--            end if;
--        end if;
--    end process;
    
--    with d_sel select
--        o_data <= o_reg2(7 downto 0) when '0',
--                  o_reg2(15 downto 8) when '1',
--                  "XXXXXXXX" when others;
    
--    with r3_sel select
--        mux_reg3 <= i_data when '0',
--                    sub when '1',
--                    "XXXXXXXX" when others;
--    process(i_clk, i_rst)
--    begin
--        if(i_rst = '1') then
--            o_reg3 <= "00000000";
--        elsif i_clk'event and i_clk = '1' then
--            if(r3_load = '1') then
--                o_reg3 <= mux_reg3;
--            end if;
--        end if;
--    end process;
    
--    sub <= o_reg3 - "00000001";
    
--    o_end <= '1' when (o_reg3 = "00000000") else '0';

end Behavioral;

