# vim: set noet ts=8 sts=0 sw=2:

SHELL=/bin/bash

RM_F=rm -f
MV_F=mv -f
CP_F=cp -f

TEX_DEPS=$(TEX_SOURCES:.tex=.tex-dep)
TEX_AUX_DEPS=$(TEX_SOURCES:.tex=.aux-dep)

TEX_STDINCLUDES:=$(shell find /usr/share/texmf/tex -type d)
OOFFICE:=$(shell which ooffice)
ifeq ($(OOFFICE),)
OOFFICE:=$(shell which libreoffice)
endif

ifndef BIB_SOURCES
BIB_SOURCES = literature.bib
endif

all: tex-all

tex-all: $(TEX_TARGETS)

clean: tex-clean

tex-clean:
	@$(RM_F) $(TEX_TARGETS)
	@find $(TEXCLEANDIRS) \( \
		-name "*.tex-dep" -o -name "*.tex-dep-enable" -o -name "*.tex-stamp*" \
	     -o	-name "*.aux-dep" -o -name "*.aux-dep-enable" -o -name "*.aux.old" \
	     -o	-name "*.dvi" -o -name "*.out" \) -delete
	@find $(TEXCLEANDIRS) \
		-name "*.nav" -o -name "*.snm" -o -name "*.vrb" -o -name "*.aux" \
	     -o	-name "*.bbl" -o -name "*.blg" -o -name "*.log" -o -name "*.idx" \
	     -o	-name "*.ilg" -o -name "*.ind" -o -name "*.toc" -o -name "*.pdf" | \
	  while read i; do \
	    if $(MAKE) "$${i%.*}.tex" 2>/dev/null >/dev/null; then \
	      $(RM_F) $$i; \
	    fi; \
	  done
	@find $(TEXCLEANDIRS) -name "*.pdf" | \
	  while read i; do \
	    if	$(MAKE) -n "$${i%.*}.fig" 2>/dev/null >/dev/null || \
		$(MAKE) -n "$${i%.*}.dia" 2>/dev/null >/dev/null || \
		$(MAKE) -n "$${i%.*}.svg" 2>/dev/null >/dev/null || \
		$(MAKE) -n "$${i%.*}.odg" 2>/dev/null >/dev/null || \
		$(MAKE) -n "$${i%.*}.eps" 2>/dev/null >/dev/null || \
		$(MAKE) -n "$${i%.*}.ps" 2>/dev/null >/dev/null; then \
	      $(RM_F) $$i; \
	    fi; \
	  done
	@find $(TEXCLEANDIRS) -name "*.ps" -o -name "*.eps" | \
	  while read i; do \
	    if	$(MAKE) -n "$${i%.*}.fig" 2>/dev/null >/dev/null || \
		$(MAKE) -n "$${i%.*}.dia" 2>/dev/null >/dev/null || \
		$(MAKE) -n "$${i%.*}.svg" 2>/dev/null >/dev/null || \
		$(MAKE) -n "$${i%.*}.odg" 2>/dev/null >/dev/null || \
		$(MAKE) -n "$${i%.*}.plt" 2>/dev/null >/dev/null; then \
	      $(RM_F) $$i; \
	    fi; \
	  done
	@find $(TEXCLEANDIRS) -name "*-fig.tex" -o -name "*-tex.ps" | \
	  while read i; do \
	    if $(MAKE) -n "$${i%-*}.fig" 2>/dev/null >/dev/null; then \
	      $(RM_F) $$i; \
	    fi; \
	  done

%.tex-dep: %.tex %.tex-dep-enable
	@{										\
	  TEXINPUTS="$(TEXINPUTS)";		export TEXINPUTS;			\
	  TEX_STDINCLUDES="$(TEX_STDINCLUDES)";	export TEX_STDINCLUDES;			\
	  RESDIR="$(RESDIR)";			export RESDIR;				\
	  SRCDIR="$(srcdir)";			export SRCDIR;				\
	  PS_OR_PDF="$(PS_OR_PDF)";		export PS_OR_PDF;			\
	  echo -n "$*.tex-stamp:" && "$(RESDIR)"/Dep-TeX.perl;				\
	} < $< > $@

