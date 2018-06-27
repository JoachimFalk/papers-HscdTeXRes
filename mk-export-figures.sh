#! /bin/bash

if test -n "${BASH_VERSION+set}" && (set -o posix) >/dev/null 2>&1; then
  set -o posix
fi

# NLS nuisances.
for as_var in \
  LANG LANGUAGE LC_ADDRESS LC_ALL LC_COLLATE LC_CTYPE LC_IDENTIFICATION \
  LC_MEASUREMENT LC_MESSAGES LC_MONETARY LC_NAME LC_NUMERIC LC_PAPER \
  LC_TELEPHONE LC_TIME
do
  if (set +x; test -n "`(eval $as_var=C; export $as_var) 2>&1`"); then
    eval $as_var=C; export $as_var
  else
    unset $as_var
  fi
done

# Name of the executable.
as_me=`basename "$0"`

# This script is in the RESDIR!
RESDIR=`dirname $0`; RESDIR=`cd $RESDIR; pwd`

if [ x"$RESDIR" != x ]; then
  export TEXINPUTS=".:${RESDIR}:${TEXINPUTS}"
else
  export TEXINPUTS=".:${RESDIR}"
fi

#standard option
FIGURES=""
FIGEXPORT_PNG="no"
FIGEXPORT_PNG_VIA="pdf"
FIGEXPORT_EPS="no"
FIGEXPORT_PDF="no"

while test $# != 0
do
  case $1 in
    --*=*)
      ac_option=`expr "x$1" : 'x\([^=]*\)='`
      ac_optarg=`expr "x$1" : 'x[^=]*=\(.*\)'`
      ac_shift=:
      ;;
    --*)
      ac_option=$1
      ac_optarg=$2
      ac_shift=shift
      ;;
    *)
      # This is not an option, so the user has probably given explicit
      # arguments.
      ac_option=$1
      ac_shift=:
  esac
  case $ac_option in
    --png)
          FIGEXPORT_PNG="yes";
      ;;
    --no-png)
          FIGEXPORT_PNG="no";
      ;;
    --eps)
          FIGEXPORT_EPS="yes";
          FIGEXPORT_PNG_VIA="eps";
      ;;
    --no-eps)
          FIGEXPORT_EPS="no";
          FIGEXPORT_PNG_VIA="pdf";
      ;;
    --pdf)
          FIGEXPORT_PDF="yes";
          FIGEXPORT_PNG_VIA="pdf";
      ;;
    --no-pdf)
          FIGEXPORT_PDF="no";
          FIGEXPORT_PNG_VIA="eps";
      ;;
    --help)
      echo "$as_me [OPTIONS] <figures>

Generates pdf/eps/png figures from xfig/metapost figures

  --help                      This message.
