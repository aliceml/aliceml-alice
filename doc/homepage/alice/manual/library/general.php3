<?php include("macros.php3"); ?>
<?php heading("The <TT>General</TT> structure", "The <TT>General</TT> structure") ?>

<?php section("synopsis", "synopsis") ?>

  <PRE>
    signature GENERAL
    structure General : GENERAL
  </PRE>

  <P>
    An extended version of the
    <A href="http://www.dina.kvl.dk/~sestoft/sml/general.html">Standard ML
    Basis' <TT>General</TT></A> structure.
  </P>

  <P>
    All of the types and values defined in General are available unqualified
    in the <A href="toplevel.php3">top-level environment</A>.
  </P>

<?php section("import", "import") ?>

  <P>
    Imported implicitly.
  </P>

<?php section("interface", "interface") ?>

  <PRE>
    signature GENERAL =
    sig
	eqtype unit
	exttype exn

	datatype order = LESS | EQUAL | GREATER

	exception Bind
	exception Chr
	exception Div
	exception Domain
	exception Fail of string
	exception Match
	exception Overflow
	exception Size
	exception Span
	exception Subscript

	val exnName :    exn -> string
	val exnMessage : exn -> string

	val inverse :    order -> order

	val ! :          'a ref -> 'a
	val op := :      'a ref * 'a -> unit
	val op :=: :     'a ref * 'a ref -> unit

	val ignore :     'a -> unit
	val before :     'a * unit -> 'a

	val id :         'a -> 'a
	val const :      'a -> 'b -> 'a
	val curry :      ('a * 'b -> 'c) -> ('a -> 'b -> 'c)
	val uncurry :    ('a -> 'b -> 'c) -> ('a * 'b -> 'c)
	val flip :       ('a * 'b -> 'c) -> ('b * 'a -> 'c)
	val op o :       ('b -> 'c) * ('a -> 'b) -> 'a -> 'c
    end
  </PRE>

<?php section("description", "description") ?>

  <P>
    Items not described here are as in the 
    <A href="http://www.dina.kvl.dk/~sestoft/sml/general.html">Standard ML
    Basis' <TT>General</TT></A> structure.
  </P>

  <DL>
    <DT>
      <TT>inverse <I>order</I></TT>
    </DT>
    <DD>
      <P>Returns the inverse of the argument <TT>order</TT>.</P>
    </DD>

    <DT>
      <TT><I>re1</I> :=: <I>re2</I></TT>
    </DT>
    <DD>
      <P>Swaps the values referred to by the references <TT><I>re1</I></TT> and
      <TT><I>re2</I></TT>.</P>
    </DD>

    <DT>
      <TT>id <I>x</I></TT>
    </DT>
    <DD>
      <P>The polymorphic identity function, i.e.</P>
      <PRE>
        id <I>x</I> = <I>x</I></PRE>
      <P>for any value <TT><I>x</I></TT>.</P>
    </DD>

    <DT>
      <TT>const <I>x</I></TT>
    </DT>
    <DD>
      <P>Creates a constant function that returns <TT><I>x</I></TT> for any
      application. The following equivalence holds:</P>
      <PRE>
        const <I>x</I> <I>y</I> = <I>x</I></PRE>
      <P>for any values <TT><I>x</I></TT> and <TT><I>y</I></TT>.</P>
    </DD>

    <DT>
      <TT>curry <I>f</I></TT> <BR>
      <TT>uncurry <I>f</I></TT>
    </DT>
    <DD>
      <P>Creates a curried function from the uncurried argument function
      <TT><I>f</I></TT>. The function <TT>uncurry</TT> is the inverse.
      The following equivalence holds:</P>
      <PRE>
        curry <I>f</I> <I>x</I> <I>y</I> = <I>f</I> (<I>x</I>, <I>y</I>)
        uncurry <I>f</I> (<I>x</I>, <I>y</I>) = <I>f</I> <I>x</I> <I>y</I></PRE>
      <P>for any values <TT><I>x</I></TT> and <TT><I>y</I></TT>.</P>
    </DD>

    <DT>
      <TT>flip <I>f</I></TT>
    </DT>
    <DD>
      <P>Creates a function that takes its arguments in the opposite order
      of function <TT><I>f</I></TT>. The following equivalence holds:</P>
      <PRE>
        flip <I>f</I> (<I>x</I>, <I>y</I>) = <I>f</I> (<I>y</I>, <I>x</I>)</PRE>
      <P>for any values <TT><I>x</I></TT> and <TT><I>y</I></TT>.</P>
    </DD>
  </DL>

<?php section("also", "see also") ?>

  <DL><DD>
    <A href="ref.php3">Ref</A>
  </DD></DL>

<?php footing() ?>
