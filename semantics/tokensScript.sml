(*Generated by Lem from tokens.lem.*)
open HolKernel Parse boolLib bossLib;
open lem_pervasives_extraTheory;

val _ = numLib.prefer_num();



local open integerTheory stringTheory in end;
val _ = new_theory "tokens"
val _ = set_grammar_ancestry ["integer", "string"];

(*
  The tokens of CakeML concrete syntax.
  Some tokens are from Standard ML and not used in CakeML.
*)
(*open import Pervasives_extra*)
val _ = Hol_datatype `
 token =
  WhitespaceT of num | NewlineT | LexErrorT
| HashT | LparT | RparT | StarT | CommaT | ArrowT | DotsT | ColonT | SealT
| SemicolonT | EqualsT | DarrowT | LbrackT | RbrackT | UnderbarT | LbraceT
| BarT | RbraceT | AndT | AndalsoT | AsT | CaseT | DatatypeT
| ElseT | EndT | EqtypeT | ExceptionT | FnT | FunT | HandleT | IfT
| InT | IncludeT | LetT | LocalT | OfT | OpT
| OpenT | OrelseT | RaiseT | RecT | SharingT | SigT | SignatureT | StructT
| StructureT | ThenT | TypeT | ValT | WhereT | WhileT | WithT | WithtypeT
| IntT of int
| HexintT of string
| WordT of num
| RealT of string
| StringT of string
| CharT of char
| TyvarT of string
| AlphaT of string
| SymbolT of string
| LongidT of string => string
| FFIT of string`;

val _ = export_theory()

