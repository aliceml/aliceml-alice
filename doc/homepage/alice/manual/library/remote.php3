<?php include("macros.php3"); ?>
<?php heading("The Remote structure",
	      "The <TT>Remote</TT> structure") ?>

<?php section("synopsis", "synopsis") ?>

  <PRE>
    signature REMOTE
    structure Remote : REMOTE</PRE>

  <P>
    This structure provides support for the implementation of distributed
    applications.  This includes exporting values from and importing values
    into sites, performing remote function application and starting a new
    site.
  </P>

  <P>
    Communication between sites is performed by <EM>cloning</EM> data
    structures.  Cloning is defined by <A href="pickle.php3">pickling</A>.
  </P>

  <P>
    The current implementation uses HTTP as the transport protocol.
    Accordingly, tickets are URLs using the <TT>http</TT> scheme.
  </P>

  <P>
    See also:
    <A href="component-manager.php3"><TT>COMPONENT_MANAGER</TT></A>,
    <A href="url.php3"><TT>Url</TT></A>,
    <A href="pickle.php3"><TT>Pickle</TT></A>
  </P>

<?php section("import", "import") ?>

  <PRE>
    import structure Remote from "x-alice:/lib/distribution/Remote"
    import signature REMOTE from "x-alice:/lib/distribution/REMOTE-sig"</PRE>

<?php section("interface", "interface") ?>

  <PRE>
    signature REMOTE =
    sig
	type <A href="#ticket">ticket</A> = string

	exception <A href="#Ticket-exn">Ticket</A>
	exception <A href="#Protocol">Protocol</A> of int * string

	val <A href="#proxy">proxy</A> : ('a -> 'b) -> ('a -> 'b)

	val <A href="#offer">offer</A> : <A href="package.php3#package">Package.t</A> -> string
	val <A href="#take">take</A> : ticket -> <A href="package.php3#package">Package.t</A>

	functor <A href="#Offer-fn">Offer</A> (signature S  structure X : S) : (val ticket : ticket)
	functor <A href="#Take-fn">Take</A> (val ticket : ticket  signature S) : S

	functor <A href="#Execute">Execute</A> (val host : string
			 signature RESULT
			 functor Start (ComponentManager : <A href="component-manager.php3">COMPONENT_MANAGER</A>) : RESULT) : RESULT
    end</PRE>

<?php section("description", "description") ?>

  <DL>
    <DT>
      <TT>type <A name="ticket">ticket</A> = string</TT>
    </DT>
    <DD>
      <P>The type of tickets representing offered values.  Tickets are
	short strings suitable for communication, for instance, over voice
	lines or by email.  Tickets are suitable for parsing as URLs.</P>
    </DD>

    <DT>
      <TT>exception <A name="Ticket-exn">Ticket</A></TT>
    </DT>
    <DD>
      <P>indicates that a ticket was not well-formed or referred to
	a site or value that could not be accessed.</P>
    </DD>

    <DT>
      <TT>exception <A name="Protocol">Protocol</A></TT>
    </DT>
    <DD>
      <P>indicates a protocol error.</P>
    </DD>

    <DT>
      <TT><A name="proxy">proxy</A> <I>f</I></TT>
    </DT>
    <DD>
      <P>returns a proxy for&nbsp;<TT><I>f</I></TT>.  The proxy differs
	from&nbsp;<TT><I>f</I></TT> in that:</P>
      <UL>
	<LI><P>the argument to the proxy is cloned before&nbsp;<TT><I>f</I
	  ></TT> is applied to it;</P>
	<LI><P>the return value from&nbsp;<I>f</I> is cloned before
	  it is returned from the proxy;</P>
	<LI><P>when the proxy is cloned, a reference to the running site is
	  cloned which does not contain a clone of&nbsp;<TT><I>f</I></TT>;</P>
	<LI><P>when the proxy is applied no matter on which site, this
	  causes <TT><I>f</I></TT> to be applied on the site on which the
	  proxy was created.</P>
      </UL>
      <P>When the site on which the proxy was created terminates,
	the proxy becomes invalid.  Applications of the proxy on other
	sites will raise the <TT><A href="#Ticket-exn">Ticket</A></TT>
	exception.</P>
    </DD>

    <DT>
      <TT><A name="offer">offer</A> <I>package</I></TT>
    </DT>
    <DD>
      <P>makes <TT><I>package</I></TT> available to other sites for taking.
	Returns a ticket suitable for <TT><A href="#take">take</A></TT>
	or <TT><A href="#Take-fn">Take</A></TT>.  If the argument
	is a mutable data structure, then taking returns a clone of
	how the data structure looked when the offer was initially made.</P>
    </DD>

    <DT>
      <TT><A name="take">take</A> <I>ticket</I></TT>
    </DT>
    <DD>
      <P>imports the data structure denoted by <TT><I>ticket</I></TT>, which
	must have been created by <TT><A href="#offer">offer</A></TT>
	or <TT><A href="#Offer-fn">Offer</A></TT>.  Raises
	<TT><A href="#Ticket-exn">Ticket</A></TT> if the ticket is
	invalid or the site on which it was created no longer exists.</P>
    </DD>

    <DT>
      <TT><A name="Offer-fn">Offer</A> (signature S = <I>S</I>
	structure X = <I>X</I>)</TT>
    </DT>
    <DD>
      <P>makes <TT><I>X</I></TT> available to other sites for taking with
	signature&nbsp;<I>S</I>.  Returns a ticket suitable for <TT><A
	href="#take">take</A></TT> or <TT><A href="#Take-fn">Take</A></TT>.
	If the argument is a mutable data structure, then taking returns
	a clone of how the data structure looked when the offer was
	initially made. Equivalent to</P>
        <PRE>
	(val ticket = offer (pack <I>X</I> :> <I>S</I>))</PRE>
    </DD>

    <DT>
      <TT><A name="Take-fn">Take</A> (val ticket = <I>ticket</I>
	signature S = <I>S</I>)</TT>
    </DT>
    <DD>
      <P>imports the data structure denoted by <TT><I>ticket</I></TT>, which
	must have been created by <TT><A href="#offer">offer</A></TT> or <TT
	><A href="#Offer-fn">Offer</A></TT>, under signature&nbsp;<TT><I>S</I
	></TT>.  Raises <TT><A href="#Ticket-exn">Ticket</A></TT> if the
	ticket is invalid or the site on which it was created no longer
	exists.  Raises <TT><A href="package.php3#Mismatch">Package.Mismatch</A
	></TT> if the value was not exported with a signature matching&nbsp;<TT
	><I>S</I></TT>. Equivalent to</P>
        <PRE>
	unpack (take <I>ticket</I>) : <I>S</I></PRE>
    </DD>

    <DT>
      <TT><A name="Execute">Execute</A> (val host = <I>host</I>
	signature RESULT = <I>S</I>
	functor Start = <I>F</I>)</TT>
    </DT>
    <DD>
      <P>creates a new site on <TT><I>host</I></TT>, transfers a clone of
	<TT><I>Start</I></TT> to the new site, on which it is applied to
	the local component manager.  A clone of the resulting structure is
	transferred back to the caller of <TT>Execute</TT> and returned as
	the resulting structure.</P>
    </DD>
  </DL>

<?php footing() ?>
