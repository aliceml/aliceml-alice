(*
 * Authors:
 *   Leif Kornstaedt <kornstae@ps.uni-sb.de>
 *   Andreas Rossberg <rossberg@ps.uni-sb.de>
 *
 * Copyright:
 *   Leif Kornstaedt and Andreas Rossberg, 2001-2005
 *
 * Last change:
 *   $Date$ by $Author$
 *   $Revision$
 *)

import structure Date         from "Date"
import structure OS           from "OS"
import signature CONFIG       from "CONFIG-sig"
import structure UnsafeConfig from "UnsafeConfig"

structure Config : CONFIG =
struct
    datatype platform = WIN32 | UNIX

    val platform = UnsafeConfig.platform
    val vm = UnsafeConfig.vm

(*--** obtain from UnsafeConfig; normalize *)
    fun homeDir () = Option.valOf (OS.Process.getEnv "ALICE_HOME")

    val pathEscape =
	case platform of
	    WIN32 => NONE
	  | UNIX => SOME #"\\"

    val pathSeparator =
	case platform of
	    WIN32 => #";"
	  | UNIX => #":"

    val major = 1
    val minor = 1
    val revision = 0
    val version = {major, minor, revision}

    val majors = #["Stockhausen", "Kraftwerk"]

    val allMinors = #[
	    (* 0.X *) #[],
	    (* 1.X *) #["Debut", "Eval Your Own"]
	]
    val minors = Vector.sub (allMinors, major) handle Subscript => #[]

    val allRevisions = #[
	    (* 0.X *) #[],
	    (* 1.X *) #[
		(* 1.0.X *) #["", "Lord of the Lib"],
		(* 1.1.X *) #[""]
			]
	]
    val revisions = Vector.sub (Vector.sub (allRevisions, major), minor)
		    handle Subscript => #[]

    fun name (s, vs, n) =
	"'" ^ Vector.sub (vs, n) ^ "' " ^ s
	handle Subscript => s ^ " " ^ Int.toString (n+1)

    val codename =
	case vm of
	    "mozart" => "Stockhausen Operette 3 Ultrarare Mix"
	  | "seam" =>
		"Kraftwerk " ^ name ("Album", minors, minor) ^
		(if revision = 0 then "" else
		 " " ^ name ("Remix", revisions, revision))
	  | _ => "Alien Invaders Breakz Mix"

    val buildDate = valOf (Date.fromISO ("substr(esyscmd(date "-I"), 0, 10)"))
end
