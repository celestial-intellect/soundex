NAME     = soundex

OCAMLC   = ocamlfind ocamlc -g
OCAMLL   = $(OCAMLC) -package "$(REQUIRES)" -linkpkg graphics.cma
OCAMLOPT = ocamlfind ocamlopt
OCAMLDEP = ocamldep

EXECS = soundex-cli test-dynarray test-graph test-fst test-soundex

OBJECTS  = dynarray.cmo
XOBJECTS = dynarray.cmx
ARCHIVE  = $(NAME).cma
XARCHIVE = $(NAME).cmxa

REQUIRES =
PREDICATES =

.PHONY: all pkg optpkg

all: $(EXECS)

soundex-cli: dynarray.cmo digraph.cmo fst.cmo soundex.cmo soundex-cli.cmo
	$(OCAMLL) $^ -o $@

test-dynarray: dynarray.cmo test-dynarray.cmo
	$(OCAMLL) $^ -o $@

test-graph: dynarray.cmo digraph.cmo test-graph.cmo
	$(OCAMLL) $^ -o $@

test-fst: dynarray.cmo digraph.cmo fst.cmo test-fst.cmo
	$(OCAMLL) $^ -o $@

test-soundex: dynarray.cmo digraph.cmo fst.cmo soundex.cmo test-soundex.cmo
	$(OCAMLL) $^ -o $@

pkg: $(ARCHIVE)
optpkg: $(XARCHIVE)

$(ARCHIVE): $(OBJECTS)
	$(OCAMLC) -a -o $(ARCHIVE) -package "$(REQUIRES)" -linkpkg \
	-predicates "$(PREDICATES)" $(OBJECTS)
$(XARCHIVE): $(XOBJECTS)
	$(OCAMLOPT) -a -o $(XARCHIVE) -package "$(REQUIRES)" -linkpkg \
	-predicates "$(PREDICATES)" $(XOBJECTS)

.SUFFIXES: .cmo .cmi .cmx .ml .mli

.ml.cmo:
	$(OCAMLC) -package "$(REQUIRES)" -predicates "$(PREDICATES)" \
	-c $<
.mli.cmi:
	$(OCAMLC) -package "$(REQUIRES)" -predicates "$(PREDICATES)" \
	-c $<
.ml.cmx:
	$(OCAMLOPT) -package "$(REQUIRES)" -predicates "$(PREDICATES)" \
	-c $<

include depend

depend: $(wildcard *.ml*)
	if ! ($(OCAMLDEP) *.mli *.ml >depend); then rm depend; fi

.PHONY: install uninstall clean

install: all
	{ test ! -f $(XARCHIVE) || extra="$(XARCHIVE) "`basename $(XARCHIVE) .cmxa`.a }; \
	ocamlfind install $(NAME) *.mli *.cmi $(ARCHIVE) META $$extra

uninstall:
	ocamlfind remove $(NAME)

clean:
	rm -f depend *.cmi *.cmo *.cmx *.cma *.cmxa *.a $(EXECS)
	rm -f depend *.dvi *.log *.aux *.ps
