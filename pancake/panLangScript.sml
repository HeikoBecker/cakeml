(*
  The abstract syntax of Pancake language
  Pancake: an imperative language with loop statements,
  internal and external function calls and delay primitive
*)

open preamble
     mlstringTheory
     asmTheory            (* for binop and cmp *)
     backend_commonTheory (* for overloading the shift operation *);

val _ = new_theory "panLang";

Type shift = ``:ast$shift``

Type varname = ``:mlstring``

Type funname = ``:mlstring``

val _ = Datatype `
  exp = Const ('a word)
      | Var varname
      | Load exp
      | LoadByte exp
      | Op binop (exp list)
      | Cmp cmp exp exp
      | Shift shift exp num`


val _ = Datatype `
  ret = Tail
      | Ret varname
      | Handle varname varname prog; (* ret variable, excp variable *)

  prog = Skip
       | Assign    varname ('a exp)
       | Store     ('a exp) varname
       | StoreByte ('a exp) varname
       | Seq prog prog
       | If    ('a exp) prog prog
       | While ('a exp) prog
       | Break
       | Continue
       | Call ret ('a exp) (('a exp) list)
       (*  | ExtCall funname varname (('a exp) list) *)
       | ExtCall funname varname varname varname varname (* FFI name, conf_ptr, conf_len, array_ptr, array_len *)
       | Raise ('a exp)
       | Return ('a exp)
       | Tick
`;

(*
  Information for FFI:
  C types: bool, int, arrays (mutable/immuatable, w/wo length)
  arguments to be passed from pancake: list of expressions.
  array with length is passed as two arguments: start of the array + length.
  length should evaluate to Word


  *)

Theorem MEM_IMP_exp_size:
   !xs a. MEM a xs ==> (exp_size l a < exp1_size l xs)
Proof
  Induct \\ FULL_SIMP_TAC (srw_ss()) []
  \\ REPEAT STRIP_TAC \\ SRW_TAC [] [definition"exp_size_def"]
  \\ RES_TAC \\ DECIDE_TAC
QED


Overload shift = “backend_common$word_shift”

val _ = export_theory();