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

(*
 * An implementation of Tarjan's Depth-First Search algorithm.
 * Takes a map describing a directed graph as input,
 * returns a topological ordering of all strongly connected components.
 *)

functor MakeDepthFirstSearch
    (structure Key: HASH_KEY
     structure Map: IMP_MAP where type key = Key.t): DEPTH_FIRST_SEARCH =
    struct
	structure Map = Map

	type state =
	     {currentId: int ref,
	      stack: Key.t list ref,
	      done: int Map.t,
	      sorted: Key.t list list ref}

	fun newState (): state =
	    {currentId = ref 0,
	     stack = ref nil,
	     done = Map.new (),
	     sorted = ref nil}

	fun getCycle (key::keyr, key', state: state) =
	    if Key.equals (key, key') then (#stack state := keyr; [key])
	    else key::getCycle (keyr, key', state)
	  | getCycle (nil, _, _) = raise Assert.failure

	fun visit (map, key, state as {currentId, stack, done, sorted}) =
	    let
		val id = !currentId
		val _ = Map.insertDisjoint (done, key, id)
		val _ = currentId := id + 1
		val _ = stack := key::(!stack)
		val minId =
		    List.foldl
		    (fn (key', minId) =>
		     Int.min (case Map.lookup (done, key') of
				  SOME id => id
				| NONE => visit (map, key', state), minId))
		    id (Map.lookupExistent (map, key))
	    in
		if minId = id then
		    (Map.insert (done, key, Map.size map);
		     sorted := getCycle (!stack, key, state)::(!sorted))
		else ();
		minId
	    end

	fun search map =
	    let
		val state as {done, sorted, ...} = newState ()
	    in
		Map.appi (fn (key, _) =>
			  if Map.member (done, key) then ()
			  else ignore (visit (map, key, state))) map;
		!sorted
	    end
    end
