open HolKernel bossLib boolLib boolSimps pairTheory listTheory pred_setTheory finite_mapTheory alistTheory relationTheory SatisfySimps arithmeticTheory rich_listTheory lcsymtacs
open MiniMLTheory MiniMLTerminationTheory miscTheory miniMLExtraTheory compileTerminationTheory intLangTheory
val _ = new_theory "pmatch"
val fsd = full_simp_tac std_ss

(* Characterise MAP-like constants *)

val exps_to_Cexps_MAP = store_thm(
"exps_to_Cexps_MAP",
``∀s es. exps_to_Cexps s es = MAP (exp_to_Cexp s) es``,
gen_tac >> Induct >> rw[exp_to_Cexp_def])

val pes_to_Cpes_MAP = store_thm(
"pes_to_Cpes_MAP",
``∀s pes. pes_to_Cpes s pes = MAP (λ(p,e). let (s',Cp) = pat_to_Cpat s p in (Cp, exp_to_Cexp s' e)) pes``,
gen_tac >> Induct >- rw[exp_to_Cexp_def] >>
Cases >> rw[exp_to_Cexp_def])

val defs_to_Cdefs_MAP = store_thm(
"defs_to_Cdefs_MAP",
``∀s defs. defs_to_Cdefs s defs = MAP (λ(d,t1,vn,t2,e). INL (1,exp_to_Cexp (s with <|bvars := vn::s.bvars|>) e)) defs``,
gen_tac >> Induct >- rw[exp_to_Cexp_def] >>
qx_gen_tac `d` >> PairCases_on `d` >> rw[exp_to_Cexp_def])

val vs_to_Cvs_MAP = store_thm(
"vs_to_Cvs_MAP",
``∀s vs. vs_to_Cvs s vs = MAP (v_to_Cv s) vs``,
gen_tac >> Induct >> rw[v_to_Cv_def])

val env_to_Cenv_MAP = store_thm(
"env_to_Cenv_MAP",
``∀s env. env_to_Cenv s env = MAP (v_to_Cv s o FST o SND) env``,
gen_tac >> Induct >- rw[exp_to_Cexp_def,v_to_Cv_def] >>
qx_gen_tac`h` >> PairCases_on`h` >>
rw[exp_to_Cexp_def,v_to_Cv_def])

val Cpat_vars_list_SUM_MAP = store_thm("Cpat_vars_list_SUM_MAP",
  ``∀ps. Cpat_vars_list ps = SUM (MAP Cpat_vars ps)``,
  Induct >> rw[])

(* free vars lemmas *)

val free_vars_remove_mat_vp = store_thm(
"free_vars_remove_mat_vp",
``(∀p fk sk v.
    (free_vars (remove_mat_vp fk sk v p) DIFF {v;fk} =
     IMAGE (λm. m - (Cpat_vars p)) (free_vars sk DIFF (count (Cpat_vars p))) DIFF {v;fk})) ∧
  (∀ps fk sk v n.
   (free_vars (remove_mat_con fk sk v n ps) DIFF {v;fk} =
    IMAGE (λm. m - (Cpat_vars_list ps))
      (free_vars sk DIFF (count (Cpat_vars_list ps))) DIFF {v;fk}))``,
ho_match_mp_tac (TypeBase.induction_of(``:Cpat``)) >>
strip_tac >- (
  rw[EXTENSION,PRE_SUB1] >> PROVE_TAC[]) >>
strip_tac >- (
  rw[EXTENSION] >> PROVE_TAC[] ) >>
strip_tac >- (
  rw[FOLDL_UNION_BIGUNION] >>
  fs[EXTENSION] >> METIS_TAC[] ) >>
strip_tac >- (
  rw[] >> rw[] >>
  rw[EXTENSION] >>
  Cases_on`x=v`>>fs[]>>
  Cases_on`x=fk`>>fs[]>>
  first_x_assum(qspecl_then[`fk+1`,`shift 1 (Cpat_vars p) sk`,`0`]mp_tac) >>
  simp[EXTENSION,PRE_SUB1] >>
  disch_then(qspec_then`x+1`mp_tac) >>
  simp[] >> strip_tac >>
  srw_tac[ARITH_ss][EQ_IMP_THM] >> fs[] >- (
    fsrw_tac[ARITH_ss][] >>
    rw[] >> pop_assum mp_tac >> rw[] >> fs[] >>
    qmatch_assum_rename_tac`z ∈ free_vars sk`[] >>
    qexists_tac`z` >>
    fsrw_tac[ARITH_ss][] ) >>
  qexists_tac`m - Cpat_vars p + 1` >>
  fsrw_tac[ARITH_ss][] >>
  qexists_tac`m+1` >>
  fsrw_tac[ARITH_ss][] >>
  qexists_tac`m` >>
  fsrw_tac[ARITH_ss][] ) >>
strip_tac >- (
  rw[EXTENSION] >> PROVE_TAC[] ) >>
rw[LET_THM] >>
Q.PAT_ABBREV_TAC`sk0 = remove_mat_con fk0 sk1 v0 (n + 1) ps` >>
simp_tac std_ss [Once EXTENSION] >>
qx_gen_tac `x` >> fs[] >>
Cases_on `x=v` >> fs[] >>
Cases_on `x=fk` >> fs[] >>
qmatch_assum_abbrev_tac`Abbrev (sk0 = remove_mat_con fk1 sk1 v1 n1 ps)` >>
first_x_assum (qspecl_then [`fk1`,`sk1`,`v1`,`n1`] mp_tac) >>
simp_tac std_ss [Once EXTENSION] >>
fs[] >> strip_tac >>
first_x_assum(qspecl_then [`fk+1`,`sk0`,`0`] mp_tac) >>
simp_tac std_ss [Once EXTENSION] >>
fs[] >> strip_tac >>
simp[PRE_SUB1] >>
unabbrev_all_tac >>
fsrw_tac[ARITH_ss][] >> rfs[] >>
srw_tac[ARITH_ss][EQ_IMP_THM] >> fs[] >- (
  fsrw_tac[ARITH_ss][] >> rw[] >> rfs[] >>
  qmatch_assum_abbrev_tac`z ∈ free_vars Z` >>
  first_x_assum(qspec_then`z`mp_tac) >>
  simp[] >> rw[] >>
  first_x_assum(qspec_then`m`mp_tac) >>
  simp[] >> rw[] >>
  rw[]>>fsrw_tac[ARITH_ss][] >>
  PROVE_TAC[] ) >>
fsrw_tac[ARITH_ss][] >> rw[] >> rfs[] >>
qexists_tac`m - (Cpat_vars p + Cpat_vars_list ps) + 1` >>
srw_tac[ARITH_ss][] >>
first_x_assum(qspec_then`m - (Cpat_vars p + Cpat_vars_list ps) + 1`mp_tac)>>
srw_tac[ARITH_ss][] >>
qexists_tac`m + 1 - Cpat_vars_list ps` >>
srw_tac[ARITH_ss][] >>
first_x_assum(qspec_then`m + 1 - Cpat_vars_list ps`mp_tac)>>
srw_tac[ARITH_ss][] >>
qexists_tac`m + 1` >>
srw_tac[ARITH_ss][] >>
qexists_tac`m` >>
srw_tac[ARITH_ss][])

val free_vars_remove_mat_vp_SUBSET = store_thm(
"free_vars_remove_mat_vp_SUBSET",
``(∀p fk sk v. free_vars (remove_mat_vp fk sk v p) ⊆
  {v;fk} ∪ (IMAGE (λm. m - Cpat_vars p) (free_vars sk DIFF count (Cpat_vars p)))) ∧
(∀ps fk sk v n. free_vars (remove_mat_con fk sk v n ps) ⊆
  {v;fk} ∪ (IMAGE (λm. m - Cpat_vars_list ps) (free_vars sk DIFF count (Cpat_vars_list ps))))``,
ho_match_mp_tac (TypeBase.induction_of(``:Cpat``)) >>
strip_tac >- (
  rw[SUBSET_DEF] >> rw[PRE_SUB1] >> PROVE_TAC[]) >>
strip_tac >- rw[] >>
strip_tac >- rw[FOLDL_UNION_BIGUNION] >>
strip_tac >- (
  rw[LET_THM,SUBSET_DEF] >>
  res_tac >> fsrw_tac[ARITH_ss][PRE_SUB1] >>
  PROVE_TAC[]) >>
strip_tac >- rw[] >>
srw_tac[DNF_ss][LET_THM,SUBSET_DEF] >>
first_x_assum(qspecl_then[`fk+1+Cpat_vars p`,`shift 1 (Cpat_vars_list ps + Cpat_vars p) sk`,`v+1+Cpat_vars p`,`n+1`]mp_tac) >>
qmatch_assum_abbrev_tac`z ∈ free_vars (remove_mat_vp fk0 sk0 v0 p)` >>
first_x_assum(qspecl_then[`fk0`,`sk0`,`v0`,`z`]mp_tac) >>
unabbrev_all_tac >> srw_tac[ARITH_ss][PRE_SUB1] >- (
  disj1_tac >> disj2_tac >> simp[] ) >>
first_x_assum(qspec_then`m`mp_tac) >>
simp[] >> strip_tac >> simp[] >> rw[] >>
pop_assum mp_tac >> rw[] >> fsrw_tac[ARITH_ss][] >>
metis_tac[])

(*
val free_vars_remove_mat_var = store_thm(
"free_vars_remove_mat_var",
``∀v pes. free_vars FEMPTY (remove_mat_var v pes) DIFF {v} =
  BIGUNION (IMAGE (λ(p,e). free_vars FEMPTY e DIFF Cpat_vars p) (set pes)) DIFF {v}``,
ho_match_mp_tac remove_mat_var_ind >>
strip_tac >- rw[remove_mat_var_def] >>
rw[remove_mat_var_def] >>
rw[] >>
full_simp_tac std_ss [EXTENSION,IN_UNION,IN_DIFF,IN_SING] >>
qx_gen_tac `x` >>
Cases_on `x=v` >> fsd[] >>
Cases_on `x=fk` >> fsd[] >- (
  `fk ∉ free_vars FEMPTY sk` by (
    unabbrev_all_tac >>
    match_mp_tac fresh_var_not_in_any >>
    fs[SUBSET_DEF] ) >>
  fsd[] >>
  PROVE_TAC[] ) >>
mp_tac (CONJUNCT1 free_vars_remove_mat_vp) >>
fsd[EXTENSION,IN_DIFF,IN_INSERT,IN_SING] >>
metis_tac[])
*)

(* Misc. lemmas *)

val free_labs_remove_mat_vp = store_thm("free_labs_remove_mat_vp",
  ``(∀p fk e x. (free_labs (remove_mat_vp fk e x p) = free_labs e)) ∧
    (∀ps fk e x n. (free_labs (remove_mat_con fk e x n ps) = free_labs e))``,
  ho_match_mp_tac(TypeBase.induction_of(``:Cpat``)) >> simp[])
val _ = export_rewrites["free_labs_remove_mat_vp"]

(* TODO: move *)

val pat_to_Cpat_cnmap = store_thm("pat_to_Cpat_cnmap",
  ``(∀(p:α pat) m. (FST (pat_to_Cpat m p)).cnmap = m.cnmap) ∧
    (∀(ps:α pat list) m. (FST (pats_to_Cpats m ps)).cnmap = m.cnmap)``,
  ho_match_mp_tac (TypeBase.induction_of``:α pat``) >>
  rw[pat_to_Cpat_def] >> metis_tac[FST])

