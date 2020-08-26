-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.



  
library ieee,ibm,support,tri,work;
   use ieee.std_logic_1164.all;
   use ibm.std_ulogic_unsigned.all;
   use ibm.std_ulogic_support.all; 
   use ibm.std_ulogic_function_support.all;
   use support.power_logic_pkg.all;
   use tri.tri_latches_pkg.all;
   use ibm.std_ulogic_ao_support.all; 
   use ibm.std_ulogic_mux_support.all; 


 
entity fuq_eov is 
generic( expand_type               : integer := 2  ); -- 0 - ibm tech, 1 - other );
port( 
 

       vdd                                       :inout power_logic;
       gnd                                       :inout power_logic;
       clkoff_b                                  :in   std_ulogic; -- tiup
       act_dis                                   :in   std_ulogic; -- ??tidn??
       flush                                     :in   std_ulogic; -- ??tidn??
       delay_lclkr                               :in   std_ulogic_vector(4 to 5); -- tidn,
       mpw1_b                                    :in   std_ulogic_vector(4 to 5); -- tidn,
       mpw2_b                                    :in   std_ulogic_vector(0 to 1); -- tidn,
       sg_1                                      :in   std_ulogic;
       thold_1                                   :in   std_ulogic;
       fpu_enable                                :in   std_ulogic; --dc_act
       nclk                                      :in   clk_logic;



       f_eov_si                                 :in   std_ulogic                    ;-- perv
       f_eov_so                                 :out  std_ulogic                    ;-- perv
       ex2_act_b                                :in   std_ulogic                    ;-- act

       f_tbl_ex4_unf_expo                        :in   std_ulogic ; 
       f_tbe_ex3_may_ov                          :in   std_ulogic;
       f_tbe_ex3_expo                            :in   std_ulogic_vector(1 to 13)    ;
       f_pic_ex3_sel_est                         :in   std_ulogic;
       f_eie_ex3_iexp                            :in   std_ulogic_vector(1 to 13)    ;

       f_pic_ex3_sp_b                            :in   std_ulogic                    ;
       f_pic_ex4_oe                              :in   std_ulogic                    ;
       f_pic_ex4_ue                              :in   std_ulogic                    ;
       f_pic_ex4_ov_en                           :in   std_ulogic                    ;
       f_pic_ex4_uf_en                           :in   std_ulogic                    ;
       f_pic_ex4_spec_sel_k_e                    :in   std_ulogic                    ;
       f_pic_ex4_spec_sel_k_f                    :in   std_ulogic                    ;
       f_pic_ex4_sel_ov_spec                     :in   std_ulogic                    ;
       f_pic_ex4_to_int_ov_all                   :in   std_ulogic                    ;

       f_lza_ex4_sh_rgt_en_eov                   :in   std_ulogic; 
       f_lza_ex4_lza_amt_eov                     :in   std_ulogic_vector(0 to 7)     ;
       f_lza_ex4_no_lza_edge                     :in   std_ulogic                    ;
       f_nrm_ex4_extra_shift                     :in   std_ulogic                    ;
       f_eov_ex4_may_ovf                         :out  std_ulogic                    ;--//#pic generate constant

       f_eov_ex5_sel_k_f                         :out  std_ulogic                    ;--//#rnd
       f_eov_ex5_sel_k_e                         :out  std_ulogic                    ;--//#rnd
       f_eov_ex5_sel_kif_f                       :out  std_ulogic                    ;--//#rnd
       f_eov_ex5_sel_kif_e                       :out  std_ulogic                    ;--//#rnd
       f_eov_ex5_unf_expo                        :out  std_ulogic                    ;--//#rnd for ux
       f_eov_ex5_ovf_expo                        :out  std_ulogic                    ;--//#rnd for INF,ox
       f_eov_ex5_ovf_if_expo                     :out  std_ulogic                    ;--//#rnd for INF,ox
       f_eov_ex5_expo_p0                         :out  std_ulogic_vector(1 to 13)    ;--//#rnd result exponent
       f_eov_ex5_expo_p1                         :out  std_ulogic_vector(1 to 13)    ;--//#rnd result exponent if rnd_up_all1
       f_eov_ex5_expo_p0_ue1oe1                  :out  std_ulogic_vector(3 to 7)     ;--//#rnd
       f_eov_ex5_expo_p1_ue1oe1                  :out  std_ulogic_vector(3 to 7)      --//#rnd

); -- end ports
 
-- synopsys translate_off
 


-- synopsys translate_on

