signature INTERMEDIATE =
  sig

    (* Generic *)

    type info

    (* Literals *)

    datatype lit =
	  WordLit   of word
	| IntLit    of int
	| CharLit   of char
	| StringLit of string
	| RealLit   of string

    (* Identifiers *)

    type stamp      = int

    datatype name   = ExId of string | InId

    datatype lab    = Lab     of info * string
    datatype id     = Id      of info * stamp * name
    datatype longid = ShortId of info * id
		    | LongId  of info * longid * id

    (* Expressions *)

    datatype exp =
	  LitExp    of info * lit
	| VarExp    of info * longid
	| ConExp    of info * longid * exp option
	| TupExp    of info * exp list
	| RecExp    of info * exp field list		(* distinct labels *)
	| SelExp    of info * lab
	| FunExp    of info * id * exp
	| AppExp    of info * exp * exp
	| AdjExp    of info * exp * exp
	| AndExp    of info * exp * exp
	| OrExp     of info * exp * exp
	| IfExp     of info * exp * exp * exp
	| WhileExp  of info * exp * exp
	| SeqExp    of info * exp list
	| CaseExp   of info * exp * match list * longid (* failure exception *)
	| RaiseExp  of info * exp
	| HandleExp of info * exp * id * exp
	| LetExp    of info * dec list * exp

    and 'a field = Field of info * lab * 'a

    and match    = Match of info * pat * exp

    (* Patterns (always linear) *)

    and pat =
	  WildPat   of info
	| LitPat    of info * lit
	| VarPat    of info * id
	| ConPat    of info * longid * pat option
	| TupPat    of info * pat list
	| RecPat    of info * pat field list * bool (* dots *)	(* distinct *)
	| AsPat     of info * id * pat
	| AltPat    of info * pat list		(* all pats bind same ids *)
	| NegPat    of info * pat
	| GuardPat  of info * pat * exp
	| WithPat   of info * pat * dec list

    (* Declarations *)

    and dec =
	  ValDec    of info * id list * exp		(* distinct ids *)
	| ConDec    of info * id * bool (* has args *)


    (* Predefined *)

    val stamp_false :	stamp
    val stamp_true :	stamp
    val stamp_nil :	stamp
    val stamp_cons :	stamp
    val stamp_ref :	stamp
    val stamp_Match :	stamp
    val stamp_Bind :	stamp
    val stamp_eq :	stamp
    val stamp_assign :	stamp

    val id_false :	id
    val id_true :	id
    val id_nil :	id
    val id_cons :	id
    val id_ref :	id
    val id_Match :	id
    val id_Bind :	id
    val id_eq :		id
    val id_assign :	id

    val longid_false :	longid
    val longid_true :	longid
    val longid_nil :	longid
    val longid_cons :	longid
    val longid_ref :	longid
    val longid_Match :	longid
    val longid_Bind :	longid
    val longid_eq :	longid
    val longid_assign :	longid


    (* Operations *)

    val info_lab :	lab	-> info
    val info_id :	id	-> info
    val info_longid :	longid	-> info
    val info_exp :	exp	-> info
    val info_field :	'a field-> info
    val info_match :	match	-> info
    val info_pat :	pat	-> info
    val info_dec :	dec	-> info

    val output_lit :	TextIO.outstream * lit		-> unit
    val output_lab :	TextIO.outstream * lab		-> unit
    val output_id :	TextIO.outstream * id		-> unit
    val output_longid :	TextIO.outstream * longid	-> unit
    val output_exp :	TextIO.outstream * exp		-> unit
    val output_field : (TextIO.outstream * 'a -> unit)	->
			TextIO.outstream * 'a field	-> unit
    val output_match :	TextIO.outstream * match	-> unit
    val output_pat :	TextIO.outstream * pat		-> unit
    val output_dec :	TextIO.outstream * dec		-> unit

  end