-include $(TEX_DEPS) $(TEX_AUX_DEPS)

%.bbl: %.aux $(BIB_SOURCES)
	set $(dir $^); if test x"$$1" != x; then cd $$1; fi && BIBINPUTS=`cd $$2; pwd`:"$$BIBINPUTS" bibtex $(notdir $(basename $<))

%.eps: %.fig
	( cd `dirname $<` && fig2dev -L eps `basename $<` ) > $@

%.pdf: %.fig
	( cd `dirname $<` && fig2dev -L pdf `basename $<` ) > $@

%.eps: %.odg
	cd $(dir $<) && $(OOFFICE) --headless --convert-to eps $(notdir $<)

%.pdf: %.odg
	cd $(dir $<) && $(OOFFICE) --headless --convert-to pdf $(notdir $<)

%.eps: %.dot
	dot -Tps $< > $@

%.fig: %.dot
	dot -Tfig $< > $@

%.eps: %.dia
	cd `dirname $<` && dia --nosplash --filter=eps `basename $<` --export `basename $@`

%.eps: %.svg
	cd `dirname $<` && inkscape --export-eps `basename $@` `basename $<`

%.pdf: %.svg
	cd `dirname $<` && inkscape --export-pdf `basename $@` `basename $<`

%.eps: %.plt
	cd `dirname $<` && (\
		echo "set output \""`basename $@`"\"";\
		echo 'set terminal postscript eps enhanced color';\
		sed -e '/^set terminal /d' `basename $<` ) | gnuplot

%-fig.tex: %.fig
	{ [ -d `dirname $@` ] || mkdir `dirname $@`; } &&				\
	{ echo -e '\\begin{picture}(0,0)%' &&						\
	  echo -e '\\includegraphics[]{$*-tex}%' &&					\
	  echo -e '\\end{picture}%' &&							\
	  ( cd `dirname $<` && fig2dev -L pstex_t `basename $<` ); } > $*-fig.tex

%-tex.pdf: %.fig
	{ [ -d `dirname $@` ] || mkdir `dirname $@`; } &&				\
	( cd `dirname $<` && fig2dev -L pdftex `basename $<` ) > $*-tex.pdf

%-tex.ps: %.fig
	{ [ -d `dirname $@` ] || mkdir `dirname $@`; } &&				\
	( cd `dirname $<` && fig2dev -L pstex  `basename $<` ) > $*-tex.ps

%.pdf: %.ps
	epstopdf $< --outfile=$@

%.pdf: %.eps
	epstopdf $< --outfile=$@

%.ps: %.dvi
	dvips $<

.PRECIOUS: %.tex-stamp
.PRECIOUS: %.aux

%.tex-stamp: %.tex
	@{ [ -f $*.tex-dep-enable ] && touch $@; } || { touch $*.tex-dep-enable;	\
	  $(MAKE) $@; RETVAL=$$?; $(RM_F) $*.tex-dep-enable; exit $$RETVAL; }

%.tex-stamp-bibtex:
	@touch $@

%-2x1.pdf: %.pdf
	pdfnup $<

# ps & pdf to (color) png conversion
%.png: %.ps
	gs -r300 -sDEVICE=pngalpha -dNOPAUSE -dBATCH -sOutputFile="$*.png" "$<"
#	gs -r600 -sDEVICE=png16m -dNOPAUSE -dBATCH -sOutputFile="$*-non-transparent.png" "$<" && \
#	  convert -transparent white "$*-non-transparent.png" "$@"; \
#	RETVAL=$$?; $(RM_F) "$*-non-transparent.png"; exit $$RETVAL

%.png: %.pdf
	gs -r300 -sDEVICE=pngalpha -dNOPAUSE -dBATCH -sOutputFile="$*.png" "$<"
#	gs -r600 -sDEVICE=png16m -dNOPAUSE -dBATCH -sOutputFile="$*-non-transparent.png" "$<" && \
#	  convert -transparent white "$*-non-transparent.png" "$@"; \
#	RETVAL=$$?; $(RM_F) "$*-non-transparent.png"; exit $$RETVAL

%.ind: %.idx
	makeindex "$<"

.PHONY: all clean tex-all tex-clean