end fuq_eov; -- ENTITY
 
 
architecture fuq_eov of fuq_eov is 
 
    constant tiup  :std_ulogic := '1';
    constant tidn  :std_ulogic := '0';
 
    signal sg_0                                  :std_ulogic                   ;
    signal thold_0_b, thold_0, forcee               :std_ulogic                   ;
    signal ex3_act                                 :std_ulogic                   ;
    signal ex2_act                                 :std_ulogic                   ;
    signal ex4_act                                 :std_ulogic                   ;
    signal act_spare_unused                        :std_ulogic_vector(0 to 2)    ;
    -------------------
    signal act_so                                  :std_ulogic_vector(0 to 4)    ;--SCAN
    signal act_si                                  :std_ulogic_vector(0 to 4)    ;--SCAN
    signal ex4_iexp_so                             :std_ulogic_vector(0 to 15)   ;--SCAN
    signal ex4_iexp_si                             :std_ulogic_vector(0 to 15)   ;--SCAN
    signal ex5_ovctl_so                            :std_ulogic_vector(0 to 2)    ;--SCAN
    signal ex5_ovctl_si                            :std_ulogic_vector(0 to 2)    ;--SCAN
    signal ex5_misc_so                             :std_ulogic_vector(0 to 12)   ;--SCAN
    signal ex5_misc_si                             :std_ulogic_vector(0 to 12)   ;--SCAN
    signal ex5_urnd0_so                            :std_ulogic_vector(0 to 12)   ;--SCAN
    signal ex5_urnd0_si                            :std_ulogic_vector(0 to 12)   ;--SCAN
    signal ex5_urnd1_so                            :std_ulogic_vector(0 to 12)   ;--SCAN
    signal ex5_urnd1_si                            :std_ulogic_vector(0 to 12)   ;--SCAN
    -------------------
    signal ex4_sp                                  :std_ulogic                   ;
    signal ex4_unf_m1_co12                         :std_ulogic                   ;
    signal ex4_unf_p0_co12                         :std_ulogic                   ;
    signal ex4_ovf_m1_co12                         :std_ulogic                   ;
    signal ex4_ovf_p0_co12                         :std_ulogic                   ;
    signal ex4_ovf_p1_co12                         :std_ulogic                   ;
    signal ex4_ovf_m1                              :std_ulogic                   ;
    signal ex4_ovf_p0                              :std_ulogic                   ;
    signal ex4_ovf_p1                              :std_ulogic                   ;
    signal ex4_unf_m1                              :std_ulogic                   ;
    signal ex4_unf_p0                              :std_ulogic                   ;


    signal ex4_i_exp                               :std_ulogic_vector(1 to 13)  ;
    signal ex4_ue1oe1_k                            :std_ulogic_vector(3 to 7)   ;
    signal ex4_lzasub_sum                          :std_ulogic_vector(1 to 13)  ;  
    signal ex4_lzasub_car                          :std_ulogic_vector(1 to 12)  ;
    signal ex4_lzasub_p                            :std_ulogic_vector(1 to 12)  ;
    signal ex4_lzasub_t                            :std_ulogic_vector(2 to 12)  ;
    signal ex4_lzasub_g                            :std_ulogic_vector(2 to 12)  ;
    signal ex4_lzasub_m1                           :std_ulogic_vector(1 to 13)  ;
    signal ex4_lzasub_p0                           :std_ulogic_vector(1 to 13)  ;
    signal ex4_lzasub_p1                           :std_ulogic_vector(1 to 13)  ;   
    signal ex4_lzasub_c0                           :std_ulogic_vector(2 to 11)  ;
    signal ex4_lzasub_c1                           :std_ulogic_vector(2 to 11)  ;
    signal ex4_lzasub_s0                           :std_ulogic_vector(1 to 11)  ;
    signal ex4_lzasub_s1                           :std_ulogic_vector(1 to 11)  ;
    signal ex4_ovf_sum                             :std_ulogic_vector(1 to 13)  ;
    signal ex4_ovf_car                             :std_ulogic_vector(1 to 12)  ;
    signal ex4_ovf_g                               :std_ulogic_vector(2 to 12)  ;
    signal ex4_ovf_t                               :std_ulogic_vector(2 to 12)  ;
    signal ex4_ovf_p                               :std_ulogic_vector(1 to  1)  ;
    signal ex4_unf_sum                             :std_ulogic_vector(1 to 13)  ;  
    signal ex4_unf_car                             :std_ulogic_vector(1 to 12)  ;
    signal ex4_unf_g                               :std_ulogic_vector(2 to 12)  ;
    signal ex4_unf_t                               :std_ulogic_vector(2 to 12)  ;
    signal ex4_unf_p                               :std_ulogic_vector(1 to 1)  ;
    signal ex4_unf_ci0_02t11                       :std_ulogic;
    signal ex4_unf_ci1_02t11                       :std_ulogic;
    signal ex4_expo_p0                             :std_ulogic_vector(1 to 13)  ;
    signal ex4_expo_p1                             :std_ulogic_vector(1 to 13)  ;
    signal ex5_expo_p0                             :std_ulogic_vector(1 to 13)  ;
    signal ex5_expo_p1                             :std_ulogic_vector(1 to 13)  ;
    signal ex5_ue1oe1_k                            :std_ulogic_vector(3 to 7)   ;
    signal ex5_ue1oe1_p0_p                         :std_ulogic_vector(3 to 7)   ;
    signal ex5_ue1oe1_p0_t                         :std_ulogic_vector(4 to 6)   ;
    signal ex5_ue1oe1_p0_g                         :std_ulogic_vector(4 to 7)   ;
    signal ex5_ue1oe1_p0_c                         :std_ulogic_vector(4 to 7)   ;
    signal ex5_ue1oe1_p1_p                         :std_ulogic_vector(3 to 7)   ;
    signal ex5_ue1oe1_p1_t                         :std_ulogic_vector(4 to 6)   ;
    signal ex5_ue1oe1_p1_g                         :std_ulogic_vector(4 to 7)   ;
    signal ex5_ue1oe1_p1_c                         :std_ulogic_vector(4 to 7)   ;
    signal ex4_lzasub_m1_c12                       :std_ulogic                  ;
    signal ex4_lzasub_p0_c12                       :std_ulogic                  ;
    signal ex4_lzasub_p1_c12                       :std_ulogic                  ;
    signal ex4_may_ovf                             :std_ulogic                  ;
    signal ex4_lza_amt_b                           :std_ulogic_vector(0 to 7)   ;
    signal ex4_lza_amt                             :std_ulogic_vector(0 to 7)   ;
    signal ex3_iexp                                :std_ulogic_vector(1 to 13)  ;
    signal ex3_sp                                  :std_ulogic                  ;
    signal ex3_may_ovf                             :std_ulogic                  ;
    signal ex4_unf_c2_m1  :std_ulogic;
    signal ex4_unf_c2_p0  :std_ulogic;
    signal ex4_c2_m1  :std_ulogic;
    signal ex4_c2_p0  :std_ulogic;
    signal ex4_c2_p1  :std_ulogic;
    signal ex5_ue1oe1_p0_g2_b :std_ulogic_vector(4 to 7);
    signal ex5_ue1oe1_p0_t2_b :std_ulogic_vector(4 to 5);
    signal ex5_ue1oe1_p1_g2_b :std_ulogic_vector(4 to 7);
    signal ex5_ue1oe1_p1_t2_b :std_ulogic_vector(4 to 5);
 signal ex4_unf_g2_02t03  :std_ulogic;
 signal ex4_unf_g2_04t05  :std_ulogic;
 signal ex4_unf_g2_06t07  :std_ulogic;
 signal ex4_unf_g2_08t09  :std_ulogic;
 signal ex4_unf_g2_10t11  :std_ulogic;
 signal ex4_unf_ci0_g2    :std_ulogic;
 signal ex4_unf_ci1_g2    :std_ulogic;
 signal ex4_unf_t2_02t03  :std_ulogic;
 signal ex4_unf_t2_04t05  :std_ulogic;
 signal ex4_unf_t2_06t07  :std_ulogic;
 signal ex4_unf_t2_08t09  :std_ulogic;
 signal ex4_unf_t2_10t11  :std_ulogic;
 signal ex4_unf_g4_02t05  :std_ulogic;
 signal ex4_unf_g4_06t09  :std_ulogic;
 signal ex4_unf_ci0_g4    :std_ulogic;
 signal ex4_unf_ci1_g4    :std_ulogic;
 signal ex4_unf_t4_02t05  :std_ulogic;
 signal ex4_unf_t4_06t09  :std_ulogic;
 signal ex4_unf_g8_02t09  :std_ulogic;
 signal ex4_unf_ci0_g8    :std_ulogic;
 signal ex4_unf_ci1_g8    :std_ulogic;
 signal ex4_unf_t8_02t09  :std_ulogic;

    signal ex4_ovf_ci0_02t11                       :std_ulogic;
    signal ex4_ovf_ci1_02t11                       :std_ulogic;

    signal ex4_ovf_g2_02t03 :std_ulogic;
    signal ex4_ovf_g2_04t05 :std_ulogic;
    signal ex4_ovf_g2_06t07 :std_ulogic;
    signal ex4_ovf_g2_08t09 :std_ulogic;
    signal ex4_ovf_g2_ci0   :std_ulogic;
    signal ex4_ovf_g2_ci1   :std_ulogic;
    signal ex4_ovf_t2_02t03 :std_ulogic;
    signal ex4_ovf_t2_04t05 :std_ulogic;
    signal ex4_ovf_t2_06t07 :std_ulogic;
    signal ex4_ovf_t2_08t09 :std_ulogic;
    signal ex4_ovf_g4_02t05 :std_ulogic;
    signal ex4_ovf_g4_06t09 :std_ulogic;
    signal ex4_ovf_g4_ci0   :std_ulogic;
    signal ex4_ovf_g4_ci1   :std_ulogic;
    signal ex4_ovf_t4_02t05 :std_ulogic;
    signal ex4_ovf_t4_06t09 :std_ulogic;
    signal ex4_ovf_g8_02t09 :std_ulogic;
    signal ex4_ovf_g8_ci0   :std_ulogic;
    signal ex4_ovf_g8_ci1   :std_ulogic;
    signal ex4_ovf_t8_02t09 :std_ulogic;

    signal ex4_lzasub_gg02 :std_ulogic_vector(2 to 11);
    signal ex4_lzasub_gt02 :std_ulogic_vector(2 to 11);
    signal ex4_lzasub_gg04 :std_ulogic_vector(2 to 11);
    signal ex4_lzasub_gt04 :std_ulogic_vector(2 to 11);
    signal ex4_lzasub_gg08 :std_ulogic_vector(2 to 11);
    signal ex4_lzasub_gt08 :std_ulogic_vector(2 to 11);
    signal ex4_sh_rgt_en_b :std_ulogic;

    signal ex3_may_ov_usual :std_ulogic;



  signal ex4_ovf_calc            :std_ulogic;
  signal ex4_ovf_if_calc         :std_ulogic;
  signal ex4_unf_calc            :std_ulogic;
  signal ex4_unf_tbl             :std_ulogic;
  signal ex4_unf_tbl_spec_e      :std_ulogic;
  signal ex4_ov_en               :std_ulogic;
  signal ex4_ov_en_oe0           :std_ulogic;
  signal ex4_sel_ov_spec         :std_ulogic;
  signal ex4_unf_en_nedge        :std_ulogic;
  signal ex4_unf_ue0_nestsp       :std_ulogic;
  signal ex4_sel_k_part_f        :std_ulogic;
  signal ex4_sel_k_part_e        :std_ulogic;
  signal ex5_ovf_calc            :std_ulogic;
  signal ex5_ovf_if_calc         :std_ulogic;
  signal ex5_unf_calc            :std_ulogic;
  signal ex5_unf_tbl             :std_ulogic;
  signal ex5_unf_tbl_b           :std_ulogic;
  signal ex5_unf_tbl_spec_e      :std_ulogic;
  signal ex5_ov_en               :std_ulogic;
  signal ex5_ov_en_oe0           :std_ulogic;
  signal ex5_sel_ov_spec         :std_ulogic;
  signal ex5_unf_en_nedge        :std_ulogic;
  signal ex5_unf_ue0_nestsp      :std_ulogic;
  signal ex5_sel_k_part_f        :std_ulogic;
  signal ex5_sel_ov_spec_b     :std_ulogic;
  signal ex5_ovf_b             :std_ulogic;
  signal ex5_ovf_if_b          :std_ulogic;
  signal ex5_ovf_oe0_b         :std_ulogic;
  signal ex5_ovf_if_oe0_b      :std_ulogic;
  signal ex5_unf_b             :std_ulogic;
  signal ex5_unf_ue0_b         :std_ulogic;
  signal ex5_sel_k_part_f_b    :std_ulogic;
  signal ex5_unf_tbl_spec_e_b  :std_ulogic;
  signal ex4_sel_est :std_ulogic;
  signal ex4_est_sp :std_ulogic;

signal ex4_expo_p0_0_b, ex4_expo_p0_1_b, ex4_expo_p1_0_b, ex4_expo_p1_1_b :std_ulogic_vector(1 to 13) ;
signal ex4_ovf_calc_0_b, ex4_ovf_calc_1_b, ex4_ovf_if_calc_0_b, ex4_ovf_if_calc_1_b, ex4_unf_calc_0_b, ex4_unf_calc_1_b :std_ulogic ;
   signal ex5_d1clk, ex5_d2clk :std_ulogic ; 
   signal ex5_lclk :clk_logic; 
   signal unused :std_ulogic ;

-- synopsys translate_off

-- synopsys translate_on

   
begin 

unused <= 
     or_reduce( ex4_expo_p0(1 to 13) ) or 
     or_reduce( ex4_expo_p1(1 to 13) ) or 
                ex4_ovf_calc           or 
                ex4_ovf_if_calc        or 
                ex4_unf_calc           ;

--//############################################
--//# pervasive
--//############################################
    
    thold_reg_0:  tri_plat  generic map (expand_type => expand_type) port map (
         vd        => vdd,
         gd        => gnd,
         nclk      => nclk,  
         flush     => flush ,
         din(0)    => thold_1,   
         q(0)      => thold_0  ); 
    
    sg_reg_0:  tri_plat     generic map (expand_type => expand_type) port map (
         vd        => vdd,
         gd        => gnd,
         nclk      => nclk,
         flush     => flush ,
         din(0)    => sg_1  ,     
         q(0)      => sg_0  );   


    lcbor_0: tri_lcbor generic map (expand_type => expand_type ) port map (
        clkoff_b     => clkoff_b,
        thold        => thold_0,  
        sg           => sg_0,
        act_dis      => act_dis,
        forcee => forcee,
        thold_b      => thold_0_b );

    ex5_lcb : tri_lcbnd generic map (expand_type => expand_type) port map( 
        delay_lclkr =>  delay_lclkr(5) ,
        mpw1_b      =>  mpw1_b(5)      ,
        mpw2_b      =>  mpw2_b(1)      ,
        forcee => forcee,
        nclk        =>  nclk        ,
        vd          =>  vdd         ,
        gd          =>  gnd         ,
        act         =>  ex4_act     ,
        sg          =>  sg_0        ,
        thold_b     =>  thold_0_b   ,
        d1clk       =>  ex5_d1clk   ,
        d2clk       =>  ex5_d2clk   ,
        lclk        =>  ex5_lclk   );


 
