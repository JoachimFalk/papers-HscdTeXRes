# vim: set noet ts=8 sts=0 sw=2:

TEX_TARGETS=$(TEX_SOURCES:.tex=.ps)

PS_OR_PDF=ps

include $(RESDIR)/Rules-TeX-Common.mk

LATEX=latex --file-line-error-style

%.aux-dep: %.aux %.aux-dep-enable
	@{										\
	  STEM="$*"; export STEM;							\
	  echo -n "$*.dvi:" && "$(RESDIR)"/Cite-TeX.perl;				\
	  grep "makeidx" "$*.log" > /dev/null && echo " $*.ind" || echo;		\
	} < $< > $@

%.aux: %.tex %.tex-stamp
	@{ TEXINPUTS="$(TEXINPUTS)" $(LATEX) $< </dev/null || $(RM_F) $*.aux; } |	\
	  sed -e 's/^\(.*\.tex:[0-9].*\)$$/[31m\1[30m/';				\
	$(RM_F) $*.dvi;									\
	[ -f $*.aux ]

%.dvi %.idx: %.tex %.tex-stamp
	@if test -f $*.aux-dep-enable; then						\
	  $(MAKE) $*.aux && $(MV_F) $*.aux $*.aux-old && $(CP_F) $*.aux-old $*.aux ||   \
	    { $(RM_F) $*.dvi $*.aux $*.aux-old; exit 1; };				\
	  TEXINPUTS="$(TEXINPUTS)" $(LATEX) $< </dev/null ||				\
	    { $(RM_F) $*.dvi $*.aux $*.aux-old; exit 1; };				\
	  diff $*.aux-old $*.aux >/dev/null &&						\
	    { $(MV_F) $*.aux-old $*.aux && exit 0 || exit 1; };				\
	  $(RM_F) $@ && $(MAKE) $@ && exit 0 || exit 1;					\
	else										\
	  touch $*.aux-dep-enable; $(MAKE) $@; RETVAL=$$?; $(RM_F) $*.aux-dep-enable;	\
	  exit $$RETVAL;								\
	fi

.PRECIOUS: %.dvi
