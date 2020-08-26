-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

--
--  Description: Pervasive Core LCB Control Component
--
--*****************************************************************************

library ieee;
use ieee.std_logic_1164.all;
library ibm;
use ibm.std_ulogic_support.all;
use ibm.std_ulogic_function_support.all;
library support;
use support.power_logic_pkg.all;
library tri;
use tri.tri_latches_pkg.all;

entity pcq_clks_ctrl is
generic(expand_type             : integer := 2          -- 0 = ibm (Umbra), 1 = non-ibm, 2 = ibm (MPG)
);         
port(
    vdd                         : inout power_logic;
    gnd                         : inout power_logic;
    nclk                        : in    clk_logic;
    rtim_sl_thold_5             : in    std_ulogic;
    func_sl_thold_5             : in    std_ulogic;
    func_nsl_thold_5            : in    std_ulogic;
    ary_nsl_thold_5             : in    std_ulogic;
    sg_5                        : in    std_ulogic;
    fce_5                       : in    std_ulogic;
    gsd_test_enable_dc          : in    std_ulogic;
    gsd_test_acmode_dc          : in    std_ulogic;
    ccflush_dc                  : in    std_ulogic;
    ccenable_dc                 : in    std_ulogic;
    scan_type_dc                : in    std_ulogic_vector(0 to 8);
    lbist_en_dc                 : in    std_ulogic;
    lbist_ip_dc                 : in    std_ulogic;
    rg_ck_fast_xstop            : in    std_ulogic;
    ct_ck_pm_ccflush_disable    : in    std_ulogic;
    ct_ck_pm_raise_tholds       : in    std_ulogic;
--  --Thold + control outputs to the units
    pc_pc_ccflush_out_dc        : out   std_ulogic;
    pc_pc_gptr_sl_thold_4       : out   std_ulogic;
    pc_pc_time_sl_thold_4       : out   std_ulogic;
    pc_pc_repr_sl_thold_4       : out   std_ulogic;
    pc_pc_cfg_sl_thold_4        : out   std_ulogic;
    pc_pc_cfg_slp_sl_thold_4    : out   std_ulogic;
    pc_pc_abst_sl_thold_4       : out   std_ulogic;
    pc_pc_abst_slp_sl_thold_4   : out   std_ulogic;
    pc_pc_regf_sl_thold_4       : out   std_ulogic;
    pc_pc_regf_slp_sl_thold_4   : out   std_ulogic;
    pc_pc_func_sl_thold_4       : out   std_ulogic_vector(0 to 1);
    pc_pc_func_slp_sl_thold_4   : out   std_ulogic_vector(0 to 1);
    pc_pc_func_nsl_thold_4      : out   std_ulogic;
    pc_pc_func_slp_nsl_thold_4  : out   std_ulogic;
    pc_pc_ary_nsl_thold_4       : out   std_ulogic;
    pc_pc_ary_slp_nsl_thold_4   : out   std_ulogic;
    pc_pc_rtim_sl_thold_4       : out   std_ulogic;
    pc_pc_sg_4                  : out   std_ulogic_vector(0 to 1);
    pc_pc_fce_4                 : out   std_ulogic_vector(0 to 1)
);
-- synopsys translate_off

-- synopsys translate_on
end pcq_clks_ctrl;

architecture pcq_clks_ctrl of pcq_clks_ctrl is
-- Scan ring select decodes for scan_type_dc vector
constant scantype_func : natural  := 0;
constant scantype_mode : natural  := 1;
constant scantype_ccfg : natural  := 2;
constant scantype_gptr : natural  := 2;
constant scantype_regf : natural  := 3;
constant scantype_fuse : natural  := 3;
constant scantype_lbst : natural  := 4;
constant scantype_abst : natural  := 5;
constant scantype_repr : natural  := 6;
constant scantype_time : natural  := 7;
constant scantype_bndy : natural  := 8;
constant scantype_fary : natural  := 9;