"
        exit 0;
      ;;
    -*)
      echo "$as_me: error: unrecognized option: $1
    Try \`$0 --help\' for more information."
      exit 1;
      ;;
    *)
      FIGURES="$FIGURES $1"
      ;;
  esac
  shift
done

if test x"$FIGEXPORT_PNG" != x"no"; then
  FIGEXPORT_PNG="via-$FIGEXPORT_PNG_VIA";
fi

doFig() {
  local figure=$1

  DEFS=`dirname "$figure"`/defs.tex
  if [ -f "$DEFS" ]; then
    DEFS="\\input{$DEFS}"
  else
    DEFS=""
  fi

  rm -f foo.pdf foo.eps

  case $figure in
    *.fig)
      if test x"$FIGEXPORT_PDF" != x"no" -o x"$FIGEXPORT_PNG" = x"via-pdf"; then
        cat > foo-pdf.tex <<EOF &&
\documentclass[a4paper, 12pt, english]{article}
\usepackage[landscape]{geometry}

\input{hscd-common.tex}

\renewcommand{\graphicPostfix}{pdf}

$DEFS

\pagestyle{empty}

\begin{document}
\scalebox{0.6}[0.6]{\input{${figure%%.fig}-fig.tex}}
\end{document}
EOF
        { make ${figure%%.fig}-tex.pdf ${figure%%.fig}-fig.tex &&
            pdflatex foo-pdf.tex && pdfcrop foo-pdf.pdf && mv foo-pdf-crop.pdf foo.pdf;
          } < /dev/null > ${figure%%.fig}.log 2>&1
        STATUS=$?
        if test x"$FIGEXPORT_PDF" != x"no"; then
          [ $STATUS -eq 0 ] && cp foo.pdf ${figure%%.fig}.pdf &&
            echo "Success ${figure%%.fig}.pdf" || { echo "Failed ${figure%%.fig}.pdf"; false; }
        fi
      fi

      if test x"$FIGEXPORT_EPS" != x"no" -o x"$FIGEXPORT_PNG" = x"via-eps"; then
        cat > foo-eps.tex <<EOF &&
\documentclass[a4paper, 12pt, english]{article}
\usepackage[landscape]{geometry}

\input{hscd-common.tex}

\renewcommand{\graphicPostfix}{ps}

$DEFS

\pagestyle{empty}

\begin{document}
\scalebox{0.6}[0.6]{\input{${figure%%.fig}-fig.tex}}
\end{document}
EOF
        { make ${figure%%.fig}-tex.ps ${figure%%.fig}-fig.tex &&
            latex foo-eps.tex && dvips foo-eps.dvi && ps2epsi foo-eps.ps foo.eps;
          } < /dev/null > ${figure%%.fig}.log 2>&1
        STATUS=$?
        if test x"$FIGEXPORT_EPS" != x"no"; then
          [ $STATUS -eq 0 ] && cp foo.eps ${figure%%.fig}.eps &&
            echo "Success ${figure%%.fig}.eps" || { echo "Failed ${figure%%.fig}.eps"; false; }
        fi
      fi
      ;;
    */fig.*|fig.*)
      if test x"$FIGEXPORT_PDF" != x"no" -o x"$FIGEXPORT_PNG" = x"via-pdf"; then
        cat > foo-pdf.tex <<EOF &&
\documentclass[a4paper, 12pt, english]{article}
\usepackage[landscape]{geometry}

\input{hscd-common.tex}

\renewcommand{\graphicPostfix}{pdf}

$DEFS

\pagestyle{empty}

\begin{document}
\scalebox{1}[1]{\includegraphics{$figure}}
\end{document}
EOF
        { pdflatex foo-pdf.tex && pdfcrop foo-pdf.pdf && \
          mv foo-pdf-crop.pdf foo.pdf; } < /dev/null > ${figure%%.fig}.log 2>&1
        STATUS=$?
        if test x"$FIGEXPORT_PDF" != x"no"; then
          [ $STATUS -eq 0 ] && cp foo.pdf ${figure}.pdf &&
            echo "Success ${figure}.pdf" || { echo "Failed ${figure}.pdf"; false; }
        fi
      fi

      if test x"$FIGEXPORT_EPS" != x"no" -o x"$FIGEXPORT_PNG" = x"via-eps"; then
        cat > foo-eps.tex <<EOF &&
\documentclass[a4paper, 12pt, english]{article}
\usepackage[landscape]{geometry}

\input{hscd-common.tex}

\renewcommand{\graphicPostfix}{pdf}

$DEFS

\pagestyle{empty}

\begin{document}
\scalebox{1}[1]{\includegraphics{$figure}}
\end{document}
EOF
        { latex foo-eps.tex && dvips foo-eps.dvi && \
          ps2epsi foo-eps.ps foo.eps; } < /dev/null > ${figure%%.fig}.log 2>&1
        STATUS=$?
        if test x"$FIGEXPORT_EPS" != x"no"; then
          [ $STATUS -eq 0 ] && cp foo.eps ${figure}.eps &&
            echo "Success ${figure}.eps" || { echo "Failed ${figure}.eps"; false; }
        fi
      fi

      ;;
  esac

  if test x"$FIGEXPORT_PNG" != x"no"; then
    if test x"$FIGEXPORT_PNG" = x"via-eps"; then
      SRC="foo.eps"
    else
      SRC="foo.pdf"
    fi
    { gs -r600 -sDEVICE=pnggray -sOutputFile=foo.png -dNOPAUSE -dBATCH $SRC &&
        convert -transparent white foo.png ${figure%%.fig}.png;
      } < /dev/null > /dev/null 2>/dev/null &&
      echo "Success ${figure%%.fig}.png" || { echo "Failed ${figure%%.fig}.png"; false; }
  fi
}

RETVAL=0

for j in $FIGURES; do
  if [ -d "$j" ];then
    for i in "$j/"*.fig "$j/"fig.*; do
      doFig $i || RETVAL=1
    done
  else
    doFig $j || RETVAL=1
  fi
done

rm -f foo-pdf.tex foo-pdf.pdf foo-pdf-crop.pdf foo-pdf.aux foo-pdf.out foo-pdf.log foo.pdf
rm -f foo-eps.tex foo-eps.dvi foo-eps.ps       foo-eps.aux foo-eps.out foo-eps.log foo.eps
rm -f foo.png

exit $RETVAL
