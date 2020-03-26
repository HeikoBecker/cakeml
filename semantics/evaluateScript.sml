(*Generated by Lem from evaluate.lem.*)
open HolKernel Parse boolLib bossLib;
open lem_pervasives_extraTheory libTheory fpValTreeTheory fpSemTheory astTheory namespaceTheory ffiTheory semanticPrimitivesTheory;

val _ = numLib.prefer_num();



val _ = new_theory "evaluate"

(*
  Functional big-step semantics for evaluation of CakeML programs.
*)
(*open import Pervasives_extra*)
(*open import Lib*)
(*open import Ast*)
(*open import Namespace*)
(*open import SemanticPrimitives*)
(*open import Ffi*)
(*open import FpValTree FpSem*)

(* The semantics is defined here using fix_clock so that HOL4 generates
 * provable termination conditions. However, after termination is proved, we
 * clean up the definition (in HOL4) to remove occurrences of fix_clock. *)

val _ = Define `
 ((fix_clock:'a state -> 'b state#'c -> 'b state#'c) s (s', res)=
   (( s' with<| clock := (if s'.clock <= s.clock
                     then s'.clock else s.clock) |>), res))`;


val _ = Define `
 ((dec_clock:'a state -> 'a state) s=  (( s with<| clock := (s.clock -( 1 : num)) |>)))`;


val _ = Define `
 ((shift_fp_opts:'a state -> 'a state) s=  (( s with<| fp_state :=
                         (( s.fp_state with<|
                           opts := (\ x .  s.fp_state.opts (x +( 1 : num)));
                           choices := (s.fp_state.choices +( 1 : num)) |>)) |>)))`;


(* list_result is equivalent to map_result (\v. [v]) I, where map_result is
 * defined in evalPropsTheory *)
 val _ = Define `

((list_result:('a,'b)result ->(('a list),'b)result) (Rval v)=  (Rval [v]))
/\
((list_result:('a,'b)result ->(('a list),'b)result) (Rerr e)=  (Rerr e))`;