signal scan_type_b                      : std_ulogic_vector(0 to 8); -- scantype;
signal fast_xstop_gated_staged          : std_ulogic;
signal fce_in, sg_in                    : std_ulogic;
signal ary_nsl_thold, func_nsl_thold    : std_ulogic;
signal rtim_sl_thold, func_sl_thold     : std_ulogic;
signal gptr_sl_thold_in                 : std_ulogic;
signal time_sl_thold_in                 : std_ulogic;
signal repr_sl_thold_in                 : std_ulogic;
signal rtim_sl_thold_in                 : std_ulogic;
signal cfg_run_sl_thold_in              : std_ulogic;
signal cfg_slp_sl_thold_in              : std_ulogic;
signal abst_run_sl_thold_in             : std_ulogic;
signal abst_slp_sl_thold_in             : std_ulogic;
signal regf_run_sl_thold_in             : std_ulogic;
signal regf_slp_sl_thold_in             : std_ulogic;
signal func_run_sl_thold_in             : std_ulogic;
signal func_slp_sl_thold_in             : std_ulogic;
signal func_run_nsl_thold_in            : std_ulogic;
signal func_slp_nsl_thold_in            : std_ulogic;
signal ary_run_nsl_thold_in             : std_ulogic;
signal ary_slp_nsl_thold_in             : std_ulogic;
signal pm_ccflush_disable_dc            : std_ulogic;
signal ccflush_out_dc_int               : std_ulogic;
signal testdc                           : std_ulogic;
signal thold_overide_ctrl               : std_ulogic;

signal unused_signals                   : std_ulogic;




begin


-- unused signals
unused_signals <= or_reduce(scan_type_b(2) & scan_type_b(4) & scan_type_b(6 to 8) & lbist_ip_dc);
 
-- detect test dc mode
testdc  <= gsd_test_enable_dc and not gsd_test_acmode_dc;

-- enable sg/fce before latching
sg_in   <= sg_5   and ccenable_dc;
fce_in  <= fce_5  and ccenable_dc;
   
-- scan chain type
scan_type_b <= GATE_AND(sg_in, not scan_type_dc);

-- setup for xx_thold_5 inputs
thold_overide_ctrl <= fast_xstop_gated_staged and not sg_in and not lbist_en_dc and not gsd_test_enable_dc;

rtim_sl_thold   <=  rtim_sl_thold_5;
func_sl_thold   <=  func_sl_thold_5  OR thold_overide_ctrl;
func_nsl_thold  <=  func_nsl_thold_5 OR thold_overide_ctrl;
ary_nsl_thold   <=  ary_nsl_thold_5  OR thold_overide_ctrl;

-- setup for plat flush control signals
-- Active when power_management enabled (PM_Sleep_enable or PM_RVW_enable active)
-- If plats were in flush mode, forces plats to be clocked again for power-savings.
pm_ccflush_disable_dc <= ct_ck_pm_ccflush_disable;

ccflush_out_dc_int   <= ccflush_dc AND (NOT pm_ccflush_disable_dc OR lbist_en_dc OR testdc);
pc_pc_ccflush_out_dc <= ccflush_out_dc_int;


-- OR and MUX of thold signals
                         -- scan only: stop if not scanning, not part of LBIST, hence no sg_in here
gptr_sl_thold_in      <= func_sl_thold  or not scan_type_dc(scantype_gptr) or not ccenable_dc;

                         -- scan only: stop if not scanning, not part of LBIST, hence no sg_in here
time_sl_thold_in      <= func_sl_thold  or not scan_type_dc(scantype_time) or not ccenable_dc;

                         -- scan only: stop if not scanning, not part of LBIST, hence no sg_in here
repr_sl_thold_in      <= func_sl_thold  or not scan_type_dc(scantype_repr) or not ccenable_dc; 


cfg_run_sl_thold_in   <= func_sl_thold  or scan_type_b(scantype_mode) or
                         (ct_ck_pm_raise_tholds and not sg_in and not lbist_en_dc and not gsd_test_enable_dc);

cfg_slp_sl_thold_in   <= func_sl_thold  or scan_type_b(scantype_mode);


abst_run_sl_thold_in  <= func_sl_thold  or scan_type_b(scantype_abst) or
                         (ct_ck_pm_raise_tholds and not sg_in and not lbist_en_dc and not gsd_test_enable_dc);

abst_slp_sl_thold_in  <= func_sl_thold  or scan_type_b(scantype_abst);


regf_run_sl_thold_in  <= func_sl_thold  or scan_type_b(scantype_regf) or
                         (ct_ck_pm_raise_tholds and not sg_in and not lbist_en_dc and not gsd_test_enable_dc);

