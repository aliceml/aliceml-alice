(*
 * Author:
 *   Leif Kornstaedt <kornstae@ps.uni-sb.de>
 *
 * Copyright:
 *   Leif Kornstaedt, 2000
 *
 * Last change:
 *   $Date$ by $Author$
 *   $Revision$
 *)

functor MakeBackendCommon(Switches: SWITCHES) =
    let
	structure Phase1 =
	    MakeTracingPhase(structure Phase = FlatteningPhase
			     structure Switches = Switches
			     val name = "Flattening")
	structure Phase1' =
	    MakeDumpingPhase(structure Phase = Phase1
			     structure Switches = Switches
			     val header = "Flat Syntax"
			     val pp =
				 PrettyPrint.text
				 o OutputFlatGrammar.outputComponent
			     val switch = Switches.Debug.dumpFlatteningResult)
	structure BackendCommon = Phase1'

	structure Phase2 =
	    MakeTracingPhase(structure Phase = ValuePropagationPhase
			     structure Switches = Switches
			     val name = "Value Propagation")
	structure Phase2' =
	    MakeDumpingPhase(structure Phase = Phase2
			     structure Switches = Switches
			     val header = "Propagated Syntax"
			     val pp =
				 PrettyPrint.text
				 o OutputFlatGrammar.outputComponent
			     val switch =
				 Switches.Debug.dumpValuePropagationResult)
	structure BackendCommon =
	    ComposePhases(structure Phase1 = BackendCommon
			  structure Phase2 = Phase2'
			  structure Context = EmptyContext
			  fun context1 () = ()
			  fun context2 () = ())

	structure Phase3 =
	    MakeTracingPhase(structure Phase = LivenessAnalysisPhase
			     structure Switches = Switches
			     val name = "Liveness Analysis")
	structure Phase3' =
	    MakeDumpingPhase(structure Phase = Phase3
			     structure Switches = Switches
			     val header = "Live Syntax"
			     val pp =
				 PrettyPrint.text
				 o OutputFlatGrammar.outputComponent
			     val switch =
				 Switches.Debug.dumpLivenessAnalysisResult)
	structure BackendCommon =
	    ComposePhases(structure Phase1 = BackendCommon
			  structure Phase2  = Phase3'
			  structure Context = EmptyContext
			  fun context1 () = ()
			  fun context2 () = ())
    in
	BackendCommon
    end
