<?php include("macros.php3"); ?>
<?php heading("The <TT>Option</TT> structure", "The <TT>Option</TT> structure") ?>

<?php section("synopsis", "synopsis") ?>

  <PRE>
    signature OPTION
    structure Option : OPTION
  </PRE>

  <P>
    An extended version of the
    <A href="http://www.dina.kvl.dk/~sestoft/sml/option.html">Standard ML
    Basis' <TT>Option</TT></A> structure.
  </P>

  <P>
    The type <TT>option</TT> and its constructors, the exception <TT>Option</TT>
    and the functions <TT>isSome</TT>, <TT>isNone</TT>, <TT>valOf</TT> and
    <TT>getOpt</TT> are available in the
    <A href="toplevel.php3">top-level environment</A>.
  </P>

<?php section("import", "import") ?>

  <P>
    Imported implicitly.
  </P>

<?php section("interface", "interface") ?>

  <PRE>
    signature OPTION =
    sig
	datatype 'a option = NONE | SOME of 'a
	type     'a t      = 'a option

	exception Option

	val equal :          ('a * 'a -> bool) -> 'a option * 'a option -> bool
	val compare :        ('a * 'a -> order) -> 'a option * 'a option -> order

	val isSome :         'a option -> bool
	val isNone :         'a option -> bool
	val valOf :          'a option -> 'a
	val getOpt :         'a option * 'a -> 'a

	val filter :         ('a -> bool) -> 'a -> 'a option
	val join :           'a option option -> 'a option
	val app :            ('a -> unit) -> 'a option -> unit
	val map :            ('a -> 'b) -> 'a option -> 'b option
	val mapPartial :     ('a -> 'b option) -> 'a option -> 'b option
	val fold :           ('a * 'b -> 'b) -> 'b -> 'a option -> 'b
	val compose :        ('a -> 'c) * ('b -> 'a option) -> 'b -> 'c option
	val composePartial : ('a -> 'c option) * ('b -> 'a option) -> 'b -> 'c option
    end
  </PRE>

<?php section("description", "description") ?>

  <P>
    Items not described here are as in the 
    <A href="http://www.dina.kvl.dk/~sestoft/sml/option.html">Standard ML
    Basis' <TT>Option</TT></A> structure.
  </P>

  <DL>
    <DT>
      <TT>type t = option</TT>
    </DT>
    <DD>
      <P>A synonym for type <TT>option</TT>.</P>
    </DD>

    <DT>
      <TT>isNone <I>opt</I></TT>
    </DT>
    <DD>
      <P>Returns <TT>true</TT> if
      <TT><I>opt</I></TT> is <TT>NONE</TT>, <TT>false</TT> otherwise.
      This function is the negation of the function <TT>isSome</TT>.</P>
    </DD>

    <DT>
      <TT>app <I>f</I> <I>opt</I></TT>
    </DT>
    <DD>
      <P>Applies the function <TT><I>f</I></TT> to
      <TT><I>v</I></TT> if <TT><I>opt</I></TT> is <TT>SOME <I>v</I></TT>, and
      does nothing otherwise.</P>
    </DD>

    <DT>
      <TT>fold <I>f</I> <I>b</I> <I>opt</I></TT>
    </DT>
    <DD>
      <P>Returns <TT><I>f</I> (<I>v</I>,<I>b</I>)</TT> if 
      <TT><I>opt</I></TT> is <TT>SOME <I>v</I></TT>, and <TT><I>b</I></TT>
      otherwise.</P>
    </DD>

    <DT>
      <TT>equal <I>equal'</I> (<I>opt1</I>, <I>opt2</I>)</TT>
    </DT>
    <DD>
      <P>Creates an equality function on options, given a suitable equality
      function for the constituent type.</P>
    </DD>

    <DT>
      <TT>compare <I>compare'</I> (<I>opt1</I>, <I>opt2</I>)</TT>
    </DT>
    <DD>
      <P>Creates an ordering function on options, given a suitable ordering
      function on the constituent type. The constructed ordering is defined
      as follows:</P>
      <PRE>
      fun compare compare' =
	  fn (NONE,   NONE)   = EQUAL
	   | (NONE,   SOME _) = LESS
	   | (SOME _, NONE)   = GREATER
	   | (SOME x, SOME y) = compare' (x, y)</PRE>
    </DD>
  </DL>

<?php section("also", "see also") ?>

  <DL><DD>
    <A href="pair.php3">Alt</A>
  </DD></DL>

<?php footing() ?>
