
LIBRARY ieee;
USE work.ALL;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity SimLinkRx is port (
      rxClk            : in    std_logic;
      rxReset          : in    std_logic;
      vcFrameRxSOF     : out   std_logic;
      vcFrameRxEOF     : out   std_logic;
      vcFrameRxEOFE    : out   std_logic;
      vcFrameRxData    : out   std_logic_vector(15 downto 0);
      vc0FrameRxValid  : out   std_logic;
      vc0LocBuffAFull  : in    std_logic;
      vc1FrameRxValid  : out   std_logic;
      vc1LocBuffAFull  : in    std_logic;
      vc2FrameRxValid  : out   std_logic;
      vc2LocBuffAFull  : in    std_logic;
      vc3FrameRxValid  : out   std_logic;
      vc3LocBuffAFull  : in    std_logic;
      ethMode          : in    std_logic
   );
end SimLinkRx;

-- Define architecture
architecture SimLinkRx of SimLinkRx is
   Attribute FOREIGN of SimLinkRx: architecture is 
      "vhpi:SimSw_lib:VhpiGenericElab:SimLinkRxInit:SimLinkRx";
begin
end SimLinkRx;

