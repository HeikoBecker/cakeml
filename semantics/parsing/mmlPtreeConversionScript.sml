open HolKernel Parse boolLib bossLib

open mmlGrammarTheory

open monadsyntax lcsymtacs

val _ = new_theory "mmlPtreeConversion"

(* ----------------------------------------------------------------------
    Parse trees to abstract syntax
   ---------------------------------------------------------------------- *)

(* Use of parsing-heap means that this theory is secretly a descendent of
   pegexecTheory, where 'nt' is a constructor name.

   This is a disgusting failing of our theory mechanism.  *)
val _ = hide "nt"

val ptree_Tyop_def = Define`
  ptree_Tyop ptree =
    case ptree of
      Lf _ => NONE
    | Nd (mkNT nTyOp) [Lf (TK (AlphaT s))] => SOME s
    | Nd (mkNT nTyOp) [Lf (TK (SymbolT s))] => SOME s
    | _ => NONE
`;

val ptree_linfix_def = Define`
  ptree_linfix topnt opn elnt (pt : mlptree) =
    case pt of
        Lf _ => NONE
      | Nd nt args =>
        if nt = mkNT topnt then
          case args of
              [pt] => do e <- elnt pt; SOME [e] od
            | [top; op_pt; pt] => do
                assert(op_pt = Lf (TK opn));
                front <- ptree_linfix topnt opn elnt top;
                last <- elnt pt;
                SOME(front ++ [last])
              od
            | _ => NONE
        else NONE
`

val ptree_Type_def = Define`
  (ptree_Type ptree : ast_t option =
    case ptree of
      Nd nt args =>
      (case nt of
         mkNT nType => (case args of
                         [dt] => ptree_Type dt
                       | [dt;Lf(TK ArrowT);rt] => do
                           dty <- ptree_Type dt;
                           rty <- ptree_Type rt;
                           SOME(Ast_Tfn dty rty)
                         od
                       | _ => NONE)
       | mkNT nDType => (case args of
                           [Lf (TK (TyvarT s))] => SOME (Ast_Tvar s)
                         | [opn] => do
                             opname <- ptree_Tyop opn;
                             SOME(Ast_Tapp [] opname)
                           od
                         | [dt; opn] => do
                             dty <- ptree_Type dt;
                             opname <- ptree_Tyop opn;
                             SOME(Ast_Tapp [dty] opname)
                           od
                         | [Lf (TK LparT); t; Lf (TK RparT)] => ptree_Type t
                         | [Lf (TK LparT); tl; Lf (TK RparT); opn] => do
                             tylist <- ptree_Typelist tl;
                             opname <- ptree_Tyop opn;
                             SOME(Ast_Tapp tylist opname)
                           od
                         | _ => NONE)
       | _ => NONE)
    | _ => NONE) ∧
  (ptree_Typelist ptree : ast_t list option =
     case ptree of
       Lf _ => NONE
     | Nd nt args =>
       (case nt of
          mkNT nTypeList => (case args of
                               [dt] => do
                                  ty <- ptree_Type dt;
                                  SOME[ty]
                               od
                             | [dt; Lf (TK CommaT); tl'] => do
                                 ty <- ptree_Type dt;
                                 tylist <- ptree_Typelist tl';
                                 SOME(ty::tylist)
                               od
                             | _ => NONE)
         | _ => NONE))
`;

val ptree_TypeName_def = Define`
  ptree_TypeName ptree : (tvarN list # typeN) option =
    case ptree of
      Lf _ => NONE
    | Nd nt args =>
      if nt = mkNT nTypeName then
        case args of
          [opt] => do opn <- ptree_Tyop opt ; SOME([], opn) od
        | [sym; opt] => do tyvn <- destTyvarPT sym ;
                           opn <- ptree_Tyop opt ;
                           SOME ([tyvn], opn)
                        od
        | [lp; tyvl; rp; opt] =>
          if lp = Lf (TK LparT) ∧ rp = Lf (TK RparT) then do
              tyvnms <- ptree_linfix nTyVarList CommaT destTyvarPT tyvl;
              opn <- ptree_Tyop opt;
              SOME(tyvnms, opn)
            od
          else NONE
        | _ => NONE
      else NONE
`;

