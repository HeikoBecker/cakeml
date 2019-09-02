(*Generated by Lem from typeSystem.lem.*)
open HolKernel Parse boolLib bossLib;
open lem_pervasives_extraTheory libTheory astTheory namespaceTheory semanticPrimitivesTheory;

val _ = numLib.prefer_num();



val _ = new_theory "typeSystem"

(*
  Specification of CakeML's type system.
*)
(*open import Pervasives_extra*)
(*open import Lib*)
(*open import Ast*)
(*open import Namespace*)
(*open import SemanticPrimitives*)

val _ = type_abbrev( "type_ident" , ``: num``);

(* Types *)
val _ = Hol_datatype `
 t =
  (* Type variables that the user writes down ('a, 'b, etc.) *)
    Tvar of tvarN
  (* deBruijn indexed type variables. *)
  | Tvar_db of num
  (* Type applications *)
  | Tapp of t list => type_ident`;


(* Some abbreviations *)
val _ = Define `
 ((Tarray_num:num) : type_ident= (( 0 : num)))`;

val _ = Define `
 ((Tbool_num:num) : type_ident= (( 1 : num)))`;

val _ = Define `
 ((Tchar_num:num) : type_ident= (( 2 : num)))`;

val _ = Define `
 ((Texn_num:num) : type_ident= (( 3 : num)))`;

val _ = Define `
 ((Tfn_num:num) : type_ident= (( 4 : num)))`;

val _ = Define `
 ((Tint_num:num) : type_ident= (( 5 : num)))`;

val _ = Define `
 ((Tlist_num:num) : type_ident= (( 6 : num)))`;

val _ = Define `
 ((Tref_num:num) : type_ident= (( 7 : num)))`;

val _ = Define `
 ((Tstring_num:num) : type_ident= (( 8 : num)))`;

val _ = Define `
 ((Ttup_num:num) : type_ident= (( 9 : num)))`;

val _ = Define `
 ((Tvector_num:num) : type_ident= (( 10 : num)))`;

val _ = Define `
 ((Tword64_num:num) : type_ident= (( 11 : num)))`;

val _ = Define `
 ((Tword8_num:num) : type_ident= (( 12 : num)))`;

val _ = Define `
 ((Tword8array_num:num) : type_ident= (( 13 : num)))`;


(* The numbers for the primitive types *)
val _ = Define `
 ((prim_type_nums:(num)list)=
   ([Tarray_num; Tchar_num; Texn_num; Tfn_num; Tint_num; Tref_num; Tstring_num; Ttup_num;
   Tvector_num; Tword64_num; Tword8_num; Tword8array_num]))`;


val _ = Define `
 ((Tarray:t -> t) t=  (Tapp [t] Tarray_num))`;

val _ = Define `
 ((Tbool:t)=  (Tapp [] Tbool_num))`;

val _ = Define `
 ((Tchar:t)=  (Tapp [] Tchar_num))`;

val _ = Define `
 ((Texn:t)=  (Tapp [] Texn_num))`;

val _ = Define `
 ((Tfn:t -> t -> t) t1 t2=  (Tapp [t1;t2] Tfn_num))`;

val _ = Define `
 ((Tint:t)=  (Tapp [] Tint_num))`;

val _ = Define `
 ((Tlist:t -> t) t=  (Tapp [t] Tlist_num))`;

val _ = Define `
 ((Tref:t -> t) t=  (Tapp [t] Tref_num))`;

val _ = Define `
 ((Tstring:t)=  (Tapp [] Tstring_num))`;

val _ = Define `
 ((Ttup:(t)list -> t) ts=  (Tapp ts Ttup_num))`;

val _ = Define `
 ((Tvector:t -> t) t=  (Tapp [t] Tvector_num))`;

val _ = Define `
 ((Tword64:t)=  (Tapp [] Tword64_num))`;

val _ = Define `
 ((Tword8:t)=  (Tapp [] Tword8_num))`;

val _ = Define `
 ((Tword8array:t)=  (Tapp [] Tword8array_num))`;


(* Check that the free type variables are in the given list. Every deBruijn
 * variable must be smaller than the first argument. So if it is 0, no deBruijn
 * indices are permitted. *)
(*val check_freevars : nat -> list tvarN -> t -> bool*)
 val check_freevars_defn = Defn.Hol_multi_defns `

((check_freevars:num ->(string)list -> t -> bool) dbmax tvs (Tvar tv)=
   (MEM tv tvs))
/\
((check_freevars:num ->(string)list -> t -> bool) dbmax tvs (Tapp ts tn)=
   (EVERY (check_freevars dbmax tvs) ts))
/\
((check_freevars:num ->(string)list -> t -> bool) dbmax tvs (Tvar_db n)=  (n < dbmax))`;

val _ = Lib.with_flag (computeLib.auto_import_definitions, false) (List.map Defn.save_defn) check_freevars_defn;

(*val check_freevars_ast : list tvarN -> ast_t -> bool*)
 val check_freevars_ast_defn = Defn.Hol_multi_defns `

((check_freevars_ast:(string)list -> ast_t -> bool) tvs (Atvar tv)=
   (MEM tv tvs))
/\
((check_freevars_ast:(string)list -> ast_t -> bool) tvs (Attup ts)=
   (EVERY (check_freevars_ast tvs) ts))
/\
((check_freevars_ast:(string)list -> ast_t -> bool) tvs (Atfun t1 t2)=
   (check_freevars_ast tvs t1 /\ check_freevars_ast tvs t2))
/\
((check_freevars_ast:(string)list -> ast_t -> bool) tvs (Atapp ts tn)=
   (EVERY (check_freevars_ast tvs) ts))`;

val _ = Lib.with_flag (computeLib.auto_import_definitions, false) (List.map Defn.save_defn) check_freevars_ast_defn;

(* Simultaneous substitution of types for type variables in a type *)
(*val type_subst : Map.map tvarN t -> t -> t*)
 val type_subst_defn = Defn.Hol_multi_defns `

((type_subst:((string),(t))fmap -> t -> t) s (Tvar tv)=
   ((case FLOOKUP s tv of
      NONE => Tvar tv
    | SOME(t) => t
  )))
/\
((type_subst:((string),(t))fmap -> t -> t) s (Tapp ts tn)=
   (Tapp (MAP (type_subst s) ts) tn))
/\
((type_subst:((string),(t))fmap -> t -> t) s (Tvar_db n)=  (Tvar_db n))`;

val _ = Lib.with_flag (computeLib.auto_import_definitions, false) (List.map Defn.save_defn) type_subst_defn;

