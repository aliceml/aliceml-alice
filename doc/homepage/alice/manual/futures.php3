<?php include("macros.php3"); ?>

<?php heading("Futures", "futures") ?>



<?php section("overview", "overview") ?>

<P>A <EM>future</EM> is a place-holder for the undetermined result of a
(concurrent) computation. Once the computation delivers a result, the
associated future is eliminated by globally replacing it with the result value.
That value may be a future on its own.</P>

<P>Whenever a future is <EM>requested</EM> by a concurrent computation, i.e. it
tries to access its value, that computation automatically synchronizes on the
future by blocking until it becomes determined or failed.</P>

<P>If the computation associated with a future terminates with an exception,
the future is <EM>failed</EM>. A failed future carries the corresponding
exception and reraises it on every request.</P>

<P>There are three basic kinds of futures:</P>

<UL>
  <LI> <A href="#spawn"><EM>concurrent futures</EM></A> stand for the
	result of an concurrent computation </LI>
  <LI> <A href="#lazy"><EM>lazy futures</EM></A> stand for the
	result of a computation that is only performed on request </LI>
  <LI> <A href="#promise"><EM>promised futures</EM></A> stand for the
	a value that is delivered through an explicit operation </LI>
</UL>


<?php section("spawn", "concurrency") ?>

<P>A concurrent future is created by the expression</P>

<PRE class=code>
spawn <I>exp</I></PRE>

<P>which evaluates the expression <TT><I>exp</I></TT> in new thread and returns
immediately with a future of its result. When the expression has been
evaluated, the future is globally replaced by the result. We speak of
<EM>functional threads</EM>. See the below discussion on <A
href="#failed">failed futures</A> for the treatment of possible error
conditions.</P>


<?php subsection("spawn-example", "Example") ?>

<P>The following expression creates a table and concurrently fills it with the
results of function <TT>f</TT>. Each entry becomes available as soon as its
calculation terminates:</P>

<PRE class=code>
Vector.tabulate (30, fn i => spawn f i)</PRE>


<?php subsection("spawn-sugar", "Syntactic sugar") ?>

<P>A derived form is provided for defining functions that always evaluate in
separate threads:</P>

<PRE class=code>
fun spawn f x y = exp</PRE>

<P>An application <TT>f a b</TT> will spawn a new thread for evaluation. See <A
href="#syntax">below</A> for a precise definition of this derived form.</P>



<?php section("lazy", "laziness") ?>

<P>An expression can be marked as lazy:</P>

<PRE class=code>
lazy <I>exp</I></PRE>

<P>A lazy expression immediately evaluates to a lazy future of the result of
<TT><I>exp</I></TT>. As soon as a thread <A href="#request">requests</A> the
future, the computation is initiated in a new thread. The lazy future is
replaced by a concurrent future and evaluation proceeds similar to <A
href="#spawn"><TT>spawn</TT></A>. In particular, <A href="#failed">failure</A>
is handled consistently.</P>


<?php subsection("lazy-example", "Example") ?>

<P>Lazy futures enable full support for the whole range of lazy programming
techniques. For example, the following function generates an infinite lazy
stream of integers:</P>

<PRE class=code>
fun enum n = lazy n :: enum (n+1)</PRE>


<?php subsection("lazy-sugar", "Syntactic sugar") ?>

<P>Analogous to <A href="#spawn-sugar"><TT>spawn</TT></A>, a derived form is
provided for defining lazy functions:</P>

<PRE class=code>
fun lazy f x y = exp</PRE>

<P>See <A href="#syntax">below</A> for a precise definition of this derived
form. It allows convenient formulation of lazy functions. For example, a lazy
variant of the <TT>map</TT> function on lists can be written</P>

<PRE class=code>
fun lazy mapl f   []    = nil
       | mapl f (x::xs) = f x :: mapl f xs</PRE>

<P>This formulation is equivalent to</P>

<PRE class=code>
fun mapl f xs = lazy (case xs of
                           []   => nil
                        | x::xs => f x :: mapl f xs)</PRE>



<?php section("promise", "promises") ?>

<P><EM>Promises</EM> are explicit handles for futures. A promise is created
through the polymorphic library function <A
href="library/promise.php3"><TT>Promise.promise</TT></A>:

<PRE class=code>
val p = Promise.promise ()</PRE>

<P>Associated with every promise is a future. Creating a new promise also
creates a fresh future. The future can be extracted as

<PRE class=code>
val f = Promise.future p</PRE>

<P>A promised future is eliminated explicitly by applying

<PRE class=code>
Promise.fulfill (p, v)</PRE>

<P>to the corresponding promise, which globally replaces the future with the
value <TT><I>v</I></TT>.</P>

<P class=note><EM>Note:</EM> Promises may be thought of as single-assignment
references that allow dereferencing prior to assignment, yielding a future. The
operations <TT>promise</TT>, <TT>future</TT> and <TT>fulfill</TT> correspond to
<TT>ref</TT>, <TT>!</TT> and <TT>:=</TT>, respectively.</P>


<?php subsection("promise-example", "Example") ?>