val SND_pat_to_Cpat_cnmap = store_thm(
"SND_pat_to_Cpat_cnmap",
``(∀(p:α pat) m m'. (m.cnmap = m'.cnmap) ⇒ (SND (pat_to_Cpat m p) = SND (pat_to_Cpat m' p))) ∧
  (∀(ps:α pat list) m m'. (m.cnmap = m'.cnmap) ⇒ (SND (pats_to_Cpats m ps) = SND (pats_to_Cpats m' ps)))``,
ho_match_mp_tac (TypeBase.induction_of``:α pat``) >>
strip_tac >- rw[pat_to_Cpat_def] >>
strip_tac >- rw[pat_to_Cpat_def] >>
strip_tac >- (
  rw[pat_to_Cpat_def] >>
  qspecl_then[`ps`,`m`]strip_assume_tac(CONJUNCT2 pat_to_Cpat_cnmap)>>
  qspecl_then[`ps`,`m'`]strip_assume_tac(CONJUNCT2 pat_to_Cpat_cnmap)>>
  rfs[] >> first_x_assum(qspecl_then[`m`,`m'`]mp_tac) >>rw[] ) >>
strip_tac >- (
  rw[pat_to_Cpat_def] >>
  qspecl_then[`p`,`m`]strip_assume_tac(CONJUNCT1 pat_to_Cpat_cnmap)>>
  qspecl_then[`p`,`m'`]strip_assume_tac(CONJUNCT1 pat_to_Cpat_cnmap)>>
  rfs[] >> first_x_assum(qspecl_then[`m`,`m'`]mp_tac) >>rw[] ) >>
strip_tac >- rw[pat_to_Cpat_def] >>
rw[pat_to_Cpat_def] >>
qspecl_then[`p`,`m`]strip_assume_tac(CONJUNCT1 pat_to_Cpat_cnmap)>>
qspecl_then[`p`,`m'`]strip_assume_tac(CONJUNCT1 pat_to_Cpat_cnmap)>>
qmatch_assum_rename_tac`pats_to_Cpats m2 ps = (m3,Cps')`[] >>
qmatch_assum_rename_tac`pats_to_Cpats m0 ps = (m1,Cps)`[] >>
qspecl_then[`ps`,`m0`]strip_assume_tac(CONJUNCT2 pat_to_Cpat_cnmap)>>
qspecl_then[`ps`,`m2`]strip_assume_tac(CONJUNCT2 pat_to_Cpat_cnmap)>>
rfs[] >>
first_x_assum(qspecl_then[`m0`,`m2`]mp_tac)>>
first_x_assum(qspecl_then[`m`,`m'`]mp_tac)>>
rw[] )

val pats_to_Cpats_LENGTH = store_thm("pats_to_Cpats_LENGTH",
  ``∀ps m. LENGTH (SND (pats_to_Cpats m ps)) = LENGTH ps``,
  Induct >> rw[pat_to_Cpat_def] >> fs[] >> metis_tac[SND])

(* intermediate language pattern-matching *)

val (Cpmatch_rules,Cpmatch_ind,Cpmatch_cases) = Hol_reln`
  (Cpmatch s CPvar v [v]) ∧
  (Cpmatch s (CPlit l) (CLitv l) []) ∧
  (Cpmatch s p v env ∧ (el_check n s = SOME v)
   ⇒ Cpmatch s (CPref p) (CLoc n) env) ∧
  (Cpmatch_list s ps vs env
   ⇒ Cpmatch s (CPcon n ps) (CConv n vs) env) ∧
  (Cpmatch_list s [] [] []) ∧
  (Cpmatch s p v env ∧ Cpmatch_list s ps vs envs
    ⇒ Cpmatch_list s (p::ps) (v::vs) (envs ++ env))`

val (Cpnomatch_rules,Cpnomatch_ind,Cpnomatch_cases) = Hol_reln`
  (l ≠ l' ⇒ Cpnomatch s (CPlit l) (CLitv l')) ∧
  (c ≠ c' ⇒ Cpnomatch s (CPcon c ps) (CConv c' vs)) ∧
  (Cpnomatch s p v ∧ (el_check n s = SOME v) ⇒
   Cpnomatch s (CPref p) (CLoc n)) ∧
  (Cpnomatch_list s ps vs ⇒
   Cpnomatch s (CPcon c ps) (CConv c vs)) ∧
  (Cpnomatch s p v ∧ (LENGTH ps = LENGTH vs) ⇒ Cpnomatch_list s (p::ps) (v::vs)) ∧
  (Cpmatch s p v env ∧ Cpnomatch_list s ps vs ⇒ Cpnomatch_list s (p::ps) (v::vs))`

val (Cpmatch_error_rules,Cpmatch_error_ind,Cpmatch_error_cases) = Hol_reln`
  (Cpmatch_error s (CPlit l) (CConv c vs)) ∧
  (Cpmatch_error s (CPlit l) (CRecClos env defs n)) ∧
  (Cpmatch_error s (CPlit l ) (CLoc m)) ∧
  (Cpmatch_error s (CPcon c ps) (CLitv l)) ∧
  (Cpmatch_error s (CPcon c ps) (CRecClos env defs n)) ∧
  (Cpmatch_error s (CPcon c ps) (CLoc m)) ∧
  (Cpmatch_error s (CPref p) (CLitv l)) ∧
  (Cpmatch_error s (CPref p) (CConv c vs)) ∧
  (Cpmatch_error s (CPref p) (CRecClos env defs n)) ∧
  ((el_check m s = NONE) ⇒ Cpmatch_error s (CPref p) (CLoc m)) ∧
  (Cpmatch_error s p v ∧ (el_check m s = SOME v) ⇒ Cpmatch_error s (CPref p) (CLoc m)) ∧
  (Cpmatch_list_error s ps vs ⇒ Cpmatch_error s (CPcon c ps) (CConv c' vs)) ∧
  (Cpmatch_list_error s (p::ps) []) ∧
  (Cpmatch_list_error s [] (v::vs)) ∧
  (Cpmatch_error s p v ⇒ Cpmatch_list_error s (p::ps) (v::vs)) ∧
  (Cpmatch_list_error s ps vs ⇒ Cpmatch_list_error s (p::ps) (v::vs))`

val Cpmatch_NOT_Cpnomatch = store_thm("Cpmatch_NOT_Cpnomatch",
  ``(∀p v env. Cpmatch s p v env ⇒ ¬Cpnomatch s p v) ∧
    (∀ps vs env. Cpmatch_list s ps vs env ⇒ ¬Cpnomatch_list s ps vs)``,
  ho_match_mp_tac Cpmatch_ind >>
  strip_tac >- rw[Once Cpnomatch_cases] >>
  strip_tac >- rw[Once Cpnomatch_cases] >>
  strip_tac >- ( rw[] >> rw[Once Cpnomatch_cases] ) >>
  strip_tac >- ( rw[] >> rw[Once Cpnomatch_cases] ) >>
  strip_tac >- rw[Once Cpnomatch_cases] >>
  rw[] >> rw[Once Cpnomatch_cases])

val Cpmatch_list_error_LENGTH = store_thm("Cpmatch_list_error_LENGTH",
 ``∀s ps vs. LENGTH ps ≠ LENGTH vs ⇒ Cpmatch_list_error s ps vs``,
 gen_tac >> Induct >> rw[Once Cpmatch_error_cases] >>
 Cases_on `vs` >> fs[])

val Cpmatch_trichotomy = store_thm("Cpmatch_trichotomy",
  ``(∀p s v. (∃env. Cpmatch s p v env) ∨ Cpnomatch s p v ∨ Cpmatch_error s p v) ∧
    (∀ps s vs.  (∃env. Cpmatch_list s ps vs env) ∨ Cpnomatch_list s ps vs ∨ Cpmatch_list_error s ps vs)``,
  ho_match_mp_tac(TypeBase.induction_of``:Cpat``) >>
  strip_tac >- rw[Once Cpmatch_cases] >>
  strip_tac >- (
    rw[Once Cpmatch_cases] >>
    rw[Once Cpmatch_error_cases] >>
    rw[Once Cpnomatch_cases] >>
    Cases_on `v` >> rw[] >> PROVE_TAC[] ) >>
  strip_tac >- (
    rw[] >>
    rw[Once Cpmatch_cases] >>
    rw[Once Cpnomatch_cases] >>
    rw[Once Cpmatch_error_cases] >>
    Cases_on `v` >> rw[] >>
    spose_not_then strip_assume_tac >>
    rfs[] >> fs[] >> PROVE_TAC[]) >>
  strip_tac >- (
    rw[] >>
    rw[Once Cpmatch_cases] >>
    rw[Once Cpnomatch_cases] >>
    rw[Once Cpmatch_error_cases] >>
    Cases_on `v` >> rw[] >>
    Cases_on `el_check n s` >> rw[]) >>
  strip_tac >- (
    rw[Once Cpmatch_cases] >>
    rw[Once Cpnomatch_cases] >>
    rw[Once Cpmatch_error_cases] >>
    Cases_on `vs` >> rw[] >> PROVE_TAC[] ) >>
  rw[] >>
  rw[Once Cpmatch_cases] >>
  rw[Once Cpnomatch_cases] >>
  rw[Once Cpmatch_error_cases] >>
  Cases_on `vs` >> rw[] >>
  PROVE_TAC[Cpmatch_list_error_LENGTH] )

val Cpmatch_determ = store_thm("Cpmatch_determ",
  ``(∀p v env. Cpmatch s p v env ⇒ ∀env'. Cpmatch s p v env' ⇒ (env' = env)) ∧
    (∀ps vs env. Cpmatch_list s ps vs env ⇒ ∀env'. Cpmatch_list s ps vs env' ⇒ (env' = env))``,
  ho_match_mp_tac Cpmatch_ind >>
  strip_tac >- rw[Once Cpmatch_cases] >>
  strip_tac >- rw[Once Cpmatch_cases] >>
  strip_tac >- (
    rpt gen_tac >> strip_tac >>
    rw[Once Cpmatch_cases] ) >>
  strip_tac >- (
    rw[] >>
    first_x_assum match_mp_tac >>
    fs[Once Cpmatch_cases] ) >>
  strip_tac >- rw[Once Cpmatch_cases] >>
  rw[] >>
  pop_assum mp_tac >>
  rw[Once Cpmatch_cases] >>
  PROVE_TAC[])

val (Cevaluate_match_rules,Cevaluate_match_ind,Cevaluate_match_cases) = Hol_reln`
  (Cevaluate_match s v [] [] NONE) ∧
  (Cpmatch s p v env
    ⇒ Cevaluate_match s v ((p,e)::pes) env (SOME e)) ∧
  (Cpnomatch s p v ∧ Cevaluate_match s v pes env r
    ⇒ Cevaluate_match s v ((p,e)::pes) env r)`

(* correctness *)

val Cpmatch_list_LENGTH = store_thm("Cpmatch_list_LENGTH",
  ``∀s ps vs menv. Cpmatch_list s ps vs menv ⇒ (LENGTH ps = LENGTH vs)``,
  gen_tac >> Induct >> rw[Once Cpmatch_cases] >> rw[] >> PROVE_TAC[])

val Cpmatch_list_nil = store_thm("Cpmatch_list_nil",
  ``(Cpmatch_list s [] vs e = ((vs = []) ∧ (e = []))) ∧
    (Cpmatch_list s ps [] e = ((ps = []) ∧ (e = [])))``,
  rw[Once Cpmatch_cases] >>
  rw[Once Cpmatch_cases] )
val _ = export_rewrites["Cpmatch_list_nil"]

val Cpmatch_list_APPEND = store_thm("Cpmatch_list_APPEND",
  ``∀s p0 p1 vs e. Cpmatch_list s (p0 ++ p1) vs e =
            ∃e0 e1. Cpmatch_list s p0 (TAKE (LENGTH p0) vs) e0 ∧
                    Cpmatch_list s p1 (DROP (LENGTH p0) vs) e1 ∧
                    (e = e1 ++ e0)``,
  gen_tac >> Induct >- (
    rw[Once Cpmatch_cases] >>
    Cases_on `p1` >> fs[] >>
    rw[Once Cpmatch_cases,SimpRHS] ) >>
  rw[Once Cpmatch_cases] >>
  Cases_on `vs` >> fs[] >>
  rw[Once Cpmatch_cases,SimpRHS] >>
  srw_tac[DNF_ss][] >>
  PROVE_TAC[])

val pmatch_Cpmatch = store_thm("pmatch_Cpmatch",
  ``(∀tvs cenv s p (v:'a v) env env'. (pmatch tvs cenv s p v env = Match (env' ++ env))
      ⇒ ∀m. Cpmatch (MAP (v_to_Cv m) s) (SND (pat_to_Cpat m p)) (v_to_Cv m v) (env_to_Cenv m env')) ∧
    (∀tvs cenv s ps (vs:'a v list) env env'. (pmatch_list tvs cenv s ps vs env = Match (env' ++ env))
      ⇒ ∀m. Cpmatch_list (MAP (v_to_Cv m) s) (SND (pats_to_Cpats m ps)) (vs_to_Cvs m vs) (env_to_Cenv m env'))``,
  ho_match_mp_tac pmatch_ind >>
  strip_tac >- (
    rw[pmatch_def,bind_def,env_to_Cenv_MAP,pat_to_Cpat_def] >>
    rw[Once Cpmatch_cases] ) >>
  strip_tac >- (
    rw[pat_to_Cpat_def,Once Cpmatch_cases,v_to_Cv_def
      ,env_to_Cenv_MAP,pmatch_def]) >>
  strip_tac >- (
    fs[pmatch_def] >>
    rpt gen_tac >> strip_tac >>
    Cases_on `ALOOKUP cenv n` >> fs[] >>
    qmatch_assum_rename_tac `ALOOKUP cenv n = SOME p`[] >>
    PairCases_on `p` >> fs[] >>
    Cases_on `ALOOKUP cenv n'` >> fs[] >>
    qmatch_assum_rename_tac `ALOOKUP cenv n' = SOME p`[] >>
    PairCases_on `p` >> fs[] >>
    rw[] >> rfs[] >>
    fs[pat_to_Cpat_def,LET_THM,UNCURRY] >>
    rw[v_to_Cv_def] >>
    rw[Once Cpmatch_cases] >>
    rw[pat_to_Cpat_cnmap]) >>
  strip_tac >- (
    fs[pmatch_def] >>
    rpt gen_tac >> strip_tac >>
    Cases_on `store_lookup lnum s` >> fs[] >>
    gen_tac >> strip_tac >>
    fs[pat_to_Cpat_def,LET_THM,UNCURRY,v_to_Cv_def] >>
    rw[Once Cpmatch_cases] >>
    qexists_tac`v_to_Cv m x` >> rw[] >>
    fs[el_check_def,store_lookup_def,EL_MAP]) >>
  strip_tac >- rw[pmatch_def] >>
  strip_tac >- rw[pmatch_def] >>
  strip_tac >- rw[pmatch_def] >>
  strip_tac >- rw[pmatch_def] >>
  strip_tac >- rw[pmatch_def] >>
  strip_tac >- rw[pmatch_def] >>
  strip_tac >- rw[pmatch_def] >>
  strip_tac >- rw[pmatch_def] >>
  strip_tac >- rw[pmatch_def] >>
  strip_tac >- rw[pmatch_def] >>
  strip_tac >- rw[pmatch_def] >>
  strip_tac >- rw[pmatch_def] >>
  strip_tac >- (
    rw[pmatch_def,env_to_Cenv_MAP,pat_to_Cpat_def,vs_to_Cvs_MAP] >>
    rw[Once Cpmatch_cases] ) >>
  strip_tac >- (
    rw[pmatch_def] >>
    pop_assum mp_tac >>
    fs[Once pmatch_nil] >>
    rw[Once (CONJUNCT1 pmatch_nil)] >>
    Cases_on `pmatch tvs cenv s p v []` >> fs[] >> rw[] >>
    qmatch_assum_rename_tac `pmatch tvs cenv s p v [] = Match env0`[] >>
    qpat_assum`pmatch_list tvs cenv s ps vs X = Y` mp_tac >>
    simp[Once pmatch_nil] >> strip_tac >>
    Cases_on `pmatch_list tvs cenv s ps vs []` >> fs[] >> rw[] >>
    qmatch_assum_rename_tac `pmatch_list tvs cenv s ps vs [] = Match env1`[] >>
    fs[Once (Q.INST[`env`|->`env0++env`]pmatch_nil)] >>
    fs[pat_to_Cpat_def,vs_to_Cvs_MAP,UNCURRY,env_to_Cenv_MAP,LET_THM] >>
    REWRITE_TAC[Once(rich_listTheory.CONS_APPEND)] >>
    REWRITE_TAC[Cpmatch_list_APPEND] >>
    simp[Once Cpmatch_cases] >>
    qexists_tac`MAP (v_to_Cv m o FST o SND) env0` >>
    simp[] >>
    metis_tac[SND_pat_to_Cpat_cnmap,pat_to_Cpat_cnmap]) >>
  strip_tac >- rw[pmatch_def] >>
  rw[pmatch_def])

val pmatch_Cpnomatch = store_thm("pmatch_Cpnomatch",
  ``(∀tvs cenv (s:α store) p v env. good_cenv cenv ∧ (pmatch tvs cenv s p v env = No_match)
      ⇒ ∀m. good_cmap cenv m.cnmap ⇒
            Cpnomatch (MAP (v_to_Cv m) s) (SND (pat_to_Cpat m p)) (v_to_Cv m v)) ∧
    (∀tvs cenv (s:α store) ps vs env env'. good_cenv cenv ∧ (pmatch_list tvs cenv s ps vs env = No_match) ∧ (LENGTH ps = LENGTH vs)
      ⇒ ∀m. good_cmap cenv m.cnmap ⇒
            Cpnomatch_list (MAP (v_to_Cv m) s) (SND (pats_to_Cpats m ps)) (vs_to_Cvs m vs))``,
  ho_match_mp_tac pmatch_ind >>
  strip_tac >- rw[pmatch_def] >>
  strip_tac >- (
    rw[pmatch_def,lit_same_type_def] >>
    rpt (pop_assum mp_tac) >>
    BasicProvers.CASE_TAC >>
    BasicProvers.CASE_TAC >>
    rw[pat_to_Cpat_def,Once Cpnomatch_cases,v_to_Cv_def] ) >>
  strip_tac >- (
    fs[pmatch_def] >>
    rpt gen_tac >> strip_tac >>
    Cases_on `ALOOKUP cenv n` >> fs[] >>
    qmatch_assum_rename_tac `ALOOKUP cenv n = SOME p`[] >>
    PairCases_on `p` >> fs[] >>
    Cases_on `ALOOKUP cenv n'` >> fs[] >>
    qmatch_assum_rename_tac `ALOOKUP cenv n' = SOME p`[] >>
    PairCases_on `p` >> fs[] >>
    rw[] >>
    pop_assum mp_tac >> rw[] >>
    rw[pat_to_Cpat_def] >> rw[v_to_Cv_def] >>
    rw[Once Cpnomatch_cases]
      >- PROVE_TAC[SND,optionTheory.SOME_11,PAIR_EQ] >>
    fs[good_cenv_def,good_cmap_def] >>
    imp_res_tac ALOOKUP_MEM >>
    metis_tac[pat_to_Cpat_cnmap,FST] ) >>
  strip_tac >- (
    rw[pmatch_def] >>
    Cases_on `store_lookup lnum s` >> fs[] >>
    rw[pat_to_Cpat_def,v_to_Cv_def] >>
    rw[Once Cpnomatch_cases] >>
    qexists_tac `v_to_Cv m x` >>
    first_x_assum (qspec_then`m`mp_tac) >> rw[] >>
    fs[store_to_fmap_def,store_lookup_def,el_check_def,EL_MAP] ) >>
  strip_tac >- rw[pmatch_def] >>
  strip_tac >- rw[pmatch_def] >>
  strip_tac >- rw[pmatch_def] >>
  strip_tac >- rw[pmatch_def] >>
  strip_tac >- rw[pmatch_def] >>
  strip_tac >- rw[pmatch_def] >>
  strip_tac >- rw[pmatch_def] >>
  strip_tac >- rw[pmatch_def] >>
  strip_tac >- rw[pmatch_def] >>
  strip_tac >- rw[pmatch_def] >>
  strip_tac >- rw[pmatch_def] >>
  strip_tac >- rw[pmatch_def] >>
  strip_tac >- rw[pmatch_def] >>
  strip_tac >- (
    rw[pmatch_def] >>
    qpat_assum`X = No_match`mp_tac>>
    fs[Once pmatch_nil] >>
    rw[Once (CONJUNCT1 pmatch_nil)] >>
    Cases_on `pmatch tvs cenv s p v []` >> fs[] >> rw[] >- (
      rw[pat_to_Cpat_def,vs_to_Cvs_MAP] >>
      rw[Once Cpnomatch_cases] >>
      metis_tac[SND_pat_to_Cpat_cnmap,SND,pat_to_Cpat_cnmap,pats_to_Cpats_LENGTH]) >>
    rw[pat_to_Cpat_def,vs_to_Cvs_MAP] >>
    rw[Once Cpnomatch_cases] >>
    fs[vs_to_Cvs_MAP] >> rw[] >>
    `l = l ++ []` by rw[] >>
    qpat_assum `x = Match l` mp_tac >>
    pop_assum SUBST1_TAC >> strip_tac >>
    imp_res_tac pmatch_Cpmatch >>
    disj2_tac >>
    simp[LEFT_EXISTS_AND_THM] >>
    conj_tac >- metis_tac[SND] >>
    metis_tac[SND,pat_to_Cpat_cnmap,SND_pat_to_Cpat_cnmap,FST]) >>
  strip_tac >- rw[pmatch_def] >>
  rw[pmatch_def])

val matchres_def = Define`
  matchres (env:α envE) cenv s env' e r = ∃env''. (env' = env'' ++ env) ∧ (r = (s, Rval (env'',e)))`

val evaluate_match_with_Cevaluate_match = store_thm("evaluate_match_with_Cevaluate_match",
  ``∀pes r. evaluate_match_with (matchres env) cenv s env v pes r ⇒
      ∀m. good_cenv cenv ∧ good_cmap cenv m.cnmap ⇒
        ((r = (s, Rerr (Rraise Bind_error)))
            ⇒ Cevaluate_match (MAP (v_to_Cv m) s) (v_to_Cv m v)
                (MAP (λ(p,e). (SND (pat_to_Cpat m p),e)) pes)
                [] NONE) ∧
        ∀env' e. (r = (s, Rval (env',e)))
          ⇒ Cevaluate_match (MAP (v_to_Cv m) s) (v_to_Cv m v)
              (MAP (λ(p,e). (SND (pat_to_Cpat m p),e)) pes)
              (env_to_Cenv m env') (SOME e)``,
  ho_match_mp_tac evaluate_match_with_ind >>
  strip_tac >- ( rw[] >> rw[Once Cevaluate_match_cases] ) >>
  strip_tac >- (
    rw[] >> rw[Once Cevaluate_match_cases] >>
    fs[matchres_def] >>
    PROVE_TAC[pmatch_Cpmatch] ) >>
  strip_tac >- (
    rw[] >>
    rw[Once Cevaluate_match_cases] >>
    PROVE_TAC[pmatch_Cpnomatch] ) >>
  strip_tac >- rw[] >> rw[] )

val evaluate_match_with_matchres = store_thm("evaluate_match_with_matchres",
  ``∀pes r. evaluate_match_with P cenv s env v pes r ⇒
            (SND r ≠ Rerr Rtype_error) ⇒
            ((SND r = Rerr (Rraise Bind_error)) ∧
             evaluate_match_with (matchres env) cenv s env v pes (s, Rerr (Rraise Bind_error)) ∧
             (FST r = s)) ∨
            ∃menv mr. evaluate_match_with (matchres env) cenv s env v pes (s, Rval (menv,mr)) ∧
                      P cenv s (menv++env) mr r``,
  ho_match_mp_tac evaluate_match_with_ind >>
  strip_tac >- rw[Once evaluate_match_with_cases] >>
  strip_tac >- (
    rw[] >>
    disj2_tac >>
    rw[Once evaluate_match_with_cases] >>
    rw[matchres_def] >>
    fs[Once pmatch_nil] >>
    Cases_on `pmatch (SOME 0) cenv s p v []` >>fs[] >>
    PROVE_TAC[] ) >>
  strip_tac >- (
    rw[] >> fs[] >>
    rw[Once evaluate_match_with_cases] >>
    disj2_tac >>
    rw[Once evaluate_match_with_cases] >>
    PROVE_TAC[] ) >>
  strip_tac >- rw[] >>
  rw[])

val evaluate_match_with_matchres_closed = store_thm("evaluate_match_with_matchres_closed",
  ``∀pes r. evaluate_match_with (matchres env) cenv s env v pes r ⇒
            EVERY closed s ∧ EVERY closed (MAP (FST o SND) env) ∧ closed v ⇒
            every_result (λ(menv,mr). EVERY closed (MAP (FST o SND) menv) ∧
                                      ∃p. MEM (p,mr) pes ∧
                                          (set (MAP FST menv) = pat_vars p)) (SND r) ``,
  ho_match_mp_tac evaluate_match_with_ind >>
  strip_tac >- rw[] >>
  strip_tac >- (
    rw[matchres_def] >>
    fs[] >>
    fs[Once pmatch_nil] >>
    Cases_on `pmatch (SOME 0) cenv s p v []` >> fs[] >>
    qspecl_then [`SOME 0`,`cenv`,`s`,`p`,`v`,`[]`] mp_tac (CONJUNCT1 pmatch_closed) >>
    fs[] >> fsrw_tac[DNF_ss][] ) >>
  strip_tac >- (
    rw[] >> fs[] >>
    Cases_on `SND r` >> fs[] >>
    fs[UNCURRY] >>
    fsrw_tac[DNF_ss][] >> PROVE_TAC[]) >>
  strip_tac >- rw[] >>
  rw[])

val Cevaluate_match_MAP_exp = store_thm("Cevaluate_match_MAP_exp",
  ``∀pes env r. Cevaluate_match s v pes env r ⇒
      ∀f. Cevaluate_match s v (MAP (λ(p,e). (p, f e)) pes) env (OPTION_MAP f r)``,
  ho_match_mp_tac Cevaluate_match_ind >>
  strip_tac >- rw[Once Cevaluate_match_rules] >>
  strip_tac >- rw[Once Cevaluate_match_cases] >>
  rw[] >>
  rw[Once Cevaluate_match_cases])

val Cpmatch_FDOM = store_thm("Cpmatch_FDOM",
  ``(∀p v env. Cpmatch s p v env ⇒ (LENGTH env = Cpat_vars p)) ∧
    (∀ps vs env. Cpmatch_list s ps vs env ⇒ (LENGTH env = SUM (MAP Cpat_vars ps)))``,
  ho_match_mp_tac Cpmatch_ind >> rw[] >> fsrw_tac[ARITH_ss][] >>
  pop_assum kall_tac >>
  Induct_on`ps` >> rw[])

val Cpmatch_closed = store_thm("Cpmatch_closed",
  ``(∀p v e. Cpmatch s p v e ⇒ Cclosed c v ∧ (EVERY (Cclosed c) s) ⇒ EVERY (Cclosed c) e) ∧
    (∀ps vs e. Cpmatch_list s ps vs e ⇒ EVERY (Cclosed c) vs ∧ (EVERY (Cclosed c) s) ⇒ EVERY (Cclosed c) e)``,
  ho_match_mp_tac Cpmatch_ind >>
  strip_tac >- rw[] >>
  strip_tac >- rw[] >>
  strip_tac >- (rw[] >> fs[el_check_def,EVERY_MEM,MEM_EL] >> PROVE_TAC[]) >>
  strip_tac >- (rw[] >> fs[Once Cclosed_cases]) >>
  rw[])

val Cpmatch_strongind = theorem"Cpmatch_strongind"

val Cpmatch_remove_mat = store_thm("Cpmatch_remove_mat",
  ``(∀p v menv. Cpmatch s p v menv ⇒
       ∀env x fk e r0.
         (el_check x env = SOME v) ∧
         free_vars e ⊆ count (Cpat_vars p + LENGTH env) ∧
         fk < LENGTH env ∧
         (free_labs e = {}) ∧
         Cevaluate FEMPTY s (menv ++ env) e r0
       ⇒ ∃r. Cevaluate FEMPTY s env (remove_mat_vp fk e x p) r ∧
             EVERY2 (syneq FEMPTY FEMPTY) (FST r) (FST r0) ∧
             result_rel (syneq FEMPTY FEMPTY) (SND r) (SND r0)) ∧
    (∀ps vs menv. Cpmatch_list s ps vs menv ⇒
       ∀env x c vs0 menv0 fk e r0.
         (el_check x (menv0 ++ env) = SOME (CConv c (vs0++vs))) ∧
         free_vars e ⊆ count (LENGTH (menv ++ menv0 ++ env)) ∧
         fk < LENGTH (menv0 ++ env) ∧
         (free_labs e = {}) ∧
         Cevaluate FEMPTY s (menv ++ menv0 ++ env) e r0
       ⇒ ∃r. Cevaluate FEMPTY s (menv0 ++ env) (remove_mat_con fk e x (LENGTH vs0) ps) r ∧
             EVERY2 (syneq FEMPTY FEMPTY) (FST r) (FST r0) ∧
             result_rel (syneq FEMPTY FEMPTY) (SND r) (SND r0))``,
  ho_match_mp_tac Cpmatch_strongind >>
  strip_tac >- (
    rw[remove_mat_var_def] >>
    rw[Once Cevaluate_cases] >>
    fs[el_check_def] >>
    metis_tac[result_rel_syneq_refl,EVERY2_syneq_refl]) >>
  strip_tac >- (
    rw[remove_mat_vp_def] >>
    fs[el_check_def] >>
    rw[Once Cevaluate_cases] >>
    srw_tac[DNF_ss][] >>
    disj1_tac >>
    CONV_TAC (RESORT_EXISTS_CONV List.rev) >> qexists_tac `T` >>
    fs[] >>
    rw[Once Cevaluate_cases] >>
    rw[Once Cevaluate_cases] >>
    rw[Once Cevaluate_cases] >>
    rw[Once Cevaluate_cases] >>
    metis_tac[result_rel_syneq_refl,EVERY2_syneq_refl]) >>
  strip_tac >- (
    rw[remove_mat_vp_def,LET_THM] >>
    rw[Once Cevaluate_cases] >>
    srw_tac[DNF_ss][] >>
    disj1_tac >>
    rw[Once Cevaluate_cases,LET_THM] >>
    fs[el_check_def] >> rw[] >>
    imp_res_tac Cpmatch_FDOM >>
    qspecl_then[`FEMPTY`,`s`,`menv++env`,`e`,`r0`]mp_tac(CONJUNCT1 Cevaluate_syneq) >>
    simp[] >>
    disch_then(qspecl_then[`FEMPTY`,`λv1 v2. if v1 < LENGTH menv then (v2 = v1) else (v2 = v1+1)`
                          ,`s`,`menv++(EL n s::env)`,`shift 1 (Cpat_vars p) e`]mp_tac) >>
    qmatch_abbrev_tac`(P ⇒ Q) ⇒ R` >>
    `P` by (
      unabbrev_all_tac >> simp[] >>
      conj_tac >- (
        simp[shift_def] >>
        match_mp_tac mkshift_thm >>
        simp[] ) >>
      lrw[EL_APPEND1,EL_APPEND2,EL_CONS,PRE_SUB1] ) >>
    simp[] >>
    map_every qunabbrev_tac[`P`,`Q`,`R`] >> fs[] >>
    disch_then(Q.X_CHOOSE_THEN`r1`strip_assume_tac) >>
    first_x_assum(qspecl_then[`EL n s::env`,`0`,`fk+1`,`shift 1 (Cpat_vars p) e`,`r1`]mp_tac) >>
    simp[] >>
    qmatch_abbrev_tac`(P ⇒ Q) ⇒ R` >>
    `P` by (
      unabbrev_all_tac >>
      fsrw_tac[DNF_ss][EVERY_MEM,MEM_EL,SUBSET_DEF,ADD1] >>
      rw[] >> fsrw_tac[ARITH_ss][] >>
      res_tac >>
      fsrw_tac[ARITH_ss][] ) >>
    map_every qunabbrev_tac[`P`,`Q`,`R`] >> fs[] >>
    PROVE_TAC[result_rel_syneq_trans,result_rel_syneq_sym,
              EVERY2_syneq_sym,EVERY2_syneq_trans] ) >>
  strip_tac >- (
    rw[] >>
    rw[Once Cevaluate_cases] >>
    srw_tac[DNF_ss][] >>
    disj1_tac >>
    CONV_TAC (RESORT_EXISTS_CONV List.rev) >> qexists_tac `T` >>
    fs[] >>
    qexists_tac`s` >>
    fs[RIGHT_EXISTS_AND_THM,GSYM CONJ_ASSOC] >>
    conj_tac >- (
      rw[Once Cevaluate_cases] >>
      fs[el_check_def] ) >>
    `0 = LENGTH ([]:Cv list)` by rw[] >> pop_assum SUBST1_TAC >>
    `env = [] ++ env` by rw[] >> pop_assum SUBST1_TAC >>
    first_x_assum (match_mp_tac o MP_CANON) >>
    fs[FOLDL_UNION_BIGUNION] >>
    imp_res_tac Cpmatch_FDOM >>
    fsrw_tac[DNF_ss][SUBSET_DEF,Cpat_vars_list_SUM_MAP]) >>
  strip_tac >- (
    rw[FUNION_FEMPTY_1] >>
    PROVE_TAC[result_rel_syneq_refl,EVERY2_syneq_refl] ) >>
  rpt gen_tac >> strip_tac >>
  rpt gen_tac >> strip_tac >>
  rw[LET_THM] >>
  rw[Once Cevaluate_cases] >>
  srw_tac[DNF_ss][] >>
  disj1_tac >>
  rw[Once Cevaluate_cases] >>
  srw_tac[DNF_ss][] >>
  map_every (fn q => CONV_TAC SWAP_EXISTS_CONV >> qexists_tac q) [`c`,`vs0++v::vs`] >>
  fs[el_check_def] >>
  fs[rich_listTheory.EL_LENGTH_APPEND] >>
  qspecl_then[`FEMPTY`,`s`,`menv' ++ menv ++ menv0 ++ env`,`e`,`r0`]mp_tac(CONJUNCT1 Cevaluate_syneq) >>
  simp[] >>
  disch_then(qspecl_then[`FEMPTY`,`λv1 v2. if v1 < LENGTH menv' + LENGTH menv then (v2 = v1) else (v2 = v1+1)`
                        ,`s`,`menv'++menv++[v]++menv0++env`
                        ,`shift 1 (Cpat_vars_list ps + Cpat_vars p) e`]mp_tac) >>
  qmatch_abbrev_tac`(P ⇒ Q) ⇒ R` >>
  `P` by (
    map_every qunabbrev_tac[`P`,`Q`,`R`] >>
    simp[] >>
    conj_tac >- (
      simp[shift_def] >>
      match_mp_tac mkshift_thm >>
      imp_res_tac Cpmatch_FDOM >>
      simp[Cpat_vars_list_SUM_MAP] >>
      fsrw_tac[DNF_ss][SUBSET_DEF] >>
      qx_gen_tac`z` >> strip_tac >>
      first_x_assum(qspec_then`z`mp_tac) >>
      simp[SUM_APPEND] ) >>
    lrw[ADD1,EL_APPEND1,EL_APPEND2,EL_CONS,PRE_SUB1] >>
    qabbrev_tac`l1 = menv' ++ menv` >>
    REWRITE_TAC[GSYM APPEND_ASSOC] >>
    `LENGTH l1 ≤ v1` by simp[Abbr`l1`] >>
    simp[EL_APPEND2]) >>
  simp[] >>
  map_every qunabbrev_tac[`P`,`Q`,`R`] >>
  pop_assum kall_tac >>
  disch_then(Q.X_CHOOSE_THEN`r1`strip_assume_tac) >>
  first_x_assum (qspecl_then [`env`,`x+(Cpat_vars p+1)`,`c`,`vs0 ++ [v]`,`menv ++ [v] ++ menv0`,`fk+(Cpat_vars p+1)`
                             ,`shift 1 (Cpat_vars_list ps + Cpat_vars p) e`,`r1`] mp_tac) >>
  qmatch_abbrev_tac`(P ⇒ Q) ⇒ R` >>
  `P` by (
    map_every qunabbrev_tac[`P`,`Q`,`R`] >>
    imp_res_tac Cpmatch_FDOM >>
    simp[ADD1] >>
    conj_tac >- (
      qabbrev_tac`l1 = menv ++ [v]` >>
      `LENGTH l1 = Cpat_vars p + 1` by simp[Abbr`l1`] >>
      REWRITE_TAC[Once (GSYM APPEND_ASSOC)] >>
      qabbrev_tac`l2 = menv0 ++ env` >>
      REWRITE_TAC[Once (GSYM APPEND_ASSOC)] >>
      lrw[EL_APPEND2]) >>
    fsrw_tac[ARITH_ss,DNF_ss][SUBSET_DEF,Cpat_vars_list_SUM_MAP,SUM_APPEND] >>
    qx_gen_tac`z` >> strip_tac >>
    first_x_assum(qspec_then`z`mp_tac) >>
    simp[] ) >>
  simp[] >>
  map_every qunabbrev_tac[`P`,`Q`,`R`] >>
  pop_assum kall_tac >>
  disch_then(Q.X_CHOOSE_THEN`r2`strip_assume_tac) >>
  fsrw_tac[ARITH_ss][] >>
  Q.PAT_ABBREV_TAC`e' = remove_mat_con X Y Z A B` >>
  first_x_assum(qspecl_then[`[v]++menv0++env`,`0`,`fk+1`,`e'`,`r2`]mp_tac) >>
  qmatch_abbrev_tac`(P ⇒ Q) ⇒ R` >>
  `P` by (
    map_every qunabbrev_tac[`P`,`Q`,`R`] >>
    simp[Abbr`e'`] >>
    qmatch_abbrev_tac`free_vars (remove_mat_con fk0 sk0 v0 n0 ps) ⊆ s0` >>
    match_mp_tac SUBSET_TRANS >>
    qspecl_then[`ps`,`fk0`,`sk0`,`v0`,`n0`]strip_assume_tac(CONJUNCT2 free_vars_remove_mat_vp_SUBSET) >>
    HINT_EXISTS_TAC >> simp[] >>
    fsrw_tac[DNF_ss][SUBSET_DEF,Abbr`v0`,Abbr`fk0`,Abbr`s0`,Abbr`sk0`] >>
    simp[] >>
    imp_res_tac Cpmatch_FDOM >>
    srw_tac[ARITH_ss][Cpat_vars_list_SUM_MAP] >>
    fsrw_tac[ARITH_ss][] >>
    res_tac >> DECIDE_TAC ) >>
  fs[] >> pop_assum kall_tac >>
  map_every qunabbrev_tac[`Q`,`R`] >>
  metis_tac[result_rel_syneq_trans,EVERY2_syneq_trans,
            result_rel_syneq_sym,EVERY2_syneq_sym])

val Cpnomatch_strongind = theorem"Cpnomatch_strongind"

val Cpnomatch_remove_mat = store_thm("Cpnomatch_remove_mat",
  ``(∀p v. Cpnomatch s p v ⇒
       ∀env x fk e r0.
         (FLOOKUP env x = SOME v) ∧ fk ∈ FDOM env ∧
         x ∉ Cpat_vars p ∧
         fk ∉ Cpat_vars p ∧
         Cclosed FEMPTY v ∧ (∀v. v ∈ FRANGE env ⇒ Cclosed FEMPTY v) ∧
         (∀v. v ∈ FRANGE s ⇒ Cclosed FEMPTY v) ∧
         free_vars FEMPTY e ⊆ Cpat_vars p ∪ FDOM env ∧
         Cevaluate FEMPTY FEMPTY s env (CCall (CVar fk) []) r0
         ⇒ ∃r. Cevaluate FEMPTY FEMPTY s env (remove_mat_vp fk e x p) r ∧
               fmap_rel (syneq FEMPTY) (FST r) (FST r0) ∧
               result_rel (syneq FEMPTY) (SND r) (SND r0)) ∧
    (∀ps vs. Cpnomatch_list s ps vs ⇒
       ∀env x c ps0 vs0 menv fk e r0.
         (FLOOKUP env x = SOME (CConv c (vs0 ++ vs))) ∧ fk ∈ FDOM env ∧
         x ∉ BIGUNION (IMAGE Cpat_vars (set (ps0 ++ ps))) ∧
         fk ∉ BIGUNION (IMAGE Cpat_vars (set (ps0 ++ ps))) ∧
         EVERY (Cclosed FEMPTY) (vs0 ++ vs) ∧ (∀v. v ∈ FRANGE env ⇒ Cclosed FEMPTY v) ∧
         (∀v. v ∈ FRANGE s ⇒ Cclosed FEMPTY v) ∧
         free_vars FEMPTY e ⊆ BIGUNION (IMAGE Cpat_vars (set (ps0 ++ ps))) ∪ FDOM env ∧
         Cpmatch_list s ps0 vs0 menv ∧
         Cevaluate FEMPTY FEMPTY s env (CCall (CVar fk) []) r0
         ⇒ ∃r. Cevaluate FEMPTY FEMPTY s (menv ⊌ env) (remove_mat_con fk e x (LENGTH ps0) ps) r ∧
               fmap_rel (syneq FEMPTY) (FST r) (FST r0) ∧
               result_rel (syneq FEMPTY) (SND r) (SND r0))``,
  ho_match_mp_tac Cpnomatch_ind >>
  strip_tac >- (
    rw[] >>
    rw[Once Cevaluate_cases] >>
    srw_tac[DNF_ss][] >>
    disj1_tac >>
    CONV_TAC (RESORT_EXISTS_CONV List.rev) >>qexists_tac `F` >> fs[] >>
    rw[Once Cevaluate_cases] >>
    rw[Once Cevaluate_cases] >>
    simp[Once Cevaluate_cases] >>
    fs[FLOOKUP_DEF] >>
    rw[] >>
    rw[Once Cevaluate_cases] >>
    PROVE_TAC[result_rel_refl,syneq_refl,fmap_rel_refl]) >>
  strip_tac >- (
    rw[] >>
    rw[Once Cevaluate_cases] >>
    rw[Once Cevaluate_cases] >>
    fsrw_tac[DNF_ss][] >>
    fs[FLOOKUP_DEF] >>
    PROVE_TAC[result_rel_refl,syneq_refl,fmap_rel_refl]) >>
  strip_tac >- (
    rw[LET_THM] >>
    rw[Once Cevaluate_cases] >>
    srw_tac[DNF_ss][] >>
    disj1_tac >>
    rw[Once Cevaluate_cases,LET_THM] >>
    fs[FLOOKUP_DEF] >> rw[] >>
    Q.PAT_ABBREV_TAC`v = fresh_var X` >>
    qspecl_then[`FEMPTY`,`FEMPTY`,`s`,`env`,`CCall (CVar fk) []`,`r0`,`v`,`s ' n`]mp_tac Cevaluate_FUPDATE >>
    qmatch_abbrev_tac`(P ⇒ Q) ⇒ R` >>
    `P` by (
      unabbrev_all_tac >> simp[] >>
      fsrw_tac[DNF_ss][IN_FRANGE,SUBSET_DEF,FUNION_DEF] >>
      Q.PAT_ABBREV_TAC`v = fresh_var X` >>
      `v ∉ {fk}` by (
        unabbrev_all_tac >>
        match_mp_tac fresh_var_not_in_any >>
        rw[] ) >>
      fs[]) >>
    map_every qunabbrev_tac[`P`,`Q`,`R`] >> fs[] >>
    disch_then(Q.X_CHOOSE_THEN`r2`strip_assume_tac) >>
    first_x_assum(qspecl_then[`env|+(v, s ' n)`,`v`,`fk`,`e`,`r2`]mp_tac) >>
    qmatch_abbrev_tac`(P ⇒ Q) ⇒ R` >>
    `P` by (
      unabbrev_all_tac >> simp[] >>
      conj_tac >- (
        match_mp_tac fresh_var_not_in_any >>
        rw[] ) >>
      conj_tac >- (
        fsrw_tac[DNF_ss][IN_FRANGE,DOMSUB_FAPPLY_THM] ) >>
      fsrw_tac[DNF_ss][SUBSET_DEF] >>
      PROVE_TAC[] ) >>
    map_every qunabbrev_tac[`P`,`Q`,`R`] >> fs[] >>
    fsrw_tac[DNF_ss][] >>
    PROVE_TAC[result_rel_syneq_trans,result_rel_syneq_sym,
              fmap_rel_syneq_sym,fmap_rel_syneq_trans] ) >>
  strip_tac >- (
    rw[FLOOKUP_DEF] >>
    rw[Once Cevaluate_cases] >>
    rw[Once Cevaluate_cases] >>
    fsrw_tac[DNF_ss][] >>
    first_x_assum (qspecl_then [`env`,`x`,`c`,`[]`,`[]`,`FEMPTY`,`fk`,`e`] mp_tac) >>
    fs[FUNION_FEMPTY_1] >>
    fs[Once Cclosed_cases,FOLDL_UNION_BIGUNION]) >>
  strip_tac >- (
    rw[FLOOKUP_DEF,LET_THM] >>
    rw[Once Cevaluate_cases] >>
    rw[Once Cevaluate_cases] >>
    rw[Cevaluate_proj] >>
    imp_res_tac Cpmatch_FDOM >>
    Cases_on `x ∈ FDOM menv` >- (
      pop_assum mp_tac >> fs[] >>
      metis_tac[] ) >>
    fs[FUNION_DEF] >>
    imp_res_tac Cpmatch_list_LENGTH >>
    fsrw_tac[ARITH_ss][] >>
    simp_tac std_ss[Once(GSYM APPEND_ASSOC)] >>
    rw[rich_listTheory.EL_LENGTH_APPEND] >>
    Q.PAT_ABBREV_TAC`u = fresh_var (X ∪ free_vars FEMPTY e ∪ Y)` >>
    first_x_assum (qspecl_then [`(menv ⊌ env) |+ (u,v)`,`u`,`fk`] mp_tac) >>
    fs[FAPPLY_FUPDATE_THM] >>
    `∀v. v ∈ FRANGE (menv ⊌ env) ⇒ Cclosed FEMPTY v` by (
      unabbrev_all_tac >>
      match_mp_tac IN_FRANGE_FUNION_suff >>
      imp_res_tac Cpmatch_closed >> fs[] ) >>
    `∀v. v ∈ FRANGE ((menv ⊌ env) \\ u) ⇒ Cclosed FEMPTY v` by (
      match_mp_tac IN_FRANGE_DOMSUB_suff >> rw[]) >>
    `free_vars FEMPTY (CCall (CVar fk) []) ⊆ FDOM env` by rw[] >>
    `u ∉ free_vars FEMPTY (CCall (CVar fk) [])` by (
      unabbrev_all_tac >>
      match_mp_tac fresh_var_not_in_any >>
      rw[] ) >>
    `u ∉ Cpat_vars p` by (
      unabbrev_all_tac >>
      match_mp_tac fresh_var_not_in_any >>
      rw[] ) >>
    qspecl_then [`FEMPTY`,`FEMPTY`,`s`,`env`,`CCall (CVar fk) []`,`r0`,`u`,`v`] mp_tac Cevaluate_FUPDATE >>
    `fk ∉ Cpat_vars p` by metis_tac[] >> fs[] >>
    rw[] >>
    fsrw_tac[DNF_ss][] >>
    Q.PAT_ABBREV_TAC`ee= remove_mat_con fk e x n ps` >>
    first_x_assum (qspec_then `ee` mp_tac) >>
    fs[] >>
    Q.PAT_ABBREV_TAC`P = free_vars FEMPTY ee ⊆ X` >>
    `P` by (
      unabbrev_all_tac >>
      qspecl_then [`ps`,`fk`,`e`,`x`,`LENGTH vs0 + 1`] mp_tac
        (CONJUNCT2 free_vars_remove_mat_vp_SUBSET) >>
      fsrw_tac[DNF_ss][SUBSET_DEF] >>
      metis_tac[]) >> qunabbrev_tac`P` >> fs[] >>
    qho_match_abbrev_tac `(∀x. P x ⇒ R x) ⇒ Z` >>
    qsuff_tac `∃x. P x ∧
      fmap_rel (syneq FEMPTY) (FST r0) (FST x) ∧
      result_rel (syneq FEMPTY) (SND r0) (SND x)` >- (
      unabbrev_all_tac >> fs[] >>
      PROVE_TAC[result_rel_syneq_trans,result_rel_syneq_sym,
                fmap_rel_syneq_trans,fmap_rel_syneq_sym] ) >>
    qunabbrev_tac`P` >> fs[] >>
    qho_match_abbrev_tac `∃r1. Cevaluate FEMPTY FEMPTY s (env1 |+ (u,v)) exp1 r1 ∧ P r1` >>
    qspecl_then [`FEMPTY`,`FEMPTY`,`s`,`env`,`exp1`,`r0`,`u`,`v`] mp_tac Cevaluate_FUPDATE >>
    fs[] >>
    fs[Abbr`P`,Abbr`exp1`,Abbr`env1`] >>
    qspecl_then [`FEMPTY`,`FEMPTY`,`s`,`env`,`CCall (CVar fk) []`,`r0`] mp_tac Cevaluate_free_vars_env >>
    fs[] >>
    disch_then (Q.X_CHOOSE_THEN `r2` strip_assume_tac) >>
    qabbrev_tac `env1 = (menv ⊌ env) |+ (u,v)` >>
    qspecl_then [`FEMPTY`,`FEMPTY`,`s`,`env1`,`CCall (CVar fk)[]`,`r2`] mp_tac Cevaluate_any_super_env >>
    fs[] >>
    `fk ∈ FDOM env1` by fs[Abbr`env1`] >>
    `DRESTRICT env1 {fk} = DRESTRICT env {fk}` by (
      fs[DRESTRICT_EQ_DRESTRICT] >>
      fs[SUBMAP_DEF,FDOM_DRESTRICT] >>
      fs[Once EXTENSION] >>
      fs[DRESTRICT_DEF] >>
      `env1 ' fk = env ' fk` by (
        rw[Abbr`env1`] >>
        rw[FAPPLY_FUPDATE_THM] >>
        rw[FUNION_DEF] >>
        metis_tac[] ) >>
      fs[] >>
      metis_tac[] ) >>
    fs[] >>
    `∀v. v ∈ FRANGE env1 ⇒ Cclosed FEMPTY v` by (
      unabbrev_all_tac >>
      match_mp_tac IN_FRANGE_FUPDATE_suff >>
      fs[] ) >>
    fs[] >>
    PROVE_TAC[result_rel_syneq_trans,result_rel_syneq_sym,
              fmap_rel_syneq_trans,fmap_rel_syneq_sym]) >>
  rw[FLOOKUP_DEF,LET_THM] >>
  rw[Once Cevaluate_cases] >>
  rw[Once Cevaluate_cases] >>
  rw[Cevaluate_proj] >>
  imp_res_tac Cpmatch_FDOM >>
  Cases_on `x ∈ FDOM menv` >- (
    pop_assum mp_tac >> fs[] >>
    metis_tac[] ) >>
  fs[FUNION_DEF] >>
  imp_res_tac Cpmatch_list_LENGTH >>
  fsrw_tac[ARITH_ss][] >>
  simp_tac std_ss[Once(GSYM APPEND_ASSOC)] >>
  rw[rich_listTheory.EL_LENGTH_APPEND] >>
  qspecl_then [`p`,`v`,`env`] mp_tac (CONJUNCT1 Cpmatch_remove_mat) >>
  fs[] >>
  Q.PAT_ABBREV_TAC`u = fresh_var (X ∪ free_vars FEMPTY e ∪ Y)` >>
  Q.PAT_ABBREV_TAC`ee = remove_mat_con fk e x n ps` >>
  Q.PAT_ABBREV_TAC`env0 = X |+ (u,v)` >>
  disch_then (qspecl_then [`env0`,`u`,`fk`,`ee`] mp_tac) >>
  imp_res_tac Cpmatch_closed >>
  `FLOOKUP env0 u = SOME v` by (unabbrev_all_tac >> fs[FLOOKUP_DEF]) >> fs[] >>
  `fk ∈ FDOM env0` by (unabbrev_all_tac >> fs[]) >> fs[] >>
  `u ∉ Cpat_vars p` by (unabbrev_all_tac >> match_mp_tac fresh_var_not_in_any >> rw[]) >> fs[] >>
  `∀v. v ∈ FRANGE env0 ⇒ Cclosed FEMPTY v` by (
    unabbrev_all_tac >>
    match_mp_tac IN_FRANGE_FUPDATE_suff >>
    asm_simp_tac std_ss[] >>
    match_mp_tac IN_FRANGE_FUNION_suff >>
    fs[] ) >> fs[] >>
  `free_vars FEMPTY ee ⊆ Cpat_vars p ∪ FDOM env0` by (
    unabbrev_all_tac >>
    ntac 4 (pop_assum kall_tac) >>
    qspecl_then [`ps`,`fk`,`e`,`x`,`LENGTH vs0 + 1`] mp_tac
      (CONJUNCT2 free_vars_remove_mat_vp_SUBSET) >>
    fsrw_tac[DNF_ss][SUBSET_DEF] >>
    metis_tac[]) >> fs[] >>
  qsuff_tac `∃rx. Cevaluate FEMPTY FEMPTY s (env ⊌ env0) ee rx ∧
                  fmap_rel (syneq FEMPTY) (FST rx) (FST r0) ∧
                  result_rel (syneq FEMPTY) (SND rx) (SND r0)` >-
    PROVE_TAC[result_rel_syneq_trans,result_rel_syneq_sym,
              fmap_rel_syneq_trans,fmap_rel_syneq_sym] >>
  first_x_assum (qspecl_then [`env0`,`x`,`c`,`ps0 ++ [p]`,`vs0 ++ [v]`,`env ⊌ menv`,`fk`,`e`] mp_tac) >>
  `x ∈ FDOM env0` by fs[Abbr`env0`] >> fs[] >>
  `env0 ' x = CConv c (vs0 ++ [v] ++ vs)` by (
    qunabbrev_tac`env0` >>
    `u ∉ {x}` by (
      unabbrev_all_tac >>
      match_mp_tac fresh_var_not_in_any >>
      rw[] ) >>
    `x ∉ FDOM env` by metis_tac[] >>
    fs[FAPPLY_FUPDATE_THM,FUNION_DEF]>> fs[] ) >> fs[] >>
  qho_match_abbrev_tac `(∀x. P ∧ Q x ⇒ R x) ⇒ Z` >>
  `P` by (
    unabbrev_all_tac >> rw[] >>
    metis_tac[] ) >> qunabbrev_tac`P` >> fs[] >>
  qunabbrev_tac`Q` >> fs[] >>
  qho_match_abbrev_tac `(∀x. P ∧ Q x ⇒ R x) ⇒ Z` >>
  `P` by (
    unabbrev_all_tac >> rw[] >>
    metis_tac[] ) >> qunabbrev_tac`P` >> fs[] >>
  qunabbrev_tac`Q` >> fs[] >>
  qho_match_abbrev_tac `(∀x. P ∧ Q x ⇒ R x) ⇒ Z` >>
  `P` by (
    unabbrev_all_tac >> rw[] >>
    ntac 10 (pop_assum kall_tac) >>
    fsrw_tac[DNF_ss][SUBSET_DEF] >>
    metis_tac[]) >> qunabbrev_tac`P` >> fs[] >>
  qunabbrev_tac `Q` >> fs[] >>
  fs[Cpmatch_list_APPEND] >>
  fs[rich_listTheory.BUTFIRSTN_LENGTH_APPEND] >>
  fs[rich_listTheory.FIRSTN_LENGTH_APPEND] >>
  simp_tac std_ss[Q.SPEC`[p]` (CONJUNCT2 (SPEC_ALL Cpmatch_cases))] >>
  fsrw_tac[DNF_ss][] >>
  fs[FUNION_FEMPTY_1] >>
  disch_then (mp_tac o Q.SPEC`menv` o CONV_RULE SWAP_FORALL_CONV) >>
  disch_then (mp_tac o Q.SPEC`env` o CONV_RULE SWAP_FORALL_CONV) >>
  fs[] >>
  qunabbrev_tac`R` >> fs[] >>
  qunabbrev_tac`Z` >> fs[] >>
  `u ∉ FDOM env` by (
    unabbrev_all_tac >>
    match_mp_tac fresh_var_not_in_any >>
    fsrw_tac[DNF_ss][SUBSET_DEF] ) >>
  qspecl_then[`FEMPTY`,`FEMPTY`,`s`,`env'`,`CCall (CVar fk) []`,`r0`] mp_tac Cevaluate_free_vars_env >>
  fs[] >>
  disch_then (Q.X_CHOOSE_THEN`r2` strip_assume_tac) >>
  `DRESTRICT env0 {fk} = DRESTRICT env' {fk}` by (
    fs[DRESTRICT_EQ_DRESTRICT] >>
    fs[SUBMAP_DEF,DRESTRICT_DEF] >>
    `u ∉ {fk}` by (
      unabbrev_all_tac >>
      match_mp_tac fresh_var_not_in_any >>
      rw[] ) >>
    pop_assum mp_tac >>
    asm_simp_tac (srw_ss())[FAPPLY_FUPDATE_THM] >>
    strip_tac >>
    `fk ∉ FDOM menv` by (
      asm_simp_tac(srw_ss())[] >>
      metis_tac[] ) >>
    `env0 ' fk = env' ' fk` by (
      qunabbrev_tac`env0` >>
      asm_simp_tac(srw_ss())[FUNION_DEF,FAPPLY_FUPDATE_THM] ) >>
    asm_simp_tac(srw_ss())[] >>
    asm_simp_tac(srw_ss())[Once EXTENSION] >>
    qunabbrev_tac`env0` >>
    simp_tac std_ss [FDOM_FUPDATE,FDOM_FUNION] >>
    simp_tac(srw_ss())[] >>
    metis_tac[] ) >>
  qspecl_then[`FEMPTY`,`FEMPTY`,`s`,`env0`,`CCall (CVar fk) []`,`r2`] mp_tac Cevaluate_any_super_env >>
  fs[] >>
  disch_then (Q.X_CHOOSE_THEN `r3` strip_assume_tac) >>
  disch_then (qspec_then `r3` mp_tac) >> fs[] >>
  disch_then (Q.X_CHOOSE_THEN `r4` strip_assume_tac) >>
  qspecl_then [`FEMPTY`,`FEMPTY`,`s`,`env ⊌ menv ⊌ env0`,`ee`,`r4`] mp_tac Cevaluate_free_vars_env >>
  fs[] >>
  Q.PAT_ABBREV_TAC`P = free_vars FEMPTY ee ⊆ X` >>
  `P` by (
    fsrw_tac[DNF_ss][SUBSET_DEF,Abbr`P`] >>
    metis_tac[] ) >> qunabbrev_tac`P` >> fs[] >>
  qho_match_abbrev_tac`(P ⇒ Q) ⇒ R` >>
  `P` by (
    qunabbrev_tac `P` >>
    match_mp_tac IN_FRANGE_FUNION_suff >> fs[] >>
    match_mp_tac IN_FRANGE_FUNION_suff >> fs[] ) >>
  qunabbrev_tac`P` >> fs[] >>
  qunabbrev_tac`Q`>>qunabbrev_tac`R` >>
  disch_then (Q.X_CHOOSE_THEN `r5` strip_assume_tac) >>
  qspecl_then [`FEMPTY`,`FEMPTY`,`s`,`env ⊌ env0`,`ee`,`r5`] mp_tac Cevaluate_any_super_env >>
  fs[] >>
  `DRESTRICT (env ⊌ env0) (free_vars FEMPTY ee) = DRESTRICT (env ⊌ menv ⊌ env0) (free_vars FEMPTY ee)` by (
    qunabbrev_tac`env0` >>
    simp_tac std_ss[GSYM FUNION_ASSOC] >>
    asm_simp_tac std_ss[FUNION_FUPDATE_2] >>
    `u ∉ free_vars FEMPTY ee` by (
      qunabbrev_tac`ee` >>
      qspecl_then [`ps`,`fk`,`e`,`x`,`LENGTH vs0 + 1`] mp_tac (CONJUNCT2 free_vars_remove_mat_vp_SUBSET) >>
      asm_simp_tac (std_ss++DNF_ss) [SUBSET_DEF,IN_UNION,IN_DIFF] >>
      strip_tac >>
      `u ∉ {x;fk}` by (
        qunabbrev_tac`u` >>
        match_mp_tac fresh_var_not_in_any >>
        rw[] ) >>
      `u ∉ free_vars FEMPTY e` by (
        qunabbrev_tac`u` >>
        match_mp_tac fresh_var_not_in_any >>
        rw[] >> rw[SUBSET_DEF]) >>
      metis_tac[] ) >>
    asm_simp_tac std_ss[DRESTRICT_FUPDATE] >>
    simp_tac std_ss[FUNION_ASSOC,FUNION_IDEMPOT] >>
    Cases_on `u ∈ BIGUNION (IMAGE Cpat_vars (set ps0))` >>
    asm_simp_tac std_ss[FUNION_ASSOC] >>
    asm_simp_tac std_ss[FUNION_FUPDATE_2,DRESTRICT_FUPDATE,FUNION_ASSOC] ) >>
  fs[] >>
  qho_match_abbrev_tac`(P ⇒ Q) ⇒ R` >>
  `P` by (
    qunabbrev_tac `P` >>
    match_mp_tac IN_FRANGE_FUNION_suff >> fs[] ) >>
  qunabbrev_tac`P` >> fs[] >>
  metis_tac[result_rel_syneq_trans,result_rel_syneq_sym,
            fmap_rel_syneq_trans,fmap_rel_syneq_sym] )

val Cevaluate_match_strongind = theorem"Cevaluate_match_strongind"

val Cevaluate_match_least_el = store_thm("Cevaluate_match_least_el",
  ``∀pes env r. Cevaluate_match s v pes env r ⇒ ∀e. (r = SOME e) ⇒
      ∃i p. i < LENGTH pes ∧ (EL i pes = (p,e)) ∧ Cpmatch s p v env ∧
      ∀j. j < i ⇒ Cpnomatch s (FST (EL j pes)) v``,
  ho_match_mp_tac Cevaluate_match_ind >>
  rw[] >- ( qexists_tac `0` >> rw[] ) >>
  qexists_tac `SUC i` >> rw[] >>
  Cases_on `j` >> rw[] >>
  fs[])

val Cevaluate_match_NONE_FEMPTY = store_thm("Cevaluate_match_NONE_FEMPTY",
  ``Cevaluate_match s v pes env NONE ⇒ (env = FEMPTY)``,
  qsuff_tac `∀pes env r. Cevaluate_match s v pes env r ⇒ (r = NONE) ⇒ (env = FEMPTY)` >- PROVE_TAC[] >>
  ho_match_mp_tac Cevaluate_match_ind >> rw[])

val Cevaluate_match_remove_mat_var = store_thm("Cevaluate_match_remove_mat_var",
  ``∀pes menv mr. Cevaluate_match s v pes menv mr ⇒
      ∀env x. (FLOOKUP env x = SOME v) ∧
              x ∉ BIGUNION (IMAGE (Cpat_vars o FST) (set pes)) ∧
              BIGUNION (IMAGE (λ(p,e). free_vars FEMPTY e DIFF Cpat_vars p) (set pes)) ⊆ FDOM env ∧
              Cclosed FEMPTY v ∧
              (∀v. v ∈ FRANGE env ⇒ Cclosed FEMPTY v) ∧
              (∀v. v ∈ FRANGE s ⇒ Cclosed FEMPTY v) ⇒
       case mr of
       | NONE =>
           ∃r. Cevaluate FEMPTY FEMPTY s env (remove_mat_var x pes) r ∧
               fmap_rel (syneq FEMPTY) (FST r) s ∧
               (SND r = Rerr (Rraise Bind_error))
       | SOME e => ∀r0. Cevaluate FEMPTY FEMPTY s (menv ⊌ env) e r0 ⇒
           ∃r. Cevaluate FEMPTY FEMPTY s env (remove_mat_var x pes) r ∧
               fmap_rel (syneq FEMPTY) (FST r) (FST r0) ∧
               result_rel (syneq FEMPTY) (SND r) (SND r0)``,
  ho_match_mp_tac Cevaluate_match_strongind >>
  strip_tac >- rw[remove_mat_var_def] >>
  strip_tac >- (
    rw[remove_mat_var_def,LET_THM] >>
    rw[Once Cevaluate_cases] >>
    fsrw_tac[DNF_ss][] >>
    Q.PAT_ABBREV_TAC`fk = fresh_var X` >>
    qho_match_abbrev_tac `∃r. Cevaluate FEMPTY FEMPTY s ee (remove_mat_vp fk e x p) r ∧
                           P r ∧ Q r` >>
    map_every qunabbrev_tac[`P`,`Q`] >> simp[] >>
    qspecl_then [`p`,`v`,`menv`] mp_tac (CONJUNCT1 Cpmatch_remove_mat) >>
    fs[] >>
    disch_then (qspecl_then [`ee`,`x`,`fk`,`e`] mp_tac) >>
    fsrw_tac[DNF_ss][FORALL_PROD] >>
    `fk ∉ {x} ∪ free_vars FEMPTY e` by (
      qunabbrev_tac`fk` >> match_mp_tac fresh_var_not_in_any >> rw[SUBSET_DEF] ) >>
    `FLOOKUP ee x = SOME v` by fs[Abbr`ee`,FLOOKUP_UPDATE] >> fs[] >>
    `fk ∈ FDOM ee` by fs[Abbr`ee`] >> fs[] >>
    `x ∉ Cpat_vars p` by metis_tac[] >> fs[] >>
    `∀v. v ∈ FRANGE ee ⇒ Cclosed FEMPTY v` by (
      unabbrev_all_tac >>
      match_mp_tac IN_FRANGE_FUPDATE_suff  >>
      fs[] >>
      rw[Once Cclosed_cases] >>
      qspecl_then [`x`,`pes`] strip_assume_tac free_vars_remove_mat_var >>
      pop_assum mp_tac >>
      srw_tac[DNF_ss][Once EXTENSION,SUBSET_DEF] >>
      fsrw_tac[DNF_ss][EXISTS_PROD,SUBSET_DEF] >>
      `x ∈ FDOM env` by fs[FLOOKUP_DEF] >>
      fsrw_tac[DNF_ss][FORALL_PROD] >>
      metis_tac[] ) >> fs[] >>
    `free_vars FEMPTY e ⊆ Cpat_vars p ∪ FDOM ee` by (
      fsrw_tac[DNF_ss][SUBSET_DEF] >>
      rw[Abbr`ee`] >>
      metis_tac[] ) >> fs[] >>
    qsuff_tac `∃rx. Cevaluate FEMPTY FEMPTY s (menv ⊌ ee) e rx ∧
                    fmap_rel (syneq FEMPTY) (FST r0) (FST rx) ∧
                    result_rel (syneq FEMPTY) (SND r0) (SND rx)` >-
      metis_tac[result_rel_syneq_trans,result_rel_syneq_sym,
                fmap_rel_syneq_trans,fmap_rel_syneq_sym,
                         pair_CASES,PAIR_EQ,FST,SND] >>
    unabbrev_all_tac >>
    Q.PAT_ABBREV_TAC`fk = fresh_var (a ∪ b)` >>
    Cases_on `fk ∈ FDOM menv` >>
    rw[FUNION_FUPDATE_2] >-
      metis_tac[result_rel_refl,syneq_refl,fmap_rel_refl] >>
    match_mp_tac (MP_CANON Cevaluate_FUPDATE) >>
    fs[] >>
    imp_res_tac Cpmatch_FDOM >>
    fsrw_tac[DNF_ss][SUBSET_DEF] >>
    conj_tac >- PROVE_TAC[] >>
    match_mp_tac IN_FRANGE_FUNION_suff >>
    fs[] >>
    imp_res_tac Cpmatch_closed) >>
  rw[] >>
  rw[remove_mat_var_def,LET_THM] >>
  qspecl_then [`p`,`v`] mp_tac (CONJUNCT1 Cpnomatch_remove_mat) >>
  rw[] >>
  Q.PAT_ABBREV_TAC`ex = CLet fk X Y` >>
  qsuff_tac `∀r0. (case mr of NONE =>
                     fmap_rel (syneq FEMPTY) (FST r0) s ∧
                     (SND r0 = Rerr (Rraise Bind_error))
                   | SOME e => Cevaluate FEMPTY FEMPTY s (menv ⊌ env) e r0)
                   ⇒ ∃r. Cevaluate FEMPTY FEMPTY s env ex r ∧
                         fmap_rel (syneq FEMPTY) (FST r) (FST r0) ∧
                         result_rel (syneq FEMPTY) (SND r) (SND r0)` >- (
    Cases_on `mr` >> fs[EXISTS_PROD,FORALL_PROD]) >>
  qx_gen_tac `r0` >>
  strip_tac >>
  qunabbrev_tac`ex` >>
  rw[Once Cevaluate_cases] >>
  Q.PAT_ABBREV_TAC`cl = CRecClos env X Y Z` >>
  Q.PAT_ABBREV_TAC`env1 = env |+ X` >>
  fs[FORALL_PROD] >>
  `x ∉ Cpat_vars p` by metis_tac[] >>
  Q.PAT_ABBREV_TAC`fk = fresh_var X` >>
  first_x_assum (qspecl_then [`env1`,`x`,`fk`,`e`] mp_tac) >>
  fs[] >>
  `fk ∉ {x}` by (
    qunabbrev_tac`fk` >>
    match_mp_tac fresh_var_not_in_any >>
    rw[] ) >>
  fs[] >>
  `Cclosed FEMPTY cl` by (
    unabbrev_all_tac >>
    rw[Once Cclosed_cases] >>
    qmatch_abbrev_tac `a ⊆ b` >>
    qsuff_tac `a DIFF {x} ⊆ b DIFF {x}` >- (
      unabbrev_all_tac >>
      rw[SUBSET_DEF] >>
      fs[FLOOKUP_DEF] >>
      metis_tac[] ) >>
    qunabbrev_tac`a` >>
    rw[free_vars_remove_mat_var] >>
    qunabbrev_tac`b` >>
    fsrw_tac[DNF_ss][SUBSET_DEF] >>
    metis_tac[] ) >>
  `FLOOKUP env1 x = SOME v` by (
    qunabbrev_tac`env1` >>
    rw[FLOOKUP_UPDATE] ) >>
  `fk ∈ FDOM env1` by rw[Abbr`env1`] >>
  `fk ∉ Cpat_vars p` by (
    qunabbrev_tac`fk` >>
    match_mp_tac fresh_var_not_in_any >>
    rw[SUBSET_DEF] ) >>
  `∀v. v ∈ FRANGE env1 ⇒ Cclosed FEMPTY v` by (
    qunabbrev_tac`env1` >>
    match_mp_tac IN_FRANGE_FUPDATE_suff >>
    rw[] ) >>
  `free_vars FEMPTY e ⊆ Cpat_vars p ∪ FDOM env1` by (
    qunabbrev_tac`env1` >>
    fsrw_tac[DNF_ss][SUBSET_DEF] >>
    metis_tac[] ) >>
  fs[] >>
  qsuff_tac
  `∃s1 r1.
        Cevaluate FEMPTY FEMPTY s env1 (CCall (CVar fk) []) (s1,r1) ∧
        fmap_rel (syneq FEMPTY) s1 (FST r0) ∧
        result_rel (syneq FEMPTY) r1 (SND r0)` >-
      metis_tac[result_rel_syneq_trans,fmap_rel_syneq_trans] >>
  ntac 5 (pop_assum kall_tac) >>
  rw[Once Cevaluate_cases,Abbr`env1`,Abbr`cl`] >>
  srw_tac[DNF_ss][] >>
  simp_tac std_ss [Once Cevaluate_cases] >>
  rw[Once Cevaluate_cases,SimpR``$\/``] >>
  rw[extend_rec_env_def] >>
  first_x_assum (qspecl_then [`env`,`x`] mp_tac) >>
  fs[] >>
  qmatch_abbrev_tac `(P ⇒ Q) ⇒ R` >>
  `P` by ( metis_tac[] ) >>
  pop_assum mp_tac >> simp_tac std_ss [] >>
  disch_then kall_tac >> qunabbrev_tac`P` >>
  qunabbrev_tac`Q` >> qunabbrev_tac`R` >>
  Cases_on `mr` >> fs[EXISTS_PROD] >>
  Cases_on`r0`>>
  fsrw_tac[DNF_ss][EXISTS_PROD,FORALL_PROD] >>
  metis_tac[result_rel_syneq_trans,result_rel_syneq_sym,
            fmap_rel_syneq_trans,fmap_rel_syneq_sym,PAIR_EQ])

val Cpmatch_syneq = store_thm("Cpmatch_syneq",
  ``(∀p v env. Cpmatch s p v env ⇒
      ∀c s' w. syneq c v w ∧ fmap_rel (syneq c) s s' ⇒
      ∃env'. Cpmatch s' p w env' ∧ fmap_rel (syneq c) env env') ∧
    (∀ps vs env. Cpmatch_list s ps vs env ⇒
      ∀c s' ws. EVERY2 (syneq c) vs ws ∧ fmap_rel (syneq c) s s' ⇒
      ∃env'. Cpmatch_list s' ps ws env' ∧ fmap_rel (syneq c) env env')``,
  ho_match_mp_tac Cpmatch_ind >>
  strip_tac >- rw[Once Cpmatch_cases,fmap_rel_def] >>
  strip_tac >- rw[Once Cpmatch_cases,Once syneq_cases] >>
  strip_tac >- (
    rw[] >>
    rw[Once Cpmatch_cases] >>
    Cases_on`w`>>fs[Once (Q.SPECL[`c`,`CLoc n`]syneq_cases)] >>
    fsrw_tac[DNF_ss][] >> rw[] >>
    `∃w. (FLOOKUP s' n = SOME w) ∧ syneq c v w` by (
      fs[fmap_rel_def,FLOOKUP_DEF] >> rw[]) >>
    fs[]) >>
  strip_tac >- (
    rw[Once syneq_cases] >>
    res_tac >>
    rw[Once Cpmatch_cases] ) >>
  strip_tac >- rw[Once Cpmatch_cases] >>
  rw[] >>
  rw[Once Cpmatch_cases] >>
  res_tac >>
  srw_tac[DNF_ss][] >>
  metis_tac[fmap_rel_FUNION_rels])

val Cpnomatch_syneq = store_thm("Cpnomatch_syneq",
  ``(∀p v. Cpnomatch s p v ⇒
      ∀c s' w. syneq c v w ∧ fmap_rel (syneq c) s s' ⇒
        Cpnomatch s' p w) ∧
    (∀ps vs. Cpnomatch_list s ps vs ⇒
      ∀c s' ws. EVERY2 (syneq c) vs ws ∧ fmap_rel (syneq c) s s' ⇒
        Cpnomatch_list s' ps ws)``,
  ho_match_mp_tac Cpnomatch_ind >>
  rw[] >>
  TRY (
    rw[Once Cpnomatch_cases] >>
    fs[Once syneq_cases] >>
    res_tac >> NO_TAC) >>
  TRY (
    fs[Once(Q.SPECL[`c`,`CLoc n`]syneq_cases)]>>
    rw[Once Cpnomatch_cases] >>
    `∃w. (FLOOKUP s' n = SOME w) ∧ syneq c v w` by (
      fs[fmap_rel_def,FLOOKUP_DEF] >> rw[] ) >>
    fs[] >> first_x_assum match_mp_tac >>
    qexists_tac`c` >> rw[] >>
    NO_TAC) >>
  rw[Once Cpnomatch_cases] >>
  fs[EVERY2_EVERY] >>
  metis_tac[Cpmatch_syneq])

val Cevaluate_match_syneq = store_thm("Cevaluate_match_syneq",
  ``∀pes env r. Cevaluate_match s v pes env r ⇒
      ∀c s' w. syneq c v w ∧ fmap_rel (syneq c) s s' ⇒
        ∃env'. Cevaluate_match s' w pes env' r ∧ fmap_rel (syneq c) env env'``,
  ho_match_mp_tac Cevaluate_match_ind >>
  strip_tac >- rw[Once Cevaluate_match_cases] >>
  strip_tac >- (
    rw[Once Cevaluate_match_cases] >>
    imp_res_tac Cpmatch_syneq >>
    rw[Once Cevaluate_match_cases] >>
    metis_tac[] ) >>
  rw[] >>
  rw[Once Cevaluate_match_cases] >>
  metis_tac[Cpnomatch_syneq])

val Cevaluate_match_closed = store_thm("Cevaluate_match_closed",
  ``∀pes env r. Cevaluate_match s v pes env r ⇒
      (∀v. v ∈ FRANGE s ⇒ Cclosed c v) ∧ Cclosed c v ⇒
      (∀v. v ∈ FRANGE env ⇒ Cclosed c v)``,
  ho_match_mp_tac Cevaluate_match_ind >>
  rw[Cpmatch_closed] >>
  imp_res_tac Cpmatch_closed)

val _ = export_theory()
