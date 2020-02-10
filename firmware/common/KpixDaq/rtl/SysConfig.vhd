-------------------------------------------------------------------------------
-- Title      : KPIX Config
-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Configuration registers for KPIX DAQ
-------------------------------------------------------------------------------
-- This file is part of KPIX. It is subject to
-- the license terms in the LICENSE.txt file found in the top-level directory
-- of this distribution and at:
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
-- No part of KPIX, including this file, may be
-- copied, modified, propagated, or distributed except according to the terms
-- contained in the LICENSE.txt file.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


library surf;
use surf.StdRtlPkg.all;
use surf.AxiLitePkg.all;

use work.KpixPkg.all;

entity SysConfig is

   generic (
      TPD_G : time := 1 ns);
   port (
      clk200 : in sl;
      rst200 : in sl;

      -- AXI-Lite interface for registers
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType;

      -- System level configuration
      config : out SysConfigType);
end entity SysConfig;

architecture rtl of SysConfig is

   type RegType is record
      config         : SysConfigType;
      axilWriteSlave : AxiLiteWriteSlaveType;
      axilReadSlave  : AxiLiteReadSlaveType;
   end record;

   constant REG_INIT_C : RegType := (
      config         => SYS_CONFIG_INIT_C,
      axilWriteSlave => AXI_LITE_WRITE_SLAVE_INIT_C,
      axilReadSlave  => AXI_LITE_READ_SLAVE_INIT_C);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

begin

   comb : process (axilReadMaster, axilWriteMaster, r, rst200) is
      variable v      : RegType;
      variable axilEp : AxiLiteEndpointType;
   begin
      v := r;

      v.config.kpixReset := '0';
      ----------------------------------------------------------------------------------------------
      -- AXI Lite registers
      ----------------------------------------------------------------------------------------------
      axiSlaveWaitTxn(axilEp, axilWriteMaster, axilReadMaster, v.axilWriteSlave, v.axilReadSlave);

      axiSlaveRegister(axilEp, x"00", 0, v.config.kpixReset);
      axiSlaveRegister(axilEp, x"04", 0, v.config.inputEdge);
      axiSlaveRegister(axilEp, x"04", 1, v.config.outputEdge);
--      axiSlaveRegister(axilEp, X"04", 2, v.config.rawDataMode);
      axiSlaveRegister(axilEp, X"04", 3, v.config.autoReadDisable);
      axiSlaveRegister(axilEp, X"08", 0, v.config.kpixEnable);
      axiSlaveRegister(axilEp, X"0C", 0, v.config.debugASel);
      axiSlaveRegister(axilEp, X"0C", 5, v.config.debugBSel);
      --axiSlaveRegister(axilEp, X"10", 4, v.config.numColumns);      

      axiSlaveDefault(axilEp, v.axilWriteSlave, v.axilReadSlave, AXI_RESP_DECERR_C);

      if (rst200 = '1') then
         v := REG_INIT_C;
      end if;

      rin <= v;

      config         <= r.config;
      axilReadSlave  <= r.axilReadSlave;
      axilWriteSlave <= r.axilWriteSlave;
   end process;

   seq : process (clk200) is
   begin
      if (rising_edge(clk200)) then
         r <= rin after TPD_G;
      end if;
   end process seq;
end architecture rtl;


