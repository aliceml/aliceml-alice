(*
 * Note: We assume complete binding analysis and alpha conversion has been
 * performed on the input program. So we would not need to bother with scoping.
 * Nevertheless, we sometimes use scopes to reduce the size of the symbol
 * table.
 *)

structure Elab :> ELAB =
  struct

    structure I = AbstractGrammar
    structure O = TypedGrammar

    open Env

    nonfix mod


  (* Errors *)

    val error = ElabError.error


  (* Until we are finished... *)

    fun unfinished i funname casename =
	Error.warn(i, "Elab." ^ funname ^ ": " ^ casename ^ " not checked yet")


  (* Predefined types *)

    val wordPath    = Path.PLAIN(Prebound.stamp_word,   Name.InId)
    val intPath     = Path.PLAIN(Prebound.stamp_int,    Name.InId)
    val charPath    = Path.PLAIN(Prebound.stamp_char,   Name.InId)
    val stringPath  = Path.PLAIN(Prebound.stamp_string, Name.InId)
    val realPath    = Path.PLAIN(Prebound.stamp_real,   Name.InId)
    val boolPath    = Path.PLAIN(Prebound.stamp_bool,   Name.InId)
    val exnPath     = Path.PLAIN(Prebound.stamp_exn,    Name.InId)
    val refPath     = Path.PLAIN(Prebound.stamp_ref,    Name.InId)
    val vecPath     = Path.PLAIN(Prebound.stamp_vec,    Name.InId)
    val listPath    = Path.PLAIN(Prebound.stamp_list,   Name.InId)

    val wordCon     = (Type.STAR, Type.CLOSED, wordPath)
    val intCon      = (Type.STAR, Type.CLOSED, intPath)
    val charCon     = (Type.STAR, Type.CLOSED, charPath)
    val stringCon   = (Type.STAR, Type.CLOSED, stringPath)
    val realCon     = (Type.STAR, Type.CLOSED, realPath)
    val boolCon     = (Type.STAR, Type.CLOSED, boolPath)
    val exnCon      = (Type.STAR, Type.CLOSED, exnPath)
    val refCon      = (Type.ARROW(Type.STAR, Type.STAR), Type.CLOSED, refPath)
    val vecCon      = (Type.ARROW(Type.STAR, Type.STAR), Type.CLOSED, vecPath)
    val listCon     = (Type.ARROW(Type.STAR, Type.STAR), Type.CLOSED, listPath)

    val unitTyp     = let val t = Type.inTuple []    in fn() => t end
    val boolTyp     = let val t = Type.inCon boolCon in fn() => t end
    val exnTyp      = let val t = Type.inCon exnCon  in fn() => t end

    fun wordTyp()   = Type.inCon wordCon	(* UNFINISHED: overloading *)
    fun intTyp()    = Type.inCon intCon		(* UNFINISHED: overloading *)
    fun charTyp()   = Type.inCon charCon	(* UNFINISHED: overloading *)
    fun stringTyp() = Type.inCon stringCon	(* UNFINISHED: overloading *)
    fun realTyp()   = Type.inCon realCon	(* UNFINISHED: overloading *)

    fun refTyp t    = Type.inApp(Type.inCon refCon, t)
    fun vecTyp t    = Type.inApp(Type.inCon vecCon, t)
    fun listTyp t   = Type.inApp(Type.inCon listCon, t)


  (* Output info field *)

    fun nonInfo(i)   = (i, TypedInfo.NON)
    fun typInfo(i,t) = (i, TypedInfo.TYP t)
    fun infInfo(i,j) = (i, TypedInfo.INF j)


  (* Literals *)

    fun elabLit(E, I.WordLit w)		= ( wordTyp(), O.WordLit w )
      | elabLit(E, I.IntLit n)		= ( intTyp(), O.IntLit n )
      | elabLit(E, I.CharLit c)		= ( charTyp(), O.CharLit c )
      | elabLit(E, I.StringLit s)	= ( stringTyp(), O.StringLit s )
      | elabLit(E, I.RealLit x)		= ( realTyp(), O.RealLit x )


  (* Elaborate kind of type (no higher kinds yet) *)

    fun elabTypKind(E, I.FunTyp(i, id, typ)) =
	    Type.ARROW(Type.STAR, elabTypKind(E, typ))

      | elabTypKind(E, _) =
	    Type.STAR


  (* Rows (polymorphic, thus put here) *)

    fun elabLab(E, I.Lab(i, s)) = ( Lab.fromString s, O.Lab(nonInfo(i), s) )

    fun elabRow(elabX, E, I.Row(i, fields, b)) =
	let
	    val  r0         = (if b then Type.unknownRow else Type.emptyRow)()
	    val (r,fields') = elabFields(elabX, E, r0, fields)
	    val  t          = Type.inRow r
	in
	    ( t, O.Row(nonInfo(i), fields', b) )
	end

    and elabField(elabX, E, I.Field(i, lab, x)) =
	let
	    val (l,lab') = elabLab(E, lab)
	    val (t,x')   = elabX(E, x)
	in
	    ( l, t, O.Field(nonInfo(i), lab', x') )
	end

    and elabFields(elabX, E, r, fields) =
	let
	    fun elabField1(field, (r,fields')) =
		let
		    val (l,t,field') = elabField(elabX, E, field)
		in
		    ( Type.extendRow(l, t, r), field'::fields' )
		end
	in
	    List.foldr elabField1 (r,[]) fields
	end


  (* Expressions *)

    fun elabValId(E, id as I.Id(i, stamp, name)) =
	(* May be binding occurance *)
	let
	    val t = Type.instance(#2(lookupVal(E, stamp)))
		    handle Lookup _ =>
			let val t = Type.unknown Type.STAR in
			    insertVal(E, stamp, (id,t)) ; t
			end
	in
	    ( t, O.Id(typInfo(i,t), stamp, name) )
	end

    and elabValLongid(E, I.ShortId(i, id)) =
	let
	    val (t,id') = elabValId(E, id)
	in
	    ( t, O.ShortId(typInfo(i,t), id') )
	end

      | elabValLongid(E, I.LongId(i, longid, lab)) =
	(*UNFINISHED*)
	let
	    val (E',longid') = elabModLongid(E, longid)
	    val (l,lab')     = elabLab(E, lab)
	    val  t           = Type.unknown Type.STAR 
	in
	    unfinished i "elabValLongid" "long ids";
	    ( t, O.LongId(typInfo(i,t), longid', lab') )
	end


    and elabExp(E, I.LitExp(i, lit)) =
	let
	    val (t,lit') = elabLit(E, lit)
	in
	    ( t, O.LitExp(typInfo(i,t), lit') )
	end

      | elabExp(E, I.PrimExp(i, s, typ)) =
	let
	    val (t,typ') = elabTyp(E, typ)
	in
	    ( t, O.PrimExp(typInfo(i,t), s, typ') )
	end

      | elabExp(E, I.VarExp(i, longid)) =
	let
	    val (t,longid') = elabValLongid(E, longid)
	in
	    ( t, O.VarExp(typInfo(i,t), longid') )
	end

      | elabExp(E, I.ConExp(i, n, longid)) =
	let
	    val (t,longid') = elabValLongid(E, longid)
	in
	    ( t, O.ConExp(typInfo(i,t), n, longid') )
	end

      | elabExp(E, I.RefExp(i)) =
	let
	    val t = refTyp(Type.unknown Type.STAR)
	in
	    ( t, O.RefExp(typInfo(i,t)) )
	end

      | elabExp(E, I.TupExp(i, exps)) =
	let
	    val (ts,exps') = elabExps(E, exps)
	    val  t         = Type.inTuple ts
	in
	    ( t, O.TupExp(typInfo(i,t), exps') )
	end

      | elabExp(E, I.RowExp(i, exprow)) =
	let
	    val (t,exprow') = elabRow(elabExp, E, exprow)
	in
	    ( t, O.RowExp(typInfo(i,t), exprow') )
	end

      | elabExp(E, I.SelExp(i, lab)) =
	let
	    val (l,lab') = elabLab(E, lab)
	    val  r       = Type.extendRow(l, Type.unknown Type.STAR,
					     Type.unknownRow())
	    val  t       = Type.inRow r
	in
	    ( t, O.SelExp(typInfo(i,t), lab') )
	end

      | elabExp(E, I.VecExp(i, exps)) =
	let
	    val (ts,exps') = elabExps(E, exps)
	    val  t         = vecTyp(List.hd ts)
	    val  _         = Type.unifyList ts
			     handle Type.UnifyList(n,t1,t2) =>
				error(I.infoExp(List.nth(exps,n)),
				      ElabError.VecExpUnify(t, List.nth(ts,n),
							    t1, t2))
	in
	    ( t, O.VecExp(typInfo(i,t), exps') )
	end

      | elabExp(E, I.FunExp(i, id, exp)) =
	let
	    val (t1,id')  = elabValId(E, id)
	    val (t2,exp') = elabExp(E, exp)
	    val  t        = Type.inArrow(t1,t2)
	in
	    ( t, O.FunExp(typInfo(i,t), id', exp') )
	end

      | elabExp(E, I.AppExp(i, exp1, exp2)) =
	let
	    val (t1,exp1') = elabExp(E, exp1)
	    val (t2,exp2') = elabExp(E, exp2)
	    val  t11       = Type.unknown Type.STAR
	    val  t12       = Type.unknown Type.STAR
	    val  t1'       = Type.inArrow(t11,t12)
	    val  _         = Type.unify(t1',t1)
			     handle Type.Unify(t3,t4) =>
				error(I.infoExp exp1,
				      ElabError.AppExpFunUnify(t1', t1, t3, t4))
	    val  _         = Type.unify(t11,t2)
			     handle Type.Unify(t3,t4) =>
				error(i,
				      ElabError.AppExpArgUnify(t11, t2, t3, t4))
	in
	    ( t12, O.AppExp(typInfo(i,t12), exp1', exp2') )
	end

      | elabExp(E, I.CompExp(i, exp1, exp2)) =
	(* UNFINISHED *)
	let
	    val (t1,exp1') = elabExp(E, exp1)
	    val (t2,exp2') = elabExp(E, exp2)
	    val  t         = Type.unknown Type.STAR
	in
	    unfinished i "elabExp" "record composition";
	    ( t, O.CompExp(typInfo(i,t), exp1', exp2') )
	end

      | elabExp(E, I.AndExp(i, exp1, exp2)) =
	let
	    val (t1,exp1') = elabExp(E, exp1)
	    val (t2,exp2') = elabExp(E, exp2)
	    val  t         = boolTyp()
	    val  _         = Type.unify(t1,t)
			     handle Type.Unify(t3,t4) =>
				error(I.infoExp exp1,
				      ElabError.AndExpUnify(t1, t, t3, t4))
	    val  _         = Type.unify(t2,t)
			     handle Type.Unify(t3,t4) =>
				error(I.infoExp exp2,
				      ElabError.AndExpUnify(t2, t, t3, t4))
	in
	    ( t, O.AndExp(typInfo(i,t), exp1', exp2') )
	end

      | elabExp(E, I.OrExp(i, exp1, exp2)) =
	let
	    val (t1,exp1') = elabExp(E, exp1)
	    val (t2,exp2') = elabExp(E, exp2)
	    val  t         = boolTyp()
	    val  _         = Type.unify(t1,t)
			     handle Type.Unify(t3,t4) =>
				error(I.infoExp exp1,
				      ElabError.OrExpUnify(t1, t, t3, t4))
	    val  _         = Type.unify(t2,t)
			     handle Type.Unify(t3,t4) =>
				error(I.infoExp exp2,
				      ElabError.OrExpUnify(t2, t, t3, t4))
	in
	    ( t, O.OrExp(typInfo(i,t), exp1', exp2') )
	end

      | elabExp(E, I.IfExp(i, exp1, exp2, exp3)) =
	let
	    val (t1,exp1') = elabExp(E, exp1)
	    val (t2,exp2') = elabExp(E, exp2)
	    val (t3,exp3') = elabExp(E, exp3)
	    val  tb        = boolTyp()
	    val  _         = Type.unify(t1,tb)
			     handle Type.Unify(t4,t5) =>
				error(I.infoExp exp1,
				      ElabError.IfExpCondUnify(t1, tb, t4, t5))
	    val  _         = Type.unify(t2,t3)
			     handle Type.Unify(t4,t5) =>
				error(i,
				      ElabError.IfExpBranchUnify(t2,t3, t4, t5))
	in
	    ( t2, O.IfExp(typInfo(i,t2), exp1', exp2', exp3') )
	end

      | elabExp(E, I.WhileExp(i, exp1, exp2)) =
	let
	    val (t1,exp1') = elabExp(E, exp1)
	    val (t2,exp2') = elabExp(E, exp2)
	    val  tb        = boolTyp()
	    val  t         = unitTyp()
	    val  _         = Type.unify(t1,tb)
			     handle Type.Unify(t3,t4) =>
				error(I.infoExp exp1,
				      ElabError.WhileExpCondUnify(t1,tb, t3,t4))
	in
	    ( t, O.WhileExp(typInfo(i,t), exp1', exp2') )
	end

      | elabExp(E, I.SeqExp(i, exps)) =
	let
	    val (ts,exps') = elabExps(E, exps)
	    val  t         = List.last ts
	in
	    ( t, O.SeqExp(typInfo(i,t), exps') )
	end

      | elabExp(E, I.CaseExp(i, exp, matchs)) =
	(* UNFINISHED: check for exhaustiveness and redundancy *)
	let
	    val (t1,exp')    = elabExp(E, exp)
	    val (t2,matchs') = elabMatchs(E, t1, matchs)
	in
	    ( t2, O.CaseExp(typInfo(i,t2), exp', matchs') )
	end

      | elabExp(E, I.RaiseExp(i, exp)) =
	let
	    val (t1,exp') = elabExp(E, exp)
	    val  te       = exnTyp()
	    val  t        = Type.unknown Type.STAR
	    val  _        = Type.unify(t1,te)
			    handle Type.Unify(t2,t3) =>
				error(I.infoExp exp,
				      ElabError.RaiseExpUnify(t1, te, t2, t3))
	in
	    ( t, O.RaiseExp(typInfo(i,t), exp') )
	end

      | elabExp(E, I.HandleExp(i, exp, matchs)) =
	(* UNFINISHED: check for redundancy *)
	let
	    val (t1,exp')    = elabExp(E, exp)
	    val (t2,matchs') = elabMatchs(E, exnTyp(), matchs)
	    val  _           = Type.unify(t1,t2)
			       handle Type.Unify(t3,t4) =>
				error(i, ElabError.HandleExpUnify(t1,t2, t3,t4))
	in
	    ( t1, O.HandleExp(typInfo(i,t1), exp', matchs') )
	end

      | elabExp(E, I.AnnExp(i, exp, typ)) =
	let
	    val (t1,exp') = elabExp(E, exp)
	    val (t2,typ') = elabStarTyp(E, typ)
	    val  _        = Type.unify(t1,t2)
			    handle Type.Unify(t3,t4) =>
				error(i, ElabError.AnnExpUnify(t1, t2, t3, t4))
	in
	    ( t2, O.AnnExp(typInfo(i,t2), exp', typ') )
	end

      | elabExp(E, I.LetExp(i, decs, exp)) =
	let
	    val  _          = insertScope E
	    val  decs'      = elabDecs(E, decs)
	    val (t,exp')    = elabExp(E, exp)
	    val  _          = deleteScope E
	in
	    ( t, O.LetExp(typInfo(i,t), decs', exp') )
	end


    and elabExps(E, exps) =
	ListPair.unzip(List.map (fn exp => elabExp(E,exp)) exps)


  (* Matches *)

    and elabMatch(E, t1, t2, I.Match(i, pat, exp)) =
	let
	    val  _        = insertScope E
	    val (t3,pat') = elabPat(E, pat)
	    val  _        = Type.unify(t1,t3)
			    handle Type.Unify(t5,t6) =>
				error(I.infoPat pat,
				      ElabError.MatchPatUnify(t1, t3, t5, t6))
	    val (t4,exp') = elabExp(E, exp)
	    val  _        = Type.unify(t2,t4)
			    handle Type.Unify(t5,t6) =>
				error(I.infoExp exp,
				      ElabError.MatchExpUnify(t2, t4, t5, t6))
	    val  _        = deleteScope E
	in
	    O.Match(nonInfo(i), pat', exp')
	end

    and elabMatchs(E, t1, matchs) =
	let
	    val t2 = Type.unknown Type.STAR

	    fun elabMatch1 match = elabMatch(E, t1, t2, match)
	in
	    ( t2, List.map elabMatch1 matchs )
	end


  (* Patterns *)

    and elabPat(E, I.JokPat(i)) =
	let
	    val t = Type.unknown Type.STAR
	in
	    ( t, O.JokPat(typInfo(i,t)) )
	end

      | elabPat(E, I.LitPat(i, lit)) =
	let
	    val (t,lit') = elabLit(E, lit)
	in
	    ( t, O.LitPat(typInfo(i,t), lit') )
	end

      | elabPat(E, I.VarPat(i, id)) =
	let
	    val (t,id') = elabValId(E, id)
	in
	    ( t, O.VarPat(typInfo(i,t), id') )
	end

      | elabPat(E, I.ConPat(i, longid, pats)) =
	let
	    fun elabArgs(t1,   []  ) =
		if Type.isArrow t1 then
		    error(i, ElabError.ConPatFewArgs(longid))
		else
		    t1

	      | elabArgs(t1, t2::ts) =
		let
		    val  t11  = Type.unknown Type.STAR
		    val  t12  = Type.unknown Type.STAR
		    val  t1'  = Type.inArrow(t11,t12)
		    val  _    = Type.unify(t1',t1)
				handle Type.Unify(t3,t4) =>
				    error(i, ElabError.ConPatManyArgs(longid))
		    val  _    = Type.unify(t11,t2)
				handle Type.Unify(t3,t4) =>
				    error(i,
					  ElabError.ConPatUnify(t11,t2, t3,t4))
		in
		    elabArgs(t1, ts)
		end

	    val (t1,longid') = elabValLongid(E, longid)
	    val (ts,pats')   = elabPats(E, pats)
	    val  t           = elabArgs(t1,ts)
	in
	    ( t, O.ConPat(typInfo(i,t), longid', pats') )
	end

      | elabPat(E, I.RefPat(i, pat)) =
	let
	    val (t1,pat') = elabPat(E, pat)
	    val  t        = refTyp t1
	in
	    ( t, O.RefPat(typInfo(i,t), pat') )
	end

      | elabPat(E, I.TupPat(i, pats)) =
	let
	    val (ts,pats') = elabPats(E, pats)
	    val  t         = Type.inTuple ts
	in
	    ( t, O.TupPat(typInfo(i,t), pats') )
	end

      | elabPat(E, I.RowPat(i, patrow)) =
	let
	    val (t,patrow') = elabRow(elabPat, E, patrow)
	in
	    ( t, O.RowPat(typInfo(i,t), patrow') )
	end

      | elabPat(E, I.VecPat(i, pats)) =
	let
	    val (ts,pats') = elabPats(E, pats)
	    val  t         = vecTyp(List.hd ts)
	    val  _         = Type.unifyList ts
			     handle Type.UnifyList(n,t1,t2) =>
				error(I.infoPat(List.nth(pats,n)),
				      ElabError.VecPatUnify(t, List.nth(ts,n),
							    t1, t2))
	in
	    ( t, O.VecPat(typInfo(i,t), pats') )
	end

      | elabPat(E, I.AsPat(i, pat1, pat2)) =
	let
	    val (t1,pat1') = elabPat(E, pat1)
	    val (t2,pat2') = elabPat(E, pat2)
	    val  _         = Type.unify(t1,t2)
			     handle Type.Unify(t3,t4) =>
				error(i, ElabError.AsPatUnify(t1, t2, t3, t4))
	in
	    ( t2, O.AsPat(typInfo(i,t2), pat1', pat2') )
	end

      | elabPat(E, I.AltPat(i, pats)) =
	let
	    val (ts,pats') = elabPats(E, pats)
	    val  t         = List.hd ts
	    val  _         = Type.unifyList ts
			     handle Type.UnifyList(n,t1,t2) =>
				error(I.infoPat(List.nth(pats,n)),
				      ElabError.AltPatUnify(t, List.nth(ts,n),
							    t1, t2))
	in
	    ( t, O.AltPat(typInfo(i,t), pats') )
	end

      | elabPat(E, I.NegPat(i, pat)) =
	let
	    val (t,pat') = elabPat(E, pat)
	in
	    ( t, O.NegPat(typInfo(i,t), pat') )
	end

      | elabPat(E, I.GuardPat(i, pat, exp)) =
	let
	    val (t1,pat') = elabPat(E, pat)
	    val (t2,exp') = elabExp(E, exp)
	    val  tb       = boolTyp()
	    val  _        = Type.unify(t2,tb)
			    handle Type.Unify(t3,t4) =>
				error(i, ElabError.GuardPatUnify(t2,tb, t3,t4))
	in
	    ( t1, O.GuardPat(typInfo(i,t1), pat', exp') )
	end

      | elabPat(E, I.AnnPat(i, pat, typ)) =
	let
	    val (t1,pat') = elabPat(E, pat)
	    val (t2,typ') = elabStarTyp(E, typ)
	    val  _        = Type.unify(t1,t2)
			    handle Type.Unify(t3,t4) =>
				error(i, ElabError.AnnPatUnify(t1, t2, t3, t4))
	in
	    ( t2, O.AnnPat(typInfo(i,t2), pat', typ') )
	end

      | elabPat(E, I.WithPat(i, pat, decs)) =
	let
	    val (t,pat') = elabPat(E, pat)
	    val  decs'   = elabDecs(E, decs)
	in
	    ( t, O.WithPat(typInfo(i,t), pat', decs') )
	end


    and elabPats(E, pats) =
	ListPair.unzip(List.map (fn pat => elabPat(E,pat)) pats)


  (* Types *)

    and elabVarId(E, k, id as I.Id(i, stamp, name)) =
	(* May be binding occurance *)
	let
	    val a = #2(lookupVar(E, stamp))
		    handle Lookup _ =>
			let val a = Type.var k in
			    insertVar(E, stamp, (id,a)) ; a
			end
	in
	    ( a, O.Id(nonInfo(i), stamp, name) )
	end


    and elabTypId(E, k, id as I.Id(i, stamp, name)) =
	(* May be binding occurance *)
	let
	    val t = #2(lookupTyp(E, stamp))
		    handle Lookup _ =>
			let val t = Type.unknown k in
			    insertTyp(E, stamp, (id,t)) ; t
			end
	in
	    ( t, O.Id(typInfo(i,t), stamp, name) )
	end

    and elabTypLongid(E, I.ShortId(i, id)) =
	let
	    val (t,id') = elabTypId(E, Type.STAR, id)
	in
	    ( t, O.ShortId(typInfo(i,t), id') )
	end

      | elabTypLongid(E, I.LongId(i, longid, lab)) =
	(*UNFINISHED*)
	let
	    val (E',longid') = elabModLongid(E, longid)
	    val (l,lab')     = elabLab(E, lab)
	    val  t           = Type.unknown Type.STAR 
	in
	    unfinished i "elabTypLongid" "long ids";
	    ( t, O.LongId(typInfo(i,t), longid', lab') )
	end


    and elabStarTyp(E, typ) =
	let
	    val ttyp' as (t,typ') = elabTyp(E, typ)
	in
	    case Type.kind t
	      of Type.STAR => ttyp'
	       | k         => error(I.infoTyp typ, ElabError.StarTypKind(k))
	end


    and elabTyp(E, I.VarTyp(i, id)) =
	let
	    val (a,id') = elabVarId(E, Type.STAR, id)
	    val  t      = Type.inVar a
	in
	    ( t, O.VarTyp(typInfo(i,t), id') )
	end

      | elabTyp(E, I.ConTyp(i, longid)) =
	let
	    val (t,longid') = elabTypLongid(E, longid)
	in
	    ( t, O.ConTyp(typInfo(i,t), longid') )
	end

      | elabTyp(E, I.FunTyp(i, id, typ)) =
	let
	    val (a,id')   = elabVarId(E, Type.STAR, id)
	    val (t1,typ') = elabTyp(E, typ)
	    val  t        = Type.inLambda(a,t1)
	in
	    ( t, O.FunTyp(typInfo(i,t), id', typ') )
	end

      | elabTyp(E, I.AppTyp(i, typ1, typ2)) =
	let
	    val (t1,typ1') = elabTyp(E, typ1)
	    val (t2,typ2') = elabTyp(E, typ2)
	    val  k1        = Type.kind t1
	    val  k2        = Type.kind t2
	    val  _         = case k1
			       of Type.STAR =>
					error(i, ElabError.AppTypFunKind(k1))
				| Type.ARROW(k11,k12) =>
				    if k11 = k2 then () else
					error(i,ElabError.AppTypArgKind(k11,k2))
	    val  t         = Type.inApp(t1,t2)
	in
	    ( t, O.AppTyp(typInfo(i,t), typ1', typ2') )
	end

      | elabTyp(E, I.RefTyp(i, typ)) =
	let
	    val (t1,typ') = elabTyp(E, typ)
	    val  _        = case Type.kind t1 of Type.STAR => () | k =>
				error(I.infoTyp typ, ElabError.RefTypKind(k))
	    val  t        = refTyp t1
	in
	    ( t, O.RefTyp(typInfo(i,t), typ') )
	end

      | elabTyp(E, I.TupTyp(i, typs)) =
	let
	    val (ts,typs') = elabStarTyps(E, typs)
	    val  t         = Type.inTuple ts
	in
	    ( t, O.TupTyp(typInfo(i,t), typs') )
	end

      | elabTyp(E, I.RowTyp(i, typrow)) =
	let
	    val (t,typrow') = elabRow(elabStarTyp, E, typrow)
	in
	    ( t, O.RowTyp(typInfo(i,t), typrow') )
	end

      | elabTyp(E, I.ArrTyp(i, typ1, typ2)) =
	let
	    val (t1,typ1') = elabStarTyp(E, typ1)
	    val (t2,typ2') = elabStarTyp(E, typ2)
	    val  t         = Type.inArrow(t1,t2)
	in
	    ( t, O.ArrTyp(typInfo(i,t), typ1', typ2') )
	end

      | elabTyp(E, I.SumTyp(i, cons)) =
	let
	    val (t,cons') = elabCons(E, cons)
	in
	    ( t, O.SumTyp(typInfo(i,t), cons') )
	end

      | elabTyp(E, I.AllTyp(i, id, typ)) =
	let
	    val (a,id')   = elabVarId(E, Type.STAR, id)
	    val (t1,typ') = elabTyp(E, typ)
	    val  t        = Type.inAll(a,t1)
	in
	    ( t, O.AllTyp(typInfo(i,t), id', typ') )
	end

      | elabTyp(E, I.ExTyp(i, id, typ)) =
	let
	    val (a,id')   = elabVarId(E, Type.STAR, id)
	    val (t1,typ') = elabTyp(E, typ)
	    val  t        = Type.inExist(a,t1)
	in
	    ( t, O.ExTyp(typInfo(i,t), id', typ') )
	end

      | elabTyp(E, I.AbsTyp(i)) =
	Crash.crash "Elab.elabTyp: AbsTyp"

      | elabTyp(E, I.ExtTyp(i)) =
	Crash.crash "Elab.elabTyp: ExtTyp"

      | elabTyp(E, I.SingTyp(i, longid)) =
	Crash.crash "Elab.elabTyp: SingTyp"


    and elabStarTyps(E, typs) =
	ListPair.unzip(List.map (fn typ => elabStarTyp(E, typ)) typs)


    and elabCon(E, I.Con(i, id, typs)) =
	let
	    val  l         = Lab.fromString(I.lab(I.idToLab id))
	    val (t,id')    = elabValId(E, id)
	(*UNFINISHED*)
	    val (ts,typs') = elabStarTyps(E, typs)
	in
	    ( l, t, O.Con(nonInfo(i), id', typs') )
	end

    and elabCons(E, cons) =
	let
	    fun elabCon1(con, (r,cons')) =
		let
		    val (l,t,con') = elabCon(E, con)
		in
		    ( Type.extendRow(l,t,r), con'::cons' )
		end

	    val (r,cons') = List.foldr elabCon1 (Type.emptyRow(), []) cons
	in
	    ( Type.inRow r, cons' )
	end


    and elabTypRep(E, id', buildKind, I.ConTyp(i, longid)) =
	(*UNFINISHED: if t is a sum, enter constructors*)
	let
	    val (t,longid') = elabTypLongid(E, longid)
	in
	    ( t, O.ConTyp(typInfo(i,t), longid') )
	end

      | elabTypRep(E, O.Id(_,stamp,name), buildKind, I.AbsTyp(i)) =
	let
	    val k = buildKind Type.STAR
	    val p = Path.PLAIN(stamp, name)
	    val t = Type.inCon (k, Type.CLOSED, p)
	in
	    ( t, O.AbsTyp(typInfo(i,t)) )
	end

      | elabTypRep(E, O.Id(_,stamp,name), buildKind, I.ExtTyp(i)) =
	let
	    val k = buildKind Type.STAR
	    val p = Path.PLAIN(stamp, name)
	    val t = Type.inCon (k, Type.OPEN, p)
	in
	    ( t, O.AbsTyp(typInfo(i,t)) )
	end

      | elabTypRep(E, id', buildKind, I.FunTyp(i, id, typ)) =
	let
	    val (a,id')   = elabVarId(E, Type.STAR, id)
	    val  k1       = Type.kindVar a
	    val (t1,typ') = elabTypRep(E, id',
				       fn k => Type.ARROW(k1, buildKind k), typ)
	    val  t        = Type.inLambda(a,t1)
	in
	    ( t, O.FunTyp(typInfo(i,t), id', typ') )
	end

      | elabTypRep(E, id', buildKind, I.SumTyp(i, cons)) =
	(*UNFINISHED: enter constructors*)
	let
	    val (t,cons') = elabCons(E, cons)
	in
	    ( t, O.SumTyp(typInfo(i,t), cons') )
	end

      | elabTypRep(E, id', buildKind, typ) =
	    elabTyp(E, typ)


  (* Modules *)

    and elabModId(E, id as I.Id(i, stamp, name)) =
	(* May be binding occurance *)
	let
	    val j = #2(lookupMod(E, stamp))
		    handle Lookup _ =>
			(*UNFINISHED*)
			let val j = () in
			    insertMod(E, stamp, (id,j,new())) ; j
			end
	in
	    ( j, O.Id(infInfo(i,j), stamp, name) )
	end

    and elabModLongid(E, I.ShortId(i, id)) =
	let
	    val (j,id') = elabModId(E, id)
	in
	    ( j, O.ShortId(infInfo(i,j), id') )
	end

      | elabModLongid(E, I.LongId(i, longid, lab)) =
	(*UNFINISHED*)
	let
	    val (E',longid') = elabModLongid(E, longid)
	    val (l,lab')     = elabLab(E, lab)
	    val  j           = ()
	in
	    unfinished i "elabModLongid" "long ids";
	    ( j, O.LongId(infInfo(i,j), longid', lab') )
	end


    and elabMod(E, I.VarMod(i, id)) =
	let
	    val (j,id') = elabModId(E, id)
	in
	    ( j, O.VarMod(infInfo(i,j), id') )
	end

      | elabMod(E, I.StrMod(i, decs)) =
	let
	    val decs' = elabDecs(E, decs)
	(*UNFINISHED*)
	    val j     = ()
	in
	    ( j, O.StrMod(infInfo(i,j), decs') )
	end

      | elabMod(E, I.SelMod(i, mod, lab)) =
	let
	    val (j1,mod') = elabMod(E, mod)
	    val (l,lab')  = elabLab(E, lab)
	(*UNFINISHED*)
	    val  j        = ()
	in
	    ( j, O.SelMod(infInfo(i,j), mod', lab') )
	end

      | elabMod(E, I.FunMod(i, id, inf, mod)) =
	let
	    val  _        = insertScope E
	    val (j1,inf') = elabInf(E, inf)
	(*UNFINISHED: copy j1 and strengthen it *)
	    val (j3,id')  = elabModId(E, id)
	    val (j2,mod') = elabMod(E, mod)
	    val  _        = deleteScope E
	(*UNFINISHED*)
	    val  j        = ()
	in
	    ( j, O.FunMod(infInfo(i,j), id', inf', mod') )
	end

      | elabMod(E, I.AppMod(i, mod1, mod2)) =
	let
	    val (j1,mod1') = elabMod(E, mod1)
	    val (j2,mod2') = elabMod(E, mod2)
	(*UNFINISHED*)
	    val  j         = ()
	in
	    ( j, O.AppMod(infInfo(i,j), mod1', mod2') )
	end

      | elabMod(E, I.AnnMod(i, mod, inf)) =
	let
	    val (j1,mod') = elabMod(E, mod)
	    val (j2,inf') = elabInf(E, inf)
	(*UNFINISHED*)
	    val  j        = ()
	in
	    unfinished i "elabMod" "annotated modules";
	    ( j, O.AnnMod(infInfo(i,j), mod', inf') )
	end

      | elabMod(E, I.LetMod(i, decs, mod)) =
	let
	    val  _          = insertScope E
	    val  decs'      = elabDecs(E, decs)
	    val (j,mod')    = elabMod(E, mod)
	    val  _          = deleteScope E
	in
	    ( j, O.LetMod(infInfo(i,j), decs', mod') )
	end


  (* Interfaces *)

    and elabInfId(E, id as I.Id(i, stamp, name)) =
	(* May be binding occurance *)
	let
	    val j = #2(lookupInf(E, stamp))
		    handle Lookup _ =>
			(*UNFINISHED*)
			let val j = () in
			    insertInf(E, stamp, (id,j,new())) ; j
			end
	in
	    ( j, O.Id(infInfo(i,j), stamp, name) )
	end

    and elabInfLongid(E, I.ShortId(i, id)) =
	let
	    val (j,id') = elabInfId(E, id)
	in
	    ( j, O.ShortId(infInfo(i,j), id') )
	end

      | elabInfLongid(E, I.LongId(i, longid, lab)) =
	(*UNFINISHED*)
	let
	    val (E',longid') = elabInfLongid(E, longid)
	    val (l,lab')     = elabLab(E, lab)
	    val  j           = ()
	in
	    unfinished i "elabModLongid" "long ids";
	    ( j, O.LongId(infInfo(i,j), longid', lab') )
	end


    and elabInf(E, I.AnyInf(i)) =
	let
	(*UNFINISHED*)
	    val j = ()
	in
	    ( j, O.AnyInf(infInfo(i,j)) )
	end

      | elabInf(E, I.ConInf(i, longid)) =
	let
	    val (j,longid') = elabInfLongid(E, longid)
	in
	    ( j, O.ConInf(infInfo(i,j), longid') )
	end

      | elabInf(E, I.SigInf(i, specs)) =
	let
	    val specs' = elabSpecs(E, specs)
	(*UNFINISHED*)
	    val j      = ()
	in
	    ( j, O.SigInf(infInfo(i,j), specs') )
	end

      | elabInf(E, I.FunInf(i, id, inf1, inf2)) =
	let
	    val  _         = insertScope E
	    val (j1,inf1') = elabInf(E, inf1)
	(*UNFINISHED: copy j1 and strengthen it *)
	    val (j3,id')   = elabModId(E, id)
	    val (j2,inf2') = elabInf(E, inf2)
	    val  _         = deleteScope E
	(*UNFINISHED*)
	    val  j        = ()
	in
	    ( j, O.FunInf(infInfo(i,j), id', inf1', inf2') )
	end

      | elabInf(E, I.AppInf(i, inf, mod)) =
	let
	    val (j1,inf') = elabInf(E, inf)
	    val (j2,mod') = elabMod(E, mod)
	(*UNFINISHED*)
	    val j = ()
	in
	    ( j, O.AppInf(infInfo(i,j), inf', mod') )
	end

      | elabInf(E, I.CompInf(i, inf1, inf2)) =
	let
	    val (j1,inf1') = elabInf(E, inf1)
	    val (j2,inf2') = elabInf(E, inf2)
	(*UNFINISHED*)
	    val j = ()
	in
	    ( j, O.CompInf(infInfo(i,j), inf1', inf2') )
	end

      | elabInf(E, I.ArrInf(i, id, inf1, inf2)) =
	let
	    val  _         = insertScope E
	    val (j1,inf1') = elabInf(E, inf1)
	(*UNFINISHED: copy j1 and strengthen it *)
	    val (j3,id')   = elabModId(E, id)
	    val (j2,inf2') = elabInf(E, inf2)
	    val  _         = deleteScope E
	(*UNFINISHED*)
	    val  j         = ()
	in
	    ( j, O.ArrInf(infInfo(i,j), id', inf1', inf2') )
	end

      | elabInf(E, I.SingInf(i, mod)) =
	let
	    val (j1,mod') = elabMod(E, mod)
	(*UNFINISHED*)
	    val j = ()
	in
	    ( j, O.SingInf(infInfo(i,j), mod') )
	end

      | elabInf(E, I.AbsInf(i)) =
	Crash.crash "Elab.elabInf: AbsInf"


    and elabInfRep(E, O.Id(_,stamp,name), I.AbsInf(i)) =
	let
	    val p = Path.PLAIN(stamp, name)
	(*UNFINISHED*)
	    val j = ()
	in
	    ( j, O.AbsInf(infInfo(i,j)) )
	end

      | elabInfRep(E, id', I.FunInf(i, id, inf1, inf2)) =
	let
	    val  _         = insertScope E
	    val (j1,inf1') = elabInf(E, inf1)
	(*UNFINISHED: copy j1 and strengthen it *)
	    val (j3,id1')  = elabModId(E, id)
	    val (j2,inf2') = elabInfRep(E, id', inf2)
	    val  _         = deleteScope E
	(*UNFINISHED*)
	    val  j        = ()
	in
	    ( j, O.FunInf(infInfo(i,j), id1', inf1', inf2') )
	end

      | elabInfRep(E, id', inf) =
	    elabInf(E, inf)


  (* Declarations *)

    and elabDec(E, I.ValDec(i, pat, exp)) =
	let
	    val (t2,exp') = elabExp(E, exp)
	    val (t1,pat') = elabPat(E, pat)
	    val  _        = Type.unify(t1,t2)
			    handle Type.Unify(t3,t4) =>
				error(i, ElabError.ValDecUnify(t1, t2, t3, t4))
	in
	    O.ValDec(nonInfo(i), pat', exp')
	end

      | elabDec(E, I.ConDec(i, con, typ)) =
	(*UNFINISHED*)
	let
	    val  _          = insertScope E
	    val (t1,typ')   = elabTyp(E, typ)
	    val (l,t3,con') = elabCon(E, con)
	    val  _          = deleteScope E
	in
	    unfinished i "elabDec" "constructor declarations";
	    O.ConDec(nonInfo(i), con', typ')
	end

      | elabDec(E, I.TypDec(i, id, typ)) =
	let
	    val  k        = elabTypKind(E, typ)
	    val (t1,id')  = elabTypId(E, k, id)
	    val (t2,typ') = elabTypRep(E, id', fn k => k, typ)
	    val  _        = Type.unify(t1,t2)
			    handle Type.Unify(t3,t4) =>
				error(I.infoTyp typ,
				      ElabError.TypDecUnify(t1, t2, t3, t4))
	in
	    O.TypDec(nonInfo(i), id', typ')
	end

      | elabDec(E, I.ModDec(i, id, mod)) =
	let
	    val (j1,id')  = elabModId(E, id)
	    val (j2,mod') = elabMod(E, mod)
	(*UNFINISHED: strengthen j2, assign it to j1 *)
	in
	    unfinished i "elabDec" "module declarations";
	    O.ModDec(nonInfo(i), id', mod')
	end

      | elabDec(E, I.InfDec(i, id, inf)) =
	let
	    val (j1,id')  = elabInfId(E, id)
	    val (j2,inf') = elabInfRep(E, id', inf)
	(*UNFINISHED: assign j2 to j1 *)
	in
	    unfinished i "elabDec" "interface declarations";
	    O.InfDec(nonInfo(i), id', inf')
	end

      | elabDec(E, I.RecDec(i, decs)) =
	let
	    val tpats' = elabLHSRecDecs(E, decs)
	    val decs'  = elabRHSRecDecs(E, ref tpats', decs)
	in
	    O.RecDec(nonInfo(i), decs')
	end

      | elabDec(E, I.TypvarDec(i, id, decs)) =
	let
	    val (a,id') = elabVarId(E, Type.STAR, id)
	    val  decs'  = elabDecs(E, decs)
	(*UNFINISHED: check that a does not appear in top scope of E*)
	in
	    unfinished i "elabDec" "scoped type variables";
	    O.TypvarDec(nonInfo(i), id', decs')
	end

      | elabDec(E, I.LocalDec(i, decs)) =
	let
	    val decs' = elabDecs(E, decs)
	(*UNFINISHED: effects the building of the structure env*)
	in
	    unfinished i "elabDec" "local and hiding";
	    O.LocalDec(nonInfo(i), decs')
	end


    and elabDecs(E, decs) = List.map (fn dec => elabDec(E, dec)) decs


  (* Recursive declarations *)

    and elabLHSRecDecs(E, decs) =
	List.foldr (fn(dec,xs) => elabLHSRecDec(E,dec) @ xs) [] decs

    and elabLHSRecDec(E, I.ValDec(i, pat, exp)) =
	    [elabPat(E, pat)]

      | elabLHSRecDec(E, I.ConDec(i, con, typ)) =
	    ( elabLHSRecCon(E, con) ; [] )

      | elabLHSRecDec(E, I.TypDec(i, id, typ)) =
	let
	    val k = elabTypKind(E, typ)
	    val _ = elabTypId(E, k, id)
	in
	    []
	end

      | elabLHSRecDec(E, I.RecDec(i, decs)) =
	    elabLHSRecDecs(E, decs)

      | elabLHSRecDec(E, _) = []

    and elabLHSRecCon(E, I.Con(i, id, typs)) =
	(*UNFINISHED*)
	()


    and elabRHSRecDecs(E, rtpats', decs) =
	    List.map (fn dec => elabRHSRecDec(E, rtpats', dec)) decs

    and elabRHSRecDec(E, r as ref((t1,pat')::tpats'), I.ValDec(i, pat, exp)) =
	let
	    val (t2,exp') = elabExp(E, exp)
	    val  _        = r := tpats'
	    val  _        = Type.unify(t1,t2)
			    handle Type.Unify(t3,t4) =>
				error(i, ElabError.ValDecUnify(t1, t2, t3, t4))
	in
	    O.ValDec(nonInfo(i), pat', exp')
	end

      | elabRHSRecDec(E, rtpats', I.RecDec(i, decs)) =
	let
	    val dec' = elabRHSRecDecs(E, rtpats', decs)
	in
	    O.RecDec(nonInfo(i), dec')
	end

      | elabRHSRecDec(E, rtpats', dec) =
	    elabDec(E, dec)



  (* Specifications *)

    and elabSpec(E, I.ValSpec(i, id, typ)) =
	let
	    val (t1,id')  = elabValId(E, id)
	    val (t2,typ') = elabTyp(E, typ)
	    val  _        = Type.unify(t1,t2)
			    handle Type.Unify(t3,t4) =>
				Crash.crash "Elab.elabSpec: rebound value stamp"
	in
	    O.ValSpec(nonInfo(i), id', typ')
	end

      | elabSpec(E, I.ConSpec(i, con, typ)) =
	(*UNFINISHED*)
	let
	    val  _          = insertScope E
	    val (t1,typ')   = elabTyp(E, typ)
	    val (l,t3,con') = elabCon(E, con)
	    val  _          = deleteScope E
	in
	    unfinished i "elabSpec" "constructor specifications";
	    O.ConSpec(nonInfo(i), con', typ')
	end

      | elabSpec(E, I.TypSpec(i, id, typ)) =
	let
	    val  k        = elabTypKind(E, typ)
	    val (t1,id')  = elabTypId(E, k, id)
	    val (t2,typ') = elabTypRep(E, id', fn k => k, typ)
	    val  _        = Type.unify(t1,t2)
			    handle Type.Unify(t3,t4) =>
				error(I.infoTyp typ,
				      ElabError.TypSpecUnify(t1, t2, t3, t4))
	in
	    O.TypSpec(nonInfo(i), id', typ')
	end

      | elabSpec(E, I.ModSpec(i, id, inf)) =
	let
	    val (j1,id')  = elabModId(E, id)
	    val (j2,inf') = elabInf(E, inf)
	(*UNFINISHED: strengthen j2, assign it to j1 *)
	in
	    unfinished i "elabSpec" "module specifications";
	    O.ModSpec(nonInfo(i), id', inf')
	end

      | elabSpec(E, I.InfSpec(i, id, inf)) =
	let
	    val (j1,id')  = elabInfId(E, id)
	    val (j2,inf') = elabInfRep(E, id', inf)
	(*UNFINISHED: assign j2 to j1 *)
	in
	    unfinished i "elabSpec" "interface specifications";
	    O.InfSpec(nonInfo(i), id', inf')
	end

      | elabSpec(E, I.RecSpec(i, specs)) =
	let
	    val _      = elabLHSRecSpecs(E, specs)
	    val specs' = elabRHSRecSpecs(E, specs)
	in
	    O.RecSpec(nonInfo(i), specs')
	end

      | elabSpec(E, I.LocalSpec(i, specs)) =
	let
	    val specs' = elabSpecs(E, specs)
	(*UNFINISHED: effects the building of the structure env*)
	in
	    unfinished i "elabSpec" "local and hiding";
	    O.LocalSpec(nonInfo(i), specs')
	end

      | elabSpec(E, I.ExtSpec(i, inf)) =
	let
	    val (j,inf') = elabInf(E, inf)
	(*UNFINISHED: insert stuff*)
	in
	    unfinished i "elabSpec" "signature extension";
	    O.ExtSpec(nonInfo(i), inf')
	end


    and elabSpecs(E, specs) = List.map (fn spec => elabSpec(E, spec)) specs


  (* Recursive specifications *)

    and elabLHSRecSpecs(E, specs) =
	List.app (fn spec => elabLHSRecSpec(E,spec)) specs

    and elabLHSRecSpec(E, I.ConSpec(i, con, typ)) =
	    elabLHSRecCon(E, con)

      | elabLHSRecSpec(E, I.TypSpec(i, id, typ)) =
	let
	    val k = elabTypKind(E, typ)
	    val t = Type.unknown k
	in
	    insertTyp(E, I.stamp id, (id,t))
	end

      | elabLHSRecSpec(E, I.RecSpec(i, specs)) =
	    elabLHSRecSpecs(E, specs)

      | elabLHSRecSpec(E, _) = ()


    and elabRHSRecSpecs(E, specs) =
	List.map (fn spec => elabRHSRecSpec(E, spec)) specs

    and elabRHSRecSpec(E, I.RecSpec(i, specs)) =
	let
	    val spec' = elabRHSRecSpecs(E, specs)
	in
	    O.RecSpec(nonInfo(i), spec')
	end

      | elabRHSRecSpec(E, spec) =
	    elabSpec(E, spec)



  (* Programs *)

    fun elabProgram(E,program) =
	let
	    val _     = insertScope E
	    val decs' = elabDecs(E,program)
	    val _     = mergeScope E
	in
	    decs'
	end
	handle Error.Error x => ( deleteScope E ; raise Error.Error x )

  end
