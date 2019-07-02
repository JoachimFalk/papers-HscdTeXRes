# vim: set noet ts=8 sts=0 sw=2:

TEX_TARGETS=$(TEX_SOURCES:.tex=.ps)

PS_OR_PDF=ps

include $(RESDIR)/Rules-TeX-Common.mk

LATEX=latex --file-line-error-style

.PRECIOUS: %.aux

%.aux %.idx: %.tex %.tex-dep
	@{ TEXINPUTS="$(TEXINPUTS)" $(LATEX)						\
	     -output-directory $(dir $@) $< </dev/null || 				\
	     { $(RM_F) $*.pdf $*.aux $*.idx; exit 1; } } |				\
	  sed -e 's/^\(.*\.tex:[0-9].*\)$$/[31m\1[39m/';				\
	$(RM_F) $*.pdf;									\
	[ -f $*.aux ]

.PRECIOUS: %.dvi

ifeq ($(BUILD_TEX_AUX_DEPS),yes)
%.dvi: %.tex %.tex-dep %.aux-dep
	$(MAKE) $*.aux && {								\
	    $(MV_F) $*.idx $*.idx-old && $(CP_F) $*.idx-old $*.idx;			\
	    $(MV_F) $*.aux $*.aux-old && $(CP_F) $*.aux-old $*.aux;			\
	  } ||										\
	  { $(RM_F) $*.dvi $*.aux $*.aux-old $*.idx $*.idx-old; exit 1; };		\
	TEXINPUTS="$(TEXINPUTS)" $(LATEX) $< </dev/null ||				\
	  { $(RM_F) $*.dvi $*.aux $*.aux-old $*.idx $*.idx-old; exit 1; };		\
	diff $*.aux-old $*.aux >/dev/null && {						\
	    $(MV_F) $*.idx-old $*.idx;							\
	    $(MV_F) $*.aux-old $*.aux && exit 0 || exit 1;				\
	  };										\
	$(RM_F) $@ && $(MAKE) $@ && exit 0 || exit 1
else
%.dvi: %.tex
	$(MAKE) BUILD_TEX_DEPS=yes $(TEX_DEPS)
	$(MAKE) BUILD_TEX_AUX_DEPS=yes $@
endif