<P>Promises essentially represent a more structured form of "logic variables"
as found in logic programming languages. Their presence allows application of
diverse idioms from concurrent logic programming to ML. Examples can be found in
the documentation of the <A href="library/promise.php3#examples"><TT>Promise</TT></A>
structure.</P>


<?php section("request", "requesting a futures") ?>

<P>A future is <EM>requested</EM> if it is used as an argument to a
<EM>strict</EM> operation. Strict operations are:</P>

<UL>
  <LI> Pattern matching </LI>
  <LI> Primitive operations that need to access a value (e.g. <TT>op+</TT>) </LI>
</UL>

<P>If a future is requested by a thread, that thread blocks until the future
has been replaced by a non-future value (or a failed future, see <A
href="#failed">below</A>). After the value has been determined, the thread
proceeds.</P>

<P>Requesting a lazy future triggers initiation of the corresponding
computation. The future is replaced by a concurrent future of the computation's
result. The requesting thread blocks until the result is determined.</P>

<P>Request of a promised future will block at least until a <TT>fulfill</TT>
operation has been applied to the corresponding promise. Blocking continues if
the promise is fulfilled with another future.</P>

<P>The implicit data-flow synchronisation implied by the future semantics
enables concurrent programming on a high level of abstraction.</P>


<?php section("failed", "failed futures") ?>

<P>If the computation associated with a concurrent or lazy future terminates
with an exception, that future cannot be eliminated. Instead, it turns into a
<EM>failed future</EM>. Promised futures can be failed explicitly by means of
the <A href="library/promise.php3"><TT>Promise.fail</TT></A> function. Any
attempt to request a failed future will reraise the exception that was the
cause of the failure.</P>

<P>A second error condition is the attempt to replace a future with itself. This
may happen if a recursive <TT>spawn</TT> or <TT>lazy</TT> expression is
unfounded, or if a promise is fulfilled with its own future. In all cases, the
future will be failed with the special exception <TT>Future.Cyclic</TT>.</P>


<?php section("lib", "library support") ?>

<P>The following library modules provide functionality relevant for
programming with futures, promises and concurrent threads:</P>

<UL>
  <LI> <A href="library/future.php3"><TT>Future</TT></A> </LI>
  <LI> <A href="library/promise.php3"><TT>Promise</TT></A> </LI>
  <LI> <A href="library/thread.php3"><TT>Thread</TT></A> </LI>
  <LI> <A href="library/os-process.php3"><TT>OS.Process</TT></A> </LI>
  <LI> <A href="library/byneed.php3"><TT>ByNeed</TT></A> </LI>
</UL>

<P>The latter is a functor that allows creation of lazy futures for modules.</P>

<P>Lazy modules are also at the core of the semantics of <A
href="components.php3">components</A>.</P>


<?php section("syntax", "syntax summary") ?>

<TABLE class=bnf>
  <TR>
    <TD> <I>exp</I> </TD>
    <TD align="center">::=</TD>
    <TD> ... </TD>
    <TD> </TD>
  </TR>
  <TR>
    <TD></TD> <TD></TD>
    <TD> <TT>lazy</TT> <I>exp</I> </TD>
    <TD> lazy </TD>
  </TR>
  <TR>
    <TD></TD> <TD></TD>
    <TD> <TT>spawn</TT> <I>exp</I> </TD>
    <TD> concurrent </TD>
  </TR>

  <TR></TR>
  <TR>
    <TD> <I>fvalbind</I> </TD>
    <TD align="center">::=</TD>
    <TD> &lt;<TT>lazy</TT> | <TT>spawn</TT>&gt; </TD>
    <TD> (<I>m</I>,<I>n</I>&ge;1) (*) </TD>
  </TR><TR>
    <TD></TD><TD></TD>
    <TD> &nbsp;&nbsp;
         &lt;<TT>op</TT>&gt; <I>vid atpat</I><SUB>11</SUB> ... <I>atpat</I><SUB>1<I>n</I></SUB> &lt;<TT>:</TT> ty<SUB>1</SUB>&gt;
	 <TT>=</TT> <I>exp</I><SUB>1</SUB> </TD>
  </TR><TR>
    <TD></TD><TD></TD>
    <TD> <TT>|</TT>
         &lt;<TT>op</TT>&gt; <I>vid atpat</I><SUB>21</SUB> ... <I>atpat</I><SUB>2<I>n</I></SUB> &lt;<TT>:</TT> ty<SUB>2</SUB>&gt;
	 <TT>=</TT> <I>exp</I><SUB>2</SUB> </TD>
  </TR><TR>
    <TD></TD><TD></TD>
    <TD> <TT>|</TT> ... </TD>
  </TR><TR>
    <TD></TD><TD></TD>
    <TD> <TT>|</TT>
         &lt;<TT>op</TT>&gt; <I>vid atpat</I><SUB><I>m</I>1</SUB> ... <I>atpat</I><SUB><I>mn</I></SUB> &lt;<TT>:</TT> ty<SUB><I>m</I></SUB>&gt;
	 <TT>=</TT> <I>exp</I><SUB><I>m</I></SUB> </TD>
  </TR><TR>
    <TD></TD><TD></TD>
    <TD> &lt;<TT>and</TT> <I>fvalbind</I>&gt; </TD>
  </TR>