(*val do_real_check : forall 'ffi. bool -> result v v -> maybe (result v v)*)
val _ = Define `
 ((do_real_check:bool ->((v),(v))result ->(((v),(v))result)option) b r=
   (if b then SOME r
  else (case r of
    Rval (Real r) => NONE
  | _ => SOME r
  )))`;


(*val evaluate : forall 'ffi. state 'ffi -> sem_env v -> list exp -> state 'ffi * result (list v) v*)
(*val evaluate_match : forall 'ffi. state 'ffi -> sem_env v -> v -> list (pat * exp) -> v -> state 'ffi * result (list v) v*)
 val evaluate_defn = Defn.Hol_multi_defns `

((evaluate:'ffi state ->(v)sem_env ->(exp)list -> 'ffi state#(((v)list),(v))result) st env []=  (st, Rval []))
/\
((evaluate:'ffi state ->(v)sem_env ->(exp)list -> 'ffi state#(((v)list),(v))result) st env (e1::e2::es)=
   ((case fix_clock st (evaluate st env [e1]) of
    (st', Rval v1) =>
      (case evaluate st' env (e2::es) of
        (st'', Rval vs) => (st'', Rval (HD v1::vs))
      | res => res
      )
  | res => res
  )))
/\
((evaluate:'ffi state ->(v)sem_env ->(exp)list -> 'ffi state#(((v)list),(v))result) st env [Lit l]=  (st, Rval [Litv l]))
/\
((evaluate:'ffi state ->(v)sem_env ->(exp)list -> 'ffi state#(((v)list),(v))result) st env [Raise e]=
   ((case evaluate st env [e] of
    (st', Rval v) => (st', Rerr (Rraise (HD v)))
  | res => res
  )))
/\
((evaluate:'ffi state ->(v)sem_env ->(exp)list -> 'ffi state#(((v)list),(v))result) st env [Handle e pes]=
   ((case fix_clock st (evaluate st env [e]) of
    (st', Rerr (Rraise v)) =>
      if can_pmatch_all env.c st'.refs (MAP FST pes) v
      then evaluate_match st' env v pes v
      else (st', Rerr (Rabort Rtype_error))
  | res => res
  )))
/\
((evaluate:'ffi state ->(v)sem_env ->(exp)list -> 'ffi state#(((v)list),(v))result) st env [Con cn es]=
   (if do_con_check env.c cn (LENGTH es) then
    (case evaluate st env (REVERSE es) of
      (st', Rval vs) =>
        (case build_conv env.c cn (REVERSE vs) of
          SOME v => (st', Rval [v])
        | NONE => (st', Rerr (Rabort Rtype_error))
        )
    | res => res
    )
  else (st, Rerr (Rabort Rtype_error))))
/\
((evaluate:'ffi state ->(v)sem_env ->(exp)list -> 'ffi state#(((v)list),(v))result) st env [Var n]=
   ((case nsLookup env.v n of
    SOME v => (st, Rval [v])
  | NONE => (st, Rerr (Rabort Rtype_error))
  )))
/\
((evaluate:'ffi state ->(v)sem_env ->(exp)list -> 'ffi state#(((v)list),(v))result) st env [Fun x e]=  (st, Rval [Closure env x e]))
/\
((evaluate:'ffi state ->(v)sem_env ->(exp)list -> 'ffi state#(((v)list),(v))result) st env [App op es]=
   ((case fix_clock st (evaluate st env (REVERSE es)) of
    (st', Rval vs) =>
    (case (getOpClass op) of
      FunApp =>
        (case do_opapp (REVERSE vs) of
          SOME (env',e) =>
            if st'.clock =( 0 : num) then
              (st', Rerr (Rabort Rtimeout_error))
            else
              evaluate (dec_clock st') env'  [e]
        | NONE => (st', Rerr (Rabort Rtype_error))
        )
    | Simple =>
        (case do_app (st'.refs,st'.ffi) op (REVERSE vs) of
          NONE => (st', Rerr (Rabort Rtype_error))
        | SOME ((refs,ffi),r) =>
            (( st' with<| refs := refs; ffi := ffi |>), list_result r)
        )
    | Icing =>
      (case do_app (st'.refs,st'.ffi) op (REVERSE vs) of
        NONE => (st', Rerr (Rabort Rtype_error))
      | SOME ((refs,ffi),r) =>
        let fp_opt =
          (if (st'.fp_state.canOpt = FPScope Opt)
          then
            ((case (do_fprw r (st'.fp_state.opts(( 0 : num))) (st'.fp_state.rws)) of
            (* if it fails, just use the old value tree *)
              NONE => r
            | SOME r_opt => r_opt
            ))
            (* If we cannot optimize, we should not allow matching on the structure in the oracle *)
          else r)
        in
        let stN = (if (st'.fp_state.canOpt = FPScope Opt) then shift_fp_opts st' else st') in
        let fp_res =
          (if (isFpBool op)
          then (case fp_opt of
              Rval (FP_BoolTree fv) => Rval (Boolv (compress_bool fv))
            | v => v
            )
          else fp_opt)
        in ((( stN with<| refs := refs; ffi := ffi |>)), list_result fp_res)
      )
    | Reals =>
      if (st'.fp_state.real_sem) then
      (case do_app (st'.refs,st'.ffi) op (REVERSE vs) of
        NONE => (shift_fp_opts st', Rerr (Rabort Rtype_error))
      | SOME ((refs,ffi),r) =>
        (( (shift_fp_opts st') with<| refs := refs; ffi := ffi |>), list_result r)
      )
      else (shift_fp_opts st', Rerr (Rabort Rtype_error))
    )
  | res => res
  )))
/\
((evaluate:'ffi state ->(v)sem_env ->(exp)list -> 'ffi state#(((v)list),(v))result) st env [Log lop e1 e2]=
   ((case fix_clock st (evaluate st env [e1]) of
    (st', Rval v1) =>
      (case do_log lop (HD v1) e2 of
        SOME (Exp e) => evaluate st' env  [e]
      | SOME (Val v) => (st', Rval [v])
      | NONE => (st', Rerr (Rabort Rtype_error))
      )
  | res => res
  )))
/\
((evaluate:'ffi state ->(v)sem_env ->(exp)list -> 'ffi state#(((v)list),(v))result) st env [If e1 e2 e3]=
   ((case fix_clock st (evaluate st env [e1]) of
    (st', Rval v) =>
    (case do_if (HD v) e2 e3 of
      SOME e => evaluate st' env  [e]
    | NONE => (st', Rerr (Rabort Rtype_error))
    )
  | res => res
  )))
/\
((evaluate:'ffi state ->(v)sem_env ->(exp)list -> 'ffi state#(((v)list),(v))result) st env [Mat e pes]=
   ((case fix_clock st (evaluate st env [e]) of
    (st', Rval v) =>
      if can_pmatch_all env.c st'.refs (MAP FST pes) (HD v)
      then evaluate_match st' env (HD v) pes bind_exn_v
      else (st', Rerr (Rabort Rtype_error))
  | res => res
  )))
/\
((evaluate:'ffi state ->(v)sem_env ->(exp)list -> 'ffi state#(((v)list),(v))result) st env [Let xo e1 e2]=
   ((case fix_clock st (evaluate st env [e1]) of
    (st', Rval v) => evaluate st' ( env with<| v := (nsOptBind xo (HD v) env.v) |>)  [e2]
  | res => res
  )))
/\
((evaluate:'ffi state ->(v)sem_env ->(exp)list -> 'ffi state#(((v)list),(v))result) st env [Letrec funs e]=
   (if ALL_DISTINCT (MAP (\ (x,y,z) .  x) funs) then
    evaluate st ( env with<| v := (build_rec_env funs env env.v) |>) [e]
  else
    (st, Rerr (Rabort Rtype_error))))
/\
((evaluate:'ffi state ->(v)sem_env ->(exp)list -> 'ffi state#(((v)list),(v))result) st env [Tannot e t]=
   (evaluate st env [e]))
/\
((evaluate:'ffi state ->(v)sem_env ->(exp)list -> 'ffi state#(((v)list),(v))result) st env [Lannot e l]=
   (evaluate st env [e]))
/\
((evaluate:'ffi state ->(v)sem_env ->(exp)list -> 'ffi state#(((v)list),(v))result) st env [FpOptimise annot e]=
   (let newFpState =
    (if (st.fp_state.canOpt = Strict)
    then st.fp_state
    else ( st.fp_state with<| canOpt := (FPScope annot)|>))
  in
    (case fix_clock st (evaluate (( st with<| fp_state := newFpState |>)) env [e]) of
      (st', Rval vs) =>
    (( st' with<| fp_state := (( st'.fp_state with<| canOpt := (st.fp_state.canOpt) |>)) |>),
        Rval (do_fpoptimise annot vs))
    | (st', Rerr e) =>
    (( st' with<| fp_state := (( st'.fp_state with<| canOpt := (st.fp_state.canOpt) |>)) |>), Rerr e)
    )))
/\
((evaluate_match:'ffi state ->(v)sem_env -> v ->(pat#exp)list -> v -> 'ffi state#(((v)list),(v))result) st env v [] err_v=  (st, Rerr (Rraise err_v)))
/\
((evaluate_match:'ffi state ->(v)sem_env -> v ->(pat#exp)list -> v -> 'ffi state#(((v)list),(v))result) st env v ((p,e)::pes) err_v=
    (if ALL_DISTINCT (pat_bindings p []) then
    (case pmatch env.c st.refs p v [] of
      Match env_v' => evaluate st ( env with<| v := (nsAppend (alist_to_ns env_v') env.v) |>) [e]
    | No_match => evaluate_match st env v pes err_v
    | Match_type_error => (st, Rerr (Rabort Rtype_error))
    )
  else (st, Rerr (Rabort Rtype_error))))`;

val _ = Lib.with_flag (computeLib.auto_import_definitions, false) (List.map Defn.save_defn) evaluate_defn;

(*val evaluate_decs :
  forall 'ffi. state 'ffi -> sem_env v -> list dec -> state 'ffi * result (sem_env v) v*)
 val evaluate_decs_defn = Defn.Hol_multi_defns `

  ((evaluate_decs:'ffi state ->(v)sem_env ->(dec)list -> 'ffi state#(((v)sem_env),(v))result) st env []=  (st, Rval <| v := nsEmpty; c := nsEmpty |>))
/\
 ((evaluate_decs:'ffi state ->(v)sem_env ->(dec)list -> 'ffi state#(((v)sem_env),(v))result) st env (d1::d2::ds)=
   ((case evaluate_decs st env [d1] of
    (st1, Rval env1) =>
    (case evaluate_decs st1 (extend_dec_env env1 env) (d2::ds) of
      (st2, r) => (st2, combine_dec_result env1 r)
    )
  | res => res
  )))
/\
 ((evaluate_decs:'ffi state ->(v)sem_env ->(dec)list -> 'ffi state#(((v)sem_env),(v))result) st env [Dlet locs p e]=
   (if ALL_DISTINCT (pat_bindings p []) then
    (case evaluate st env [e] of
      (st', Rval v) =>
        (st',
         (case pmatch env.c st'.refs p (HD v) [] of
           Match new_vals => Rval <| v := (alist_to_ns new_vals); c := nsEmpty |>
         | No_match => Rerr (Rraise bind_exn_v)
         | Match_type_error => Rerr (Rabort Rtype_error)
         ))
    | (st', Rerr err) => (st', Rerr err)
    )
  else
    (st, Rerr (Rabort Rtype_error))))
/\
 ((evaluate_decs:'ffi state ->(v)sem_env ->(dec)list -> 'ffi state#(((v)sem_env),(v))result) st env [Dletrec locs funs]=
   (st,
   (if ALL_DISTINCT (MAP (\ (x,y,z) .  x) funs) then
     Rval <| v := (build_rec_env funs env nsEmpty); c := nsEmpty |>
   else
     Rerr (Rabort Rtype_error))))
/\
 ((evaluate_decs:'ffi state ->(v)sem_env ->(dec)list -> 'ffi state#(((v)sem_env),(v))result) st env [Dtype locs tds]=
   (if EVERY check_dup_ctors tds then
    (( st with<| next_type_stamp := (st.next_type_stamp + LENGTH tds) |>),
     Rval <| v := nsEmpty; c := (build_tdefs st.next_type_stamp tds) |>)
  else
    (st, Rerr (Rabort Rtype_error))))
/\
 ((evaluate_decs:'ffi state ->(v)sem_env ->(dec)list -> 'ffi state#(((v)sem_env),(v))result) st env [Dtabbrev locs tvs tn t]=
   (st, Rval <| v := nsEmpty; c := nsEmpty |>))
/\
 ((evaluate_decs:'ffi state ->(v)sem_env ->(dec)list -> 'ffi state#(((v)sem_env),(v))result) st env [Dexn locs cn ts]=
   (( st with<| next_exn_stamp := (st.next_exn_stamp +( 1 : num)) |>),
   Rval <| v := nsEmpty; c := (nsSing cn (LENGTH ts, ExnStamp st.next_exn_stamp)) |>))
/\
 ((evaluate_decs:'ffi state ->(v)sem_env ->(dec)list -> 'ffi state#(((v)sem_env),(v))result) st env [Dmod mn ds]=
   ((case evaluate_decs st env ds of
    (st', r) =>
      (st',
       (case r of
         Rval env' => Rval <| v := (nsLift mn env'.v); c := (nsLift mn env'.c) |>
       | Rerr err => Rerr err
       ))
  )))
/\
 ((evaluate_decs:'ffi state ->(v)sem_env ->(dec)list -> 'ffi state#(((v)sem_env),(v))result) st env [Dlocal lds ds]=
   ((case evaluate_decs st env lds of
    (st1, Rval env1) =>
    evaluate_decs st1 (extend_dec_env env1 env) ds
  | res => res
  )))`;

val _ = Lib.with_flag (computeLib.auto_import_definitions, false) (List.map Defn.save_defn) evaluate_decs_defn;
val _ = export_theory()

