### -*- Makefile -*-
###
### Author:
###   Guido Tack <tack@ps.uni-sb.de>
###
### Copyright:
###   Guido Tack, 2004
###
### Last change:
###   $Date$ by $Author$
###   $Revision$
###

INSTALLTO= `alice-config --alicelibdir`/postscript

.PHONY: all install clean distclean

all: PS.alc

install: all
	mkdir -p $(INSTALLTO)
	install -c -m444 PS.alc $(INSTALLTO)
	install -c -m444 prolog.ps $(INSTALLTO)

clean:
	rm PS.alc

distclean: clean

%.alc: %.aml
	alicec -z $< -o $@
