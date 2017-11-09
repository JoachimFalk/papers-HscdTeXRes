%%[ Kenndaten ]%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{hscd-exercises}[2017/11/09]

%%[ Load packages ]%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[ Option processing ]%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newif\ifhscd@solution
\DeclareOption{solution}{\hscd@solutiontrue}
\newif\ifhscd@english
\DeclareOption{english}{\hscd@englishtrue}
\ProcessOptions\relax

%%[ Load packages ]%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\LoadClass[a4paper]{scrartcl}
\ifhscd@english
\RequirePackage[english]{babel}
\else
\RequirePackage[ngerman]{babel}
\fi
\RequirePackage[a4paper,left=2.5cm,right=2.5cm,top=2.5cm,bottom=2.5cm,twoside]{geometry}
\RequirePackage[utf8]{inputenc}
\RequirePackage[T1]{fontenc}
\RequirePackage[dvipsnames]{xcolor}
\RequirePackage{tikz}
\RequirePackage{amsmath}
\RequirePackage{amssymb}
\RequirePackage{enumitem}
\RequirePackage{titlesec}
\RequirePackage{fancyhdr}
\RequirePackage{tgpagella}
\RequirePackage{icomma}
\RequirePackage{caption}
\RequirePackage{booktabs}

%%[ Hauptteil ]%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\usetikzlibrary{calc}

%-- Schrift -------------------------------------------------------------------
%\defaultfontfeatures{Ligatures=TeX}
%\setmainfont
%     [ BoldFont       = texgyrepagella-bold.otf ,
%       ItalicFont     = texgyrepagella-italic.otf ,
%       BoldItalicFont = texgyrepagella-bolditalic.otf ]
%     {texgyrepagella-regular.otf}

%-- Geometrie und ähnliche Optionen -------------------------------------------
\parindent 0pt   
\parskip 5pt

\setlist[enumerate]{label=\alph*)}
\setlist[enumerate,2]{label=\roman*)}

\pagestyle{fancy}
\fancyhead{}
\renewcommand{\headrulewidth}{0pt}
\fancyfoot{}
\fancyfoot[C]{\thepage}

\clubpenalty=10000
\widowpenalty=10000
\displaywidowpenalty=10000

%-- Neue Befehle --------------------------------------------------------------
\newif\ifhscd@lecture
\newcommand{\lecture}[1]{
  \def\@hscd@lecturename{#1}
  \hscd@lecturetrue}
\newcommand{\lab}[1]{
  \def\@hscd@lecturename{#1}
  \hscd@lecturefalse}

\newif\ifhscd@labexercise
\newcommand{\labnumber}[1]{
  \def\@hscd@exercisenumber{#1}
  \hscd@labexercisetrue}
\newcommand{\exercisenumber}[1]{
  \def\@hscd@exercisenumber{#1}
  \hscd@labexercisefalse}

\def\@loesungname{Lösung}

\newcommand{\@hscd@logoheader}{
\noindent%
\begin{minipage}{40mm}
\vspace{-1.25cm}
\includegraphics[width=35mm]{logos/codesign/codesign}\\
{\small\sffamily Lehrstuhl für Informatik 12\\[-1mm]
Cauerstraße 11\\[-1mm]
91058 Erlangen}
\end{minipage}
\hfill%
\begin{minipage}{65mm}
\vspace{-1.25cm}
\includegraphics[width=65mm]{logos/fau/FAU_tech_cmyk}
\end{minipage}
\vspace{0.5cm}
}

\renewcommand{\maketitle}{
\@hscd@logoheader
\begin{center}
\iflanguage{english}{
  \ifhscd@solution
  {\Large Solution for the}
  \fi
  \ifhscd@lecture
    \ifhscd@labexercise
  {\Large{\@hscd@exercisenumber}. Laboratory Exercise of the Lecture}\\
    \else
  {\Large{\@hscd@exercisenumber}. Exercise of the Lecture}\\
    \fi
  \else
  {\Large{\@hscd@exercisenumber}. Exercise of the Laboratory}\\
  \fi
}{
  \titleformat{\section}{\bfseries}{Aufgabe \thesection}{0.5em}{}
  \ifhscd@solution
  {\Large {\@loesungname} für die}
  \fi
  \ifhscd@lecture
    \ifhscd@labexercise
  {\Large{\@hscd@exercisenumber}. Rechnerübung zur Vorlesung}\\
    \else
  {\Large{\@hscd@exercisenumber}. Übung zur Vorlesung}\\
    \fi
  \else
  {\Large{\@hscd@exercisenumber}. Übung zum Praktikum}\\
  \fi
}
{\Large\textbf{\@hscd@lecturename}}
\end{center}
\vspace{1cm}
}

\newcommand{\MIPS}{\operatorname{MIPS}}
\newcommand{\MFLOPS}{\operatorname{MFLOPS}}
\newcommand{\NINSTR}{\operatorname{\#INSTR}}

%-- Neue Umgebungen -----------------------------------------------------------
%\titleformat{\section}{\bfseries}{\hscd@taskname\ \thesection}{0.5em}{}
\def\hscd@taskname{\iflanguage{english}{Task}{Aufgabe}}
\titlespacing*{\section}{0pt}{0pt}{4pt}
\titleformat{\section}{\bfseries}{\hscd@taskname\ \thesection}{0.5em}{}

\newenvironment{aufgabe}[2]{
\section{%
\ifhscd@solution
(#1)\ifx\\#2\\\else\hfill\textmd{(#2)}\fi%
\else
(#1)%
\fi
}
}{\vspace{0.5cm}}

%-- Listings -----------------------------------------------------------
\RequirePackage{listings}
\IfFileExists{zi4.sty}{%
  \RequirePackage[scaled=1.0]{zi4}
}{\IfFileExists{inconsolata.sty}{%
  % Fall back for older LaTeX distributions
  \RequirePackage[scaled=1.0]{inconsolata}
}{}}
\lstset{
  basicstyle=\ttfamily\footnotesize,
  mathescape,
}
