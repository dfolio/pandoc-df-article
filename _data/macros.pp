!comment(   pp-macros loader module   )
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
"macros.pp v0.1 (2018-10-0.4) | PP v2.6
The main macro that imports all other macro definition files.
--------------------------------------------------------------------------------
(c) 2017, David FOLIO CC-By-4.0 License.q
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!macrochars(!\)
!ifdef(MDT)(!define(LATEX)(1))
!ifdef(LATEX)(!import(latex.pp))
!ifdef(MDH)(!define(HTML)(1))
!ifdef(HTML)(!import(html.pp))
!ifdef(MDX)(!define(XML)(1))
!ifdef(XML)(!import(xml.pp))

!ifndef(LATEX)(
!define(etal)(\Latin(et&nbsp;al.))
!define(ellip)(…)
!define(nameref)( [@\1])
)

!comment( *** constant pp-macros set ***************************************** )

\define{Ddot}{conflit with pp dot}{!raw(\dot){\1}}

\define{Matrix}{Math matrix symbol}{\mathbf{\1}}
\define{Vector}{Math vector symbol}{\mathbf{\1}}
\define{Force}{Math force symbol}{\Vector{f}}
\define{Torque}{Math torque symbol}{\Vector{t}}

\define{Fp}{Math Fp symbol}{{\Force}_{\mathrm{p}}}
\define{Tp}{Math Tp symbol}{{\Torque}_{\mathrm{p}}}

\define{Fd}{Math Fd symbol}{{\Force}_{\mathrm{d}}}
\define{Td}{Math Td symbol}{{\Torque}_{\mathrm{d}}}

\define{Fext}{Math Fext symbol}{{\Force}_{\mathrm{ext}}}
\define{Text}{Math Text symbol}{{\Torque}_{\mathrm{ext}}}

\define{Fa}{Math Fa symbol}{{\Force}_{\mathrm{a}}}
\define{Ta}{Math Ta symbol}{{\Torque}_{\mathrm{a}}}

\define{Fm}{Math Fm symbol}{{\Force}_{\mathrm{m}}}
\define{Tm}{Math Tm symbol}{{\Torque}_{\mathrm{m}}}

\define{Uf}{Math Uf symbol}{{\Vector{u}}_{f}}

\define{MagB}{Math b symbol}{{\Vector{b}}}
\define{MagH}{Math b symbol}{{\Vector{h}}}
\define{MagM}{Math m symbol}{{\Vector{m}}}

\define{State}{Math state symbol}{\Vector{x}}
\define{Input}{Math state symbol}{\Vector{u}}
\define{Output}{Math state symbol}{\Vector{y}}