(* Increment the deBruijn indices in a type by n levels, skipping all levels
 * less than skip. *)
(*val deBruijn_inc : nat -> nat -> t -> t*)
 val deBruijn_inc_defn = Defn.Hol_multi_defns `

((deBruijn_inc:num -> num -> t -> t) skip n (Tvar tv)=  (Tvar tv))
/\
((deBruijn_inc:num -> num -> t -> t) skip n (Tvar_db m)=
   (if m < skip then
    Tvar_db m
  else
    Tvar_db (m + n)))
/\
((deBruijn_inc:num -> num -> t -> t) skip n (Tapp ts tn)=  (Tapp (MAP (deBruijn_inc skip n) ts) tn))`;

val _ = Lib.with_flag (computeLib.auto_import_definitions, false) (List.map Defn.save_defn) deBruijn_inc_defn;

(* skip the lowest given indices and replace the next (LENGTH ts) with the
  given types and reduce all the higher ones *)
(*val deBruijn_subst : nat -> list t -> t -> t*)
 val deBruijn_subst_defn = Defn.Hol_multi_defns `

((deBruijn_subst:num ->(t)list -> t -> t) skip ts (Tvar tv)=  (Tvar tv))
/\
((deBruijn_subst:num ->(t)list -> t -> t) skip ts (Tvar_db n)=
   (if ~ (n < skip) /\ (n < (LENGTH ts + skip)) then
    EL (n - skip) ts
  else if ~ (n < skip) then
    Tvar_db (n - LENGTH ts)
  else
    Tvar_db n))
/\
((deBruijn_subst:num ->(t)list -> t -> t) skip ts (Tapp ts' tn)=
   (Tapp (MAP (deBruijn_subst skip ts) ts') tn))`;

val _ = Lib.with_flag (computeLib.auto_import_definitions, false) (List.map Defn.save_defn) deBruijn_subst_defn;

(* Type environments *)
val _ = Hol_datatype `
 tenv_val_exp =
    Empty
  (* Binds several de Bruijn type variables *)
  | Bind_tvar of num => tenv_val_exp
  (* The number is how many de Bruijn type variables the typescheme binds *)
  | Bind_name of varN => num => t => tenv_val_exp`;


(*val bind_tvar : nat -> tenv_val_exp -> tenv_val_exp*)
val _ = Define `
 ((bind_tvar:num -> tenv_val_exp -> tenv_val_exp) tvs tenvE=  (if tvs =( 0 : num) then tenvE else Bind_tvar tvs tenvE))`;


(*val opt_bind_name : maybe varN -> nat -> t -> tenv_val_exp -> tenv_val_exp*)
val _ = Define `
 ((opt_bind_name:(string)option -> num -> t -> tenv_val_exp -> tenv_val_exp) n tvs t tenvE=
   ((case n of
      NONE => tenvE
    | SOME n' => Bind_name n' tvs t tenvE
  )))`;


(*val tveLookup : varN -> nat -> tenv_val_exp -> maybe (nat * t)*)
 val _ = Define `

((tveLookup:string -> num -> tenv_val_exp ->(num#t)option) n inc Empty=  NONE)
/\
((tveLookup:string -> num -> tenv_val_exp ->(num#t)option) n inc (Bind_tvar tvs tenvE)=  (tveLookup n (inc + tvs) tenvE))
/\
((tveLookup:string -> num -> tenv_val_exp ->(num#t)option) n inc (Bind_name n' tvs t tenvE)=
   (if n' = n then
    SOME (tvs, deBruijn_inc tvs inc t)
  else
    tveLookup n inc tenvE))`;