regf_slp_sl_thold_in  <= func_sl_thold  or scan_type_b(scantype_regf);


func_run_sl_thold_in  <= func_sl_thold  or scan_type_b(scantype_func) or
                         (ct_ck_pm_raise_tholds and not sg_in and not lbist_en_dc and not gsd_test_enable_dc);

func_slp_sl_thold_in  <= func_sl_thold  or scan_type_b(scantype_func);


func_run_nsl_thold_in <= func_nsl_thold or
                         (ct_ck_pm_raise_tholds and not fce_in and not lbist_en_dc and not gsd_test_enable_dc);

func_slp_nsl_thold_in <= func_nsl_thold;


ary_run_nsl_thold_in  <= ary_nsl_thold  or
                         (ct_ck_pm_raise_tholds and not fce_in and not lbist_en_dc and not gsd_test_enable_dc);

ary_slp_nsl_thold_in  <= ary_nsl_thold;


rtim_sl_thold_in      <= rtim_sl_thold;


-- PLAT staging/redrive
fast_stop_staging: tri_plat
   generic map( width => 1, expand_type => expand_type)
   port map( vd      => vdd,
             gd      => gnd,
             nclk    => nclk,
             flush   => ccflush_out_dc_int,
             din(0)  => rg_ck_fast_xstop,
             q(0)    => fast_xstop_gated_staged
           ); 

sg_fce_plat: tri_plat
   generic map(width => 4, expand_type => expand_type)
   port map( vd      => vdd,
             gd      => gnd,
             nclk    => nclk,
             flush   => ccflush_out_dc_int,
             din(0)  => sg_in,
             din(1)  => sg_in,
             din(2)  => fce_in,
             din(3)  => fce_in,
             q(0)    => pc_pc_sg_4(0),
             q(1)    => pc_pc_sg_4(1),
             q(2)    => pc_pc_fce_4(0),
             q(3)    => pc_pc_fce_4(1)
           );

thold_plat: tri_plat
   generic map( width => 18, expand_type => expand_type)
   port map( vd      => vdd,
             gd      => gnd,
             nclk    => nclk,
             flush   => ccflush_out_dc_int,
             din( 0) => gptr_sl_thold_in,
             din( 1) => time_sl_thold_in,
             din( 2) => repr_sl_thold_in,
             din( 3) => cfg_run_sl_thold_in,
             din( 4) => cfg_slp_sl_thold_in,
             din( 5) => abst_run_sl_thold_in,
             din( 6) => abst_slp_sl_thold_in,
             din( 7) => regf_run_sl_thold_in,
             din( 8) => regf_slp_sl_thold_in,
             din( 9) => func_run_sl_thold_in,
             din(10) => func_run_sl_thold_in,
             din(11) => func_slp_sl_thold_in,
             din(12) => func_slp_sl_thold_in,
             din(13) => func_run_nsl_thold_in,
             din(14) => func_slp_nsl_thold_in,
             din(15) => ary_run_nsl_thold_in,
             din(16) => ary_slp_nsl_thold_in,
             din(17) => rtim_sl_thold_in,
             q( 0)   => pc_pc_gptr_sl_thold_4,
             q( 1)   => pc_pc_time_sl_thold_4,
             q( 2)   => pc_pc_repr_sl_thold_4,
             q( 3)   => pc_pc_cfg_sl_thold_4,
             q( 4)   => pc_pc_cfg_slp_sl_thold_4,
             q( 5)   => pc_pc_abst_sl_thold_4,
             q( 6)   => pc_pc_abst_slp_sl_thold_4,
             q( 7)   => pc_pc_regf_sl_thold_4,
             q( 8)   => pc_pc_regf_slp_sl_thold_4,
             q( 9)   => pc_pc_func_sl_thold_4(0),
             q(10)   => pc_pc_func_sl_thold_4(1),
             q(11)   => pc_pc_func_slp_sl_thold_4(0),
             q(12)   => pc_pc_func_slp_sl_thold_4(1),
             q(13)   => pc_pc_func_nsl_thold_4,
             q(14)   => pc_pc_func_slp_nsl_thold_4,
             q(15)   => pc_pc_ary_nsl_thold_4,
             q(16)   => pc_pc_ary_slp_nsl_thold_4,
             q(17)   => pc_pc_rtim_sl_thold_4
           ); 

end pcq_clks_ctrl;
