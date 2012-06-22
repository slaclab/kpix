-------------------------------------------------------------------------------
-- Title      : Ethernet Controller Interface Package
-------------------------------------------------------------------------------
-- File       : RegCntlPkg.vhd
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-05-03
-- Last update: 2012-05-21
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Port types for EthernetCore Interfaces
-------------------------------------------------------------------------------
-- Copyright (c) 2012 SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.StdRtlPkg.all;

package EthFrontEndPkg is

  -- Register Interface
  type EthRegCntlInType is record
    regAck    : sl;
    regFail   : sl;
    regDataIn : slv(31 downto 0);
  end record EthRegCntlInType;

  type EthRegCntlOutType is record
    regInp     : sl;                    -- Operation in progress
    regReq     : sl;                    -- Request reg transaction
    regOp      : sl;                    -- Read (0) or write (1)
    regAddr    : slv(23 downto 0);      -- Address
    regDataOut : slv(31 downto 0);      -- Write Data
  end record EthRegCntlOutType;

  -- Command Interface
  type EthCmdCntlOutType is record
    cmdEn     : sl;                     -- Command available
    cmdOpCode : slv(7 downto 0);        -- Command Op Code
    cmdCtxOut : slv(23 downto 0);       -- Command Context
  end record EthCmdCntlOutType;

  -- Upstream Data Buffer Interface
  type EthUsDataOutType is record
    frameTxAfull : sl;
  end record EthUsDataOutType;

  type EthUsDataInType is record
    frameTxEnable : sl;
    frameTxSOF    : sl;
    frameTxEOF    : sl;
    frameTxData   : slv(63 downto 0);
  end record EthUsDataInType;

end package EthFrontEndPkg;
