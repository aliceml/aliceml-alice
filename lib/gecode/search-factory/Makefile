#
# Author:
#   Didier Le Botlan <botlan@ps.uni-sb.de>
#
# Copyright:
#   Didier Le Botlan, 2004
#
#  See the file "../LICENSE" for information on usage and
#  redistribution of this file, and for a
#     DISCLAIMER OF ALL WARRANTIES.
#
# Last change:
#   $Date$ by $Author$
#   $Revision$
#

ALICEC = alicec
ALICEDEP = alicedep
ALICEC_OPTS =

SOURCES = DEBUG-sig.aml Debug.aml \
          Path.aml PROBLEM-sig.aml \
          SPACENODE-sig.aml MkSpaceNode.aml \
          TREENODE-sig.aml MkTreeNode.aml \
          SEARCH-sig.aml MkSearch.aml \
          Test.aml

COMPONENTS = $(SOURCES:%.aml=%.alc)

INSTALLDIR=`alice-config --alicelibdir`/gecode/search-factory

.PHONY: all depend clean veryclean distclean

all: $(COMPONENTS)

depend:
	$(ALICEDEP) $(SOURCES) > Makefile.predepend
	sed "/\/alice\//d" Makefile.predepend > Makefile.depend

$(COMPONENTS): %.alc: %.aml
	$(ALICEC) $(ALICEC_OPTS) -c $< -o $@

##
## Installing
##
install: $(COMPONENTS)
	mkdir -p -m 775 $(INSTALLDIR)
	install -c -m444 $(COMPONENTS) $(INSTALLDIR)


##
## Cleaning Up
##

clean:
	rm -f $(COMPONENTS)

veryclean: clean

distclean: veryclean
	rm -f Makefile.depend

##
## Dependencies
##

-include Makefile.depend
