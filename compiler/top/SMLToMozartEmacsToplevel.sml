(*
 * Author:
 *   Leif Kornstaedt <kornstae@ps.uni-sb.de>
 *
 * Copyright:
 *   Leif Kornstaedt, 2001
 *
 * Last change:
 *   $Date$ by $Author$
 *   $Revision$
 *)

structure SMLToMozartEmacsToplevel =
    let
	structure Switches = MakeSwitches(val logOut = TextIO.stdOut)

	val f: (Source.desc * Url.t -> Composer.Sig.t) ref =
	    ref (fn _ => raise Crash.Crash "SMLToMozartMain.f")

	structure MozartTarget =
	    MakeMozartTarget(structure Switches = Switches
			     structure Sig = Signature)

	structure FrontendSML =
	    MakeFrontendSML(fun loadSign (desc, url) = !f (desc, url)
			    structure Switches = Switches)

	structure FrontendCommon =
	    MakeFrontendCommon(fun loadSign (desc, url) = !f (desc, url)
			       structure Switches = Switches)

	structure BackendCommon = MakeBackendCommon(Switches)

	structure BackendMozart =
	    MakeBackendMozart(structure Switches = Switches
			      structure MozartTarget = MozartTarget)

	structure Compiler =
	    MakeCompiler(structure Switches         = Switches
			 structure Target           = MozartTarget
			 structure FrontendSpecific = FrontendSML
			 structure FrontendCommon   = FrontendCommon
			 structure BackendCommon    = BackendCommon
			 structure BackendSpecific  = BackendMozart)

	structure RecursiveCompiler =
	    MakeRecursiveCompiler(structure Composer = Composer
				  structure Compiler = Compiler
				  val extension = "ozf")

	val _ = f := RecursiveCompiler.acquireSign
    in
	MakeEmacsToplevel(structure RecursiveCompiler = RecursiveCompiler)
    end
