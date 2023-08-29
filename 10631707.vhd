----------------------------------------------------------------------------------
-- Politecnico di Milano 2022/2023  
-- Gabriele Giannotto ( 10631707 )
-- Progetto Reti Logiche
-- Professore Fabio Salice
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

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

architecture StateMachine of project_reti_logiche is
    component datapath is
        Port ( 
               i_clk : in STD_LOGIC;
               i_rst : in STD_LOGIC;
               s_canale_indirizzo : in std_logic;
               r_shift_reg_indirizzo: in std_logic;
               l_shift_reg_indirizzo: in std_logic;
               l_shift_reg_canale: in std_logic;
               s_modalita: in std_logic;
               o_mem_addr : out std_logic_vector(15 downto 0);
               i_mem_data : in std_logic_vector(7 downto 0);
               i_w : in std_logic;
               o_z0 : out std_logic_vector(7 downto 0);
               o_z1 : out std_logic_vector(7 downto 0);
               o_z2 : out std_logic_vector(7 downto 0);
               o_z3 : out std_logic_vector(7 downto 0);
               supporto_o_done : in std_logic
               );
    end component;
    signal s_canale_indirizzo : std_logic;
    signal r_shift_reg_indirizzo:  std_logic;
    signal l_shift_reg_indirizzo:  std_logic;
    signal l_shift_reg_canale:  std_logic;
    signal s_modalita:  std_logic;
    signal supporto_o_done : std_logic;
    type S is (S1,S2,S3,S4,S5,S6,S7,S8);
    signal cur_state, next_state : S;
    begin
        DATAPATH0: datapath port map(
               i_clk,
               i_rst,
               s_canale_indirizzo,
               r_shift_reg_indirizzo,
               l_shift_reg_indirizzo,
               l_shift_reg_canale,
               s_modalita,
               o_mem_addr,
               i_mem_data,
               i_w,
               o_z0,
               o_z1,
               o_z2,
               o_z3,
               supporto_o_done
               );
        --  Change current state
        process(i_clk, i_rst)
        begin
            if(i_rst = '1') then
                cur_state <= S1;
            elsif i_clk'event and i_clk = '1' then
                cur_state <= next_state;
            end if;
        end process;
        
         -- Change Next state
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
        
        -- Change variable state
        process(cur_state)
        begin
            l_shift_reg_indirizzo <= '0';
            s_canale_indirizzo <= '0';
            r_shift_reg_indirizzo <= '0';
            l_shift_reg_canale <= '0';
            o_mem_we <= '0';
            o_mem_en <= '0';
            o_done <= '0';
            supporto_o_done <= '0';
            s_modalita <= '0'; 
            case cur_state is
                when S1 =>
                r_shift_reg_indirizzo <= '1';
                when S2 =>
                   l_shift_reg_canale <= '1';
                when S3 =>
                 l_shift_reg_canale <= '1';
                when S4 =>
                    l_shift_reg_indirizzo <= '1';
                    s_canale_indirizzo <= '1';
                when S5 =>
                    o_mem_en <= '1';
                when S6 =>
                --TODO
                --o_mem_en <= '0';
                when S7 =>
                   s_modalita <= '1';
                when S8 =>
                    o_done <= '1';
                    supporto_o_done <= '1';
                    --TODO
                   --modalita <= '0';
            end case;
        end process;        
end StateMachine;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity datapath is
    Port ( 
           i_clk : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           s_canale_indirizzo : in std_logic;
           r_shift_reg_indirizzo: in std_logic;
           l_shift_reg_indirizzo: in std_logic;
           l_shift_reg_canale: in std_logic;
           s_modalita: in std_logic;
           o_mem_addr : out std_logic_vector(15 downto 0);
           i_mem_data : in std_logic_vector(7 downto 0);
        
           i_w : in std_logic;
           o_z0 : out std_logic_vector(7 downto 0);
           o_z1 : out std_logic_vector(7 downto 0);
           o_z2 : out std_logic_vector(7 downto 0);
           o_z3 : out std_logic_vector(7 downto 0);
           supporto_o_done : in std_logic
           );
end datapath;

