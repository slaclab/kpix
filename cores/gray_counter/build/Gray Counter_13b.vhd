
-- 
-- Definition of  gray_counter
-- 
--      03/28/05 12:43:22
--      
--      LeonardoSpectrum Level 3, 2004a.63
-- 

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity gray_counter is
   port (
      a_reset : IN std_logic ;
      ck : IN std_logic ;
      q : INOUT std_logic_vector (13 DOWNTO 0)) ;
end gray_counter ;

architecture arch_gray_counter of gray_counter is
   signal NOT_629, nx8, nx14, nx24, nx26, nx32, nx34, nx46, nx62, nx88, nx90, 
      nx142, nx147, nx159, nx163, nx166, nx169, nx175, nx182, nx187, nx193, 
      nx198, nx204, nx222, nx222_XX0_XREP1, nx137, nx137_XX0_XREP3, nx234, 
      nx235, nx236, nx237, nx238, nx239, nx240, nx241, nx242, nx243, nx244, 
      nx176, nx245, nx246, nx247, nx248, nx249, nx250, nx251, nx252, nx58, 
      nx253, nx254, nx255, nx256, nx257, nx258, nx259, nx260, nx261, nx262, 
      nx263, nx264, nx265, nx138, nx266, nx114, nx267, nx268, nx269, nx270, 
      nx271, nx272, nx273, nx274, nx275, nx82, nx276, nx277, nx278, nx279, 
      nx280, nx281, nx282, nx283, nx284, nx285, nx122, nx286, nx180, nx287, 
      nx288, nx289, nx290, nx291, nx292, nx293, nx294, nx295, nx296, nx297, 
      nx298, nx299, nx300, nx301, nx146, nx302, nx303, nx304, nx305, nx306, 
      nx307, nx308, nx309, nx310, nx311, nx312, nx313, nx314, nx315, nx316, 
      nx317, nx318, nx319, nx320, nx321, nx322, nx323, nx324, nx325, nx162, 
      nx202, nx326, nx327, nx328, nx329, nx330, nx331, nx332, nx333, nx334, 
      nx335, nx336, nx337, nx118, nx338: std_logic ;

