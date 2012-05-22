-------------------------------------------------------------------------------
-- Title      : Ethernet Register Interface Decoder
-------------------------------------------------------------------------------
-- File       : EthRegDecoder.vhd
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-05-07
-- Last update: 2012-05-17
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Decodes register addresses from the Ethernet RegCntl interface.
-------------------------------------------------------------------------------
-- Copyright (c) 2012 SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.StdRtlPkg.all;
use work.EthFrontEndPkg.all;
use work.EthRegDecoderPkg.all;

entity EthRegDecoder is
  
  generic (
    DELAY_G : time := 1 ns);

  port (
    sysClk : in sl;
    sysRst : in sl;

    -- Interface to Ethernet core 
    ethRegCntlOut : in  EthRegCntlOutType;
    ethRegCntlIn  : out EthRegCntlInType;

    -- Interface to local module registers
    ethRegDecoderIn  : in  EthRegDecoderInType;
    ethRegDecoderOut : out EthRegDecoderOutType;

    -- Interface to KPIX reg controller (reuse EthRegCntl types)
    kpixRegCntlOut : in  EthRegCntlInType;
    kpixRegCntlIn  : out EthRegCntlOutType);

end entity EthRegDecoder;

architecture rtl of EthRegDecoder is

  type RegType is record
    ethRegCntlIn     : EthRegCntlInType;
    ethRegDecoderOut : EthRegDecoderOutType;
    kpixRegCntlIn    : EthRegCntlOutType;
  end record RegType;

  signal r, rin : RegType;

begin

  sync : process (sysClk, sysRst) is
  begin
    if (sysRst = '1') then
      r.ethRegCntlIn.regAck    <= '0';
      r.ethRegCntlIn.regDataIn <= (others => '0');
      r.ethRegCntlIn.regFail   <= '0';

      r.ethRegDecoderOut.regSelect <= (others => '0');
      r.ethRegDecoderOut.regOp     <= '0';
      r.ethRegDecoderOut.dataOut   <= (others => '0');

      r.kpixRegCntlIn.regInp     <= '0';
      r.kpixRegCntlIn.regReq     <= '0';
      r.kpixRegCntlIn.regOp      <= '0';
      r.kpixRegCntlIn.regAddr    <= (others => '0');
      r.kpixRegCntlIn.regDataOut <= (others => '0');
    elsif (rising_edge(sysClk)) then
      r <= rin;
    end if;
  end process sync;

  comb : process (r, ethRegCntlOut, kpixRegCntlOut, ethRegDecoderIn) is
    variable tmpVar           : RegType;
    variable localRegIndexVar : integer;
  begin
    tmpVar := r;

    tmpVar.ethRegCntlIn.regAck    := '0';
    tmpVar.ethRegCntlIn.regDataIn := (others => '0');  -- Not necessary
    tmpVar.ethRegCntlIn.regFail   := '0';

    tmpVar.ethRegDecoderOut.regSelect := (others => '0');
    tmpVar.ethRegDecoderOut.regOp     := '0';
    tmpVar.ethRegDecoderOut.dataOut   := (others => '0');  -- Not necessary

    tmpVar.kpixRegCntlIn.regInp     := '0';
    tmpVar.kpixRegCntlIn.regReq     := '0';
    tmpVar.kpixRegCntlIn.regOp      := '0';
    tmpVar.kpixRegCntlIn.regAddr    := (others => '0');  -- Not necessary
    tmpVar.kpixRegCntlIn.regDataOut := (others => '0');  -- Not necessary



    if (ethRegCntlOut.regReq = '1') then
      
      if (ethRegCntlOut.regAddr(ADDR_BLOCK_RANGE_C) = LOCAL_REGS_ADDR_C) then
        -- Local Regs being accessed
        localRegIndexVar := to_integer(unsigned(ethRegCntlOut.regAddr(LOCAL_REGS_ADDR_RANGE_C)));

        -- Assert select/etc. for local regs
        tmpVar.ethRegDecoderOut.regSelect(localRegIndexVar) := '1';
        tmpVar.ethRegDecoderOut.regOp                       := ethRegCntlOut.regOp;
        tmpVar.ethRegDecoderOut.dataOut                     := ethRegCntlOut.regDataOut;

        -- Ack right away
        tmpVar.ethRegCntlIn.regAck    := '1';
        tmpVar.ethRegCntlIn.regDataIn := ethRegDecoderIn.dataIn(localRegIndexVar);
        if (not isZero(ethRegCntlOut.regAddr(NOT_LOCAL_REGS_ADDR_RANGE_C))) then
          -- Error if addressing reg that doesnt exist
          tmpVar.ethRegCntlIn.regFail := '1';
        end if;

      elsif (ethRegCntlOut.regAddr(ADDR_BLOCK_RANGE_C) = KPIX_REGS_ADDR_C) then
        -- KPIX regs being accessed
        -- Pass EthCntl io right though
        -- Will revert back when ethRegCntlOut.regReq falls
        tmpVar.kpixRegCntlIn := ethRegCntlOut;
        tmpVar.ethRegCntlIn  := kpixRegCntlOut;

      end if;
    end if;

    rin <= tmpVar;

    ethRegCntlIn     <= r.ethRegCntlIn;
    ethRegDecoderOut <= r.ethRegDecoderOut;
    kpixRegCntlIn    <= r.kpixRegCntlIn;

  end process comb;

end architecture rtl;
