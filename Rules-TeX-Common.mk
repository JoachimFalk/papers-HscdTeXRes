# vim: set noet ts=8 sts=0 sw=2:

RM_F=rm -f
MV_F=mv -f
CP_F=cp -f

TEX_DEPS=$(TEX_SOURCES:.tex=.tex-dep)
TEX_AUX_DEPS=$(TEX_SOURCES:.tex=.aux-dep)

TEX_STDINCLUDES:=$(shell find /usr/share/texmf/tex -type d)

ifndef BIB_SOURCES
BIB_SOURCES = literature.bib
endif

all: tex-all

tex-all: $(TEX_TARGETS)

clean: tex-clean

tex-clean:
	@$(RM_F) $(TEX_TARGETS)
	@for j in $(TEXCLEANDIRS); do \
	  $(RM_F) $$j/*.tex-dep $$j/*.tex-dep-enable $$j/*.tex-stamp* \
	  	  $$j/*.aux-dep $$j/*.aux-dep-enable $$j/*.aux-old \
		  $$j/*.dvi $$j/*.out ; \
	  for i in $$j/*.{nav,snm,vrb,aux,bbl,blg,log,idx,ilg,ind,toc,pdf}; do \
	    if $(MAKE) "$${i%.*}.tex" 2>/dev/null >/dev/null; then \
	      $(RM_F) $$i; \
	    fi; \
	  done; \
	  for i in $$j/*.pdf; do \
	    if	$(MAKE) -n "$${i%.*}.fig" 2>/dev/null >/dev/null || \
		$(MAKE) -n "$${i%.*}.dia" 2>/dev/null >/dev/null || \
		$(MAKE) -n "$${i%.*}.svg" 2>/dev/null >/dev/null || \
		$(MAKE) -n "$${i%.*}.eps" 2>/dev/null >/dev/null || \
		$(MAKE) -n "$${i%.*}.ps" 2>/dev/null >/dev/null; then \
	      $(RM_F) $$i; \
	    fi; \
	  done; \
	  for i in $$j/*.ps $$j/*.eps; do \
	    if	$(MAKE) -n "$${i%.*}.fig" 2>/dev/null >/dev/null || \
		$(MAKE) -n "$${i%.*}.dia" 2>/dev/null >/dev/null || \
		$(MAKE) -n "$${i%.*}.svg" 2>/dev/null >/dev/null || \
		$(MAKE) -n "$${i%.*}.plt" 2>/dev/null >/dev/null; then \
	      $(RM_F) $$i; \
	    fi; \
	  done; \
	  for i in $$j/*-{fig.tex,tex.ps}; do \
	    if $(MAKE) -n "$${i%-*}.fig" 2>/dev/null >/dev/null; then \
	      $(RM_F) $$i; \
	    fi; \
	  done; \
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
	set $(dir $^); ABSAUXDIR=`cd $$1; pwd`; if test x"$$2" != x; then cd $$2; fi && bibtex $$ABSAUXDIR/$(notdir $(basename $<))

%.eps: %.fig
	( cd `dirname $<` && fig2dev -L eps `basename $<` ) > $@

%.pdf: %.fig
	( cd `dirname $<` && fig2dev -L pdf `basename $<` ) > $@

%.eps: %.dot
	dot -Tps $< > $@

%.fig: %.dot
	dot -Tfig $< > $@

%.eps: %.dia
	cd `dirname $<` && dia --nosplash --filter=eps `basename $<` --export `basename $@`

%.eps: %.svg
	cd `dirname $<` && inkscape --export-eps `basename $@` `basename $<`

%.eps: %.plt
	cd `dirname $<` && (\
		echo "set output \""`basename $@`"\"";\
		echo 'set terminal postscript eps enhanced color';\
		sed -e '/^set terminal /d' `basename $<` ) | gnuplot

%-fig.tex: %.fig
	{ [ -d `dirname $@` ] || mkdir `dirname $@`; } &&				\
	{ echo '\begin{picture}(0,0)%' &&						\
	  echo '\includegraphics[]{$*-tex}%' &&						\
	  echo '\end{picture}%' &&							\
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