val ptree_StarTypes_def = Define`
  ptree_StarTypes p pt : ast_t list option =
    case pt of
        Lf _ => NONE
      | Nd nt args =>
        if p ∧ (nt = mkNT nStarTypesP) then
          case args of
              [pt0] => ptree_StarTypes F pt0
            | [lp; pt0; rp] => do assert (lp = Lf (TK LparT)) ;
                                  assert (rp = Lf (TK RparT)) ;
                                  ptree_StarTypes F pt0
                               od
            | _ => NONE
        else if ¬p ∧ (nt = mkNT nStarTypes) then
          case args of
              [pt0] => do ty <- ptree_Type pt0; SOME([ty]) od
            | [pt1; star; pt2] => do
                 assert(star = Lf (TK StarT));
                 pfx <- ptree_StarTypes F pt1;
                 ty <- ptree_Type pt2;
                 SOME(list$APPEND pfx [ty: ast_t])
              od
        else NONE
`;

val ptree_ConstructorName_def = Define`
  ptree_ConstructorName ast =
    case ast of
        Lf _ => NONE
      | Nd nt args =>
        if nt = mkNT nConstructorName then
          case args of
              [Lf (TOK t)] => destAlphaT t
            | _ => NONE
        else NONE
`

val ptree_Dconstructor_def = Define`
  ptree_Dconstructor ast =
    case ast of
        Lf x => NONE
      | Nd nt args =>
        if nt = mkNT nDconstructor then
          case args of
              [] => NONE
            | t::ts =>
              do
                 cname <- ptree_ConstructorName t;
                 types <- case ts of
                               [] => SOME []
                             | [oft; startys] =>
                               if oft = Lf (TK OfT) then
                                 ptree_StarTypes T startys
                               else NONE
                             | _ => NONE;
                 SOME(cname, types)
              od
            | _ :: t => NONE
        else NONE
`;

val ptree_DtypeDecl_def = Define`
  ptree_DtypeDecl (pt : mlptree) =
    case pt of
        Lf _ => NONE
      | Nd nt args =>
        if nt = mkNT nDtypeDecl then
          case args of
              [tynm_pt; eqt; dtc_pt] => do
                assert(eqt = Lf (TK EqualsT));
                tynm <- ptree_TypeName tynm_pt;
                dtc <- ptree_linfix nDtypeCons BarT ptree_Dconstructor dtc_pt;
                SOME(FST tynm,SND tynm,dtc)
              od
            | _ => NONE
        else NONE
`;

val ptree_TypeDec_def = Define`
  ptree_TypeDec ptree : ast_type_def option =
    case ptree of
      Lf _ => NONE
    | Nd nt args =>
      if nt = mkNT nTypeDec then
        case args of
            [datatype_pt; pt] => do
              assert(datatype_pt = Lf (TK DatatypeT));
              ptree_linfix nDtypeDecls AndT ptree_DtypeDecl pt
            od
          | _ => NONE
      else NONE`;

val OPTION_CHOICE_def = Define`
  OPTION_CHOICE (SOME y) x = SOME y ∧
  OPTION_CHOICE NONE x = x
`
val _ = overload_on ("++", ``OPTION_CHOICE``)

val ptree_Op_def = Define`
  ptree_Op (Lf _) = NONE ∧
  ptree_Op (Nd nt subs) =
    if nt = mkNT nMultOps then
      if subs = [Lf (TK StarT)] then SOME "*"
      else if subs = [Lf (TK (SymbolT "/"))] then SOME "/"
      else if subs = [Lf (TK (AlphaT "mod"))] then SOME "mod"
      else if subs = [Lf (TK (AlphaT "div"))] then SOME "div"
      else NONE
    else if nt = mkNT nAddOps then
      if subs = [Lf (TK (SymbolT "+"))] then SOME "+"
      else if subs = [Lf (TK (SymbolT "-"))] then SOME "-"
      else NONE
    else if nt = mkNT nRelOps then
      do
        sym <- destLf (HD subs);
        tok <- destTOK sym;
        s <- (destSymbolT tok ++ SOME "=");
        SOME s
      od
    else NONE
`;

val ptree_V_def = Define`
  ptree_V (Lf _) = NONE ∧
  ptree_V (Nd nt subs) =
    if nt = mkNT nV then
      case subs of
          [Lf (TOK t)] => destAlphaT t ++ destSymbolT t
        | _ => NONE
    else NONE
`;

