# vim: set noet ts=8 sts=0 sw=2:

RESDIR=$(shell while [ ! -d HscdTeXRes -a x`pwd` != x'/' ]; do cd ..; done; cd HscdTeXRes; pwd)

TEX_SOURCES=paper.tex

doc: tex-all

all:

SUBDIRS=

TEXCLEANDIRS=. figs images
TEXINPUTS:=.:figs:images:$(RESDIR):$(TEXINPUTS)

include $(RESDIR)/Rules-TeX-PDF.mk

todo:
	grep -n todo *.tex

force:
	$(MAKE) clean
	$(MAKE) tex-all

.PHONY: todo force all doc
