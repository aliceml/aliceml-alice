# Makefile for alice xml binding

NATIVES = UnsafeGecode

SOURCES = \
	UnsafeGecode.cc \
	GecodeSpace.cc \
	GecodeBAB.cc

TARGETS = \
	FD-sig.stc \
	FD.stc \
	PROBLEM-sig.stc \
	MkProblem.stc \
	SPACE-sig.stc \
	Space.stc \
	SEARCH-sig.stc \
	Search.stc

EXTRA_LIBS =
EXTRA_INCLUDES = -I../..

MAKEDEPEND = alicetool makedepend

GECODEOBJ = \
	generic/kernel.o \
	generic/memory-manager.o \
	generic/statistics.o \
	generic/relations.o \
	generic/prop-heap.o \
	generic/search.o \
	support/memory.o \
	support/scrap-heap.o \
	support/memory-chunk.o \
	int/bool/not.o \
	int/bool/and.o \
	int/bool/or.o \
	int/bool/imp.o \
	int/bool/xor.o \
	int/bool/eq.o \
	int/bool/post.o \
	int/distinct/post.o \
	int/rel/eq-nq.o \
	int/rel/lq-le.o \
	int/rel/dom.o \
	int/rel/element-int.o \
	int/rel/element-var.o \
	int/rel/lex.o \
	int/rel/post.o \
	int/count/rel.o \
	int/count/post.o \
	int/combinators/select.o \
	int/combinators/post.o \
	int/arithmetic/abs.o \
	int/arithmetic/minmax.o \
	int/arithmetic/mult.o \
	int/arithmetic/post.o \
	int/linear/novar.o \
	int/linear/preprocess.o \
	int/linear/supportset.o \
	int/linear/post.o \
	int/linear/post-01.o \
	int/linear/boolean.o \
	int/var.o \
	int/var/rangelist.o \
	int/var/domain.o \
	int/var/dom-spec.o \
	int/var/core.o \
	int/var/print.o \
	int/branching/branch.o \
	int/branching/assign.o \
	int/branching/posvaldesc.o

CXXFLAGS=-O2 -Dforceinline=inline -DNDEBUG -pipe

all: $(NATIVES:%=%.dll) $(TARGETS)

UnsafeGecode.dll: $(SOURCES:%.cc=%.o) $(GECODEOBJ:%=../../%)

%.o: %.cc
	alicetool compile $(EXTRA_INCLUDES) $(CXXFLAGS) \
	-c  $< -o $@

%.dll: %.o
	alicetool link $(LDFLAGS) $(SOURCES:%.cc=%.o) $(GECODEOBJ:%=../../%) \
	$(EXTRA_LIBS) -o $@

%.stc: %.aml
	alicec -c $< -o $@

clean:
	rm -f $(NATIVES:%=%.o) $(SOURCES:%.cc=%.o)
	rm -f $(TARGETS)

veryclean: clean
	rm -f $(NATIVES:%=%.dll.def)

distclean: veryclean
	rm -f $(NATIVES:%=%.dll)
	rm -f Makefile.depend

depend:
	alicedep *.aml > Makefile.depend
	$(MAKEDEPEND) $(EXTRA_INCLUDES) $(SOURCES) >> Makefile.depend

-include Makefile.depend