--//############################################
--//# ACT LATCHES
--//############################################

    ex2_act <= not ex2_act_b;
 
    act_lat:  tri_rlmreg_p generic map (width=> 5, expand_type => expand_type, needs_sreset => 0) port map ( 
        forcee => forcee,-- tidn,
        delay_lclkr      => delay_lclkr(4)   ,-- tidn,
        mpw1_b           => mpw1_b(4)        ,-- tidn,
        mpw2_b           => mpw2_b(0)        ,-- tidn,
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk, 
        thold_b          => thold_0_b,
        sg               => sg_0, 
        act              => fpu_enable, 
        scout            => act_so   ,                     
        scin             => act_si   ,                   
        -------------------
         din(0)             => act_spare_unused(0),
         din(1)             => act_spare_unused(1),
         din(2)             => ex2_act,
         din(3)             => ex3_act,
         din(4)             => act_spare_unused(2),
        -------------------
        dout(0)             => act_spare_unused(0),
        dout(1)             => act_spare_unused(1),
        dout(2)             => ex3_act,
        dout(3)             => ex4_act,
        dout(4)             => act_spare_unused(2) );


--//##############################################
--//# EX3 logic
--//##############################################
        
       ex3_iexp(1 to 13) <=
             ( (1 to 13=> not f_pic_ex3_sel_est) and f_eie_ex3_iexp(1 to 13) ) or
             ( (1 to 13=>     f_pic_ex3_sel_est) and f_tbe_ex3_expo(1 to 13) ) ;

       ex3_sp               <= not f_pic_ex3_sp_b;




       ex3_may_ovf <=
                ( ex3_may_ov_usual and  not f_pic_ex3_sel_est) or
                ( f_tbe_ex3_may_ov and      f_pic_ex3_sel_est);

       ex3_may_ov_usual <=
            (not f_eie_ex3_iexp(1) and  f_eie_ex3_iexp(2)                                             ) or 
            (not f_eie_ex3_iexp(1) and  f_eie_ex3_iexp(3) and f_eie_ex3_iexp(4)                       ) or
            (not f_eie_ex3_iexp(1) and  f_eie_ex3_iexp(3) and f_eie_ex3_iexp(5)                       ) or
            (not f_eie_ex3_iexp(1) and  f_eie_ex3_iexp(3) and f_eie_ex3_iexp(6)                       ) or
            (not f_eie_ex3_iexp(1) and  f_eie_ex3_iexp(3) and f_eie_ex3_iexp(7)                       ) or
            (not f_eie_ex3_iexp(1) and  f_eie_ex3_iexp(3) and f_eie_ex3_iexp(8) and f_eie_ex3_iexp(9) );

--//##############################################
--//# EX4 latch inputs from ex3
--//##############################################

    ex4_iexp_lat:  tri_rlmreg_p generic map (width=> 16, expand_type => expand_type, needs_sreset => 0) port map ( 
        forcee => forcee,-- tidn,
        delay_lclkr      => delay_lclkr(4)   ,-- tidn,
        mpw1_b           => mpw1_b(4)        ,-- tidn,
        mpw2_b           => mpw2_b(0)        ,-- tidn,
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk, 
        thold_b          => thold_0_b,
        sg               => sg_0, 
        act              => ex3_act, 
        scout            => ex4_iexp_so  ,                      
        scin             => ex4_iexp_si  ,                    
        -------------------
         din(0)             => ex3_sp ,
         din(1 to 13)       => ex3_iexp(1 to 13) ,
         din(14)            => ex3_may_ovf ,
         din(15)            => f_pic_ex3_sel_est,
        -------------------
        dout(0)             => ex4_sp               ,--LAT--
        dout(1 to 13)       => ex4_i_exp(1 to 13)   ,--LAT--
        dout(14)            => ex4_may_ovf          ,--LAT--
        dout(15)            => ex4_sel_est         );--LAT--

        f_eov_ex4_may_ovf <= ex4_may_ovf;
 
