%%%
%%% Author:
%%%   Leif Kornstaedt <kornstae@ps.uni-sb.de>
%%%
%%% Copyright:
%%%   Leif Kornstaedt, 2002
%%%
%%% Last change:
%%%   $Date$ by $Author$
%%%   $Revision$
%%%

functor
export
   interpreter: Me
define
   NONE = 0
   SOME = 1

   IdDef    = 0
   Wildcard = 1

   Global = 0
   Local  = 1

   OneArg  = 0
   TupArgs = 1

   %Function = 0

   AppConst       = 0
   AppPrim        = 1
   AppVar         = 2
   ConTest        = 3
   EndHandle      = 4
   EndTry         = 5
   GetRef         = 6
   GetTup         = 7
   IntTest        = 8
   Kill           = 9
   PutCon         = 10
   PutConst       = 11
   PutFun         = 12
   PutNew         = 13
   PutRef         = 14
   PutTag         = 15
   PutTup         = 16
   PutVar         = 17
   PutVec         = 18
   Raise          = 19
   RealTest       = 20
   Reraise        = 21
   Return         = 22
   Shared         = 23
   StringTest     = 24
   TagTest        = 25
   Try            = 26
   VecTest        = 27
   WideStringTest = 28

   Con       = 0
   StaticCon = 1

   fun {Deref X}
      case X of transient(TransientState) then
	 case {Access TransientState} of ref(Y) then {Deref Y}
	 else X
	 end
      else X
      end
   end

   fun {LitCase I N X YInstrVec ElseInstr}
      if I > N then ElseInstr
      elsecase YInstrVec.I of tuple(!X ThenInstr) then ThenInstr
      else {LitCase I + 1 N X YInstrVec ElseInstr}
      end
   end

   fun {TagCase I N T Cases}
      if I > N then unit
      elsecase Cases.I of Case=tuple(!T _ _) then Case
      else {TagCase I + 1 N T Cases}
      end
   end

   fun {NullaryConCase I N C Cases Closure L ElseInstr}
      if I > N then ElseInstr
      elsecase Cases.I of tuple(Con0 ThenInstr) then C2 in
	 C2 = case Con0 of tag(!Con IdRef) then
		 case IdRef of tag(!Local Id) then L.Id
		 [] tag(!Global J) then Closure.(J + 2)
		 end
	      [] tag(!StaticCon X) then X
	      end
	 if C == C2 then ThenInstr
	 else {NullaryConCase I + 1 N C Cases Closure L ElseInstr}
	 end
      end
   end

   fun {NAryConCase I N C Cases Closure L}
      if I > N then unit
      elsecase Cases.I of Case=tuple(Con0 _ _) then C2 in
	 C2 = case Con0 of tag(!Con IdRef) then
		 case IdRef of tag(!Local Id) then L.Id
		 [] tag(!Global J) then Closure.(J + 2)
		 end
	      [] tag(!StaticCon X) then X
	      end
	 if C == C2 then Case
	 else {NAryConCase I + 1 N C Cases Closure L}
	 end
      end
   end

   fun {VecCase I N J IdDefsInstrVec}
      if I > N then unit
      elsecase IdDefsInstrVec.I
      of Case=tuple(IdDefs _) andthen {Width IdDefs} == J then Case
      else {VecCase I + 1 N J IdDefsInstrVec}
      end
   end

   fun {Emulate Instr Closure L TaskStack}
      case Instr of tag(!Kill Ids NextInstr) then
	 for I in 1..{Width Ids} do
	    L.(Ids.I) := killed
	 end
	 {Emulate NextInstr Closure L TaskStack}
      [] tag(!PutConst Id X NextInstr) then
	 L.Id := X
	 {Emulate NextInstr Closure L TaskStack}
      [] tag(!PutVar Id IdRef NextInstr) then
	 L.Id := case IdRef of tag(!Local Id2) then L.Id2
		 [] tag(!Global I) then Closure.(I + 2)
		 end
	 {Emulate NextInstr Closure L TaskStack}
      [] tag(!PutNew Id NextInstr) then
	 L.Id := {NewName}
	 {Emulate NextInstr Closure L TaskStack}
      [] tag(!PutTag Id I IdRefs NextInstr) then N T in
	 N = {Width IdRefs}
	 T = {MakeTuple tag N + 1}
	 T.1 = I
	 for J in 1..N do
	    T.(J + 1) = case IdRefs.J of tag(!Local Id2) then L.Id2
			[] tag(!Global K) then Closure.(K + 2)
			end
	 end
	 L.Id := T
	 {Emulate NextInstr Closure L TaskStack}
      [] tag(!PutCon Id Con0 IdRefs NextInstr) then N T in
	 N = {Width IdRefs}
	 T = {MakeTuple con N + 1}
	 T.1 = case Con0 of tag(!Con IdRef) then
		  case IdRef of tag(!Local Id2) then L.Id2
		  [] tag(!Global I) then Closure.(I + 2)
		  end
	       [] tag(!StaticCon X) then X
	       end
	 for J in 1..N do
	    T.(J + 1) = case IdRefs.J of tag(!Local Id2) then L.Id2
			[] tag(!Global K) then Closure.(K + 2)
			end
	 end
	 L.Id := T
	 {Emulate NextInstr Closure L TaskStack}
      [] tag(!PutRef Id IdRef NextInstr) then
	 L.Id := {NewCell case IdRef of tag(!Local Id2) then L.Id2
			  [] tag(!Global I) then Closure.(I + 2)
			  end}
	 {Emulate NextInstr Closure L TaskStack}
      [] tag(!PutTup Id IdRefs NextInstr) then N T in
	 N = {Width IdRefs}
	 T = {MakeTuple tuple N}
	 for J in 1..N do
	    T.J = case IdRefs.J of tag(!Local Id2) then L.Id2
		  [] tag(!Global K) then Closure.(K + 2)
		  end
	 end
	 L.Id := T
	 {Emulate NextInstr Closure L TaskStack}
      [] tag(!PutVec Id IdRefs NextInstr) then N T in
	 N = {Width IdRefs}
	 T = {MakeTuple vector N}
	 for J in 1..N do
	    T.J = case IdRefs.J of tag(!Local Id2) then L.Id2
		  [] tag(!Global K) then Closure.(K + 2)
		  end
	 end
	 L.Id := T
	 {Emulate NextInstr Closure L TaskStack}
      [] tag(!PutFun Id IdRefs Function NextInstr) then N NewClosure in
	 N = {Width IdRefs}
	 NewClosure = {MakeTuple closure N + 1}
	 NewClosure.1 = Function
	 for J in 1..N do
	    NewClosure.(J + 1) = case IdRefs.J of tag(!Local Id2) then L.Id2
				 [] tag(!Global K) then Closure.(K + 2)
				 end
	 end
	 L.Id := NewClosure
	 {Emulate NextInstr Closure L TaskStack}
      [] tag(!AppPrim Op IdRefs IdDefInstrOpt) then Args in
	 case {Width IdRefs} of 1 then
	    Args = arg(case IdRefs.1 of tag(!Local Id) then L.Id
		       [] tag(!Global K) then Closure.(K + 2)
		       end)
	 elseof N then
	    Args = {MakeTuple args N}
	    for J in 1..N do
	       Args.J = case IdRefs.J of tag(!Local Id) then L.Id
			[] tag(!Global K) then Closure.(K + 2)
			end
	    end
	 end
	 case IdDefInstrOpt of !NONE then   % tail call
	    continue(Args {Op.1.1.pushCall Op TaskStack})
	 [] tag(!SOME tuple(IdDef NextInstr)) then NewFrame in
	    NewFrame = frame(Me tag(!OneArg IdDef) NextInstr Closure L)
	    continue(Args {Op.1.1.pushCall Op NewFrame|TaskStack})
	 end
      [] tag(!AppVar IdRef IdRefArgs IdDefArgsInstrOpt) then Op in
	 Op = case IdRef of tag(!Local Id) then L.Id
	      [] tag(!Global I) then Closure.(I + 2)
	      end
	 {Emulate tag(AppConst Op IdRefArgs IdDefArgsInstrOpt)
	  Closure L TaskStack}
      [] tag(!AppConst Op0 IdRefArgs IdDefArgsInstrOpt) then Args in
	 case {Deref Op0} of Transient=transient(_) then NewFrame in
	    NewFrame = frame(Me tag(TupArgs vector()) Instr Closure L)
	    request(Transient args() NewFrame|TaskStack)
	 elseof Op then
	    %% construct argument:
	    case IdRefArgs of tag(!OneArg IdRef) then
	       Args = arg(case IdRef of tag(!Local Id) then L.Id
			  [] tag(!Global I) then Closure.(I + 2)
			  end)
	    [] tag(!TupArgs IdRefs) then N in
	       N = {Width IdRefs}
	       Args = {MakeTuple args N}
	       for J in 1..N do
		  Args.J = case IdRefs.J of tag(!Local Id) then L.Id
			   [] tag(!Global K) then Closure.(K + 2)
			   end
	       end
	    end
	    case IdDefArgsInstrOpt of !NONE then   % tail call
	       continue(Args {Op.1.1.pushCall Op TaskStack})
	    [] tag(!SOME tuple(IdDefArgs NextInstr)) then NewFrame in
	       NewFrame = frame(Me IdDefArgs NextInstr Closure L)
	       continue(Args {Op.1.1.pushCall Op NewFrame|TaskStack})
	    end
	 end
      [] tag(!GetRef Id IdRef NextInstr) then R0 in
	 R0 = case IdRef of tag(!Local Id2) then L.Id2
	      [] tag(!Global I) then Closure.(I + 2)
	      end
	 case {Deref R0} of Transient=transient(_) then NewFrame in
	    NewFrame = frame(Me tag(TupArgs vector()) Instr Closure L)
	    request(Transient args() NewFrame|TaskStack)
	 elseof R then
	    L.Id := {Access R}
	    {Emulate NextInstr Closure L TaskStack}
	 end
      [] tag(!GetTup IdDefs IdRef NextInstr) then T0 in
	 T0 = case IdRef of tag(!Local Id) then L.Id
	      [] tag(!Global I) then Closure.(I + 2)
	      end
	 case {Deref T0} of Transient=transient(_) then NewFrame in
	    NewFrame = frame(Me tag(TupArgs vector()) Instr Closure L)
	    request(Transient args() NewFrame|TaskStack)
	 elseof T then N in
	    N = {Width IdDefs}
	    for J in 1..N do
	       case IdDefs.J of tag(!IdDef Id) then
		  L.Id := T.J
	       [] !Wildcard then skip
	       end
	    end
	    {Emulate NextInstr Closure L TaskStack}
	 end
      [] tag(!Raise IdRef) then Exn in
	 Exn = case IdRef of tag(!Local Id) then L.Id
	       [] tag(!Global I) then Closure.(I + 2)
	       end
	 exception(nil Exn TaskStack)
      [] tag(!Reraise IdRef) then X in
	 X = case IdRef of tag(!Local Id) then L.Id
	     [] tag(!Global I) then Closure.(I + 2)
	     end
	 case X of package(Debug Exn) then
	    exception(Debug Exn TaskStack)
	 end
      [] tag(!Try TryInstr IdDef1 IdDef2 HandleInstr) then
	 {Emulate TryInstr Closure L
	  handler(Me IdDef1 IdDef2 HandleInstr Closure L)|TaskStack}
      [] tag(!EndTry NextInstr) then
	 case TaskStack of handler(_ _ _ _ _ _)|Rest then
	    {Emulate NextInstr Closure L Rest}
	 end
      [] tag(!EndHandle NextInstr) then
	 {Emulate NextInstr Closure L TaskStack}
      [] tag(!IntTest IdRef IntInstrVec ElseInstr) then I0 in
	 I0 = case IdRef of tag(!Local Id) then L.Id
	     [] tag(!Global J) then Closure.(J + 2)
	     end
	 case {Deref I0} of Transient=transient(_) then NewFrame in
	    NewFrame = frame(Me tag(TupArgs vector()) Instr Closure L)
	    request(Transient args() NewFrame|TaskStack)
	 elseof I then ThenInstr in
	    ThenInstr = {LitCase 1 {Width IntInstrVec} I IntInstrVec ElseInstr}
	    {Emulate ThenInstr Closure L TaskStack}
	 end
      [] tag(!RealTest IdRef RealInstrVec ElseInstr) then F0 in
	 F0 = case IdRef of tag(!Local Id) then L.Id
	      [] tag(!Global I) then Closure.(I + 2)
	      end
	 case {Deref F0} of Transient=transient(_) then NewFrame in
	    NewFrame = frame(Me tag(TupArgs vector()) Instr Closure L)
	    request(Transient args() NewFrame|TaskStack)
	 elseof F then ThenInstr in
	    ThenInstr = {LitCase 1 {Width RealInstrVec}
			 F RealInstrVec ElseInstr}
	    {Emulate ThenInstr Closure L TaskStack}
	 end
      [] tag(!StringTest IdRef StringInstrVec ElseInstr) then S0 in
	 S0 = case IdRef of tag(!Local Id) then L.Id
	     [] tag(!Global I) then Closure.(I + 2)
	     end
	 case {Deref S0} of Transient=transient(_) then NewFrame in
	    NewFrame = frame(Me tag(TupArgs vector()) Instr Closure L)
	    request(Transient args() NewFrame|TaskStack)
	 elseof S then ThenInstr in
	    ThenInstr = {LitCase 1 {Width StringInstrVec}
			 S StringInstrVec ElseInstr}
	    {Emulate ThenInstr Closure L TaskStack}
	 end
      [] tag(!WideStringTest IdRef StringInstrVec ElseInstr) then
	 {Emulate tag(StringTest IdRef StringInstrVec ElseInstr)
	  Closure L TaskStack}
      [] tag(!TagTest IdRef NullaryCases NAryCases ElseInstr) then T0 in
	 T0 = case IdRef of tag(!Local Id) then L.Id
	      [] tag(!Global I) then Closure.(I + 2)
	      end
	 case {Deref T0} of Transient=transient(_) then NewFrame in
	    NewFrame = frame(Me tag(TupArgs vector()) Instr Closure L)
	    request(Transient args() NewFrame|TaskStack)
	 elseof T then
	    if {IsInt T} then ThenInstr in
	       ThenInstr = {LitCase 1 {Width NullaryCases}
			    T NullaryCases ElseInstr}
	       {Emulate ThenInstr Closure L TaskStack}
	    elsecase {TagCase 1 {Width NAryCases} T.1 NAryCases}
	    of tuple(_ IdDefs ThenInstr) then N in
	       N = {Width IdDefs}
	       for J in 1..N do
		  case IdDefs.J of tag(!IdDef Id) then
		     L.Id := T.(J + 1)
		  [] !Wildcard then skip
		  end
	       end
	       {Emulate ThenInstr Closure L TaskStack}
	    [] unit then
	       {Emulate ElseInstr Closure L TaskStack}
	    end
	 end
      [] tag(!ConTest IdRef NullaryCases NAryCases ElseInstr) then C0 in
	 C0 = case IdRef of tag(!Local Id) then L.Id
	      [] tag(!Global I) then Closure.(I + 2)
	      end
	 case {Deref C0} of Transient=transient(_) then NewFrame in
	    NewFrame = frame(Me tag(TupArgs vector()) Instr Closure L)
	    request(Transient args() NewFrame|TaskStack)
	 elseof C then
	    if {IsName C} then ThenInstr in
	       ThenInstr = {NullaryConCase 1 {Width NullaryCases}
			    C NullaryCases Closure L ElseInstr}
	       {Emulate ThenInstr Closure L TaskStack}
	    elsecase {NAryConCase 1 {Width NAryCases} C.1 NAryCases Closure L}
	    of tuple(_ IdDefs ThenInstr) then N in
	       N = {Width IdDefs}
	       for J in 1..N do
		  case IdDefs.J of tag(!IdDef Id) then
		     L.Id := C.(J + 1)
		  [] !Wildcard then skip
		  end
	       end
	       {Emulate ThenInstr Closure L TaskStack}
	    [] unit then
	       {Emulate ElseInstr Closure L TaskStack}
	    end
	 end
      [] tag(!VecTest IdRef IdDefsInstrVec ElseInstr) then V0 in
	 V0 = case IdRef of tag(!Local Id) then L.Id
	      [] tag(!Global I) then Closure.(I + 2)
	      end
	 case {Deref V0} of Transient=transient(_) then NewFrame in
	    NewFrame = frame(Me tag(TupArgs vector()) Instr Closure L)
	    request(Transient args() NewFrame|TaskStack)
	 elseof V then
	    case {VecCase 1 {Width IdDefsInstrVec} {Width V} IdDefsInstrVec}
	    of tuple(IdDefs ThenInstr) then N in
	       N = {Width IdDefs}
	       for J in 1..N do
		  case IdDefs.J of tag(!IdDef Id) then
		     L.Id := V.J
		  [] !Wildcard then skip
		  end
	       end
	       {Emulate ThenInstr Closure L TaskStack}
	    [] unit then
	       {Emulate ElseInstr Closure L TaskStack}
	    end
	 end
      [] tag(!Shared _ NextInstr) then
	 {Emulate NextInstr Closure L TaskStack}
      [] tag(!Return IdRefArgs) then Args in
	 %% construct arguments to call the continuation with:
	 case IdRefArgs of tag(!OneArg IdRef) then
	    Args = arg(case IdRef of tag(!Local Id) then L.Id
		       [] tag(!Global I) then Closure.(I + 2)
		       end)
	 [] tag(!TupArgs IdRefs) then N in
	    N = {Width IdRefs}
	    Args = {MakeTuple args N}
	    for J in 1..N do
	       Args.J = case IdRefs.J of tag(!Local Id) then L.Id
			[] tag(!Global K) then Closure.(K + 2)
			end
	    end
	 end
	 continue(Args TaskStack)
      end
   end

   fun {Run Args TaskStack}
      try
	 case TaskStack of frame(_ IdDefArgs Instr Closure L)|Rest then
	    case IdDefArgs of tag(!OneArg IdDef0) then
	       case IdDef0 of tag(!IdDef Id) then
		  L.Id := case Args of arg(X) then X
			  [] args(...) then {Adjoin Args tuple}   % "construct"
			  end
	       [] !Wildcard then skip
	       end
	    [] tag(!TupArgs IdDefs) then T N in
	       T = case Args of arg(X0) then
		      case {Deref X0} of Transient=transient(_) then
			 raise request(Transient Args TaskStack) end
		      elseof X then X   % "deconstruct"
		      end
		   [] args(...) then Args
		   end
	       N = {Width IdDefs}
	       for J in 1..N do
		  case IdDefs.J of tag(!IdDef Id) then
		     L.Id := T.J
		  [] !Wildcard then skip
		  end
	       end
	    end
	    {Emulate Instr Closure L Rest}
	 end
      catch Request=request(_ _ _) then Request
      end
   end

   fun {Handle Debug Exn TaskStack}
      case TaskStack of handler(_ IdDef1 IdDef2 Instr Closure L)|Rest then
	 case IdDef1 of tag(!IdDef Id) then
	    L.Id := package(Debug Exn)
	 [] !Wildcard then skip
	 end
	 case IdDef2 of tag(!IdDef Id) then
	    L.Id := Exn
	 [] !Wildcard then skip
	 end
	 {Emulate Instr Closure L Rest}
      [] Frame=frame(_ _ _ _ _)|Rest then
	 exception(Frame|Debug Exn Rest)
      end
   end

   fun {PushCall Closure TaskStack}
      case Closure of closure(function(_ _ _ NL IdDefArgs BodyInstr) ...) then
	 L = {NewArray 0 NL - 1 uninitialized}
      in
	 frame(Me IdDefArgs BodyInstr Closure L)|TaskStack
      end
   end

   AliceFunction = {ByteString.make 'Alice.function'}

   fun {Abstract function(_ F#L#C NG NL IdDefArgs Instr)}
      transform(AliceFunction tag(0 tuple({ByteString.make F} L C)
				  NG NL IdDefArgs Instr))
   end

   Me = abstractCodeInterpreter(run: Run
				handle: Handle
				pushCall: PushCall
				abstract: Abstract)
end