val updAst_Conname_def = Define`
  updAst_Conname cname (Ast_Con _ args) = SOME (Ast_Con cname args) ∧
  updAst_Conname _ _ = NONE
`

val backAppCon_def = Define`
  backAppCon (Ast_Con x args) b = SOME (Ast_Con x (args ++ [b])) ∧
  backAppCon _ _ = NONE
`;

val frontAppCon_def = Define`
  frontAppCon e (Ast_Con x args) = SOME (Ast_Con x (e::args)) ∧
  frontAppCon _ _ = NONE
`;

val ptree_Expr_def = Define`
  ptree_Expr ent (Lf _) = NONE ∧
  ptree_Expr ent (Nd nt subs) =
    (if mkNT ent = nt then
      if nt = mkNT nEbase then
        case subs of
            [lpart; pt; rpart] =>
            if lpart = Lf (TK LparT) ∧ rpart = Lf (TK RparT) then
              ptree_Expr nE pt
            else NONE
          | [single] =>
              do
                lf <- destLf single;
                t <- destTOK lf;
                i <- destIntT t ;
                SOME (Ast_Lit (IntLit i))
              od ++
              do
                s <- ptree_V single;
                SOME (Ast_Var s)
              od ++
              do cname <- ptree_ConstructorName single;
                 SOME (Ast_Con cname [])
              od
          | [lett;funt;andfdecls;intok;ept;endt] =>
            do
              assert(lett = Lf (TOK LetT) ∧ funt = Lf (TOK FunT));
              assert(intok = Lf (TOK InT) ∧ endt = Lf (TOK EndT));
              decls <- ptree_AndFDecls andfdecls;
              e <- ptree_Expr nE ept;
              SOME(Ast_Letrec decls e)
            od
          | [lett;valt;varpt;eqt;e1pt;intok;e2pt;endt] =>
            do
              vname <- ptree_V varpt;
              e1 <- ptree_Expr nE e1pt;
              e2 <- ptree_Expr nE e2pt;
              SOME(Ast_Let vname e1 e2)
            od
          | _ => NONE
      else if nt = mkNT nEapp then
        case subs of
            [t1; t2] => do
                          a1 <- ptree_Expr nEapp t1;
                          a2 <- ptree_Expr nEbase t2;
                          SOME(Ast_App a1 a2)
                        od ++
                        do
                          cname <- ptree_ConstructorName t1;
                          cargs <- ptree_Expr nEtuple t2;
                          updAst_Conname cname cargs
                        od
          | [t] => ptree_Expr nEbase t
          | _ => NONE
      else if nt = mkNT nEtuple then
        case subs of
            [lpart; el2; rpart] =>
            if lpart = Lf (TOK LparT) ∧ rpart = Lf (TOK RparT) then
              ptree_Expr nElist2 el2
            else NONE
          | _ => NONE
      else if nt = mkNT nElist2 then
        case subs of
            [e; ct; el] =>
              do
                assert(ct = Lf (TOK CommaT));
                front <- ptree_Expr nE e;
                back <- ptree_Expr nElist1 el;
                frontAppCon front back
              od
          | _ => NONE
      else if nt = mkNT nElist1 then
        case subs of
            [sing] => do e <- ptree_Expr nE sing; SOME(Ast_Con "" [e]) od
          | [el1;ct;e] =>
            if ct = Lf (TOK CommaT) then
              do
                front <- ptree_Expr nElist1 el1 ;
                back <- ptree_Expr nE e;
                backAppCon front back
              od
            else NONE
      else if nt = mkNT nEmult then
        case subs of
          [t1; opt; t2] => do (* s will be *, /, div, or mod *)
            a1 <- ptree_Expr nEmult t1;
            a_op <- ptree_Op opt;
            a2 <- ptree_Expr nEapp t2;
            SOME(Ast_App (Ast_App (Ast_Var a_op) a1) a2)
          od
        | [t] => ptree_Expr nEapp t
        | _ => NONE
      else if nt = mkNT nEadd then
        case subs of
            [t1;opt;t2] => do
              a1 <- ptree_Expr nEadd t1;
              a_op <- ptree_Op opt;
              a2 <- ptree_Expr nEmult t2;
              SOME (Ast_App (Ast_App (Ast_Var a_op) a1) a2)
            od
          | [t] => ptree_Expr nEmult t
          | _ => NONE
      else if nt = mkNT nErel then
        case subs of
            [t1;opt;t2] => do
              a1 <- ptree_Expr nEadd t1;
              a_op <- ptree_Op opt;
              a2 <- ptree_Expr nEadd t2;
              SOME (Ast_App (Ast_App (Ast_Var a_op) a1) a2)
            od
          | [t] => ptree_Expr nEadd t
          | _ => NONE
      else if nt = mkNT nEcomp then
        case subs of
            [t1;opt;t2] => do
              assert(opt = Lf(TOK (AlphaT "o")));
              a1 <- ptree_Expr nEcomp t1;
              a2 <- ptree_Expr nErel t2;
              SOME(Ast_App(Ast_App (Ast_Var "o") a1) a2)
            od
          | [t] => ptree_Expr nErel t
          | _ => NONE
      else if nt = mkNT nEbefore then
        case subs of
          [t1;opt;t2] => do
            assert(opt = Lf(TOK(AlphaT "before")));
            a1 <- ptree_Expr nEbefore t1;
            a2 <- ptree_Expr nEcomp t2;
            SOME(Ast_App (Ast_App (Ast_Var"before") a1) a2)
          od
        | [t] => ptree_Expr nEcomp t
        | _ => NONE
      else if nt = mkNT nEtyped then
        case subs of
          [t1;colon;t2] => do
            assert(colon = Lf (TOK ColonT));
            t1 <- ptree_Expr nEbefore t1;
            t2 <- ptree_Type t2;
            SOME t1 (* FIXME *)
          od
        | [t] => ptree_Expr nEbefore t
        | _ => NONE
      else if nt = mkNT nElogicAND then
        case subs of
            [t1;andt;t2] => do
              assert(andt = Lf (TOK AndalsoT));
              a1 <- ptree_Expr nElogicAND t1;
              a2 <- ptree_Expr nEtyped t2;
              SOME(Ast_Log And a1 a2)
            od
          | [t] => ptree_Expr nEtyped t
          | _ => NONE
      else if nt = mkNT nElogicOR then
        case subs of
            [t1;ort;t2] => do
              assert(ort = Lf (TOK OrelseT));
              a1 <- ptree_Expr nElogicOR t1;
              a2 <- ptree_Expr nElogicAND t2;
              SOME (Ast_Log Or a1 a2)
            od
          | [t] => ptree_Expr nElogicAND t
          | _ => NONE
      else if nt = mkNT nE then
        case subs of
          | [fnt; vnt; arrowt; ent] =>
            do
              assert (fnt = Lf (TOK FnT) ∧ arrowt = Lf (TOK DarrowT));
              v <- ptree_V vnt;
              e <- ptree_Expr nE ent;
              SOME(Ast_Fun v e)
            od
          | [ift;g;thent;te;elset;ee] => do
              assert(ift = Lf (TOK IfT) ∧ thent = Lf (TOK ThenT) ∧
                     elset = Lf (TOK ElseT));
              a1 <- ptree_Expr nE g;
              a2 <- ptree_Expr nE te;
              a3 <- ptree_Expr nE ee;
              SOME(Ast_If a1 a2 a3)
            od
          | [t] => ptree_Expr nElogicOR t
          | _ => NONE
      else NONE
    else NONE) ∧
  ptree_AndFDecls ast =
    (case ast of
        Lf _ => NONE
      | Nd nt subs =>
        if nt = mkNT nAndFDecls then
          case subs of
              [single] => do fdec <- ptree_FDecl single; SOME ([fdec]) od
            | [fdecspt;andt;fdecpt] =>
              do
                assert(andt = Lf (TOK AndT));
                fdecs <- ptree_AndFDecls fdecspt;
                fdec <- ptree_FDecl fdecpt;
                SOME(fdecs ++ [fdec])
              od
            | _ => NONE
        else NONE) ∧
  ptree_FDecl ast =
    case ast of
        Lf _ => NONE
      | Nd nt subs =>
        if nt = mkNT nFDecl then
          case subs of
              [fname_pt; vname_pt; eqt; body_pt] =>
              do
                assert(eqt = Lf (TOK EqualsT));
                fname <- ptree_V fname_pt;
                vname <- ptree_V vname_pt;
                body <- ptree_Expr nE body_pt;
                SOME(fname,vname,body)
              od
            | _ => NONE
        else NONE
`;

val _ = export_theory()