--//##############################################
--//# EX4 logic
--//##############################################

  --//#-------------------------------------------
  --//# ue1oe1 constant
  --//#-------------------------------------------
    -- need to know constant (sp/dp +/-192 +/-1536 )
    -- +1536 11000  UNF
    -- -1536 01000  OVF
    --  +192 00011  UNF
    --  -192 11101  OVF

    ex4_ue1oe1_k(3) <= (not ex4_may_ovf and not ex4_sp) or
                       (    ex4_may_ovf and     ex4_sp) ;

    ex4_ue1oe1_k(4) <= (                not     ex4_sp) or
                       (    ex4_may_ovf and     ex4_sp) ;

    ex4_ue1oe1_k(5) <= (    ex4_may_ovf and     ex4_sp) ;

    ex4_ue1oe1_k(6) <= (not ex4_may_ovf and     ex4_sp) ;
    ex4_ue1oe1_k(7) <= (                        ex4_sp) ;



    -- sort of 3:2 compresor to make room for extra carry for +1 +2;

     ex4_lza_amt_b(0 to 7) <= not f_lza_ex4_lza_amt_eov(0 to 7);
     ex4_lza_amt  (0 to 7) <=     f_lza_ex4_lza_amt_eov(0 to 7);
     ex4_sh_rgt_en_b <= not f_lza_ex4_sh_rgt_en_eov;

    ex4_lzasub_sum( 1) <=      ex4_sh_rgt_en_b  xor ex4_i_exp( 1);
    ex4_lzasub_sum( 2) <=      ex4_sh_rgt_en_b  xor ex4_i_exp( 2);
    ex4_lzasub_sum( 3) <=      ex4_sh_rgt_en_b  xor ex4_i_exp( 3);
    ex4_lzasub_sum( 4) <=      ex4_sh_rgt_en_b  xor ex4_i_exp( 4);
    ex4_lzasub_sum( 5) <=      ex4_sh_rgt_en_b  xor ex4_i_exp( 5);
    ex4_lzasub_sum( 6) <=      ex4_lza_amt_b(0) xor ex4_i_exp( 6);
    ex4_lzasub_sum( 7) <=      ex4_lza_amt_b(1) xor ex4_i_exp( 7);
    ex4_lzasub_sum( 8) <=      ex4_lza_amt_b(2) xor ex4_i_exp( 8);
    ex4_lzasub_sum( 9) <=      ex4_lza_amt_b(3) xor ex4_i_exp( 9);
    ex4_lzasub_sum(10) <=      ex4_lza_amt_b(4) xor ex4_i_exp(10);
    ex4_lzasub_sum(11) <=      ex4_lza_amt_b(5) xor ex4_i_exp(11);
    ex4_lzasub_sum(12) <=      ex4_lza_amt_b(6) xor ex4_i_exp(12);
    ex4_lzasub_sum(13) <= not( ex4_lza_amt_b(7) xor ex4_i_exp(13) );--!!!!!!!! +1 for negation
    
    ex4_lzasub_car( 1) <= ex4_sh_rgt_en_b  and ex4_i_exp( 2);
    ex4_lzasub_car( 2) <= ex4_sh_rgt_en_b  and ex4_i_exp( 3);
    ex4_lzasub_car( 3) <= ex4_sh_rgt_en_b  and ex4_i_exp( 4);
    ex4_lzasub_car( 4) <= ex4_sh_rgt_en_b  and ex4_i_exp( 5);
    ex4_lzasub_car( 5) <= ex4_lza_amt_b(0) and ex4_i_exp( 6);
    ex4_lzasub_car( 6) <= ex4_lza_amt_b(1) and ex4_i_exp( 7);
    ex4_lzasub_car( 7) <= ex4_lza_amt_b(2) and ex4_i_exp( 8);
    ex4_lzasub_car( 8) <= ex4_lza_amt_b(3) and ex4_i_exp( 9);
    ex4_lzasub_car( 9) <= ex4_lza_amt_b(4) and ex4_i_exp(10);
    ex4_lzasub_car(10) <= ex4_lza_amt_b(5) and ex4_i_exp(11);
    ex4_lzasub_car(11) <= ex4_lza_amt_b(6) and ex4_i_exp(12);
    ex4_lzasub_car(12) <= ex4_lza_amt_b(7) or  ex4_i_exp(13);--!!!!!! +1 for negation

    ex4_lzasub_p(1 to 12) <= ex4_lzasub_car(1 to 12) xor ex4_lzasub_sum(1 to 12);
    ex4_lzasub_t(2 to 12) <= ex4_lzasub_car(2 to 12)  or ex4_lzasub_sum(2 to 12);    
    ex4_lzasub_g(2 to 12) <= ex4_lzasub_car(2 to 12) and ex4_lzasub_sum(2 to 12);
    

        --//##------------------------------
        --//##-- add the 2 lower bits for the different conditions (+0,+1.+2)
        --//##------------------------------

    ex4_lzasub_m1_c12    <=  ex4_lzasub_g(12);
    ex4_lzasub_p0_c12    <=  ex4_lzasub_g(12) or (ex4_lzasub_t(12) and ex4_lzasub_sum(13) );
    ex4_lzasub_p1_c12    <=  ex4_lzasub_t(12);

    ex4_lzasub_m1(13)    <=     ex4_lzasub_sum(13); --LSB is done  +0
    ex4_lzasub_p0(13)    <= not ex4_lzasub_sum(13); --LSB is done  +1
    ex4_lzasub_p1(13)    <=     ex4_lzasub_sum(13); --LSB is done  +2

    ex4_lzasub_m1(12)    <=      ex4_lzasub_p(12);                           -- +0
    ex4_lzasub_p0(12)    <=      ex4_lzasub_p(12) xor ex4_lzasub_sum(13);    -- +1
    ex4_lzasub_p1(12)    <=  not ex4_lzasub_p(12);                           -- +2
   

        --//##-----------------------------------
        --//## the conditional carry chain (+ci,-ci)
        --//##-----------------------------------

    ex4_lzasub_gg02(11) <= ex4_lzasub_g(11) ;
    ex4_lzasub_gg02(10) <= ex4_lzasub_g(10) or ( ex4_lzasub_t(10) and ex4_lzasub_g(11) );--final
    ex4_lzasub_gg02( 9) <= ex4_lzasub_g( 9) or ( ex4_lzasub_t( 9) and ex4_lzasub_g(10) );
    ex4_lzasub_gg02( 8) <= ex4_lzasub_g( 8) or ( ex4_lzasub_t( 8) and ex4_lzasub_g( 9) );
    ex4_lzasub_gg02( 7) <= ex4_lzasub_g( 7) or ( ex4_lzasub_t( 7) and ex4_lzasub_g( 8) );
    ex4_lzasub_gg02( 6) <= ex4_lzasub_g( 6) or ( ex4_lzasub_t( 6) and ex4_lzasub_g( 7) );
    ex4_lzasub_gg02( 5) <= ex4_lzasub_g( 5) or ( ex4_lzasub_t( 5) and ex4_lzasub_g( 6) );
    ex4_lzasub_gg02( 4) <= ex4_lzasub_g( 4) or ( ex4_lzasub_t( 4) and ex4_lzasub_g( 5) );
    ex4_lzasub_gg02( 3) <= ex4_lzasub_g( 3) or ( ex4_lzasub_t( 3) and ex4_lzasub_g( 4) );
    ex4_lzasub_gg02( 2) <= ex4_lzasub_g( 2) or ( ex4_lzasub_t( 2) and ex4_lzasub_g( 3) );

    ex4_lzasub_gt02(11) <=                                            ex4_lzasub_t(11) ;
    ex4_lzasub_gt02(10) <= ex4_lzasub_g(10) or ( ex4_lzasub_t(10) and ex4_lzasub_t(11) );--final
    ex4_lzasub_gt02( 9) <=                     ( ex4_lzasub_t( 9) and ex4_lzasub_t(10) );
    ex4_lzasub_gt02( 8) <=                     ( ex4_lzasub_t( 8) and ex4_lzasub_t( 9) );
    ex4_lzasub_gt02( 7) <=                     ( ex4_lzasub_t( 7) and ex4_lzasub_t( 8) );
    ex4_lzasub_gt02( 6) <=                     ( ex4_lzasub_t( 6) and ex4_lzasub_t( 7) );
    ex4_lzasub_gt02( 5) <=                     ( ex4_lzasub_t( 5) and ex4_lzasub_t( 6) );
    ex4_lzasub_gt02( 4) <=                     ( ex4_lzasub_t( 4) and ex4_lzasub_t( 5) );
    ex4_lzasub_gt02( 3) <=                     ( ex4_lzasub_t( 3) and ex4_lzasub_t( 4) );
    ex4_lzasub_gt02( 2) <=                     ( ex4_lzasub_t( 2) and ex4_lzasub_t( 3) );

    ex4_lzasub_gg04(11) <= ex4_lzasub_gg02(11) ;
    ex4_lzasub_gg04(10) <= ex4_lzasub_gg02(10) ;
    ex4_lzasub_gg04( 9) <= ex4_lzasub_gg02( 9) or ( ex4_lzasub_gt02( 9) and ex4_lzasub_gg02(11) );--final
    ex4_lzasub_gg04( 8) <= ex4_lzasub_gg02( 8) or ( ex4_lzasub_gt02( 8) and ex4_lzasub_gg02(10) );--final
    ex4_lzasub_gg04( 7) <= ex4_lzasub_gg02( 7) or ( ex4_lzasub_gt02( 7) and ex4_lzasub_gg02( 9) );
    ex4_lzasub_gg04( 6) <= ex4_lzasub_gg02( 6) or ( ex4_lzasub_gt02( 6) and ex4_lzasub_gg02( 8) );
    ex4_lzasub_gg04( 5) <= ex4_lzasub_gg02( 5) or ( ex4_lzasub_gt02( 5) and ex4_lzasub_gg02( 7) );
    ex4_lzasub_gg04( 4) <= ex4_lzasub_gg02( 4) or ( ex4_lzasub_gt02( 4) and ex4_lzasub_gg02( 6) );
    ex4_lzasub_gg04( 3) <= ex4_lzasub_gg02( 3) or ( ex4_lzasub_gt02( 3) and ex4_lzasub_gg02( 5) );
    ex4_lzasub_gg04( 2) <= ex4_lzasub_gg02( 2) or ( ex4_lzasub_gt02( 2) and ex4_lzasub_gg02( 4) );

    ex4_lzasub_gt04(11) <= ex4_lzasub_gt02(11) ;
    ex4_lzasub_gt04(10) <= ex4_lzasub_gt02(10) ;
    ex4_lzasub_gt04( 9) <= ex4_lzasub_gg02( 9) or ( ex4_lzasub_gt02( 9) and ex4_lzasub_gt02(11) );--final
    ex4_lzasub_gt04( 8) <= ex4_lzasub_gg02( 8) or ( ex4_lzasub_gt02( 8) and ex4_lzasub_gt02(10) );--final
    ex4_lzasub_gt04( 7) <=                        ( ex4_lzasub_gt02( 7) and ex4_lzasub_gt02( 9) );
    ex4_lzasub_gt04( 6) <=                        ( ex4_lzasub_gt02( 6) and ex4_lzasub_gt02( 8) );
    ex4_lzasub_gt04( 5) <=                        ( ex4_lzasub_gt02( 5) and ex4_lzasub_gt02( 7) );
    ex4_lzasub_gt04( 4) <=                        ( ex4_lzasub_gt02( 4) and ex4_lzasub_gt02( 6) );
    ex4_lzasub_gt04( 3) <=                        ( ex4_lzasub_gt02( 3) and ex4_lzasub_gt02( 5) );
    ex4_lzasub_gt04( 2) <=                        ( ex4_lzasub_gt02( 2) and ex4_lzasub_gt02( 4) );


    ex4_lzasub_gg08(11) <= ex4_lzasub_gg04(11) ;
    ex4_lzasub_gg08(10) <= ex4_lzasub_gg04(10) ;
    ex4_lzasub_gg08( 9) <= ex4_lzasub_gg04( 9) ;
    ex4_lzasub_gg08( 8) <= ex4_lzasub_gg04( 8) ;
    ex4_lzasub_gg08( 7) <= ex4_lzasub_gg04( 7) or ( ex4_lzasub_gt04( 7) and ex4_lzasub_gg04(11) );--final
    ex4_lzasub_gg08( 6) <= ex4_lzasub_gg04( 6) or ( ex4_lzasub_gt04( 6) and ex4_lzasub_gg04(10) );--final
    ex4_lzasub_gg08( 5) <= ex4_lzasub_gg04( 5) or ( ex4_lzasub_gt04( 5) and ex4_lzasub_gg04( 9) );--final
    ex4_lzasub_gg08( 4) <= ex4_lzasub_gg04( 4) or ( ex4_lzasub_gt04( 4) and ex4_lzasub_gg04( 8) );--final
    ex4_lzasub_gg08( 3) <= ex4_lzasub_gg04( 3) or ( ex4_lzasub_gt04( 3) and ex4_lzasub_gg04( 7) );
    ex4_lzasub_gg08( 2) <= ex4_lzasub_gg04( 2) or ( ex4_lzasub_gt04( 2) and ex4_lzasub_gg04( 6) );

    ex4_lzasub_gt08(11) <= ex4_lzasub_gt04(11) ;
    ex4_lzasub_gt08(10) <= ex4_lzasub_gt04(10) ;
    ex4_lzasub_gt08( 9) <= ex4_lzasub_gt04( 9) ;
    ex4_lzasub_gt08( 8) <= ex4_lzasub_gt04( 8) ;
    ex4_lzasub_gt08( 7) <= ex4_lzasub_gg04( 7) or ( ex4_lzasub_gt04( 7) and ex4_lzasub_gt04(11) );--final
    ex4_lzasub_gt08( 6) <= ex4_lzasub_gg04( 6) or ( ex4_lzasub_gt04( 6) and ex4_lzasub_gt04(10) );--final
    ex4_lzasub_gt08( 5) <= ex4_lzasub_gg04( 5) or ( ex4_lzasub_gt04( 5) and ex4_lzasub_gt04( 9) );--final
    ex4_lzasub_gt08( 4) <= ex4_lzasub_gg04( 4) or ( ex4_lzasub_gt04( 4) and ex4_lzasub_gt04( 8) );--final
    ex4_lzasub_gt08( 3) <=                        ( ex4_lzasub_gt04( 3) and ex4_lzasub_gt04( 7) );
    ex4_lzasub_gt08( 2) <=                        ( ex4_lzasub_gt04( 2) and ex4_lzasub_gt04( 6) );


    ex4_lzasub_c0(11) <= ex4_lzasub_gg08(11) ; 
    ex4_lzasub_c0(10) <= ex4_lzasub_gg08(10) ; 
    ex4_lzasub_c0( 9) <= ex4_lzasub_gg08( 9) ; 
    ex4_lzasub_c0( 8) <= ex4_lzasub_gg08( 8) ; 
    ex4_lzasub_c0( 7) <= ex4_lzasub_gg08( 7) ; 
    ex4_lzasub_c0( 6) <= ex4_lzasub_gg08( 6) ; 
    ex4_lzasub_c0( 5) <= ex4_lzasub_gg08( 5) ; 
    ex4_lzasub_c0( 4) <= ex4_lzasub_gg08( 4) ; 
    ex4_lzasub_c0( 3) <= ex4_lzasub_gg08( 3) or ( ex4_lzasub_gt08( 3) and ex4_lzasub_gg08(11) ); --final
    ex4_lzasub_c0( 2) <= ex4_lzasub_gg08( 2) or ( ex4_lzasub_gt08( 2) and ex4_lzasub_gg08(10) ); --final

    ex4_lzasub_c1(11) <= ex4_lzasub_gt08(11) ; 
    ex4_lzasub_c1(10) <= ex4_lzasub_gt08(10) ; 
    ex4_lzasub_c1( 9) <= ex4_lzasub_gt08( 9) ; 
    ex4_lzasub_c1( 8) <= ex4_lzasub_gt08( 8) ; 
    ex4_lzasub_c1( 7) <= ex4_lzasub_gt08( 7) ; 
    ex4_lzasub_c1( 6) <= ex4_lzasub_gt08( 6) ; 
    ex4_lzasub_c1( 5) <= ex4_lzasub_gt08( 5) ; 
    ex4_lzasub_c1( 4) <= ex4_lzasub_gt08( 4) ; 
    ex4_lzasub_c1( 3) <= ex4_lzasub_gg08( 3) or ( ex4_lzasub_gt08( 3) and ex4_lzasub_gt08(11) ); --final
    ex4_lzasub_c1( 2) <= ex4_lzasub_gg08( 2) or ( ex4_lzasub_gt08( 2) and ex4_lzasub_gt08(10) ); --final





    ex4_lzasub_s0(1 to 11) <= ex4_lzasub_p(1 to 11) xor (ex4_lzasub_c0(2 to 11) & tidn) ;
    ex4_lzasub_s1(1 to 11) <= ex4_lzasub_p(1 to 11) xor (ex4_lzasub_c1(2 to 11) & tiup) ;

    ex4_lzasub_m1(1 to 11) <=
         (ex4_lzasub_s0(1 to 11) and (1 to 11 => not ex4_lzasub_m1_c12) ) or 
         (ex4_lzasub_s1(1 to 11) and (1 to 11 =>     ex4_lzasub_m1_c12) );

    ex4_lzasub_p0(1 to 11) <=
         (ex4_lzasub_s0(1 to 11) and (1 to 11 => not ex4_lzasub_p0_c12) ) or 
         (ex4_lzasub_s1(1 to 11) and (1 to 11 =>     ex4_lzasub_p0_c12) ); 

    ex4_lzasub_p1(1 to 11) <=
         (ex4_lzasub_s0(1 to 11) and (1 to 11 => not ex4_lzasub_p1_c12) ) or 
         (ex4_lzasub_s1(1 to 11) and (1 to 11 =>     ex4_lzasub_p1_c12) ); 

  --//#-------------------------------------------
  --//# determine overflow (expo bias = 1023, with signed bit)
  --//#-------------------------------------------
    --
    -- dp  overflow: ge 2047      = 2047     ge 2047
    -- sp  overflow: ge 255 + 896 = 1151     ge 1151
    --
    -- using expo_m1 as the base:
    --              m1      p0      p1
    -- dp ovf:  ge 2047  ge 2046  ge 2045
    -- sp ovf:  ge 1151  ge 1150  ge 1149
    --
    -- could just do the subtract, then decode the result. (triple compound add becomes critical).
    -- doingg compare before the add (faster)
    --
    -- 2047     0_0111_1111_1111
    -- 1151     0_0100_0111_1111
    --
    --          0 0000 0000 1111
    --          1 2345 6789 0123
    --
    ---------------------------------
    --          0_01dd_d111_1111  (minimum)
    --          1_10ss_s000_0000 !(minimum)
    --          1_10ss_s000_0001 -(minimum)
    --          1_10ss_s000_0010  BOUNDRY   +1 for -lza = !lza+1
    --          1_11                        add the lza sign xtd
    ----------------------------------
    ---         1_01ss_s000_0100
    ----------------------------------
    -- overflow if (iexp-lza)        >= 2047
    -- overflow if (iexp-lza) - 2047 >=    0
    -- POSITIVE result means    overflow.
    -- NEGATIVE result means no overflow.


    ex4_ovf_sum( 1) <=     ex4_sh_rgt_en_b xor not ex4_i_exp( 1);            -- 1    !R  [1]
    ex4_ovf_sum( 2) <=     ex4_sh_rgt_en_b xor not ex4_i_exp( 2);            -- 1    !R  [2]
    ex4_ovf_sum( 3) <=     ex4_sh_rgt_en_b xor     ex4_i_exp( 3);            -- 0    !R  [3]
    ex4_ovf_sum( 4) <=     ex4_sh_rgt_en_b xor     ex4_i_exp( 4) xor ex4_sp; -- s    !R  [4]
    ex4_ovf_sum( 5) <=     ex4_sh_rgt_en_b xor     ex4_i_exp( 5) xor ex4_sp; -- s    !R  [5]
    ex4_ovf_sum( 6) <= not ex4_lza_amt(0)  xor     ex4_i_exp( 6) xor ex4_sp; -- s  ![0]  [6]
    ex4_ovf_sum( 7) <= not ex4_lza_amt(1)  xor     ex4_i_exp( 7);            -- 0  ![1]  [7]
    ex4_ovf_sum( 8) <= not ex4_lza_amt(2)  xor     ex4_i_exp( 8);            -- 0  ![2]  [8]
    ex4_ovf_sum( 9) <= not ex4_lza_amt(3)  xor     ex4_i_exp( 9);            -- 0  ![3]  [9]
    ex4_ovf_sum(10) <= not ex4_lza_amt(4)  xor     ex4_i_exp(10);            -- 0  ![4] [10]
    ex4_ovf_sum(11) <= not ex4_lza_amt(5)  xor     ex4_i_exp(11);            -- 0  ![5] [11]
    ex4_ovf_sum(12) <= not ex4_lza_amt(6)  xor not ex4_i_exp(12);            -- 1  ![6] [12]
    ex4_ovf_sum(13) <= not ex4_lza_amt(7)  xor     ex4_i_exp(13);            -- 0  ![7] [13]
    
    ex4_ovf_car( 1) <=      ex4_sh_rgt_en_b or  ex4_i_exp( 2);      -- 1    !R  [2]
    ex4_ovf_car( 2) <=      ex4_sh_rgt_en_b and ex4_i_exp( 3);      -- 0    !R  [3]

    ex4_ovf_car( 3) <= (    ex4_sp          and ex4_i_exp( 4) ) or  -- s    !R  [4]
                       (    ex4_sh_rgt_en_b and ex4_i_exp( 4) ) or 
                       (    ex4_sh_rgt_en_b and ex4_sp        ) ;

    ex4_ovf_car( 4) <= (    ex4_sp          and ex4_i_exp( 5) ) or  -- s    !R  [5]
                       (    ex4_sh_rgt_en_b and ex4_i_exp( 5) ) or 
                       (    ex4_sh_rgt_en_b and ex4_sp        ) ;

    ex4_ovf_car( 5) <= (not ex4_lza_amt(0)  and ex4_i_exp( 6) ) or  -- s  ![0]  [6]
                       (not ex4_lza_amt(0)  and ex4_sp        ) or 
                       (    ex4_sp          and ex4_i_exp( 6) ) ;
    ex4_ovf_car( 6) <= not ex4_lza_amt(1)   and ex4_i_exp( 7);      -- 0  ![1]  [7]
    ex4_ovf_car( 7) <= not ex4_lza_amt(2)   and ex4_i_exp( 8);      -- 0  ![2]  [8]
    ex4_ovf_car( 8) <= not ex4_lza_amt(3)   and ex4_i_exp( 9);      -- 0  ![3]  [9]
    ex4_ovf_car( 9) <= not ex4_lza_amt(4)   and ex4_i_exp(10);      -- 0  ![4] [10]
    ex4_ovf_car(10) <= not ex4_lza_amt(5)   and ex4_i_exp(11);      -- 0  ![5] [11]
    ex4_ovf_car(11) <= not ex4_lza_amt(6)   or  ex4_i_exp(12);      -- 1  ![6] [12]
    ex4_ovf_car(12) <= not ex4_lza_amt(7)   and ex4_i_exp(13);      -- 0  ![7] [13]



    ex4_ovf_g(2 to 12) <= ex4_ovf_car(2 to 12) and ex4_ovf_sum(2 to 12);
    ex4_ovf_t(2 to 12) <= ex4_ovf_car(2 to 12) or  ex4_ovf_sum(2 to 12);
    ex4_ovf_p(1)       <= ex4_ovf_car(1)       xor ex4_ovf_sum(1) ;

    -- lower bits (compute 3 possible combinations)

    ex4_ovf_m1_co12 <=  ex4_ovf_g(12);
    ex4_ovf_p0_co12 <=  ex4_ovf_g(12) or (ex4_ovf_t(12) and  ex4_ovf_sum(13) );
    ex4_ovf_p1_co12 <=  ex4_ovf_t(12);

    -- upper bits (compute 2 possible combinations)


    ex4_ovf_g2_02t03 <=  ex4_ovf_g( 2) or (ex4_ovf_t( 2) and ex4_ovf_g( 3) );
    ex4_ovf_g2_04t05 <=  ex4_ovf_g( 4) or (ex4_ovf_t( 4) and ex4_ovf_g( 5) );
    ex4_ovf_g2_06t07 <=  ex4_ovf_g( 6) or (ex4_ovf_t( 6) and ex4_ovf_g( 7) );
    ex4_ovf_g2_08t09 <=  ex4_ovf_g( 8) or (ex4_ovf_t( 8) and ex4_ovf_g( 9) );
    ex4_ovf_g2_ci0   <=  ex4_ovf_g(10) or (ex4_ovf_t(10) and ex4_ovf_g(11) );
    ex4_ovf_g2_ci1   <=  ex4_ovf_g(10) or (ex4_ovf_t(10) and ex4_ovf_t(11) );

    ex4_ovf_t2_02t03 <=                   (ex4_ovf_t( 2) and ex4_ovf_t( 3) );
    ex4_ovf_t2_04t05 <=                   (ex4_ovf_t( 4) and ex4_ovf_t( 5) );
    ex4_ovf_t2_06t07 <=                   (ex4_ovf_t( 6) and ex4_ovf_t( 7) );
    ex4_ovf_t2_08t09 <=                   (ex4_ovf_t( 8) and ex4_ovf_t( 9) );

    ex4_ovf_g4_02t05 <= ex4_ovf_g2_02t03 or ( ex4_ovf_t2_02t03 and ex4_ovf_g2_04t05 );
    ex4_ovf_g4_06t09 <= ex4_ovf_g2_06t07 or ( ex4_ovf_t2_06t07 and ex4_ovf_g2_08t09 );
    ex4_ovf_g4_ci0   <= ex4_ovf_g2_ci0;
    ex4_ovf_g4_ci1   <= ex4_ovf_g2_ci1;

    ex4_ovf_t4_02t05 <=                     ( ex4_ovf_t2_02t03 and ex4_ovf_t2_04t05 );
    ex4_ovf_t4_06t09 <=                     ( ex4_ovf_t2_06t07 and ex4_ovf_t2_08t09 );

    ex4_ovf_g8_02t09 <= ex4_ovf_g4_02t05 or ( ex4_ovf_t4_02t05 and ex4_ovf_g4_06t09 );
    ex4_ovf_g8_ci0   <= ex4_ovf_g4_ci0;
    ex4_ovf_g8_ci1   <= ex4_ovf_g4_ci1;

    ex4_ovf_t8_02t09 <=                     ( ex4_ovf_t4_02t05 and ex4_ovf_t4_06t09 );


    ex4_ovf_ci0_02t11 <= ex4_ovf_g8_02t09 or (ex4_ovf_t8_02t09 and ex4_ovf_g8_ci0 );
    ex4_ovf_ci1_02t11 <= ex4_ovf_g8_02t09 or (ex4_ovf_t8_02t09 and ex4_ovf_g8_ci1 );
    

    --  13 BITS HOLDS EVERYTHING  -- positive result means overflow
    ex4_c2_m1 <= (ex4_ovf_ci0_02t11 or (ex4_ovf_ci1_02t11 and ex4_ovf_m1_co12) ) ;
    ex4_c2_p0 <= (ex4_ovf_ci0_02t11 or (ex4_ovf_ci1_02t11 and ex4_ovf_p0_co12) ) ;
    ex4_c2_p1 <= (ex4_ovf_ci0_02t11 or (ex4_ovf_ci1_02t11 and ex4_ovf_p1_co12) ) ;
   
    ex4_ovf_m1 <= not ex4_ovf_p(1) xor ex4_c2_m1;
    ex4_ovf_p0 <= not ex4_ovf_p(1) xor ex4_c2_p0;
    ex4_ovf_p1 <= not ex4_ovf_p(1) xor ex4_c2_p1;
   
   
  --//#-------------------------------------------
  --//# determine underflow (expo bias = 1023, with signed bit)
  --//#-------------------------------------------
    -- dp underflow: le 0          =  le   0  =>  !ge    1
    -- sp underflow: le 0    + 896 =  le 896  =>  !ge  897
    --
    -- if the exponent will be incremented (then there are less overflows).
    -- just need for m1, p0 because underflow is determined before rounding.
    -- if there is an underflow exception it cannot round up the exponent.
    --              m1          p0
    -- dp unf: !ge   1     !ge   0
    -- sp unf: !ge 897     !ge 896
    --
    --    1     0_0000_0000_0001         dp: 0_0000_0000_0001   sp: 0_0011_1000_0001   emin
    --    0     0_0000_0000_0000             1_1111_1111_1110       1_1100_0111_1110  !emin
    --                                       1_1111_1111_1111       1_1100_0111_1111  -emin
    --          0 0000 0000 1111             0_0000_0000_0000       1_1100_1000_0000  <= +1 -lza=!lza+1
    --          1 2345 6789 0123
    --
    --  897     0_0011_1000_0001
    --  896     0_0011_1000_0000
    ---------------------------------
    -- if (exp-lza)        >= emin  NO_UNDERFLOW
    -- if (exp-lza) - emin >= 0    UNDERFLOW {sign bit = "1"}


    ex4_unf_sum( 1) <= ex4_sh_rgt_en_b    xor     ex4_i_exp( 1) xor ex4_sp; -- s  !R    [1]
    ex4_unf_sum( 2) <= ex4_sh_rgt_en_b    xor     ex4_i_exp( 2) xor ex4_sp; -- s  !R    [2]
    ex4_unf_sum( 3) <= ex4_sh_rgt_en_b    xor     ex4_i_exp( 3) xor ex4_sp; -- s  !R    [3]
    ex4_unf_sum( 4) <= ex4_sh_rgt_en_b    xor     ex4_i_exp( 4);            -- 0  !R    [4]
    ex4_unf_sum( 5) <= ex4_sh_rgt_en_b    xor     ex4_i_exp( 5);            -- 0  !R    [5]
    ex4_unf_sum( 6) <= not ex4_lza_amt(0) xor     ex4_i_exp( 6) xor ex4_sp; -- s  ![0]  [6]
    ex4_unf_sum( 7) <= not ex4_lza_amt(1) xor     ex4_i_exp( 7);            -- 0  ![1]  [7]
    ex4_unf_sum( 8) <= not ex4_lza_amt(2) xor     ex4_i_exp( 8);            -- 0  ![2]  [8]
    ex4_unf_sum( 9) <= not ex4_lza_amt(3) xor     ex4_i_exp( 9);            -- 0  ![3]  [9]
    ex4_unf_sum(10) <= not ex4_lza_amt(4) xor     ex4_i_exp(10);            -- 0  ![4] [10]
    ex4_unf_sum(11) <= not ex4_lza_amt(5) xor     ex4_i_exp(11);            -- 0  ![5] [11]
    ex4_unf_sum(12) <= not ex4_lza_amt(6) xor     ex4_i_exp(12);            -- 0  ![6] [12]
    ex4_unf_sum(13) <= not ex4_lza_amt(7) xor     ex4_i_exp(13);            -- 0  ![7] [13]
    
    ex4_unf_car( 1) <= ( ex4_sp            and  ex4_i_exp( 2) ) or      -- s  !R   [2]
                       ( ex4_sh_rgt_en_b   and  ex4_i_exp( 2) ) or 
                       ( ex4_sh_rgt_en_b   and  ex4_sp        ) ;
    ex4_unf_car( 2) <= ( ex4_sp            and  ex4_i_exp( 3) ) or      -- s  !R   [3]
                       ( ex4_sh_rgt_en_b   and  ex4_i_exp( 3) ) or 
                       ( ex4_sh_rgt_en_b   and  ex4_sp        ) ;
    ex4_unf_car( 3) <=  ex4_sh_rgt_en_b    and ex4_i_exp( 4)         ;  -- 0  !R   [4]
    ex4_unf_car( 4) <=  ex4_sh_rgt_en_b    and ex4_i_exp( 5)         ;  -- 0  !R   [5]
    ex4_unf_car( 5) <= (not ex4_lza_amt(0) and ex4_i_exp( 6) ) or       -- s ![0]  [6]
                       (not ex4_lza_amt(0) and ex4_sp        ) or 
                       (    ex4_sp           and ex4_i_exp( 6) ) ;
    ex4_unf_car( 6) <= not ex4_lza_amt(1)  and ex4_i_exp( 7);           -- 0  ![1]  [7]
    ex4_unf_car( 7) <= not ex4_lza_amt(2)  and ex4_i_exp( 8);           -- 0  ![2]  [8]
    ex4_unf_car( 8) <= not ex4_lza_amt(3)  and ex4_i_exp( 9);           -- 0  ![3]  [9]
    ex4_unf_car( 9) <= not ex4_lza_amt(4)  and ex4_i_exp(10);           -- 0  ![4] [10]
    ex4_unf_car(10) <= not ex4_lza_amt(5)  and ex4_i_exp(11);           -- 0  ![5] [11]
    ex4_unf_car(11) <= not ex4_lza_amt(6)  and ex4_i_exp(12);           -- 0  ![6] [12]
    ex4_unf_car(12) <= not ex4_lza_amt(7)  and ex4_i_exp(13);           -- 0  ![7] [13]



    ex4_unf_g(2 to 12) <= ex4_unf_car(2 to 12) and ex4_unf_sum(2 to 12);
    ex4_unf_t(2 to 12) <= ex4_unf_car(2 to 12) or  ex4_unf_sum(2 to 12);
    ex4_unf_p(1)       <= ex4_unf_car(1)       xor ex4_unf_sum(1)      ; 


    ex4_unf_m1_co12 <=  ex4_unf_g(12);
    ex4_unf_p0_co12 <=  ex4_unf_g(12) or (ex4_unf_t(12) and  ex4_unf_sum(13) );




    ex4_unf_g2_02t03  <= ex4_unf_g( 2) or (ex4_unf_t( 2) and ex4_unf_g( 3) );
    ex4_unf_g2_04t05  <= ex4_unf_g( 4) or (ex4_unf_t( 4) and ex4_unf_g( 5) );
    ex4_unf_g2_06t07  <= ex4_unf_g( 6) or (ex4_unf_t( 6) and ex4_unf_g( 7) );
    ex4_unf_g2_08t09  <= ex4_unf_g( 8) or (ex4_unf_t( 8) and ex4_unf_g( 9) );
    ex4_unf_g2_10t11  <= ex4_unf_g(10) or (ex4_unf_t(10) and ex4_unf_g(11) );
    ex4_unf_ci0_g2    <= ex4_unf_g(12) ;
    ex4_unf_ci1_g2    <= ex4_unf_t(12) ;

    ex4_unf_t2_02t03  <=                  (ex4_unf_t( 2) and ex4_unf_t( 3) );
    ex4_unf_t2_04t05  <=                  (ex4_unf_t( 4) and ex4_unf_t( 5) );
    ex4_unf_t2_06t07  <=                  (ex4_unf_t( 6) and ex4_unf_t( 7) );
    ex4_unf_t2_08t09  <=                  (ex4_unf_t( 8) and ex4_unf_t( 9) );
    ex4_unf_t2_10t11  <=                  (ex4_unf_t(10) and ex4_unf_t(11) );

    ex4_unf_g4_02t05  <= ex4_unf_g2_02t03 or (ex4_unf_t2_02t03 and ex4_unf_g2_04t05 );
    ex4_unf_g4_06t09  <= ex4_unf_g2_06t07 or (ex4_unf_t2_06t07 and ex4_unf_g2_08t09 );
    ex4_unf_ci0_g4    <= ex4_unf_g2_10t11 or (ex4_unf_t2_10t11 and ex4_unf_ci0_g2 );
    ex4_unf_ci1_g4    <= ex4_unf_g2_10t11 or (ex4_unf_t2_10t11 and ex4_unf_ci1_g2 );

    ex4_unf_t4_02t05  <=                     (ex4_unf_t2_02t03 and ex4_unf_t2_04t05 );
    ex4_unf_t4_06t09  <=                     (ex4_unf_t2_06t07 and ex4_unf_t2_08t09 );


    ex4_unf_g8_02t09  <= ex4_unf_g4_02t05 or (ex4_unf_t4_02t05 and ex4_unf_g4_06t09 );
    ex4_unf_ci0_g8    <= ex4_unf_ci0_g4;
    ex4_unf_ci1_g8    <= ex4_unf_ci1_g4;

    ex4_unf_t8_02t09  <=                     (ex4_unf_t4_02t05 and ex4_unf_t4_06t09 );

    ex4_unf_ci0_02t11 <= ex4_unf_g8_02t09 or ( ex4_unf_t8_02t09 and ex4_unf_ci0_g8); 
    ex4_unf_ci1_02t11 <= ex4_unf_g8_02t09 or ( ex4_unf_t8_02t09 and ex4_unf_ci1_g8); 


    ex4_unf_c2_m1 <= (ex4_unf_ci0_02t11 or (ex4_unf_ci1_02t11 and ex4_unf_m1_co12) ) ;
    ex4_unf_c2_p0 <= (ex4_unf_ci0_02t11 or (ex4_unf_ci1_02t11 and ex4_unf_p0_co12) ) ;
   
    -- 13 BITS HOLDS EVERYTHING (sign==1 {neg} means underflow)
    ex4_unf_m1 <= ex4_unf_p(1) xor ex4_unf_c2_m1;
    ex4_unf_p0 <= ex4_unf_p(1) xor ex4_unf_c2_p0;


  
   u_expo_p0_0: ex4_expo_p0_0_b(1 to 13) <= not(ex4_lzasub_m1(1 to 13)   and (1 to 13 =>     f_nrm_ex4_extra_shift) );
   u_expo_p0_1: ex4_expo_p0_1_b(1 to 13) <= not(ex4_lzasub_p0(1 to 13)   and (1 to 13 => not f_nrm_ex4_extra_shift) ) ; 
   u_expo_p0:   ex4_expo_p0(1 to 13)     <= not(ex4_expo_p0_0_b(1 to 13) and  ex4_expo_p0_1_b(1 to 13));
   
   u_expo_p1_0: ex4_expo_p1_0_b(1 to 13) <= not(ex4_lzasub_p0(1 to 13)   and (1 to 13 =>     f_nrm_ex4_extra_shift) );
   u_expo_p1_1: ex4_expo_p1_1_b(1 to 13) <= not(ex4_lzasub_p1(1 to 13)   and (1 to 13 => not f_nrm_ex4_extra_shift) ) ; 
   u_expo_p1:   ex4_expo_p1(1 to 13)     <= not(ex4_expo_p1_0_b(1 to 13) and  ex4_expo_p1_1_b(1 to 13));
   
   u_ovf_calc_0: ex4_ovf_calc_0_b        <= not(ex4_ovf_m1             and                 f_nrm_ex4_extra_shift  ) ;
   u_ovf_calc_1: ex4_ovf_calc_1_b        <= not(ex4_ovf_p0             and             not f_nrm_ex4_extra_shift  ) ;
   u_ovf_calc:   ex4_ovf_calc            <= not(ex4_ovf_calc_0_b       and  ex4_ovf_calc_1_b ) ;
   
   u_ovf_if_calc_0: ex4_ovf_if_calc_0_b  <= not(ex4_ovf_p0             and                 f_nrm_ex4_extra_shift  ) ;
   u_ovf_if_calc_1: ex4_ovf_if_calc_1_b  <= not(ex4_ovf_p1             and             not f_nrm_ex4_extra_shift  ) ;
   u_ovf_if_calc:   ex4_ovf_if_calc      <= not(ex4_ovf_if_calc_0_b    and  ex4_ovf_if_calc_1_b ) ;
   
                  -- for recip sp : do not zero out exponent ... let it go neg_sp (norm in dp range)
   u_unf_calc_0: ex4_unf_calc_0_b        <= not(ex4_unf_m1             and                 f_nrm_ex4_extra_shift  ) ;
   u_unf_calc_1: ex4_unf_calc_1_b        <= not(ex4_unf_p0             and             not f_nrm_ex4_extra_shift  ) ;
   u_unf_calc:   ex4_unf_calc            <= not(ex4_unf_calc_0_b       and  ex4_unf_calc_1_b ) ;
   



  ex4_est_sp              <= ex4_sel_est and ex4_sp;

  ex4_unf_tbl             <= f_pic_ex4_uf_en and  f_tbl_ex4_unf_expo ;
  ex4_unf_tbl_spec_e      <= (ex4_unf_tbl and not ex4_est_sp and not f_pic_ex4_ue) or ex4_sel_k_part_e;
  ex4_ov_en               <= f_pic_ex4_ov_en ;
  ex4_ov_en_oe0           <= f_pic_ex4_ov_en and not f_pic_ex4_oe;
  ex4_sel_ov_spec         <= f_pic_ex4_sel_ov_spec;
  ex4_unf_en_nedge        <= f_pic_ex4_uf_en and not f_lza_ex4_no_lza_edge;
  ex4_unf_ue0_nestsp      <= f_pic_ex4_uf_en and not f_lza_ex4_no_lza_edge and not f_pic_ex4_ue and not(ex4_est_sp);
  ex4_sel_k_part_e        <= f_pic_ex4_spec_sel_k_e or  f_pic_ex4_to_int_ov_all ;
  ex4_sel_k_part_f        <= f_pic_ex4_spec_sel_k_f or  f_pic_ex4_to_int_ov_all ;