begin
   reg_q_0 : DFFP port map ( Q=>q(0), QB=>NOT_629, D=>NOT_629, CLK=>ck, PRB
      =>nx222_XX0_XREP1);
   gray_lsb_1_creatbit_reg_qout : DFFC port map ( Q=>q(1), QB=>nx142, D=>
      nx14, CLK=>ck, CLR=>nx222_XX0_XREP1);
   ix9 : Nor2 port map ( \OUT\=>nx8, A=>nx142, B=>q(0));
   gray_lsb_2_creatbit_reg_qout : DFFC port map ( Q=>q(2), QB=>nx147, D=>
      nx26, CLK=>ck, CLR=>nx222_XX0_XREP1);
   ix33 : Nor3 port map ( \OUT\=>nx32, A=>q(1), B=>q(0), C=>nx147);
   gray_lsb_3_creatbit_reg_qout : DFFC port map ( Q=>q(3), QB=>OPEN, D=>nx34, 
      CLK=>ck, CLR=>nx222_XX0_XREP1);
   gray_lsb_4_creatbit_reg_qout : DFFC port map ( Q=>q(4), QB=>nx163, D=>
      nx46, CLK=>ck, CLR=>nx222);
   ix160 : Nand3 port map ( \OUT\=>nx159, A=>q(3), B=>nx24, C=>nx147);
   ix25 : Nor2 port map ( \OUT\=>nx24, A=>q(1), B=>q(0));
   gray_lsb_5_creatbit_reg_qout : DFFC port map ( Q=>q(5), QB=>nx169, D=>
      nx62, CLK=>ck, CLR=>nx222);
   ix167 : Nand2 port map ( \OUT\=>nx166, A=>nx313, B=>q(4));
   gray_lsb_6_creatbit_reg_qout : DFFC port map ( Q=>q(6), QB=>nx175, D=>
      nx82, CLK=>ck, CLR=>nx222);
   ix89 : Nor2 port map ( \OUT\=>nx88, A=>nx180, B=>nx175);
   gray_lsb_7_creatbit_reg_qout : DFFC port map ( Q=>q(7), QB=>nx182, D=>
      nx90, CLK=>ck, CLR=>nx222);
   gray_lsb_8_creatbit_reg_qout : DFFC port map ( Q=>q(8), QB=>nx187, D=>
      nx122, CLK=>ck, CLR=>nx222);
   gray_lsb_9_creatbit_reg_qout : DFFC port map ( Q=>q(9), QB=>nx193, D=>
      nx118, CLK=>ck, CLR=>nx137_XX0_XREP3);
   gray_lsb_10_creatbit_reg_qout : DFFC port map ( Q=>q(10), QB=>nx198, D=>
      nx138, CLK=>ck, CLR=>nx137_XX0_XREP3);
   gray_lsb_11_creatbit_reg_qout : DFFC port map ( Q=>q(11), QB=>nx204, D=>
      nx146, CLK=>ck, CLR=>nx137);
   gray_lsb_12_creatbit_reg_qout : DFFC port map ( Q=>q(12), QB=>OPEN, D=>
      nx162, CLK=>ck, CLR=>nx137);
   gray_msb_reg_qout : DFFC port map ( Q=>q(13), QB=>OPEN, D=>nx176, CLK=>ck, 
      CLR=>nx137);
   ix15 : Xnor2 port map ( \out\=>nx14, A=>nx142, B=>q(0));
   ix27 : Xor2 port map ( \out\=>nx26, A=>nx8, B=>q(2));
   ix35 : Xor2 port map ( \out\=>nx34, A=>nx32, B=>q(3));
   ix47 : Xor2 port map ( \out\=>nx46, A=>nx163, B=>nx159);
   ix63 : Xor2 port map ( \out\=>nx62, A=>nx166, B=>nx169);
   ix91 : Xor2 port map ( \out\=>nx90, A=>nx88, B=>q(7));
   ix221 : Inv port map ( \OUT\=>nx222, A=>a_reset);
   ix221_0_XREP1 : Inv port map ( \OUT\=>nx222_XX0_XREP1, A=>a_reset);
   ix138 : Inv port map ( \OUT\=>nx137, A=>a_reset);
   ix138_0_XREP3 : Inv port map ( \OUT\=>nx137_XX0_XREP3, A=>a_reset);
   ix339 : Nand2 port map ( \OUT\=>nx234, A=>nx163, B=>nx169);
   ix340 : Nor2 port map ( \OUT\=>nx235, A=>q(11), B=>q(10));
   ix341 : Nand2 port map ( \OUT\=>nx236, A=>nx187, B=>nx193);
   ix342 : BufI4 port map ( \OUT\=>nx237, A=>nx236);
   ix343 : Nand2 port map ( \OUT\=>nx238, A=>q(12), B=>nx237);
   ix344 : Nor2 port map ( \OUT\=>nx239, A=>q(13), B=>nx238);
   ix345 : Nand4 port map ( \OUT\=>nx240, A=>nx313, B=>nx327, C=>nx235, D=>
      nx239);
   ix346 : Nor3 port map ( \OUT\=>nx241, A=>q(10), B=>q(11), C=>nx236);
   ix347 : BufI4 port map ( \OUT\=>nx242, A=>nx241);
   ix348 : Nand2 port map ( \OUT\=>nx243, A=>q(13), B=>nx242);
   ix349 : Nand2 port map ( \OUT\=>nx244, A=>q(13), B=>nx114);
   nx176_EXMPLR : Nand3 port map ( \OUT\=>nx176, A=>nx240, B=>nx243, C=>
      nx244);
   ix350 : BufI4 port map ( \OUT\=>nx245, A=>nx163);
   ix351 : BufI4 port map ( \OUT\=>nx246, A=>nx169);
   ix352 : BufI4 port map ( \OUT\=>nx247, A=>q(7));
   ix353 : Nor3 port map ( \OUT\=>nx248, A=>nx245, B=>nx236, C=>nx246);
   ix354 : Nor2 port map ( \OUT\=>nx249, A=>nx204, B=>q(10));
   ix355 : BufI4 port map ( \OUT\=>nx250, A=>q(6));
   ix356 : BufI4 port map ( \OUT\=>nx251, A=>nx236);
   ix357 : BufI4 port map ( \OUT\=>nx252, A=>nx246);
   nx58_EXMPLR : BufI4 port map ( \OUT\=>nx58, A=>nx338);
   ix358 : Nand2 port map ( \OUT\=>nx253, A=>nx198, B=>nx187);
   ix359 : BufI4 port map ( \OUT\=>nx254, A=>nx253);
   ix360 : Nand2 port map ( \OUT\=>nx255, A=>q(9), B=>nx254);
   ix361 : BufI4 port map ( \OUT\=>nx256, A=>nx255);
   ix362 : Nand2 port map ( \OUT\=>nx257, A=>nx327, B=>nx256);
   ix363 : BufI4 port map ( \OUT\=>nx258, A=>nx257);
   ix364 : Nand2 port map ( \OUT\=>nx259, A=>nx58, B=>nx258);
   ix365 : BufI4 port map ( \OUT\=>nx260, A=>nx198);
   ix366 : Nand2 port map ( \OUT\=>nx261, A=>q(9), B=>nx187);
   ix367 : BufI4 port map ( \OUT\=>nx262, A=>nx261);
   ix368 : Nand2 port map ( \OUT\=>nx263, A=>nx327, B=>nx262);
   ix369 : BufI4 port map ( \OUT\=>nx264, A=>nx198);
   ix370 : AOI22 port map ( \OUT\=>nx265, A=>nx338, B=>nx260, C=>nx263, D=>
      nx264);
   nx138_EXMPLR : Nand2 port map ( \OUT\=>nx138, A=>nx259, B=>nx265);
   ix371 : BufI4 port map ( \OUT\=>nx266, A=>nx338);
   nx114_EXMPLR : Nand2 port map ( \OUT\=>nx114, A=>nx327, B=>nx266);
   ix372 : Nand2 port map ( \OUT\=>nx267, A=>nx175, B=>nx163);
   ix373 : BufI4 port map ( \OUT\=>nx268, A=>nx267);
   ix374 : Nand2 port map ( \OUT\=>nx269, A=>q(5), B=>nx268);
   ix375 : BufI4 port map ( \OUT\=>nx270, A=>nx269);
   ix376 : Nand2 port map ( \OUT\=>nx271, A=>nx313, B=>nx270);
   ix377 : Nand2 port map ( \OUT\=>nx272, A=>q(5), B=>nx163);
   ix378 : BufI4 port map ( \OUT\=>nx273, A=>nx272);
   ix379 : Nor2 port map ( \OUT\=>nx274, A=>nx273, B=>nx175);
   ix380 : Nor2 port map ( \OUT\=>nx275, A=>nx274, B=>nx310);
   nx82_EXMPLR : Nand2 port map ( \OUT\=>nx82, A=>nx271, B=>nx275);
   ix381 : BufI4 port map ( \OUT\=>nx276, A=>nx182);
   ix382 : Nand2 port map ( \OUT\=>nx277, A=>nx187, B=>nx276);
   ix383 : Nor3 port map ( \OUT\=>nx278, A=>q(6), B=>nx234, C=>nx277);
   ix384 : Nand3 port map ( \OUT\=>nx279, A=>nx291, B=>nx292, C=>nx278);
   ix385 : BufI4 port map ( \OUT\=>nx280, A=>nx291);
   ix386 : BufI4 port map ( \OUT\=>nx281, A=>nx187);
   ix387 : Nor3 port map ( \OUT\=>nx282, A=>q(6), B=>nx234, C=>nx182);
   ix388 : Nand2 port map ( \OUT\=>nx283, A=>nx292, B=>nx282);
   ix389 : BufI4 port map ( \OUT\=>nx284, A=>nx187);
   ix390 : AOI22 port map ( \OUT\=>nx285, A=>nx280, B=>nx281, C=>nx283, D=>
      nx284);
   nx122_EXMPLR : Nand2 port map ( \OUT\=>nx122, A=>nx279, B=>nx285);
   ix391 : BufI4 port map ( \OUT\=>nx286, A=>nx234);
   nx180_EXMPLR : Nand3 port map ( \OUT\=>nx180, A=>nx291, B=>nx292, C=>
      nx286);
   ix392 : Nand2 port map ( \OUT\=>nx287, A=>nx247, B=>nx248);
   ix393 : Nor2 port map ( \OUT\=>nx288, A=>q(12), B=>q(10));
   ix394 : Nor2 port map ( \OUT\=>nx289, A=>q(6), B=>nx204);
   ix395 : Nand2 port map ( \OUT\=>nx290, A=>nx288, B=>nx289);
   ix396 : Nor2 port map ( \OUT\=>nx291, A=>q(3), B=>q(1));
   ix397 : Nor2 port map ( \OUT\=>nx292, A=>q(2), B=>q(0));
   ix398 : BufI4 port map ( \OUT\=>nx293, A=>nx291);
   ix399 : BufI4 port map ( \OUT\=>nx294, A=>nx292);
   ix400 : BufI4 port map ( \OUT\=>nx295, A=>q(7));
   ix401 : BufI4 port map ( \OUT\=>nx296, A=>nx245);
   ix402 : BufI4 port map ( \OUT\=>nx297, A=>q(11));
   ix403 : BufI4 port map ( \OUT\=>nx298, A=>nx198);
   ix404 : Nand4 port map ( \OUT\=>nx299, A=>nx250, B=>nx326, C=>nx297, D=>
      nx298);
   ix405 : Nand2 port map ( \OUT\=>nx300, A=>q(11), B=>nx198);
   ix406 : Nand2 port map ( \OUT\=>nx301, A=>q(11), B=>nx202);
   nx146_EXMPLR : Nand3 port map ( \OUT\=>nx146, A=>nx299, B=>nx300, C=>
      nx301);
   ix407 : BufI4 port map ( \OUT\=>nx302, A=>nx175);
   ix408 : Nand2 port map ( \OUT\=>nx303, A=>q(1), B=>nx302);
   ix409 : BufI4 port map ( \OUT\=>nx304, A=>nx175);
   ix410 : Nand2 port map ( \OUT\=>nx305, A=>q(2), B=>nx304);
   ix411 : BufI4 port map ( \OUT\=>nx306, A=>nx175);
   ix412 : Nand2 port map ( \OUT\=>nx307, A=>q(0), B=>nx306);
   ix413 : BufI4 port map ( \OUT\=>nx308, A=>nx175);
   ix414 : Nand2 port map ( \OUT\=>nx309, A=>q(3), B=>nx308);
   ix415 : Nand4 port map ( \OUT\=>nx310, A=>nx303, B=>nx305, C=>nx307, D=>
      nx309);
   ix416 : Nor2 port map ( \OUT\=>nx311, A=>q(1), B=>q(2));
   ix417 : Nor2 port map ( \OUT\=>nx312, A=>q(0), B=>q(3));
   ix418 : BufI4 port map ( \OUT\=>nx313, A=>nx338);
   ix419 : BufI4 port map ( \OUT\=>nx314, A=>nx293);
   ix420 : BufI4 port map ( \OUT\=>nx315, A=>nx294);
   ix421 : Nand2 port map ( \OUT\=>nx316, A=>nx252, B=>nx296);
   ix422 : BufI4 port map ( \OUT\=>nx317, A=>nx316);
   ix423 : Nand3 port map ( \OUT\=>nx318, A=>nx295, B=>nx251, C=>nx317);
   ix424 : BufI4 port map ( \OUT\=>nx319, A=>nx318);
   ix425 : Nand3 port map ( \OUT\=>nx320, A=>nx314, B=>nx315, C=>nx319);
   ix426 : Nand2 port map ( \OUT\=>nx321, A=>q(12), B=>nx320);
   ix427 : Nand2 port map ( \OUT\=>nx322, A=>nx250, B=>nx249);
   ix428 : BufI4 port map ( \OUT\=>nx323, A=>nx287);
   ix429 : Nor2 port map ( \OUT\=>nx324, A=>nx338, B=>nx290);
   ix430 : AOI22 port map ( \OUT\=>nx325, A=>q(12), B=>nx322, C=>nx323, D=>
      nx324);
   nx162_EXMPLR : Nand2 port map ( \OUT\=>nx162, A=>nx321, B=>nx325);
   nx202_EXMPLR : Nand4 port map ( \OUT\=>nx202, A=>nx250, B=>nx314, C=>
      nx315, D=>nx319);
   ix431 : Nor3 port map ( \OUT\=>nx326, A=>nx293, B=>nx294, C=>nx318);
   ix432 : Nor3 port map ( \OUT\=>nx327, A=>q(6), B=>q(7), C=>nx234);
   ix433 : Nand2 port map ( \OUT\=>nx328, A=>nx193, B=>q(8));
   ix434 : BufI4 port map ( \OUT\=>nx329, A=>nx328);
   ix435 : Nand4 port map ( \OUT\=>nx330, A=>nx311, B=>nx312, C=>nx327, D=>
      nx329);
   ix436 : Nor2 port map ( \OUT\=>nx331, A=>nx311, B=>nx193);
   ix437 : BufI4 port map ( \OUT\=>nx332, A=>nx331);
   ix438 : BufI4 port map ( \OUT\=>nx333, A=>q(6));
   ix439 : Nor2 port map ( \OUT\=>nx334, A=>q(7), B=>nx234);
   ix440 : Nand4 port map ( \OUT\=>nx335, A=>nx312, B=>q(8), C=>nx333, D=>
      nx334);
   ix441 : BufI4 port map ( \OUT\=>nx336, A=>nx193);
   ix442 : Nand2 port map ( \OUT\=>nx337, A=>nx335, B=>nx336);
   nx118_EXMPLR : Nand3 port map ( \OUT\=>nx118, A=>nx330, B=>nx332, C=>
      nx337);
   ix443 : Nand2 port map ( \OUT\=>nx338, A=>nx311, B=>nx312);
end arch_gray_counter ;

