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
	structure Phase1 =
	    MakeResultDumpingPhase(
		structure Phase = Phase1
		structure Switches = Switches
		val header = "Flat Syntax"
		val pp = PrettyPrint.text o OutputFlatGrammar.outputComponent
		val switch = Switches.Debug.dumpFlatteningResult)
	structure BackendCommon = Phase1

	structure Phase2 =
	    MakeTracingPhase(structure Phase = ValuePropagationPhase
			     structure Switches = Switches
			     val name = "Value Propagation")
	structure Phase2 =
	    MakeContextDumpingPhase(
		structure Phase = Phase2
		structure Switches = Switches
		val header = "Environment after value propagation"
		val pp = ValuePropagationPhase.dumpContext
		val switch = Switches.Debug.dumpValuePropagationContext)
	structure Phase2 =
	    MakeResultDumpingPhase(
		structure Phase = Phase2
		structure Switches = Switches
		val header = "Propagated Syntax"
		val pp = PrettyPrint.text o OutputFlatGrammar.outputComponent
		val switch = Switches.Debug.dumpValuePropagationResult)
	structure BackendCommon =
	    ComposePhases'(structure Phase1 = BackendCommon
			   structure Phase2 = Phase2)

	structure Phase3 = MakeLivenessAnalysisPhase(Switches)
	structure BackendCommon =
	    ComposePhases'(structure Phase1 = BackendCommon
			   structure Phase2 = Phase3)

	structure Phase4 =
	    MakeTracingPhase(structure Phase = DeadCodeEliminationPhase
			     structure Switches = Switches
			     val name = "Dead Code Elimination")
	structure Phase4 =
	    MakeResultDumpingPhase(
		structure Phase = Phase4
		structure Switches = Switches
		val header = "Undead Syntax"
		val pp = PrettyPrint.text o OutputFlatGrammar.outputComponent
		val switch = Switches.Debug.dumpDeadCodeEliminationResult)
	structure BackendCommon =
	    ComposePhases'(structure Phase1 = BackendCommon
			   structure Phase2 = Phase4)
    in
	BackendCommon
    end