</TABLE>


<?php subsection("syntax-derived", "derived forms") ?>

<TABLE class="bnf dyptic">
  <TR>
    <TD>
      <BR>
      &lt;<TT>lazy</TT>&nbsp;|&nbsp;<TT>spawn</TT>&gt; <BR>
      &nbsp;&nbsp;&nbsp;&lt;<TT>op</TT>&gt;&nbsp;<I>vid</I>&nbsp;<!--
	--><I>atpat</I><SUB>11</SUB>&nbsp;...&nbsp;<I>atpat</I><SUB>1<I>n</I></SUB>&nbsp;<!--
	-->&lt;<TT>:</TT>&nbsp;ty<SUB>1</SUB>&gt;&nbsp;<!--
	--><TT>=</TT>&nbsp;<I>exp</I><SUB>1</SUB> <BR>
      <TT>|</TT>&nbsp;&lt;<TT>op</TT>&gt;&nbsp;<I>vid</I>&nbsp;<!--
	--><I>atpat</I><SUB>21</SUB>&nbsp;...&nbsp;<I>atpat</I><SUB>2<I>n</I></SUB>&nbsp;<!--
	-->&lt;<TT>:</TT>&nbsp;ty<SUB>2</SUB>&gt;&nbsp;<!--
	--><TT>=</TT>&nbsp;<I>exp</I><SUB>2</SUB> <BR>
      <TT>|</TT>&nbsp;&nbsp;&nbsp;&nbsp;... <BR>
      <TT>|</TT>&nbsp;&lt;<TT>op</TT>&gt;&nbsp;<I>vid<I>&nbsp;<!--
	--></I>atpat</I><SUB><I>m</I>1</SUB>&nbsp;...&nbsp;<I>atpat</I><SUB><I>mn</I></SUB>&nbsp;<!--
	-->&lt;<TT>:</TT>&nbsp;ty<SUB><I>m</I></SUB>&gt;&nbsp;<!--
	--><TT>=</TT>&nbsp;<I>exp</I><SUB><I>m</I></SUB> <BR>
      &lt;<TT>and</TT>&nbsp;<I>fvalbind</I>&gt;
    </TD>
    <TD>
      &lt;<TT>op</TT>&gt;&nbsp;<I>vid</I>&nbsp;<TT>=</TT>&nbsp;<!--
	--><TT>fn</TT>&nbsp;<I>vid</I><SUB>1</SUB>&nbsp;<TT>=></TT>&nbsp;...&nbsp;<!--
	--><TT>fn</TT>&nbsp;<I>vid</I><SUB><I>n</I></SUB>&nbsp;<TT>=></TT> <BR>
      &lt;<TT>lazy</TT>&nbsp;|&nbsp;<TT>spawn</TT>&gt;&nbsp;<TT>case</TT>&nbsp;<!--
	--><TT>(</TT><I>vid</I><SUB>1</SUB><TT>,</TT>...<TT>,</TT><I>vid</I><SUB><I>n</I></SUB><TT>)</TT>&nbsp;<TT>of</TT> <BR>
      &nbsp;&nbsp;&nbsp;<!--
	--><TT>(</TT><I>atpat</I><SUB>11</SUB><TT>,</TT>...<TT>,</TT><I>atpat</I><SUB>1<I>n</I></SUB><TT>)</TT>&nbsp;<!--
	--><TT>=></TT> <I>exp</I><SUB>1</SUB>&nbsp;<!--
	-->&lt;<TT>:</TT>&nbsp;ty<SUB>1</SUB>&gt; <BR>
      <TT>|</TT>&nbsp;<!--
	--><TT>(</TT><I>atpat</I><SUB>21</SUB><TT>,</TT>...<TT>,</TT><I>atpat</I><SUB>2<I>n</I></SUB><TT>)</TT>&nbsp;<!--
	--><TT>=></TT>&nbsp;<I>exp</I><SUB>2</SUB>&nbsp;<!--
	-->&lt;<TT>:</TT>&nbsp;ty<SUB>2</SUB>&gt; <BR>
      <TT>|</TT>&nbsp;&nbsp;&nbsp;&nbsp;... <BR>
      <TT>|</TT>&nbsp;<!--
	--><TT>(</TT><I>atpat</I><SUB><I>m</I>1</SUB><TT>,</TT>...<TT>,</TT><I>atpat</I><SUB><I>mn</I></SUB><TT>)</TT>&nbsp;<!--
	--><TT>=></TT>&nbsp;<I>exp</I><SUB><I>m</I></SUB>&nbsp;<!--
	-->&lt;<TT>:</TT>&nbsp;ty<SUB><I>m</I></SUB>&gt; <BR>
      &lt;<TT>and</TT>&nbsp;<I>fvalbind</I>&gt;
    </TD>
  </TR>
</TABLE>

<P><I>vid</I><SUB>1</SUB>,...,<I>vid</I><SUB><I>n</I></SUB> are distinct and new.</P>

<?php footing() ?>
