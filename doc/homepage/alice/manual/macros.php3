<?php

  function prep_title($name)
  {
    $name = str_replace(" ", "&nbsp;", $name);
    $name = str_replace("\n", "<BR>", $name);
    return $name;
  }

  function heading($title, $chapter)
  {
    $chapter2 = prep_title($chapter);
?>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
  <HEAD>
    <META http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <TITLE> <?php echo "Alice Manual - $title" ?></TITLE>
    <LINK rel="stylesheet" type="text/css" href="style.css">
  </HEAD>

  <BODY>


  <!-- margin-color: #83a2eb -->

  <DIV class=margin>

  <H1>
  alice<BR>
  manual.<BR>
  </H1>

  <?php include("menu.php3") ?>

  <A href="http://www.ps.uni-sb.de/alice/">
  <IMG src="logo-small.gif"
       border=0
       alt="Alice Project">
  </A>

  </DIV>

  <H1>
  <?php echo($chapter2) ?>
  </H1>

<?php
  };

  function footing()
  {
?>
  <BR>
  <HR>
  <DIV ALIGN=RIGHT>
    <ADDRESS>
       last modified <?php echo(date("Y/m/d H:i", getlastmod())) ?>
    </ADDRESS>
  </DIV>

  </BODY>
</HTML>
<?php
  };

  function section($tag, $name)
  {
    $n = 60 - strlen($name);
    $name = prep_title($name);

    for ($bar = ""; $n > 0; $n--)
    {
	$bar .= "_";
    };

    echo("<BR><H2><A name=" . $tag . "><SUP><TT>________&nbsp;</TT></SUP>" .
	 ucfirst($name) .
	 "<SUP><TT>&nbsp;" . $bar . "</TT></SUP></A></H2>");
  };

  function subsection($tag, $name)
  {
    echo("<H3><A name=" . $tag . ">" . ucfirst($name) . "&nbsp;" . $bar .
	 "</A></H3>");
  };
?>
