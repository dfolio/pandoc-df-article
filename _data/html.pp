!comment( *** HTML pp-macros set ********************************************** )
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
html.pp v0.1 (2018-10-08) | PP v2.6
A set of macros for pandoc HTML output
--------------------------------------------------------------------------------
(c) 2017, David FOLIO CC-By-4.0 License.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!macrochars(!\)
\define{HTML}
\define{xspace}{ }
!comment( *** references pp-macros set *************************************** )
\define{cite}{Latex cite}{ [@\1]}
\define{ref}{Latex ref}{[@\1]}
\define{cref}{Latex clever ref}{[@\1]}
\define{label}{Latex label}{{#\1}}

!comment( *** bibliography pp-macros set ************************************* )
\define{doi}{DOI link}{[doi:\1](http://doi.org/\1){.doi}}
!comment( *** block pp-macros set ******************************************** )

!comment( *** inline pp-macros set ******************************************* )


!comment( *** unit pp-macros set ******************************************** )
\define{num}{Latex siunitx}{<span class="number">\1</span>}
\define{si}{Latex siunitx}{<span class="unit">\1</span>}
\define{SI}{Latex siunitx}{\num{\1}\si{\2}}
\define{cubic}{\1^3^}
\define{per}{/}
\define{ampere}{A}
\define{deg}{°}
\define{gram}{g}
\define{hour}{h}
\define{joule}{J}
\define{kilo}{k}
\define{kelvin}{K}
\define{metre}{m}
\define{micro}{µ}
\define{nano}{µ}
\define{second}{s}
\define{tesla}{T}
\define{year}{year}
\define{years}{years}


!comment( *** math pp-macros set ******************************************** )

