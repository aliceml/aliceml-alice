(*
 * Global stamp generator.
 *)


structure GlobalStamp :> GLOBAL_STAMP  =
  struct

    datatype stamp		= GEN of int * Posix.ProcEnv.pid | STR of string
    type     t			= stamp

    val r			= ref 0

    fun new()			= (r := !r + 1; GEN(!r, Posix.ProcEnv.getpid()))

    fun fromString s		= STR s

    fun toString(GEN(n,_))	= Int.toString n
      | toString(STR s)		= s

    fun hash(GEN(n,_))		= n
      | hash(STR s)		= StringHashKey.hash s

  end
