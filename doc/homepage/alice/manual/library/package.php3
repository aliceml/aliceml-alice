<?php include("macros.php3"); ?>
<?php heading("The Package structure", "The <TT>Package</TT> structure") ?>

<?php section("synopsis", "synopsis") ?>

  <PRE>
    signature PACKAGE
    structure Package : PACKAGE
  </PRE>

  <P>
    The <TT>Package</TT> structure provides functionality to construct and
    destruct <EM>packages</EM>. A package is a value encapsulating an arbitrary
    (higher-order) module and its signature. Packages enrich the static type
    system of ML with a dimension of dynamic typing: unpacking a package
    performs a dynamic type check. That basic mechanism is used to make safe
    all kinds of dynamic operations, particularly exchange of
    higher-order data structures between different processes, or export to
    a file system (pickling).
  </P>

  <P>
    <B>TODO:</B> explanation, examples
  </P>

  <P>
    The package mechanism makes essential use of the higher-order features
    of the module system, in particular nested signatures.
  </P>

  <P>See also:
    <A href="pickle.php3"><TT>Pickle</TT></A>,
    <A href="remote.php3"><TT>Remote</TT></A>
  </P>

<?php section("import", "import") ?>

  <P>
    Imported implicitly.
  </P>

<?php section("interface", "interface") ?>

  <PRE>
    signature PACKAGE =
    sig
	type package
	type t = package
	type val_package

	type mismatch = Inf.mismatch
	exception Mismatch of mismatch
	exception MismatchVal

	functor Pack (signature S  structure X : S) : (val package : package)
	functor Unpack (val package : package  signature S) : S
	functor PackVal (type t  val x : t) : (val package : val_package)
	functor UnpackVal (val package : val_package  type t) : (val x : t)
    end
  </PRE>

<?php section("description", "description") ?>

  <DL>
    <DT>
      <TT>type <A name="package">package</A></TT> <BR>
      <TT>type t = package</TT>
    </DT>
    <DD>
      <P>The type of packages. A package contains an arbitrary module and
      its signature.</P>
    </DD>

    <DT>
      <TT>type val_package</TT>
    </DT>
    <DD>
      <P>The type of value packages. Value packages are a convenient
      specialisation for encapsulating single values.</P>
    </DD>

    <DT>
      <TT>type mismatch</TT>
    </DT>
    <DD>
      <P>A type containing the abstract description of the reason of
      a signature match failure.</P>
    </DD>

    <DT>
      <TT>exception Mismatch of mismatch</TT> <BR>
      <TT>exception MismatchVal</TT>
    </DT>
    <DD>
      <P>Raised upon failed attempts to unpack a package.</P>
    </DD>

    <DT>
      <TT>Pack (signature S = <I>S</I>  structure X = <I>X</I>)</TT>
    </DT>
    <DD>
      <P>Creates a package encapsulating the module <TT><I>X</I></TT>
      under signature <TT><I>S</I></TT>. Returns a structure containing
      the package value as its only field. Equivalent to</P>
      <PRE>
	(val package = pack <I>X</I> :> <I>S</I>)</PRE>
    </DD>

    <DT>
      <TT>Unpack (val package = <I>package</I>  structure S = <I>S</I>)</TT>
    </DT>
    <DD>
      <P>Tries to unpack the package <TT><I>package</I></TT>. If the signature
      of the package matches <TT><I>S</I></TT>, the encapsulated module is
      returned. Otherwise, the exception <TT>Mismatch <I>mismatch</I></TT> will
      be raised, with <TT><I>mismatch</I></TT> describing the reason for the
      failure. Equivalent to</P>
      <PRE>
	unpack <I>package</I> : <I>S</I></PRE>
    </DD>

    <DT>
      <TT>PackVal (type t = <I>t</I>  val x = <I>v</I>)</TT>
    </DT>
    <DD>
      <P>Creates a value package encapsulating the value <TT><I>v</I></TT>
      under type <TT><I>t</I></TT>. Returns a structure containing
      the package value as its only field.</P>
    </DD>

    <DT>
      <TT>UnpackVal (val package = <I>package</I>  type t = <I>t</I>)</TT>
    </DT>
    <DD>
      <P>Tries to unpack the value package <TT><I>package</I></TT>.
      If the type of the package is <TT><I>t</I></TT>, returns a structure
      containing the encapsulated value as its only field.
      Otherwise, the exception <TT>MismatchVal</TT> will be raised.</P>
    </DD>
  </DL>

<?php footing() ?>