--//##############################################
--//# EX5 latches <outputs>
--//##############################################


    ex5_urnd0_lat:  entity tri.tri_nand2_nlats(tri_nand2_nlats) generic map (width=> 13, btr => "NLA0001_X1_A12TH", expand_type => expand_type, needs_sreset => 0 ) port map ( 
        vd          =>  vdd                  ,
        gd          =>  gnd                  ,
        LCLK             => ex5_lclk                  ,-- lclk.clk
        D1CLK            => ex5_d1clk                 ,
        D2CLK            => ex5_d2clk                 ,
        SCANIN           => ex5_urnd0_si              ,                    
        SCANOUT          => ex5_urnd0_so              ,                      
        A1               => ex4_expo_p0_0_b(1 to 13)  ,   
        A2               => ex4_expo_p0_1_b(1 to 13)  ,
        QB(0 to 12)      => ex5_expo_p0(1 to 13)     );--LAT--

    ex5_urnd1_lat:  entity tri.tri_nand2_nlats(tri_nand2_nlats) generic map (width=> 13, btr => "NLA0001_X1_A12TH", expand_type => expand_type, needs_sreset => 0 ) port map ( 
        vd          =>  vdd                  ,
        gd          =>  gnd                  ,
        LCLK             => ex5_lclk                  ,--lclk.clk
        D1CLK            => ex5_d1clk                 ,
        D2CLK            => ex5_d2clk                 ,
        SCANIN           => ex5_urnd1_si              ,                    
        SCANOUT          => ex5_urnd1_so              ,                      
        A1               => ex4_expo_p1_0_b(1 to 13)  ,   
        A2               => ex4_expo_p1_1_b(1 to 13)  ,
        QB(0 to 12)      => ex5_expo_p1(1 to 13)     );--LAT--
   
    ex5_ovctl_lat:  entity tri.tri_nand2_nlats(tri_nand2_nlats) generic map (width=> 3, btr => "NLA0001_X1_A12TH", expand_type => expand_type, needs_sreset => 0 ) port map ( 
        vd          =>  vdd                  ,
        gd          =>  gnd                  ,
        LCLK             => ex5_lclk                  ,--lclk.clk
        D1CLK            => ex5_d1clk                 ,
        D2CLK            => ex5_d2clk                 ,
        SCANIN           => ex5_ovctl_si              ,                    
        SCANOUT          => ex5_ovctl_so              ,                      
        -------------------
        A1(0)             => ex4_ovf_calc_0_b         ,
        A1(1)             => ex4_ovf_if_calc_0_b      ,
        A1(2)             => ex4_unf_calc_0_b         ,
        -------------------
        A2(0)             => ex4_ovf_calc_1_b         ,
        A2(1)             => ex4_ovf_if_calc_1_b      ,
        A2(2)             => ex4_unf_calc_1_b         ,
        -------------------
        QB(0)            => ex5_ovf_calc              ,--LAT--
        QB(1)            => ex5_ovf_if_calc           ,--LAT--
        QB(2)            => ex5_unf_calc             );--LAT--

    ex5_misc_lat:  tri_rlmreg_p generic map (width=> 13, expand_type => expand_type, needs_sreset => 0) port map ( 
        forcee => forcee,-- tidn,
        delay_lclkr      => delay_lclkr(5)   ,-- tidn,
        mpw1_b           => mpw1_b(5)        ,-- tidn,
        mpw2_b           => mpw2_b(1)        ,-- tidn,
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk, 
        thold_b          => thold_0_b,
        sg               => sg_0, 
        act              => ex4_act, 
        scout            => ex5_misc_so  ,                      
        scin             => ex5_misc_si  ,                    
        -------------------
         din(0)             => ex4_unf_tbl             ,
         din(1)             => ex4_unf_tbl_spec_e      ,
         din(2)             => ex4_ov_en               ,
         din(3)             => ex4_ov_en_oe0           ,
         din(4)             => ex4_sel_ov_spec         ,
         din(5)             => ex4_unf_en_nedge        ,
         din(6)             => ex4_unf_ue0_nestsp      ,
         din(7)             => ex4_sel_k_part_f        ,
         din(8 to 12)       => ex4_ue1oe1_k(3 to 7)    ,
        -------------------
        dout(0)             => ex5_unf_tbl             ,--LAT--
        dout(1)             => ex5_unf_tbl_spec_e      ,--LAT--
        dout(2)             => ex5_ov_en               ,--LAT--
        dout(3)             => ex5_ov_en_oe0           ,--LAT--
        dout(4)             => ex5_sel_ov_spec         ,--LAT--
        dout(5)             => ex5_unf_en_nedge        ,--LAT--
        dout(6)             => ex5_unf_ue0_nestsp      ,--LAT--
        dout(7)             => ex5_sel_k_part_f        ,--LAT--
        dout(8 to 12)       => ex5_ue1oe1_k(3 to 7)   );--LAT--


