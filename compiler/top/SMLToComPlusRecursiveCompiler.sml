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

structure SMLToComPlusMain =
    MakeMain(structure Composer = Composer
	     structure Compiler = SMLToComPlusCompiler
	     structure TargetInitialContext = InitialEmptyContext
	     val executableHeader = "")