architecture DataPath of datapath is
    signal i_indirizzo: std_logic;
    signal i_canale: std_logic;
    signal o_canale:  std_logic_vector(1 downto 0);
    signal o_scelta_canale: std_logic_vector(3 downto 0);
    signal i_modalita: std_logic_vector(3 downto 0);
    signal i_z0 : std_logic_vector(7 downto 0);
    signal i_z1 : std_logic_vector(7 downto 0);
    signal i_z2 : std_logic_vector(7 downto 0);
    signal i_z3 : std_logic_vector(7 downto 0);
    signal o_r_z0 : std_logic_vector(7 downto 0);
    signal o_r_z1 : std_logic_vector(7 downto 0);
    signal o_r_z2 : std_logic_vector(7 downto 0);
    signal o_r_z3 : std_logic_vector(7 downto 0);
    signal supporto_o_mem_addr : std_logic_vector(15 downto 0);
    signal o_w:  std_logic;
    begin
    --register W
        process(i_clk, i_rst)
        begin
            if(i_rst = '1') then
                o_w <= '0';
            elsif i_clk'event and i_clk = '1' then
              o_w <= i_w;
        end if;
        end process;
        
        --Demux s_canale_indirizzo
        with s_canale_indirizzo select
            i_indirizzo <= '0' when '0',
                                o_w when '1',
                                'X' when others;
        with s_canale_indirizzo select
            i_canale <=     o_w when '0',
                                '0' when '1',
                                'X' when others;
        
        --Left Shift register indirzzo    
        process(i_clk, i_rst)
        begin
            if(i_rst = '1') then
                o_mem_addr <= "0000000000000000";
                supporto_o_mem_addr <= "0000000000000000";
            elsif i_clk'event and i_clk = '1' then
                if(l_shift_reg_indirizzo = '1') then
                    supporto_o_mem_addr <= supporto_o_mem_addr(14 downto 0) & i_indirizzo ;
                   o_mem_addr(15) <= supporto_o_mem_addr(14);
                    o_mem_addr(14) <= supporto_o_mem_addr(13);
                    o_mem_addr(13) <= supporto_o_mem_addr(12);
                    o_mem_addr(12) <= supporto_o_mem_addr(11);
                    o_mem_addr(11) <= supporto_o_mem_addr(10);
                    o_mem_addr(10) <= supporto_o_mem_addr(9);
                    o_mem_addr(9) <= supporto_o_mem_addr(8);
                    o_mem_addr(8) <= supporto_o_mem_addr(7);
                    o_mem_addr(7) <= supporto_o_mem_addr(6);
                    o_mem_addr(6) <= supporto_o_mem_addr(5);
                    o_mem_addr(5) <= supporto_o_mem_addr(4);
                    o_mem_addr(4) <= supporto_o_mem_addr(3);
                    o_mem_addr(3) <= supporto_o_mem_addr(2);
                    o_mem_addr(2) <= supporto_o_mem_addr(1);
                    o_mem_addr(1) <= supporto_o_mem_addr(0);
                    o_mem_addr(0) <= i_indirizzo;
                elsif (r_shift_reg_indirizzo = '1')then
                -----TODO
                    o_mem_addr <= "0000000000000000";
                    supporto_o_mem_addr <= "0000000000000000";
            end if;
        end if;
        end process;      
        --TODO
        --Left Shift register canale    
        process(i_clk, i_rst)
        begin
            if(i_rst = '1') then
                o_canale <= "00";
            elsif i_clk'event and i_clk = '1' then
                if(l_shift_reg_canale = '1') then
                  o_canale <= o_canale(0) & i_canale ;
            end if;
        end if;
        end process;
        --Mux o_canale
        with o_canale select
            o_scelta_canale <= "1000" when "00",
                               "0100" when "01",
                               "0010" when "10",
                               "0001" when "11",
                               "XXXX" when others;    
        --Mux s_modalita
        with s_modalita select
            i_modalita <= "0000" when '0',
                          o_scelta_canale when '1',
                          "XXXX" when others;   
        --Demux o_canale
        with o_canale select
            i_z0 <= i_mem_data when "00",
                          "00000000" when "01",
                          "00000000" when "10",
                          "00000000" when "11",
                          "XXXXXXXX" when others;                    
        with o_canale select
            i_z1 <= "00000000" when "00",
                          i_mem_data when "01",
                          "00000000" when "10",
                          "00000000" when "11",
                          "XXXXXXXX" when others;                                                                                             
        with o_canale select
            i_z2 <= "00000000" when "00",
                          "00000000" when "01",
                          i_mem_data when "10",
                          "00000000" when "11",
                          "XXXXXXXX" when others;                    
        with o_canale select
            i_z3 <= "00000000" when "00",
                          "00000000" when "01",
                          "00000000" when "10",
                          i_mem_data when "11",
                          "XXXXXXXX" when others;                    
        --Register Z0 
        process(i_clk, i_rst)
        begin
            if(i_rst = '1') then
                o_r_z0 <= "00000000";
            elsif i_clk'event and i_clk = '1' then
                if(i_modalita = "1000") then
                   o_r_z0 <= i_z0;
            end if;
        end if;
        end process;  
        --Register Z1 
        process(i_clk, i_rst)
        begin
            if(i_rst = '1') then
                o_r_z1 <= "00000000";
            elsif i_clk'event and i_clk = '1' then
                if(i_modalita = "0100") then
                   o_r_z1 <= i_z1;
            end if;
        end if;
        end process;                                         
        --Register Z2
        process(i_clk, i_rst)
        begin
            if(i_rst = '1') then
                o_r_z2 <= "00000000";
            elsif i_clk'event and i_clk = '1' then
                if(i_modalita = "0010") then
                   o_r_z2 <= i_z2;
            end if;
        end if;
        end process;  
        --Register Z3
        process(i_clk, i_rst)
        begin
            if(i_rst = '1') then
                o_r_z3 <= "00000000";
            elsif i_clk'event and i_clk = '1' then
                if(i_modalita = "0001") then
                   o_r_z3 <= i_z3;
            end if;
        end if;
        end process;
        --Mux Z0
        with supporto_o_done select
            o_z0 <= "00000000" when '0',
                    o_r_z0 when '1',
                    "XXXXXXXX" when others;   
        --Mux Z1
        with supporto_o_done select
            o_z1 <= "00000000" when '0',
                    o_r_z1 when '1',
                    "XXXXXXXX" when others;        
        --Mux Z2
        with supporto_o_done select
            o_z2 <= "00000000" when '0',
                    o_r_z2 when '1',
                    "XXXXXXXX" when others; 
        --Mux Z3
        with supporto_o_done select
                o_z3 <= "00000000" when '0',
                        o_r_z3 when '1',
                        "XXXXXXXX" when others;                                                    
end DataPath; 