--//##############################################
--//# EX5 logic
--//##############################################

   f_eov_ex5_expo_p0(1 to 13) <= ex5_expo_p0(1 to 13) ;--//#rnd result exponent
   f_eov_ex5_expo_p1(1 to 13) <= ex5_expo_p1(1 to 13) ;--//#rnd result exponent if rnd_up_all1


    --------- LEVEL 1 -----------------------------------
    
    ex5_sel_ov_spec_b     <= not(                      ex5_sel_ov_spec    );
    ex5_ovf_b             <= not( ex5_ovf_calc     and ex5_ov_en          );
    ex5_ovf_if_b          <= not( ex5_ovf_if_calc  and ex5_ov_en          );
    ex5_ovf_oe0_b         <= not( ex5_ovf_calc     and ex5_ov_en_oe0      );
    ex5_ovf_if_oe0_b      <= not( ex5_ovf_if_calc  and ex5_ov_en_oe0      );
    ex5_unf_b             <= not( ex5_unf_calc     and ex5_unf_en_nedge   );
    ex5_unf_ue0_b         <= not( ex5_unf_calc     and ex5_unf_ue0_nestsp );
    ex5_sel_k_part_f_b    <= not(                      ex5_sel_k_part_f   );
    ex5_unf_tbl_spec_e_b  <= not(                      ex5_unf_tbl_spec_e );
    ex5_unf_tbl_b         <= not(                      ex5_unf_tbl        );
    
    --------- LEVEL 2 -----------------------------------
    
    f_eov_ex5_ovf_expo     <= not( ex5_ovf_b        and ex5_sel_ov_spec_b  );
    f_eov_ex5_ovf_if_expo  <= not( ex5_ovf_if_b     and ex5_sel_ov_spec_b  );
    f_eov_ex5_sel_k_f      <= not( ex5_ovf_oe0_b    and ex5_sel_k_part_f_b );                         
    f_eov_ex5_sel_kif_f    <= not( ex5_ovf_if_oe0_b and ex5_sel_k_part_f_b );
    f_eov_ex5_unf_expo     <= not( ex5_unf_b        and ex5_unf_tbl_b      );
    f_eov_ex5_sel_k_e      <= not( ex5_unf_ue0_b    and ex5_unf_tbl_spec_e_b and ex5_ovf_oe0_b    );
    f_eov_ex5_sel_kif_e    <= not( ex5_unf_ue0_b    and ex5_unf_tbl_spec_e_b and ex5_ovf_if_oe0_b ); 
    
  --//#-----------------------------
  --//# ue1 oe1 adders (does not need to be real fast)
  --//#-----------------------------

    f_eov_ex5_expo_p0_ue1oe1(3 to 6) <= ex5_ue1oe1_p0_p(3 to 6) xor ex5_ue1oe1_p0_c(4 to 7); --output-
    f_eov_ex5_expo_p0_ue1oe1(7)      <= ex5_ue1oe1_p0_p(7);

    ex5_ue1oe1_p0_p(3 to 7) <= ex5_expo_p0(3 to 7) xor ex5_ue1oe1_k(3 to 7);
    ex5_ue1oe1_p0_g(4 to 7) <= ex5_expo_p0(4 to 7) and ex5_ue1oe1_k(4 to 7);
    ex5_ue1oe1_p0_t(4 to 6) <= ex5_expo_p0(4 to 6) or  ex5_ue1oe1_k(4 to 6);


    ex5_ue1oe1_p0_g2_b(7) <= not( ex5_ue1oe1_p0_g(7) ) ;
    ex5_ue1oe1_p0_g2_b(6) <= not( ex5_ue1oe1_p0_g(6) or (ex5_ue1oe1_p0_t(6)  and ex5_ue1oe1_p0_g(7) )  );
    ex5_ue1oe1_p0_g2_b(5) <= not( ex5_ue1oe1_p0_g(5) ) ;
    ex5_ue1oe1_p0_g2_b(4) <= not( ex5_ue1oe1_p0_g(4) or (ex5_ue1oe1_p0_t(4)  and ex5_ue1oe1_p0_g(5) )  );

    ex5_ue1oe1_p0_t2_b(5) <= not(                                                ex5_ue1oe1_p0_t(5) )   ;
    ex5_ue1oe1_p0_t2_b(4) <= not(                       (ex5_ue1oe1_p0_t(4)  and ex5_ue1oe1_p0_t(5) )  );

    ex5_ue1oe1_p0_c(7) <= not( ex5_ue1oe1_p0_g2_b(7) );
    ex5_ue1oe1_p0_c(6) <= not( ex5_ue1oe1_p0_g2_b(6) );
    ex5_ue1oe1_p0_c(5) <= not( ex5_ue1oe1_p0_g2_b(5) and (ex5_ue1oe1_p0_t2_b(5)  or  ex5_ue1oe1_p0_g2_b(6) ) );
    ex5_ue1oe1_p0_c(4) <= not( ex5_ue1oe1_p0_g2_b(4) and (ex5_ue1oe1_p0_t2_b(4)  or  ex5_ue1oe1_p0_g2_b(6) ) );

    ---------------------

    f_eov_ex5_expo_p1_ue1oe1(3 to 6) <= ex5_ue1oe1_p1_p(3 to 6) xor ex5_ue1oe1_p1_c(4 to 7); --output-
    f_eov_ex5_expo_p1_ue1oe1(7)      <= ex5_ue1oe1_p1_p(7);

    ex5_ue1oe1_p1_p(3 to 7) <= ex5_expo_p1(3 to 7) xor ex5_ue1oe1_k(3 to 7);
    ex5_ue1oe1_p1_g(4 to 7) <= ex5_expo_p1(4 to 7) and ex5_ue1oe1_k(4 to 7);
    ex5_ue1oe1_p1_t(4 to 6) <= ex5_expo_p1(4 to 6) or  ex5_ue1oe1_k(4 to 6);


    ex5_ue1oe1_p1_g2_b(7) <= not( ex5_ue1oe1_p1_g(7) ) ;
    ex5_ue1oe1_p1_g2_b(6) <= not( ex5_ue1oe1_p1_g(6) or (ex5_ue1oe1_p1_t(6)  and ex5_ue1oe1_p1_g(7) )  );
    ex5_ue1oe1_p1_g2_b(5) <= not( ex5_ue1oe1_p1_g(5) ) ;
    ex5_ue1oe1_p1_g2_b(4) <= not( ex5_ue1oe1_p1_g(4) or (ex5_ue1oe1_p1_t(4)  and ex5_ue1oe1_p1_g(5) )  );

    ex5_ue1oe1_p1_t2_b(5) <= not(                                                ex5_ue1oe1_p1_t(5) )   ;
    ex5_ue1oe1_p1_t2_b(4) <= not(                       (ex5_ue1oe1_p1_t(4)  and ex5_ue1oe1_p1_t(5) )  );

    ex5_ue1oe1_p1_c(7) <= not( ex5_ue1oe1_p1_g2_b(7) );
    ex5_ue1oe1_p1_c(6) <= not( ex5_ue1oe1_p1_g2_b(6) );
    ex5_ue1oe1_p1_c(5) <= not( ex5_ue1oe1_p1_g2_b(5) and (ex5_ue1oe1_p1_t2_b(5)  or  ex5_ue1oe1_p1_g2_b(6) ) );
    ex5_ue1oe1_p1_c(4) <= not( ex5_ue1oe1_p1_g2_b(4) and (ex5_ue1oe1_p1_t2_b(4)  or  ex5_ue1oe1_p1_g2_b(6) ) );



--//############################################
--//# scan
--//############################################

    act_si  (0 to 4)        <= act_so        (1 to 4)  & f_eov_si ;
    ex4_iexp_si  (0 to 15)  <= ex4_iexp_so   (1 to 15) & act_so  (0);
    ex5_ovctl_si  (0 to 2)  <= ex5_ovctl_so  (1 to 2)  & ex4_iexp_so  (0);
    ex5_misc_si   (0 to 12) <= ex5_misc_so   (1 to 12) & ex5_ovctl_so  (0);
    ex5_urnd0_si  (0 to 12) <= ex5_urnd0_so  (1 to 12) & ex5_misc_so   (0);
    ex5_urnd1_si  (0 to 12) <= ex5_urnd1_so  (1 to 12) & ex5_urnd0_so  (0);
    f_eov_so                <= ex5_urnd1_so  (0);

end; -- fuq_eov ARCHITECTURE
