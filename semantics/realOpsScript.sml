(*Generated by Lem from realOps.lem.*)
open HolKernel Parse boolLib bossLib;
open lem_pervasivesTheory libTheory machine_ieeeTheory realTheory transcTheory;

val _ = numLib.prefer_num();



val _ = new_theory "realOps"

(*
  Definition of real-valued operations
*)

(*open import Pervasives*)
(*open import Lib*)

(*open import {hol} `realTheory`*)
(*open import {hol} `transcTheory`*)
(*open import {hol} `machine_ieeeTheory`*)

val _ = Hol_datatype `
 real_cmp = Real_Less | Real_LessEqual | Real_Greater | Real_GreaterEqual | Real_Equal`;

val _ = Hol_datatype `
 real_uop = Real_Abs | Real_Neg | Real_Sqrt`;

val _ = Hol_datatype `
 real_bop = Real_Add | Real_Sub | Real_Mul | Real_Div`;


(*val real_cmp : real_cmp -> real -> real -> bool*)
val _ = Define `
 ((real_cmp:real_cmp -> real -> real -> bool) fop=  ((case fop of
    Real_Less => (<)
  | Real_LessEqual => (<=)
  | Real_Greater => (>)
  | Real_GreaterEqual => (>=)
  | Real_Equal => (=)
)))`;


(*val real_uop : real_uop -> real -> real*)
val _ = Define `
 ((real_uop:real_uop -> real -> real) fop=  ((case fop of
    Real_Abs => (\ n. (if n >(real_of_num 0) then n else(real_of_num 0) - n))
  | Real_Neg => ((\ n. (real_of_num 0) - n))
  | Real_Sqrt => sqrt
)))`;


(*val real_bop : real_bop -> real -> real -> real*)
val _ = Define `
 ((real_bop:real_bop -> real -> real -> real) fop=  ((case fop of
    Real_Add => (+)
  | Real_Sub => (-)
  | Real_Mul => ( * )
  | Real_Div => (/)
)))`;


(*val float2real : word64 -> real*)val _ = export_theory()

