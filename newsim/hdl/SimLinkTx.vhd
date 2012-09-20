
LIBRARY ieee;
USE work.ALL;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity SimLinkTx is port (
      txClk            : in    std_logic;
      txReset          : in    std_logic;
      vc0FrameTxValid  : in    std_logic;
      vc0FrameTxReady  : out   std_logic;
      vc0FrameTxSOF    : in    std_logic;
      vc0FrameTxEOF    : in    std_logic;
      vc0FrameTxEOFE   : in    std_logic;
      vc0FrameTxData   : in    std_logic_vector(15 downto 0);
      vc1FrameTxValid  : in    std_logic;
      vc1FrameTxReady  : out   std_logic;
      vc1FrameTxSOF    : in    std_logic;
      vc1FrameTxEOF    : in    std_logic;
      vc1FrameTxEOFE   : in    std_logic;
      vc1FrameTxData   : in    std_logic_vector(15 downto 0);
      vc2FrameTxValid  : in    std_logic;
      vc2FrameTxReady  : out   std_logic;
      vc2FrameTxSOF    : in    std_logic;
      vc2FrameTxEOF    : in    std_logic;
      vc2FrameTxEOFE   : in    std_logic;
      vc2FrameTxData   : in    std_logic_vector(15 downto 0);
      vc3FrameTxValid  : in    std_logic;
      vc3FrameTxReady  : out   std_logic;
      vc3FrameTxSOF    : in    std_logic;
      vc3FrameTxEOF    : in    std_logic;
      vc3FrameTxEOFE   : in    std_logic;
      vc3FrameTxData   : in    std_logic_vector(15 downto 0);
      ethMode          : in    std_logic
   );
end SimLinkTx;

-- Define architecture
architecture SimLinkTx of SimLinkTx is
   Attribute FOREIGN of SimLinkTx: architecture is 
      "vhpi:SimSw_lib:VhpiGenericElab:SimLinkTxInit:SimLinkTx";
begin
end SimLinkTx;

