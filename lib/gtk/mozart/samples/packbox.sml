(*
 * Authors:
 *   Thorsten Brunklaus <brunklaus@ps.uni-sb.de>
 *
 * Copyright:
 *   Thorsten Brunklaus, 2000
 *
 * Last Change:
 *   $Date$ by $Author$
 *   $Revision$
 *
 *)

import
    structure OS
from "x-alice:/lib/OS.ozf"

import
    structure GTK
from "x-alice:/lib/gtk/GTK.ozf"

local
    fun deleteEvent () = GTK.exit ()
    
    fun makeBox(Homogeneous, Spacing, Expand, Fill, Padding) =
	let
	    val Box     = GTK.hboxNew(Homogeneous, Spacing)
	    val Button1 = GTK.buttonNewWithLabel "{Box packStart("
	    val Button2 = GTK.buttonNewWithLabel "Button"
	    val Button3 = GTK.buttonNewWithLabel (Bool.toString Expand)
	    val Button4 = GTK.buttonNewWithLabel (Bool.toString Fill)
	    val Button5 = GTK.buttonNewWithLabel ((Int.toString Padding) ^ ")}")
	    val show    = fn button => (GTK.boxPackStart(Box, button, Expand, Fill, Padding);
					GTK.widgetShow  button)
	in
	    map show [Button1, Button2, Button3, Button4, Button5]; Box
	end

    fun runDemo demo =
	let
	    val Window  = GTK.windowNew 0
	    val Box1    = GTK.vboxNew(false, 0)
	    val QuitBox = GTK.hboxNew(false, 0)
	    val Button  = GTK.buttonNewWithLabel "Quit"
	in
	    (GTK.signalConnect(Window, "delete_event", deleteEvent);
	     GTK.containerSetBorderWidth(Window, 10);
	     demo Box1;
	     GTK.signalConnect(Button, "clicked", fn () => GTK.exit ());
	     GTK.boxPackStart(Box1, QuitBox, false, false, 0);
	     GTK.containerAdd(Window, Box1);
	     GTK.widgetShow(Button);
	     GTK.widgetShow(QuitBox);
	     GTK.widgetShow(Box1);
	     GTK.widgetShow(Window))
	end

    fun demoOne Box1 =
	let
	    val Label1     = GTK.labelNew "Box = {New GTK.hBox init(false 0)}"
	    val Box2       = makeBox(false, 0, false, false, 0)
	    val Box3       = makeBox(false, 0, true, false, 0)
	    val Box4       = makeBox(false, 0, true, true, 0)
	    val Separator1 = GTK.hseparatorNew ()
	    val Label2     = GTK.labelNew "Box = {GTK.hBox init(true 0)}"
	    val Box5       = makeBox(true, 0, true, false, 0)
	    val Box6       = makeBox(true, 0, true, true, 0)
	    val Separator2 = GTK.hseparatorNew ()
	in
	    (GTK.miscSetAlignment(Label1, 0.0, 0.0);
	     GTK.boxPackStart(Box1, Label1, false , false, 0);
	     GTK.widgetShow Label1;
	     GTK.boxPackStart(Box1, Box2, false , false, 0);
	     GTK.widgetShow Box2;
	     GTK.boxPackStart(Box1, Box3, false, false, 0);
	     GTK.widgetShow Box3;
	     GTK.boxPackStart(Box1, Box4, false, false, 0);
	     GTK.widgetShow Box4;
	     GTK.boxPackStart(Box1, Separator1, false, true, 5);
	     GTK.widgetShow Separator1;
	     GTK.miscSetAlignment(Label2, 0.0, 0.0);
	     GTK.boxPackStart(Box1, Label2, false, false, 0);
	     GTK.widgetShow Label2;
	     GTK.boxPackStart(Box1, Box5, false, false, 0);
	     GTK.widgetShow Box5;
	     GTK.boxPackStart(Box1, Box6, false, false, 0);
	     GTK.widgetShow Box6;
	     GTK.boxPackStart(Box1, Separator2, false, true, 5);
	     GTK.widgetShow Separator2)
	end
in
    val _ = runDemo demoOne
end
