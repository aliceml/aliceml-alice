%%%
%%% Author:
%%%   Leif Kornstaedt <kornstae@ps.uni-sb.de>
%%%
%%% Copyright:
%%%   Leif Kornstaedt, 2000
%%%
%%% Last change:
%%%   $Date$ by $Author$
%%%   $Revision$
%%%

functor
import
   Word(toInt) at 'x-oz://boot/Word'
   Property(get)
   Pickle(saveWithCells)
   Open(file)
   CodeGen(translate) at '../../../stoc/backend-mozart/CodeGen.ozf'
   UrlComponent('Url$': Url) at 'x-alice:/misc/Url.ozf'
export
   'CodeGenPhase$': CodeGenPhase
define
   fun {StringToAtom S}
      {String.toAtom {ByteString.toString S}}
   end

   fun {TrOption Option TrX}
      case Option of 'NONE' then none
      [] 'SOME'(X) then some({TrX X})
      end
   end

   fun {TrInfo '#'(region: Region ...)}
      Region
   end

   fun {TrLit Lit}
      case Lit of 'WordLit'(W) then wordLit({Word.toInt W})
      [] 'IntLit'(I) then intLit(I)
      [] 'CharLit'(C) then charLit(C)
      [] 'StringLit'(S) then stringLit({ByteString.toString S})
      [] 'RealLit'(S) then realLit({String.toFloat {VirtualString.toString S}})
      end
   end

   fun {TrName Name}
      case Name of 'ExId'(S) then exId({StringToAtom S})
      [] 'InId' then inId
      end
   end

   fun {TrLabel Label}
      case Label of 'NUM'(I) then I
      [] 'ALPHA'(S) then
	 case {StringToAtom S} of 'true' then true
	 [] 'false' then false
	 [] '::' then '|'
	 elseof A then A
	 end
      end
   end

   fun {TrId 'Id'(Info Stamp Name)}
      id({TrInfo Info} Stamp {TrName Name})
   end

   fun {TrIdDef IdDef}
      case IdDef of 'IdDef'(Id) then idDef({TrId Id})
      [] 'Wildcard' then wildcard
      end
   end

   fun {TrFunFlag FunFlag}
      case FunFlag of 'PrintName'(String) then printName({StringToAtom String})
      [] 'AuxiliaryOf'(Stamp) then auxiliaryOf(Stamp)
      [] 'IsToplevel' then isToplevel
      end
   end

   fun {TrCon Con}
      case Con of 'Con'(Id) then con({TrId Id})
      [] 'StaticCon'(Stamp) then staticCon(Stamp)
      end
   end

   fun {TrArgs Args TrX}
      case Args of 'OneArg'(X) then oneArg({TrX X})
      [] 'TupArgs'(Xs) then tupArgs({Map Xs TrX})
      [] 'ProdArgs'(LabelXList) then
	 prodArgs({Map LabelXList fun {$ Label#X} {TrLabel Label}#{TrX X} end})
      end
   end

   fun {TrConArgs ConArgs TrX}
      {TrOption ConArgs fun {$ Args} {TrArgs Args TrX} end}
   end

   fun {TrProd Prod}
      case Prod of 'Tuple'(N) then tuple(N)
      [] 'Product'(Labels) then product({Map Labels TrLabel})
      end
   end

   proc {TrStm Stm Hd Tl ShareDict}
      case Stm of 'ValDec'(Info IdDef Exp) then
	 Hd = valDec({TrInfo Info} {TrIdDef IdDef} {TrExp Exp ShareDict})|Tl
      [] 'RecDec'(Info IdDefExpList) then
	 Hd = recDec({TrInfo Info}
		     {Map IdDefExpList
		      fun {$ IdDef#Exp}
			 {TrIdDef IdDef}#{TrExp Exp ShareDict}
		      end})|Tl
      [] 'RefAppDec'(Info IdDef Id) then
	 Hd = refAppDec({TrInfo Info} {TrIdDef IdDef} {TrId Id})|Tl
      [] 'TupDec'(Info IdDefs Id) then
	 Hd = tupDec({TrInfo Info} {Map IdDefs TrIdDef} {TrId Id})|Tl
      [] 'ProdDec'(Info LabelIdDefList Id) then
	 Hd = prodDec({TrInfo Info}
		      {Map LabelIdDefList
		       fun {$ Label#IdDef} {TrLabel Label}#{TrIdDef IdDef} end}
		      {TrId Id})|Tl
      [] 'RaiseStm'(Info Id) then
	 Hd = raiseStm({TrInfo Info} {TrId Id})|Tl
      [] 'ReraiseStm'(Info Id) then
	 Hd = reraiseStm({TrInfo Info} {TrId Id})|Tl
      [] 'TryStm'(Info TryBody IdDef HandleBody) then
	 Hd = tryStm({TrInfo Info} {TrBody TryBody $ nil ShareDict}
		     {TrIdDef IdDef} {TrBody HandleBody $ nil ShareDict})|Tl
      [] 'EndTryStm'(Info Body) then
	 Hd = endTryStm({TrInfo Info} {TrBody Body})|Tl
      [] 'EndHandleStm'(Info Body) then
	 Hd = endTryStm({TrInfo Info} {TrBody Body})|Tl
      [] 'TestStm'(Info Id Tests Body) then
	 Hd = testStm({TrInfo Info} {TrId Id}
		      case Tests of 'LitTests'(LitBodyList) then
			 litTests({Map LitBodyList
				   fun {$ Lit#Body}
				      {TrLit Lit}#{TrBody Body $ nil ShareDict}
				   end})
		      [] 'TagTests'(TagBodyList) then
			 tagTests({Map TagBodyList
				   fun {$ Label#N#ConArgs#Body}
				      {TrLabel Label}#N#
				      {TrConArgs ConArgs TrIdDef}#
				      {TrBody Body $ nil ShareDict}
				   end})
		      [] 'ConTests'(ConBodyList) then
			 conTests({Map ConBodyList
				   fun {$ Con#ConArgs#Body}
				      {TrCon Con}#{TrConArgs ConArgs TrIdDef}#
				      {TrBody Body $ nil ShareDict}
				   end})
		      [] 'VecTests'(VecBodyList) then
			 vecTests({Map VecBodyList
				   fun {$ IdDefs#Body}
				      {Map IdDefs TrIdDef}#
				      {TrBody Body $ nil ShareDict}
				   end})
		      end
		      {TrBody Body $ nil ShareDict})|Tl
      [] 'SharedStm'(Info Body Stamp) then
	 case {Dictionary.condGet ShareDict Stamp unit} of unit then NewStm in
	    {Dictionary.put ShareDict Stamp NewStm}
	    NewStm = sharedStm({TrInfo Info} {TrBody Body $ nil ShareDict}
			       Stamp)
	    Hd = NewStm|Tl
	 elseof Stm then
	    Hd = Stm|Tl
	 end
      [] 'ReturnStm'(Info Exp) then
	 Hd = returnStm({TrInfo Info} {TrExp Exp ShareDict})|Tl
      [] 'IndirectStm'(_ BodyOptRef) then
	 case {Access BodyOptRef} of 'SOME'(Body) then
	    {TrBody Body Hd Tl ShareDict}
	 end
      [] 'ExportStm'(Info Exp) then
	 Hd = exportStm({TrInfo Info} {TrExp Exp ShareDict})|Tl
      end
   end

   fun {TrExp Exp ShareDict}
      case Exp of 'LitExp'(Info Lit) then litExp({TrInfo Info} {TrLit Lit})
      [] 'PrimExp'(Info String) then
	 primExp({TrInfo Info} {StringToAtom String})
      [] 'NewExp'(Info) then newExp({TrInfo Info})
      [] 'VarExp'(Info Id) then varExp({TrInfo Info} {TrId Id})
      [] 'TagExp'(Info Label N) then tagExp({TrInfo Info} {TrLabel Label} N)
      [] 'ConExp'(Info Con) then conExp({TrInfo Info} {TrCon Con})
      [] 'TupExp'(Info Ids) then tupExp({TrInfo Info} {Map Ids TrId})
      [] 'ProdExp'(Info LabelIdList) then
	 prodExp({TrInfo Info}
		 {Map LabelIdList
		  fun {$ Label#Id} {TrLabel Label}#{TrId Id} end})
      [] 'VecExp'(Info Ids) then vecExp({TrInfo Info} {Map Ids TrId})
      [] 'FunExp'(Info Stamp Flags Args Body) then
	 funExp({TrInfo Info} Stamp {Map Flags TrFunFlag}
		{TrArgs Args TrIdDef} {TrBody Body $ nil ShareDict})
      [] 'PrimAppExp'(Info String Ids) then
	 primAppExp({TrInfo Info} {StringToAtom String} {Map Ids TrId})
      [] 'VarAppExp'(Info Id Args) then
	 varAppExp({TrInfo Info} {TrId Id} {TrArgs Args TrId})
      [] 'TagAppExp'(Info Label N Args) then
	 tagAppExp({TrInfo Info} {TrLabel Label} N {TrArgs Args TrId})
      [] 'ConAppExp'(Info Con Args) then
	 conAppExp({TrInfo Info} {TrCon Con} {TrArgs Args TrId})
      [] 'RefAppExp'(Info Id) then refAppExp({TrInfo Info} {TrId Id})
      [] 'SelAppExp'(Info Prod Label N Id) then
	 selAppExp({TrInfo Info} {TrProd Prod} {TrLabel Label} N {TrId Id})
      [] 'FunAppExp'(Info Id Stamp Args) then
	 funAppExp({TrInfo Info} {TrId Id} Stamp {TrArgs Args TrId})
      end
   end

   proc {TrBody Stms Hd Tl ShareDict}
      {FoldL Stms
       proc {$ Hd Stm Tl}
	  {TrStm Stm Hd Tl ShareDict}
       end Hd Tl}
   end

   fun {TrComponent Import#(Body#Sign)}
      {Map Import
       fun {$ IdDef#Sign#U}
	  {TrIdDef IdDef}#Sign#{StringToAtom {Url.toString U}}
       end}#
      ({TrBody Body $ nil {NewDictionary}}#Sign)
   end

   fun {Translate Desc Component} InFilename in
      InFilename = case Desc of 'SOME'(U) then {Url.toString U}
		   [] 'NONE' then ''
		   end
      {CodeGen.translate InFilename {TrComponent Component}}
   end

   fun {Sign _#_#Sign}
      Sign
   end

   fun {Apply F#_#_}
      {{Property.get 'alice.modulemanager'} link(F)}
      unit
   end

   proc {WriteFile VS File} F in
      F = {New Open.file init(name: File flags: [write create truncate])}
      {F write(vs: VS)}
      {F close()}
   end

   fun {Save OutFilename OutputAssembly F#VS#_}
      {Pickle.saveWithCells F OutFilename '' 0}
      if OutputAssembly then
	 {WriteFile VS OutFilename#'.ozm'}
      end
      unit
   end

   CodeGenPhase =
   'CodeGenPhase'(translate: Translate
		  sign: Sign
		  apply: Apply
		  save: Save)
end
