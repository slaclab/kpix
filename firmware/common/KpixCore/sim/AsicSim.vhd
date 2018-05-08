use work.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity AsicSim is port ( 
      sysclk            : in  std_logic;
      reset             : in  std_logic;
      command           : in  std_logic;
      data_out          : out std_logic
   );

end AsicSim;

architecture AsicSim of AsicSim is

   -- Local Signals
   signal reg_clock         : std_logic;
   signal reg_sel1          : std_logic;
   signal reg_sel0          : std_logic;
   signal reg_data          : std_logic;
   signal reg_wr_ena        : std_logic;
   signal rdback            : std_logic;
   signal ana_rdback        : std_logic;
   signal data_rdback       : std_logic;
   signal temp_id           : std_logic_vector(7 downto 0);
   signal temp_en           : std_logic;
   signal reset_l           : std_logic;
   signal reset_load        : std_logic;
   signal pwr_up_acq_dig    : std_logic;
   signal pwr_up_acq        : std_logic;
   signal leakage_null      : std_logic;
   signal offset_null       : std_logic;
   signal thresh_off        : std_logic;
   signal trig_inh          : std_logic;
   signal cal_strobe        : std_logic;
   signal sel_cell          : std_logic;
   signal desel_all_cells   : std_logic;
   signal ramp_period       : std_logic;
   signal precharge_bus     : std_logic;
   signal analog_state      : std_logic_vector(2 downto 0);
   signal read_state        : std_logic_vector(2 downto 0);

begin

   -- Digital Core
   U_DigCore : entity memory_array_control port map ( 
      sysclk            => sysclk,
      reset             => reset,
      command           => command,
      data_out          => data_out,
      temp_id0          => temp_id(0),
      temp_id1          => temp_id(1),
      temp_id2          => temp_id(2),
      temp_id3          => temp_id(3),
      temp_id4          => temp_id(4),
      temp_id5          => temp_id(5),
      temp_id6          => temp_id(6),
      temp_id7          => temp_id(7),
      temp_en           => temp_en,
      out_reset_l       => reset_l,
      int_reset_l       => reset_l,
      reg_clock         => reg_clock,
      reg_sel1          => reg_sel1,
      reg_sel0          => reg_sel0,
      pwr_up_acq        => pwr_up_acq,
      reset_load        => reset_load,
      leakage_null      => leakage_null,
      offset_null       => offset_null,
      thresh_off        => thresh_off,
      trig_inh          => trig_inh,
      cal_strobe        => cal_strobe,
      pwr_up_acq_dig    => pwr_up_acq_dig,
      sel_cell          => sel_cell,
      desel_all_cells   => desel_all_cells,
      ramp_period       => ramp_period,
      precharge_bus     => precharge_bus,
      analog_state      => analog_state,
      read_state        => read_state,
      reg_data          => reg_data,
      reg_wr_ena        => reg_wr_ena,
      rdback            => rdback
   );

   -- Temperature mux
   temp_id <= x"0C" when temp_en = '0' else x"55";

   -- Analog Registers
   U_AnalogReg : entity AnalogReg port map ( 
      reset       => reset,
      reg_clock   => reg_clock,
      reg_sel1    => reg_sel1,
      reg_sel0    => reg_sel0,
      reg_data    => reg_data,
      reg_wr_ena  => reg_wr_ena,
      rdback      => ana_rdback
   );

   -- Data readback
   U_DataRead : entity DataRead port map ( 
      reset             => reset,
      reset_load        => reset_load,
      pwr_up_acq_dig    => pwr_up_acq_dig,
      reg_clock         => reg_clock,
      reg_sel1          => reg_sel1,
      reg_sel0          => reg_sel0,
      rdback            => data_rdback
   );

   -- Return data
   rdback <= ana_rdback or data_rdback;

end AsicSim;