val _ = type_abbrev( "tenv_abbrev" , ``: (modN, typeN, ( tvarN list # t)) namespace``);
val _ = type_abbrev( "tenv_ctor" , ``: (modN, conN, ( tvarN list # t list # type_ident)) namespace``);
val _ = type_abbrev( "tenv_val" , ``: (modN, varN, (num # t)) namespace``);

val _ = Hol_datatype `
 type_env =
  <| v : tenv_val
   ; c : tenv_ctor
   ; t : tenv_abbrev
   ; s : (modN, sigN, ( type_ident list # ( tvarN list # type_ident) list # type_env)) namespace
   |>`;


(* A signature is a type_env containing the things specified in the signature,
   paired with two lists of type_identifiers that the signature generated. The
   first for datatypes, and the second for opaque types. Where the signature is
   used, the first should be replaced with real type identifiers that are valid
   at the usage site, and the second with real types valid at the usage site. *)
val _ = type_abbrev( "signature" , ``: type_ident list # ( tvarN list # type_ident) list # type_env``);
val _ = type_abbrev( "tenv_sig" , ``: (modN, sigN, signature) namespace``);

(*val extend_dec_tenv : type_env -> type_env -> type_env*)
val _ = Define `
 ((extend_dec_tenv:type_env -> type_env -> type_env) tenv' tenv=
   (<| v := (nsAppend tenv'.v tenv.v);
     c := (nsAppend tenv'.c tenv.c);
     t := (nsAppend tenv'.t tenv.t);
     s := (nsAppend tenv'.s tenv.s) |>))`;


(*val lookup_varE : id modN varN -> tenv_val_exp -> maybe (nat * t)*)
val _ = Define `
 ((lookup_varE:((string),(string))id -> tenv_val_exp ->(num#t)option) id tenvE=
   ((case id of
    Short x => tveLookup x(( 0 : num)) tenvE
  | _ => NONE
  )))`;


(*val lookup_var : id modN varN -> tenv_val_exp -> type_env -> maybe (nat * t)*)
val _ = Define `
 ((lookup_var:((modN),(varN))id -> tenv_val_exp -> type_env ->(num#t)option) id tenvE tenv=
   ((case lookup_varE id tenvE of
    SOME x => SOME x
  | NONE => nsLookup tenv.v id
  )))`;


(*val num_tvs : tenv_val_exp -> nat*)
 val _ = Define `

((num_tvs:tenv_val_exp -> num) Empty= (( 0 : num)))
/\
((num_tvs:tenv_val_exp -> num) (Bind_tvar tvs tenvE)=  (tvs + num_tvs tenvE))
/\
((num_tvs:tenv_val_exp -> num) (Bind_name n tvs t tenvE)=  (num_tvs tenvE))`;


(*val bind_var_list : nat -> list (varN * t) -> tenv_val_exp -> tenv_val_exp*)
 val _ = Define `

((bind_var_list:num ->(string#t)list -> tenv_val_exp -> tenv_val_exp) tvs [] tenvE=  tenvE)
/\
((bind_var_list:num ->(string#t)list -> tenv_val_exp -> tenv_val_exp) tvs ((n,t)::binds) tenvE=
   (Bind_name n tvs t (bind_var_list tvs binds tenvE)))`;


(* Substitute for the type_identifiers in a type with other type identifiers
 * (subst1) and types (subst2) *)
(*val type_ident_subst : Map.map type_ident type_ident -> Map.map type_ident (list tvarN * t) -> t -> t*)
 val type_ident_subst_defn = Defn.Hol_multi_defns `
 ((type_ident_subst:((num),(num))fmap ->((num),((string)list#t))fmap -> t -> t) subst1 subst2 (Tvar tv)=  (Tvar tv))
/\ ((type_ident_subst:((num),(num))fmap ->((num),((string)list#t))fmap -> t -> t) subst1 subst2 (Tvar_db v)=  (Tvar_db v))
/\ ((type_ident_subst:((num),(num))fmap ->((num),((string)list#t))fmap -> t -> t) subst1 subst2 (Tapp ts tid)=
   (let ts' = (MAP (type_ident_subst subst1 subst2) ts) in
  (case FLOOKUP subst1 tid of
    NONE =>
    (case FLOOKUP subst2 tid of
      NONE => Tapp ts' tid
    | SOME (tvs,t) => type_subst (FUPDATE_LIST FEMPTY (ZIP (tvs, ts'))) t
    )
  | SOME tid' => Tapp ts' tid'
  )))`;

val _ = Lib.with_flag (computeLib.auto_import_definitions, false) (List.map Defn.save_defn) type_ident_subst_defn;

(* Instantiate a signature with the given substitutions for its datatype and
 * opaque type identifiers *)
(*val sig_instantiate : Map.map type_ident type_ident ->
            Map.map type_ident (list tvarN * t) -> type_env -> type_env*)
val _ = Define `
 ((sig_instantiate:((type_ident),(type_ident))fmap ->((type_ident),((tvarN)list#t))fmap -> type_env -> type_env) subst1 subst2 tenv=
   (<| v := (nsMap (\ (tvs, t) .  (tvs, type_ident_subst subst1 subst2 t)) tenv.v);
     c := (nsMap (\ (tvs, ts, tid) . 
       (tvs, MAP (type_ident_subst subst1 subst2) ts,
        (case FLOOKUP subst1 tid of
          NONE => tid
        | SOME tid' => tid'
        ))) tenv.c);
     t := (nsMap (\ (tvs, t) .  (tvs, type_ident_subst subst1 subst2 t)) tenv.t);
     (* The following will need updating once we support nested signatures *)
     s := (tenv.s) |>))`;


(* A pattern matches values of a certain type and extends the type environment
 * with the pattern's binders. The number is the maximum deBruijn type variable
 * allowed. *)
(*val type_p : nat -> type_env -> pat -> t -> list (varN * t) -> bool*)

(* An expression has a type *)
(*val type_e : type_env -> tenv_val_exp -> exp -> t -> bool*)

(* A list of expressions has a list of types *)
(*val type_es : type_env -> tenv_val_exp -> list exp -> list t -> bool*)

(* Type a mutually recursive bundle of functions.  Unlike pattern typing, the
 * resulting environment does not extend the input environment, but just
 * represents the functions *)
(*val type_funs : type_env -> tenv_val_exp -> list (varN * varN * exp) -> list (varN * t) -> bool*)

(* Check a declaration and update the top-level environments
 * The arguments are in order:
 * - whether to do extra checks
 * - the type environment
 * - the declaration
 * - the set of type identity stamps defined here
 * - the environment of new stuff declared here *)

(*val type_d : bool -> type_env -> dec -> set nat -> type_env -> bool*)
(*val type_ds : bool -> type_env -> list dec -> set nat -> type_env -> bool*)

(* Check that the operator can have type (t1 -> ... -> tn -> t) *)
(*val type_op : op -> list t -> t -> bool*)
val _ = Define `
 ((type_op:op ->(t)list -> t -> bool) op ts t=
   ((case (op,ts) of
      (Opapp, [t1; t2]) => t1 = Tfn t2 t
    | (Opn _, [t1; t2]) => (t1 = Tint) /\ (t2 = Tint) /\ (t = Tint)
    | (Opb _, [t1; t2]) => (t1 = Tint) /\ (t2 = Tint) /\ (t = Tbool)
    | (Opw W8 _, [t1; t2]) => (t1 = Tword8) /\ (t2 = Tword8) /\ (t = Tword8)
    | (Opw W64 _, [t1; t2]) => (t1 = Tword64) /\ (t2 = Tword64) /\ (t = Tword64)
    | (FP_top _, [t1; t2; t3]) => (t1 = Tword64) /\ (t2 = Tword64) /\ (t3 = Tword64) /\ (t = Tword64)
    | (FP_bop _, [t1; t2]) => (t1 = Tword64) /\ (t2 = Tword64) /\ (t = Tword64)
    | (FP_uop _, [t1]) =>  (t1 = Tword64) /\ (t = Tword64)
    | (FP_cmp _, [t1; t2]) =>  (t1 = Tword64) /\ (t2 = Tword64) /\ (t = Tbool)
    | (Shift W8 _ _, [t1]) => (t1 = Tword8) /\ (t = Tword8)
    | (Shift W64 _ _, [t1]) => (t1 = Tword64) /\ (t = Tword64)
    | (Equality, [t1; t2]) => (t1 = t2) /\ (t = Tbool)
    | (Opassign, [t1; t2]) => (t1 = Tref t2) /\ (t = Ttup [])
    | (Opref, [t1]) => t = Tref t1
    | (Opderef, [t1]) => t1 = Tref t
    | (Aw8alloc, [t1; t2]) => (t1 = Tint) /\ (t2 = Tword8) /\ (t = Tword8array)
    | (Aw8sub, [t1; t2]) => (t1 = Tword8array) /\ (t2 = Tint) /\ (t = Tword8)
    | (Aw8length, [t1]) => (t1 = Tword8array) /\ (t = Tint)
    | (Aw8update, [t1; t2; t3]) => (t1 = Tword8array) /\ (t2 = Tint) /\ (t3 = Tword8) /\ (t = Ttup [])
    | (WordFromInt W8, [t1]) => (t1 = Tint) /\ (t = Tword8)
    | (WordToInt W8, [t1]) => (t1 = Tword8) /\ (t = Tint)
    | (WordFromInt W64, [t1]) => (t1 = Tint) /\ (t = Tword64)
    | (WordToInt W64, [t1]) => (t1 = Tword64) /\ (t = Tint)
    | (CopyStrStr, [t1; t2; t3]) => (t1 = Tstring) /\ (t2 = Tint) /\ (t3 = Tint) /\ (t = Tstring)
    | (CopyStrAw8, [t1; t2; t3; t4; t5]) =>
      (t1 = Tstring) /\ (t2 = Tint) /\ (t3 = Tint) /\ (t4 = Tword8array) /\ (t5 = Tint) /\ (t = Ttup [])
    | (CopyAw8Str, [t1; t2; t3]) => (t1 = Tword8array) /\ (t2 = Tint) /\ (t3 = Tint) /\ (t = Tstring)
    | (CopyAw8Aw8, [t1; t2; t3; t4; t5]) =>
      (t1 = Tword8array) /\ (t2 = Tint) /\ (t3 = Tint) /\ (t4 = Tword8array) /\ (t5 = Tint) /\ (t = Ttup [])
    | (Chr, [t1]) => (t1 = Tint) /\ (t = Tchar)
    | (Ord, [t1]) => (t1 = Tchar) /\ (t = Tint)
    | (Chopb _, [t1; t2]) => (t1 = Tchar) /\ (t2 = Tchar) /\ (t = Tbool)
    | (Implode, [t1]) => (t1 = Tlist Tchar) /\ (t = Tstring)
    | (Explode, [t1]) => (t1 = Tstring) /\ (t = Tlist Tchar)
    | (Strsub, [t1; t2]) => (t1 = Tstring) /\ (t2 = Tint) /\ (t = Tchar)
    | (Strlen, [t1]) => (t1 = Tstring) /\ (t = Tint)
    | (Strcat, [t1]) => (t1 = Tlist Tstring) /\ (t = Tstring)
    | (VfromList, [Tapp [t1] ctor]) => (ctor = Tlist_num) /\ (t = Tvector t1)
    | (Vsub, [t1; t2]) => (t2 = Tint) /\ (Tvector t = t1)
    | (Vlength, [Tapp [t1] ctor]) => (ctor = Tvector_num) /\ (t = Tint)
    | (Aalloc, [t1; t2]) => (t1 = Tint) /\ (t = Tarray t2)
    | (AallocEmpty, [t1]) => (t1 = Ttup []) /\ (? t2. t = Tarray t2)
    | (Asub, [t1; t2]) => (t2 = Tint) /\ (Tarray t = t1)
    | (Alength, [Tapp [t1] ctor]) => (ctor = Tarray_num) /\ (t = Tint)
    | (Aupdate, [t1; t2; t3]) => (t1 = Tarray t3) /\ (t2 = Tint) /\ (t = Ttup [])
    | (ConfigGC, [t1;t2]) => (t1 = Tint) /\ (t2 = Tint) /\ (t = Ttup [])
    | (FFI n, [t1;t2]) => (t1 = Tstring) /\ (t2 = Tword8array) /\ (t = Ttup [])
    | (ListAppend, [Tapp [t1] ctor; t2]) => (ctor = Tlist_num) /\ (t2 = Tapp [t1] ctor) /\ (t = t2)
    | _ => F
  )))`;


(* Check that the names of type constructors in an AST type are defined *)
(*val check_type_names : tenv_abbrev -> ast_t -> bool*)
 val check_type_names_defn = Defn.Hol_multi_defns `

((check_type_names:((string),(string),((string)list#t))namespace -> ast_t -> bool) tenvT (Atvar tv)=
   T)
/\
((check_type_names:((string),(string),((string)list#t))namespace -> ast_t -> bool) tenvT (Attup ts)=
   (EVERY (check_type_names tenvT) ts))
/\
((check_type_names:((string),(string),((string)list#t))namespace -> ast_t -> bool) tenvT (Atfun t1 t2)=
   (check_type_names tenvT t1 /\ check_type_names tenvT t2))
/\
((check_type_names:((string),(string),((string)list#t))namespace -> ast_t -> bool) tenvT (Atapp ts tn)=
   ((case nsLookup tenvT tn of
    SOME (tvs, _) => LENGTH tvs = LENGTH ts
  | NONE => F
  ) /\
  EVERY (check_type_names tenvT) ts))`;

val _ = Lib.with_flag (computeLib.auto_import_definitions, false) (List.map Defn.save_defn) check_type_names_defn;

(* Substitution of type names for the type they abbreviate *)
(*val type_name_subst : tenv_abbrev -> ast_t -> t*)
 val type_name_subst_defn = Defn.Hol_multi_defns `

((type_name_subst:((string),(string),((string)list#t))namespace -> ast_t -> t) tenvT (Atvar tv)=  (Tvar tv))
/\
((type_name_subst:((string),(string),((string)list#t))namespace -> ast_t -> t) tenvT (Attup ts)=
   (Ttup (MAP (type_name_subst tenvT) ts)))
/\
((type_name_subst:((string),(string),((string)list#t))namespace -> ast_t -> t) tenvT (Atfun t1 t2)=
   (Tfn (type_name_subst tenvT t1) (type_name_subst tenvT t2)))
/\
((type_name_subst:((string),(string),((string)list#t))namespace -> ast_t -> t) tenvT (Atapp ts tc)=
   (let args = (MAP (type_name_subst tenvT) ts) in
  (case nsLookup tenvT tc of
    SOME (tvs, t) => type_subst (alist_to_fmap (ZIP (tvs, args))) t
  | NONE => Ttup args (* can't happen, for a type that passes the check *)
  )))`;

val _ = Lib.with_flag (computeLib.auto_import_definitions, false) (List.map Defn.save_defn) type_name_subst_defn;

(* Check that a type definition defines no already defined types or duplicate
 * constructors, and that the free type variables of each constructor argument
 * type are included in the type's type parameters. Also check that all of the
 * types mentioned are in scope. *)
(*val check_ctor_tenv : tenv_abbrev -> list (list tvarN * typeN * list (conN * list ast_t)) -> bool*)
 val _ = Define `
 ((check_ctor_tenv:((modN),(typeN),((tvarN)list#t))namespace ->((tvarN)list#string#(conN#(ast_t)list)list)list -> bool) tenvT []=  T)
/\ ((check_ctor_tenv:((modN),(typeN),((tvarN)list#t))namespace ->((tvarN)list#string#(conN#(ast_t)list)list)list -> bool) tenvT ((tvs,tn,ctors)::tds)=
   (check_dup_ctors (tvs,tn,ctors) /\
  ALL_DISTINCT tvs /\
  EVERY
    (\ (cn,ts) .  EVERY (check_freevars_ast tvs) ts /\ EVERY (check_type_names tenvT) ts)
    ctors /\
  ~ (MEM tn (MAP (\p .
  (case (p ) of ( (_,tn,_) ) => tn )) tds)) /\
  check_ctor_tenv tenvT tds))`;


(*val build_ctor_tenv : tenv_abbrev -> list (list tvarN * typeN * list (conN * list ast_t)) -> list nat -> tenv_ctor*)
 val _ = Define `
 ((build_ctor_tenv:((modN),(typeN),((tvarN)list#t))namespace ->((tvarN)list#string#(string#(ast_t)list)list)list ->(num)list ->((string),(string),((tvarN)list#(t)list#num))namespace) tenvT [] []=  (alist_to_ns []))
/\ ((build_ctor_tenv:((modN),(typeN),((tvarN)list#t))namespace ->((tvarN)list#string#(string#(ast_t)list)list)list ->(num)list ->((string),(string),((tvarN)list#(t)list#num))namespace) tenvT ((tvs,tn,ctors)::tds) (id::ids)=
   (nsAppend
    (build_ctor_tenv tenvT tds ids)
    (alist_to_ns
      (REVERSE
        (MAP
          (\ (cn,ts) .  (cn,(tvs,MAP (type_name_subst tenvT) ts, id)))
          ctors)))))
/\ ((build_ctor_tenv:((modN),(typeN),((tvarN)list#t))namespace ->((tvarN)list#string#(string#(ast_t)list)list)list ->(num)list ->((string),(string),((tvarN)list#(t)list#num))namespace) tenvT _ _=  (alist_to_ns []))`;


(* For the value restriction on let-based polymorphism *)
(*val is_value : exp -> bool*)
 val is_value_defn = Defn.Hol_multi_defns `

((is_value:exp -> bool) (Lit _)=  T)
/\
((is_value:exp -> bool) (Con _ es)=  (EVERY is_value es))
/\
((is_value:exp -> bool) (Var _)=  T)
/\
((is_value:exp -> bool) (Fun _ _)=  T)
/\
((is_value:exp -> bool) (Tannot e _)=  (is_value e))
/\
((is_value:exp -> bool) (Lannot e _)=  (is_value e))
/\
((is_value:exp -> bool) _=  F)`;

val _ = Lib.with_flag (computeLib.auto_import_definitions, false) (List.map Defn.save_defn) is_value_defn;

val _ = Hol_reln ` (! tvs tenv t.
(check_freevars tvs [] t)
==>
type_p tvs tenv Pany t [])

/\ (! tvs tenv n t.
(check_freevars tvs [] t)
==>
type_p tvs tenv (Pvar n) t [(n,t)])

/\ (! tvs tenv n.
T
==>
type_p tvs tenv (Plit (IntLit n)) Tint [])

/\ (! tvs tenv c.
T
==>
type_p tvs tenv (Plit (Char c)) Tchar [])

/\ (! tvs tenv s.
T
==>
type_p tvs tenv (Plit (StrLit s)) Tstring [])

/\ (! tvs tenv w.
T
==>
type_p tvs tenv (Plit (Word8 w)) Tword8 [])

/\ (! tvs tenv w.
T
==>
type_p tvs tenv (Plit (Word64 w)) Tword64 [])

/\ (! tvs tenv cn ps ts tvs' tn ts' bindings.
(EVERY (check_freevars tvs []) ts' /\
(LENGTH ts' = LENGTH tvs') /\
type_ps tvs tenv ps (MAP (type_subst (alist_to_fmap (ZIP (tvs', ts')))) ts) bindings /\
(nsLookup tenv.c cn = SOME (tvs', ts, tn)))
==>
type_p tvs tenv (Pcon (SOME cn) ps) (Tapp ts' tn) bindings)

/\ (! tvs tenv ps ts bindings.
(type_ps tvs tenv ps ts bindings)
==>
type_p tvs tenv (Pcon NONE ps) (Ttup ts) bindings)

/\ (! tvs tenv p t bindings.
(type_p tvs tenv p t bindings)
==>
type_p tvs tenv (Pref p) (Tref t) bindings)

/\ (! tvs tenv p t bindings.
(check_freevars_ast [] t /\
check_type_names tenv.t t /\
type_p tvs tenv p (type_name_subst tenv.t t) bindings)
==>
type_p tvs tenv (Ptannot p t) (type_name_subst tenv.t t) bindings)

/\ (! tvs tenv.
T
==>
type_ps tvs tenv [] [] [])

/\ (! tvs tenv p ps t ts bindings bindings'.
(type_p tvs tenv p t bindings /\
type_ps tvs tenv ps ts bindings')
==>
type_ps tvs tenv (p::ps) (t::ts) (bindings'++bindings))`;

val _ = Hol_reln ` (! tenv tenvE n.
T
==>
type_e tenv tenvE (Lit (IntLit n)) Tint)

/\ (! tenv tenvE c.
T
==>
type_e tenv tenvE (Lit (Char c)) Tchar)

/\ (! tenv tenvE s.
T
==>
type_e tenv tenvE (Lit (StrLit s)) Tstring)

/\ (! tenv tenvE w.
T
==>
type_e tenv tenvE (Lit (Word8 w)) Tword8)

/\ (! tenv tenvE w.
T
==>
type_e tenv tenvE (Lit (Word64 w)) Tword64)

/\ (! tenv tenvE e t.
(check_freevars (num_tvs tenvE) [] t /\
type_e tenv tenvE e Texn)
==>
type_e tenv tenvE (Raise e) t)


/\ (! tenv tenvE e pes t.
(type_e tenv tenvE e t /\ ~ (pes = []) /\
(! ((p,e) :: LIST_TO_SET pes). ? bindings.
   ALL_DISTINCT (pat_bindings p []) /\
   type_p (num_tvs tenvE) tenv p Texn bindings /\
   type_e tenv (bind_var_list(( 0 : num)) bindings tenvE) e t))
==>
type_e tenv tenvE (Handle e pes) t)

/\ (! tenv tenvE cn es tvs tn ts' ts.
(EVERY (check_freevars (num_tvs tenvE) []) ts' /\
(LENGTH tvs = LENGTH ts') /\
type_es tenv tenvE es (MAP (type_subst (alist_to_fmap (ZIP (tvs, ts')))) ts) /\
(nsLookup tenv.c cn = SOME (tvs, ts, tn)))
==>
type_e tenv tenvE (Con (SOME cn) es) (Tapp ts' tn))

/\ (! tenv tenvE es ts.
(type_es tenv tenvE es ts)
==>
type_e tenv tenvE (Con NONE es) (Ttup ts))

/\ (! tenv tenvE n t targs tvs.
((tvs = LENGTH targs) /\
EVERY (check_freevars (num_tvs tenvE) []) targs /\
(lookup_var n tenvE tenv = SOME (tvs,t)))
==>
type_e tenv tenvE (Var n) (deBruijn_subst(( 0 : num)) targs t))

/\ (! tenv tenvE n e t1 t2.
(check_freevars (num_tvs tenvE) [] t1 /\
type_e tenv (Bind_name n(( 0 : num)) t1 tenvE) e t2)
==>
type_e tenv tenvE (Fun n e) (Tfn t1 t2))

/\ (! tenv tenvE op es ts t.
(type_es tenv tenvE es ts /\
type_op op ts t /\
check_freevars (num_tvs tenvE) [] t)
==>
type_e tenv tenvE (App op es) t)

/\ (! tenv tenvE l e1 e2.
(type_e tenv tenvE e1 Tbool /\
type_e tenv tenvE e2 Tbool)
==>
type_e tenv tenvE (Log l e1 e2) Tbool)

/\ (! tenv tenvE e1 e2 e3 t.
(type_e tenv tenvE e1 Tbool /\
type_e tenv tenvE e2 t /\
type_e tenv tenvE e3 t)
==>
type_e tenv tenvE (If e1 e2 e3) t)

/\ (! tenv tenvE e pes t1 t2.
(type_e tenv tenvE e t1 /\ ~ (pes = []) /\
(! ((p,e) :: LIST_TO_SET pes) . ? bindings.
   ALL_DISTINCT (pat_bindings p []) /\
   type_p (num_tvs tenvE) tenv p t1 bindings /\
   type_e tenv (bind_var_list(( 0 : num)) bindings tenvE) e t2))
==>
type_e tenv tenvE (Mat e pes) t2)

/\ (! tenv tenvE n e1 e2 t1 t2.
(type_e tenv tenvE e1 t1 /\
type_e tenv (opt_bind_name n(( 0 : num)) t1 tenvE) e2 t2)
==>
type_e tenv tenvE (Let n e1 e2) t2)

(*
and

letrec : forall tenv tenvE funs e t tenv' tvs.
type_funs tenv (bind_var_list 0 tenv' (bind_tvar tvs tenvE)) funs tenv' &&
type_e tenv (bind_var_list tvs tenv' tenvE) e t
==>
type_e tenv tenvE (Letrec funs e) t
*)

/\ (! tenv tenvE funs e t bindings.
(type_funs tenv (bind_var_list(( 0 : num)) bindings tenvE) funs bindings /\
type_e tenv (bind_var_list(( 0 : num)) bindings tenvE) e t)
==>
type_e tenv tenvE (Letrec funs e) t)

/\ (! tenv tenvE e t.
(check_freevars_ast [] t /\
check_type_names tenv.t t /\
type_e tenv tenvE e (type_name_subst tenv.t t))
==>
type_e tenv tenvE (Tannot e t) (type_name_subst tenv.t t))

/\ (! tenv tenvE e l t.
(type_e tenv tenvE e t)
==>
type_e tenv tenvE (Lannot e l) t)

/\ (! tenv tenvE.
T
==>
type_es tenv tenvE [] [])

/\ (! tenv tenvE e es t ts.
(type_e tenv tenvE e t /\
type_es tenv tenvE es ts)
==>
type_es tenv tenvE (e::es) (t::ts))

/\ (! tenv tenvE.
T
==>
type_funs tenv tenvE [] [])

/\ (! tenv tenvE fn n e funs bindings t1 t2.
(check_freevars (num_tvs tenvE) [] (Tfn t1 t2) /\
type_e tenv (Bind_name n(( 0 : num)) t1 tenvE) e t2 /\
type_funs tenv tenvE funs bindings /\
(ALOOKUP bindings fn = NONE))
==>
type_funs tenv tenvE ((fn, n, e)::funs) ((fn, Tfn t1 t2)::bindings))`;

(*val tenv_add_tvs : nat -> alist varN t -> alist varN (nat * t)*)
val _ = Define `
 ((tenv_add_tvs:num ->(string#t)list ->(string#(num#t))list) tvs bindings=
   (MAP (\ (n,t) .  (n,(tvs,t))) bindings))`;


(*val type_pe_determ : type_env -> tenv_val_exp -> pat -> exp -> bool*)
val _ = Define `
 ((type_pe_determ:type_env -> tenv_val_exp -> pat -> exp -> bool) tenv tenvE p e=
   (! t1 tenv1 t2 tenv2.
    (type_p(( 0 : num)) tenv p t1 tenv1 /\ type_e tenv tenvE e t1 /\
    type_p(( 0 : num)) tenv p t2 tenv2 /\ type_e tenv tenvE e t2)
    ==>
    (tenv1 = tenv2)))`;


(* Check whether the second type scheme can be instantiated to be the first *)
(*val tscheme_inst : (nat * t) -> (nat * t) -> bool*)
val _ = Define `
 ((tscheme_inst:num#t -> num#t -> bool) (tvs_spec, t_spec) (tvs_impl, t_impl)=
   (? subst.
    (LENGTH subst = tvs_impl) /\
    check_freevars tvs_impl [] t_impl /\
    EVERY (check_freevars tvs_spec []) subst /\
    (deBruijn_subst(( 0 : num)) subst t_impl = t_spec)))`;


val _ = Define `
 ((tenvLift:string -> type_env -> type_env) mn tenv=
   (<| v := (nsLift mn tenv.v); c := (nsLift mn tenv.c); t := (nsLift mn tenv.t);
     s := (nsLift mn tenv.s) |>))`;


(*val type_tdefs : type_env -> type_def -> list type_ident -> maybe type_env*)
val _ = Define `
 ((type_tdefs:type_env ->((string)list#string#(conN#(ast_t)list)list)list ->(num)list ->(type_env)option) tenv tdef tids=
   (if (LENGTH tids = LENGTH tdef) /\
     ALL_DISTINCT tids /\
     DISJOINT (LIST_TO_SET tids)
              (LIST_TO_SET (Tlist_num :: (Tbool_num :: prim_type_nums)))
  then
    let tenvT =
      (alist_to_ns (MAP2 (\ (tvs,tn,ctors) i .  (tn, (tvs, Tapp (MAP Tvar tvs) i)))
                      tdef tids))
    in
    if check_ctor_tenv (nsAppend tenvT tenv.t) tdef then
      SOME <| v := nsEmpty;
              c := (build_ctor_tenv (nsAppend tenvT tenv.t) tdef tids);
              t := tenvT;
              s := nsEmpty |>
    else
      NONE
  else
    NONE))`;


val _ = Define `
 ((tscheme_inst2:'a -> num#t -> num#t -> bool) _ ts1 ts2=  (tscheme_inst ts1 ts2))`;


val _ = Define `
 ((ctor_inst:'b ->(string)list#(t)list#'a ->(string)list#(t)list#'a -> bool) _ (tvs_spec, ts_spec, tid_spec) (tvs_impl, ts_impl, tid_impl)=
   ((tid_spec = tid_impl) /\
  (LENGTH tvs_spec = LENGTH tvs_impl) /\
  (let subst = (FUPDATE_LIST FEMPTY (ZIP (tvs_impl, (MAP Tvar tvs_spec)))) in
    ts_spec = MAP (type_subst subst) ts_impl)))`;


val _ = Define `
 ((type_def_inst:'a ->(string)list#t ->(string)list#t -> bool) _ (tvs_spec, t_spec) (tvs_impl, t_impl)=
   ((LENGTH tvs_spec = LENGTH tvs_impl) /\
  (let subst = (FUPDATE_LIST FEMPTY (ZIP (tvs_impl, (MAP Tvar tvs_spec)))) in
    t_spec = type_subst subst t_impl)))`;


(* Will need to add something for nested signature declarations *)
(*val weak_tenv : type_env -> type_env -> bool*)
val _ = Define `
 ((weak_tenv:type_env -> type_env -> bool) tenv_impl tenv_spec=
   (nsSub tscheme_inst2 tenv_spec.v tenv_impl.v /\
  nsSub ctor_inst tenv_spec.c tenv_impl.c /\
  nsSub type_def_inst tenv_spec.t tenv_impl.t))`;


(* Checks whether the tids' can be substituted for the tids in tenv to form
  tenv'. *)
(*val sig_rename_tids : signature -> signature -> bool*)
val _ = Define `
 ((sig_rename_tids:(num)list#((string)list#num)list#type_env ->(num)list#((string)list#num)list#type_env -> bool) (datatype_tids, opaque_tids, tenv)
                    (datatype_tids', opaque_tids', tenv')=
   ((LENGTH datatype_tids = LENGTH datatype_tids') /\
  (LENGTH opaque_tids = LENGTH opaque_tids') /\
  ALL_DISTINCT (datatype_tids' ++ MAP SND opaque_tids') /\
  (MAP FST opaque_tids = MAP FST opaque_tids') /\
  (tenv' =
   (sig_instantiate
    (alist_to_fmap (ZIP (datatype_tids, datatype_tids')))
    (alist_to_fmap (ZIP ((MAP SND opaque_tids), (MAP (\ (tvs, tid) .  (tvs, Tapp (MAP Tvar tvs) tid))
                   opaque_tids'))))
    tenv))))`;


(*val tenvLiftSig : modN -> signature -> signature*)
val _ = Define `
 ((tenvLiftSig:string ->(type_ident)list#((tvarN)list#type_ident)list#type_env ->(type_ident)list#((tvarN)list#type_ident)list#type_env) mn (ids1, ids2, tenv)=
   (ids1, ids2, tenvLift mn tenv))`;


val _ = Hol_reln ` (! tenv x t fvs subst.
(check_freevars_ast fvs t /\
check_type_names tenv.t t /\
(subst = alist_to_fmap (ZIP (fvs, (MAP Tvar_db (GENLIST (\ x .  x) (LENGTH fvs)))))))
==>
type_sp tenv (Sval x t)
  ([], [],
   <| v := (nsSing x (LENGTH fvs, type_subst subst (type_name_subst tenv.t t)));
      c := nsEmpty;
      t := nsEmpty;
      s := nsEmpty |>))

/\ (! tenv tdefs tids tenv'.
(type_tdefs tenv tdefs tids = SOME tenv')
==>
type_sp tenv (Stype tdefs) (tids, [], tenv'))

/\ (! tenv tvs tn type_ident.
T
==>
type_sp tenv (Stype_opq tvs tn)
  ([], [ (tvs, type_ident) ],
   <| v := nsEmpty;
      c := nsEmpty;
      t := (nsSing tn (tvs, Tapp (MAP Tvar tvs) type_ident));
      s := nsEmpty |>))

/\ (! tenv tvs tn t.
(check_freevars_ast tvs t /\
check_type_names tenv.t t /\
ALL_DISTINCT tvs)
==>
type_sp tenv (Stabbrev tvs tn t)
  ([], [],
   <| v := nsEmpty; c := nsEmpty;
      t := (nsSing tn (tvs,type_name_subst tenv.t t)); s := nsEmpty |>))

/\ (! tenv cn ts.
(EVERY (check_freevars_ast []) ts /\
EVERY (check_type_names tenv.t) ts)
==>
type_sp tenv (Sexn cn ts)
  ([], [],
   <| v := nsEmpty;
      c := (nsSing cn ([], MAP (type_name_subst tenv.t) ts, Texn_num));
      t := nsEmpty;
      s := nsEmpty |>))

/\ (! tenv mn sn signature signature'.
((nsLookup tenv.s sn = SOME signature) /\
sig_rename_tids signature signature')
==>
type_sp tenv (Smod mn sn) (tenvLiftSig mn signature'))

/\ (! tenv.
T
==>
type_sps tenv []
  ([],[], <| v := nsEmpty; c := nsEmpty; t := nsEmpty; s := nsEmpty |>))

/\ (! tenv sp sps tenv1 tenv2 datatype_tids1 datatype_tids2 opaque_tids1 opaque_tids2.
(type_sp tenv sp (datatype_tids1, opaque_tids1, tenv1) /\
type_sps (extend_dec_tenv tenv1 tenv) sps (datatype_tids1, opaque_tids1, tenv2) /\
DISJOINT (LIST_TO_SET (datatype_tids1 ++ MAP SND opaque_tids1))
         (LIST_TO_SET (datatype_tids2 ++ MAP SND opaque_tids2)))
==>
type_sps tenv (sp::sps)
  ((datatype_tids1 ++ datatype_tids2), (opaque_tids1 ++ opaque_tids2),
   extend_dec_tenv tenv2 tenv1))`;

(*val get_sig : type_env -> maybe (id modN sigN) -> signature -> maybe signature*)
val _ = Define `
 ((get_sig:type_env ->(((string),(string))id)option ->(type_ident)list#((tvarN)list#type_ident)list#type_env ->((type_ident)list#((tvarN)list#type_ident)list#type_env)option) tenv sn default=
   ((case sn of
    NONE => SOME default
  | SOME sn => nsLookup tenv.s sn
  )))`;


val _ = Hol_reln ` (! tids ts datatype_tids opaque_tids tenv_sig mod_tenv tenv_sig1.
((LENGTH datatype_tids = LENGTH tids) /\
(LENGTH opaque_tids = LENGTH ts) /\
(MAP FST opaque_tids = MAP FST ts) /\
EVERY (\ (tvs,t) .  (check_freevars(( 0 : num)) tvs t)) ts /\
ALL_DISTINCT tids /\
(tenv_sig1 = sig_instantiate
                   (alist_to_fmap (ZIP (datatype_tids, tids)))
                   (alist_to_fmap (ZIP ((MAP SND opaque_tids), ts)))
                   tenv_sig) /\
weak_tenv mod_tenv tenv_sig1)
==>
check_sig (datatype_tids, opaque_tids, tenv_sig) mod_tenv)`;

val _ = Hol_reln ` (! extra_checks tvs tenv p e t bindings locs.
(is_value e /\
ALL_DISTINCT (pat_bindings p []) /\
type_p tvs tenv p t bindings /\
type_e tenv (bind_tvar tvs Empty) e t /\
(extra_checks ==>
  (! tvs' bindings' t'.
    (type_p tvs' tenv p t' bindings' /\
    type_e tenv (bind_tvar tvs' Empty) e t') ==>
      EVERY2 tscheme_inst (MAP SND (tenv_add_tvs tvs' bindings')) (MAP SND (tenv_add_tvs tvs bindings)))))
==>
type_d extra_checks tenv (Dlet locs p e)
  {}
  <| v := (alist_to_ns (tenv_add_tvs tvs bindings)); c := nsEmpty; t := nsEmpty; s := nsEmpty |>)

/\ (! extra_checks tenv p e t bindings locs.
(
(* The following line makes sure that when the value restriction prohibits
   generalisation, a type error is given rather than picking an arbitrary
   instantiation. However, we should only do the check when the extra_checks
   argument tells us to. *)(extra_checks ==> (~ (is_value e) /\ type_pe_determ tenv Empty p e)) /\
ALL_DISTINCT (pat_bindings p []) /\
type_p(( 0 : num)) tenv p t bindings /\
type_e tenv Empty e t)
==>
type_d extra_checks tenv (Dlet locs p e)
  {} <| v := (alist_to_ns (tenv_add_tvs(( 0 : num)) bindings)); c := nsEmpty; t := nsEmpty; s := nsEmpty |>)

/\ (! extra_checks tenv funs bindings tvs locs.
(type_funs tenv (bind_var_list(( 0 : num)) bindings (bind_tvar tvs Empty)) funs bindings /\
(extra_checks ==>
  (! tvs' bindings'.
    type_funs tenv (bind_var_list(( 0 : num)) bindings' (bind_tvar tvs' Empty)) funs bindings' ==>
      EVERY2 tscheme_inst (MAP SND (tenv_add_tvs tvs' bindings')) (MAP SND (tenv_add_tvs tvs bindings)))))
==>
type_d extra_checks tenv (Dletrec locs funs)
  {} <| v := (alist_to_ns (tenv_add_tvs tvs bindings)); c := nsEmpty; t := nsEmpty; s := nsEmpty |>)

/\ (! extra_checks tenv tdefs tids tenv' locs.
(type_tdefs tenv tdefs tids = SOME tenv')
==>
type_d extra_checks tenv (Dtype locs tdefs) (LIST_TO_SET tids) tenv')

/\ (! extra_checks tenv tvs tn t locs.
(check_freevars_ast tvs t /\
check_type_names tenv.t t /\
ALL_DISTINCT tvs)
==>
type_d extra_checks tenv (Dtabbrev locs tvs tn t)
  {}
  <| v := nsEmpty; c := nsEmpty; t := (nsSing tn (tvs,type_name_subst tenv.t t)); s := nsEmpty |>)

/\ (! extra_checks tenv cn ts locs.
(EVERY (check_freevars_ast []) ts /\
EVERY (check_type_names tenv.t) ts)
==>
type_d extra_checks tenv (Dexn locs cn ts)
  {}
  <| v := nsEmpty;
     c := (nsSing cn ([], MAP (type_name_subst tenv.t) ts, Texn_num));
     t := nsEmpty;
     s := nsEmpty |>)

/\ (! extra_checks tenv mn sn_opt ds decls1 decls2 decls3 tenv' tenv_sig signature.
(type_ds extra_checks tenv ds (LIST_TO_SET decls1) tenv' /\
(get_sig tenv sn_opt (decls1, [], tenv') = SOME signature) /\
check_sig signature tenv' /\
sig_rename_tids signature (decls2, decls3, tenv_sig))
==>
type_d extra_checks tenv (Dmod mn sn_opt ds)
  (LIST_TO_SET decls2 UNION LIST_TO_SET (MAP SND decls3))
  (tenvLift mn tenv_sig))

/\ (! extra_checks tenv sn sps signature.
(type_sps tenv sps signature)
==>
type_d extra_checks tenv (Dsig sn sps) {}
  <| v := nsEmpty;
     c := nsEmpty;
     t := nsEmpty;
     s := (nsSing sn signature) |>)

/\ (! extra_checks tenv lds ds tenv1 tenv2 decls1 decls2.
(type_ds extra_checks tenv lds decls1 tenv1 /\
type_ds extra_checks (extend_dec_tenv tenv1 tenv) ds decls2 tenv2 /\
DISJOINT decls1 decls2)
==>
type_d extra_checks tenv (Dlocal lds ds) (decls1 UNION decls2) tenv2)

/\ (! extra_checks tenv.
T
==>
type_ds extra_checks tenv []
  {}
  <| v := nsEmpty; c := nsEmpty; t := nsEmpty; s := nsEmpty |>)

/\ (! extra_checks tenv d ds tenv1 tenv2 decls1 decls2.
(type_d extra_checks tenv d decls1 tenv1 /\
type_ds extra_checks (extend_dec_tenv tenv1 tenv) ds decls2 tenv2 /\
DISJOINT decls1 decls2)
==>
type_ds extra_checks tenv (d::ds)
  (decls1 UNION decls2) (extend_dec_tenv tenv2 tenv1))`;
val _ = export_theory()
