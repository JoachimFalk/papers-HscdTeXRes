# vim: set noet ts=8 sts=0 sw=2:

TEX_TARGETS=$(TEX_SOURCES:.tex=.pdf) $(TEX_SOURCES:.tex=-2x1.pdf)

PS_OR_PDF=pdf

include $(RESDIR)/Rules-TeX-Common.mk

PDFLATEX=pdflatex --file-line-error-style

%.aux-dep: %.aux %.aux-dep-enable
	@{										\
	  STEM="$*"; export STEM;							\
	  echo -n "$*.pdf:" && "$(RESDIR)"/Cite-TeX.perl; 				\
	  grep "makeidx" "$*.log" > /dev/null && echo " $*.ind" || echo;		\
	} < $< > $@

%.aux: %.tex %.tex-stamp
	@{ TEXINPUTS="$(TEXINPUTS)" $(PDFLATEX) $< </dev/null || $(RM_F) $*.aux; } |	\
	  sed -e 's/^\(.*\.tex:[0-9].*\)$$/[31m\1[30m/';				\
	$(RM_F) $*.pdf;									\
	[ -f $*.aux ]

%.pdf: %.tex %.tex-stamp
	@if test -f $*.aux-dep-enable; then						\
	  $(MAKE) $*.aux && $(MV_F) $*.aux $*.aux-old && $(CP_F) $*.aux-old $*.aux ||   \
	    { $(RM_F) $*.pdf $*.aux $*.aux-old; exit 1; };				\
	  TEXINPUTS="$(TEXINPUTS)" $(PDFLATEX) $< </dev/null ||				\
	    { $(RM_F) $*.pdf $*.aux $*.aux-old; exit 1; };				\
	  diff $*.aux-old $*.aux >/dev/null &&						\
	    { $(MV_F) $*.aux-old $*.aux && exit 0 || exit 1; };				\
	  $(RM_F) $@ && $(MAKE) $@ && exit 0 || exit 1;					\
	else										\
	  touch $*.aux-dep-enable; $(MAKE) $@; RETVAL=$$?; $(RM_F) $*.aux-dep-enable;	\
	  exit $$RETVAL;								\
	fi
