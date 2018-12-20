################################################################################
## Copyright (c) 2018 David Folio
## All rights reserved.
################################################################################
##  License : under CC by license style...
################################################################################

.DEFAULT_GOAL  ?= all
# Note that the user-global version is imported *after* the source directory,
# so that you can use stuff like ?= to get proper override behavior.
-include Makefile.ini

################################################################################
# SIMPLE CONFIGURATION #########################################################

#Select the output mode for HTML and TeX
#BUILD_OUTPUT_MODE    ?= multi
#BUILD_OUTPUT_MODE   ?= single

#Select the prefered build strategy
BUILD_TEX_STRATEGY  ?= pdflatex
#BUILD_TEX_STRATEGY  ?= lualatex
#BUILD_TEX_STRATEGY  ?= xelatex

# Select the citation TEX_BIB_STRATEGY for LateX:
#   - biblatex: intended for use in producing a LaTeX file that can be processed with bibtex or biber.
#     Note: by default in VARSDATA biber backend are used.
#     See also the BUILD_BIB_STRATEGY below.
#   - natbib: intended for use in producing a LaTeX file that can be processed with bibtex.
#TEX_BIB_STRATEGY  ?= biblatex
TEX_BIB_STRATEGY  ?= natbib

# Select the default targets
# Values any of:  pdf, html, epub, odt, docx, xml/DocBook
BUILD_DEFAULT_TARGETS       ?= html pdf

# Define the list of articles to be build
# can be basename or with their '.md' Mardown suffix
BUILD_ONLY    ?=
# Define articles that must be excluded from the build process
# can be basename or with their '.md' Mardown suffix
#
# Note: if both BUILD_ONLY and BUILD_EXCLUDE are empty, all articles will be built
BUILD_EXCLUDE ?=
# Document main language
# TODO: nowaday only 'en' (english) supported
MAINLANG    ?=en

# Define the top level division of the documentation
# Obviously for a thesis this should be chapter (or eventually to part)
# (whereas for article it should set to section)
# TODO: part level support
TOP_LEVEL_DIVISION ?=  section

# (Un)comment to (dis)enable VERBOSE
# This should be enabled mainly for debugging purpose as many outputs will be
# echoed.
# Note any value enable the VERBOSE mode
#VERBOSE     ?= 1

# If set to something, will cause temporary files to not be deleted immediately
KEEP_TEMP    ?=

# Directory where the original (Markdow) sources files are looked for.
# By default Markdown (MD) sources are assumed defined by MDDIR
#
# Note that this can be changed on the commandline or in Makefile.ini:
#
# Command line:
#   make INDIR=$HOME/Inputs
#
# Also, you can specify a relative directory (relative to the Makefile):
#   make INDIR=in myfile.pdf
#
# Or, you can use Makefile.ini:
#
#   INDIR := $(HOME)/in
MDDIR       ?=_md
INDIR       ?=$(MDDIR)
# Input Mardown extension
MDEXT       ?=md

# Directory into which we place "binaries" if it exists.
# Note that this can be changed on the commandline or in Makefile.ini:
#
# Command line:
#   make OUTDIR=$HOME/pdfs myfile.pdf
#
# Also, you can specify a relative directory (relative to the Makefile):
#   make OUTDIR=html myfile.pdf
#
# Or, you can use Makefile.ini:
#
#   OUTDIR  := $(HOME)/bin_out
#
OUTDIR      ?= build

ROOTDIR     := $(PWD)

# Name use for distribution/archive, ie. used for
#  make dist
#
DISTNAME    ?=$(notdir $(PWD))

# Subdirs
# where all templates are stored
TEMPLATEDIR ?=_layouts
TEMPLATEJEKYLLDIR   ?= $(TEMPLATEDIR)/jekyll
# data, variables, macros, glossaries should be placed in DATADIR
DATADIR     ?=_data
# various stuff can be placed ASSETSDIR such as bib, media, fonts...
# but, "publishable" (eg. in case of html outputs) files must be placed
# in "$(OUT_ASSETSDIR)"
# Some subdir of the initial ASSETSDIR could be copied   "$(OUT_ASSETSDIR)"
ASSETSDIR       ?=assets
OUT_ASSETSDIR   ?=$(OUTDIR)/$(ASSETSDIR)
BIBDIR      ?=$(ASSETSDIR)/bib
OUT_BIBDIR  ?=$(OUT_ASSETSDIR)/bib
FONTDIR     ?=$(ASSETSDIR)/fonts
OUT_FONTDIR ?=$(OUT_ASSETSDIR)/fonts
MEDIADIR    ?=$(ASSETSDIR)/media
FIGDIR      ?=$(ASSETSDIR)/fig
OUT_FIGDIR  ?=$(OUT_ASSETSDIR)/fig
# Output directories for intermediates files
MDHDIR      ?=$(OUTDIR)/mdh
MDXDIR      ?=$(OUTDIR)/mdx
MDTDIR      ?=$(TEXDIR)
PDFDIR      ?=$(OUTDIR)
TEXDIR      ?=$(OUTDIR)/tex
HTMLDIR     ?=$(OUTDIR)
HTMLMULTIDIR?=$(OUTDIR)/html
EPUBDIR     ?=$(OUTDIR)
DOCXDIR     ?=$(OUTDIR)
ODTDIR      ?=$(OUTDIR)
XMLDIR      ?=$(OUTDIR)
CHUNKDIR    ?=$(HTMLMULTIDIR)
# SASS/CSS dirs
CSS_DISTDIR ?=$(ASSETSDIR)/css
CSS_BUILDDIR?=$(OUT_ASSETSDIR)/css

LOGDIR      ?=$(OUTDIR)

# Comment/Uncomment the following line to enable/disable the use of SASS to
# generate the CSS stylesheets
# If disabled previous build in $(ASSETSDIR)/css is used
USE_SASS    ?= 1
# Define the SCSSDIR
# *Important* For consistency the following variables should be left blank or
# commented to truly disable the use of SASS!
SCSSDIR     ?=$(ASSETSDIR)/scss
SCSSINCS    ?=$(SCSSDIR)
# created by npm (nodejs)
NODEDIR     ?=node_modules
# We use bootstrap <https://getbootstrap.com/> as base stylesheets layout
SCSSINCS    +=$(NODEDIR)/bootstrap/scss

# END SIMPLE CONFIGURATION
################################################################################

################################################################################
# ADVANCED CONFIGURATION

# Sets LC_ALL=C, by default, so that the locale-aware tools, like sort, be
# immune to changes to the locale in the user environment.
export LC_ALL := C

# Base files
## Edit the METADATA to customize pandoc
METADATA    ?=$(DATADIR)/metadata.yml
## Edit the VARSDATA to customize pandoc
VARSDATA    ?=$(DATADIR)/variables.yml
PANDOC_CROSSREF_DATA ?=$(DATADIR)/pandoc-crossref.yml
## Put here all the necessary bibliography files
#BIBFILES    ?=$(BIBDIR)/string.bib $(BIBDIR)/thesis-biblio.bib
## Where all bibliographies are merged
BIB         ?=$(OUT_BIBDIR)/bibliography.bib
## The Citation Style Language (CSL) for formatting of citations and bibliographies.
CSL         ?=$(BIBDIR)/Thesis-ieee-style.csl
## The DocBook stylesheets to generate HTML chunks
XSL         ?=$(TEMPLATEDIR)/xsl/html5.xsl

# preprocessor macros
PP_MACROS   ?=$(DATADIR)/macros.pp
# HTML preprocessor macros
PP_html5_MACROS   ?=$(DATADIR)/html.pp
# XML preprocessor macros
PP_docbook5_MACROS   ?=$(DATADIR)/xml.pp
# TeX preprocessor macros
PP_latex_MACROS    ?=$(DATADIR)/latex.pp

# END ADVANCED CONFIGURATION
#############################################################################

#############################################################################
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#############################################################################
#                                                                           #
#                       FOR ADVANCED USERS ONLY                             #
#                                                                           #
#############################################################################
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#############################################################################

# IMPORTANT!
#
# When adding to the following list, do not introduce any blank lines.  The
# list is extracted for documentation using sed and is terminated by a blank
# line.
#
# EXTERNAL PROGRAMS:
## ESSENTIAL PROGRAMS
### Basic Shell Utilities
CAT       ?= cat
CP        ?= cp -f        # REQUIRED
DIFF      ?= diff         # REQUIRED
DATE      ?= date         # REQUIRED
ECHO      ?= echo         # REQUIRED
EGREP     ?= egrep        # REQUIRED
FIND      ?= find         # REQUIRED
GREP      ?= grep
MKDIR     ?= mkdir -p     # REQUIRED
MKTEMP    ?= mktemp
MV        ?= mv -f        # REQUIRED
RSYNC     ?= rsync        # RECOMMANDED
SED       ?= sed          # REQUIRED
SORT      ?= sort         # REQUIRED
TOUCH     ?= touch        # REQUIRED
UNIQ      ?= uniq         # REQUIRED
WHICH     ?= which        # REQUIRED
XARGS     ?= xargs
### Pandoc Utilities
PANDOC    ?=pandoc        # REQUIRED
PCITEPROC ?=pandoc-citeproc # RECOMMANDED
PCROSSREF ?=pandoc-crossref # RECOMMANDED
PP        ?=pp            # REQUIRED
## Usefull external program
### LaTeX Utilities
BIBTEX    ?= bibtex
BIBER     ?= biber
LATEX     ?= latex        # should be deprecated... use pdflatex instead!
PDFLATEX  ?= pdflatex
LUALATEX  ?= lualatex
XELATEX   ?= xelatex
MAKEINDEX	?= makeindex    # Not yet used (plan for future index management)
XINDY     ?= xindy        # Not yet used (plan for future index management)
KPSEWHICH ?= kpsewhich    # Not yet used (plan for future packages check)
### Makefile Color Output
TPUT      ?= tput
### Figures Generation/Conversion
CONVERT   ?= convert      # ImageMagick (REQUIRED)
INKSCAPE  ?= inkscape     # Inkscape    (RECOMMANDED for svg support)
SVGO      ?= svgo         # SVG optimizer/minification (optional)
SCOUR     ?= scour        # SVG optimizer/minification (optional)
### Usefull Utilities
TAR       ?= tar          # To make archive
ZIP       ?= zip
NPM       ?= npm          # Install node_modules/<modules> (RECOMMANDED)
NPX       ?= npx
RUBY      ?= ruby         # For Jekyll (optional)
GEM       ?= gem          # For Jekyll (optional)
BUNDLE    ?= bundle       # For Jekyll (optional)
JEKYLL    ?= jekyll
SASS      ?= $(NODEDIR)/.bin/sass # For SASS/SCSS support  (RECOMMANDED)
XSLTPROC  ?= xsltproc

# This ensures that even when echo is a shell builtin, we still use the binary
# (the builtin doesn't always understand -n)
FIXED_ECHO:= $(if $(findstring -n,$(shell $(ECHO) -n)),$(shell $(WHICH) echo),$(ECHO))
ECHO      := $(if $(FIXED_ECHO),$(FIXED_ECHO),$(ECHO))

TODAY     := $(shell $(DATE) +"%F")

################################################################################
# Default FLAGS
#
# Try to get full path of command
# $(call real-cmd,cmd)
real-cmd=$(shell $(WHICH) $(strip $1) 2>/dev/null)

# Test if command is available or not
# $(call have-cmd,cmd)
have-cmd=$(if $(call real-cmd,$1),:,)


# Default image extension.
# Suitable value can be svg (prefered) or png
default_image_extension ?= svg

RSYNC_FLAGS   ?= -r -t -p -o -g -l -c -z -u -s -a

# PP:  text preprocessor designed for Pandoc
PP_FLAGS      ?= -$(MAINLANG) -img=$(FIGDIR)

# Pandoc options
# Note: it will be more convenient to define pandoc option if its possible from
# the METADATA file.
# Any defined options below override the values from METADATA file.
#

ifdef TOP_LEVEL_DIVISION
top_lvl_div ?=--top-level-division=$(TOP_LEVEL_DIVISION)
endif

## Pandoc Global options
PANDOC_FLAGS    ?= --standalone\
  --metadata-file=$(METADATA) \
  --wrap=preserve \
  $(top_lvl_div) \
  --atx-header \
  --metadata=date:"$(TODAY)"\
  --resource-path=$(BIBDIR):$(OUTDIR):../:.

## Pandoc Markdown extensions
PANDOC_MDEXT      ?=+raw_html+raw_tex+abbreviations+yaml_metadata_block+header_attributes+definition_lists+tex_math_dollars

## Pandoc  Bibliography options managed with pandoc-citeproc
USE_CITEPROC=$(call have-cmd,$(PCITEPROC))
ifeq ($(USE_CITEPROC),:)
PANDOC_CITEPROC_FLAGS  ?= --file-scope\
  --filter pandoc-citeproc --csl=$(CSL) \
   $(foreach f,$(BIBFILES), --bibliography=$(f))
endif

USE_CROSSREF=$(call have-cmd,$(PCROSSREF))
ifeq ($(USE_CROSSREF),:)
PANDOC_CROSSREF_FLAGS  ?= --filter pandoc-crossref -M "crossrefYaml=$(PANDOC_CROSSREF_DATA)"
endif
#

## Pandoc options for Mardown/HTML generations
PANDOC_MDH_FLAGS  ?=--file-scope

PANDOC_MDH_BASE  ?= --standalone \
  $(PANDOC_MDH_FLAGS) \
	$(PANDOC_CROSSREF_FLAGS) \
  $(PANDOC_CITEPROC_FLAGS)
## Options for HTML output
## Note: CSS files must be defined in VARSDATA file not here
PANDOC_html5_FLAGS ?= $(PANDOC_MDH_BASE) \
  --default-image-extension=$(default_image_extension) --mathjax \
  --toc --toc-depth=2 --section-divs\
  --template=$(TEMPLATEDIR)/template.html5

## Options for XML/DocBook output
PANDOC_docbook5_FLAGS ?= $(PANDOC_MDH_BASE)\
  --default-image-extension=$(default_image_extension) --mathml\
  --template=$(TEMPLATEDIR)/template.docbook5

## Options for EPUB output
PANDOC_epub3_FLAGS ?= $(PANDOC_MDH_BASE)\
  --default-image-extension=$(default_image_extension) \
  --css=$(CSS_BUILDDIR)/pandoc_article_epub.css \
  --template=$(TEMPLATEDIR)/template.epub3

## Options for DOCX output
PANDOC_docx_FLAGS ?= $(PANDOC_MDH_BASE)\
  --data-dir=$(TEMPLATEDIR) \
  --reference-doc=$(TEMPLATEDIR)/template.docx \
  --default-image-extension=emf

## Options for ODT output
PANDOC_odt_FLAGS  ?= $(PANDOC_MDH_BASE)\
  --data-dir=$(TEMPLATEDIR) \
  --reference-doc=$(TEMPLATEDIR)/template.odt \
  --default-image-extension=png


## Pandoc Tex/Bibliography options
PANDOC_latex_BIB_FLAGS  ?= --file-scope \
	$(foreach f,$(BIBFILES), --bibliography='$f')
ifeq "$(strip $(TEX_BIB_STRATEGY))" "biblatex"
PANDOC_latex_BIB_FLAGS  += --biblatex
endif
ifeq "$(strip $(TEX_BIB_STRATEGY))" "natbib"
PANDOC_latex_BIB_FLAGS  += --natbib
endif

## Pandoc options for Mardown/LaTeX generations
PANDOC_MDT_FLAGS  ?= -M numberSections=false \
  --default-image-extension=pdf

## Options for LaTeX output
PANDOC_latex_FLAGS  ?= --file-scope -standalone\
  --pdf-engine=$(BUILD_TEX_STRATEGY) \
  $(PANDOC_CROSSREF_FLAGS) \
  $(PANDOC_latex_BIB_FLAGS) \
  -M numberSections=false \
  -M link-citations=false \
  --default-image-extension=pdf \
  --template=$(TEMPLATEDIR)/template.latex

## LaTex/pdfLaTeX/xeLateX/luaLaTeX flag initialization
# (before check quiet state)
TEXFLAGS      ?= -synctex=1 --shell-escape

SASS_FLAGS    ?= --load-path="$(SCSSDIR)" --load-path="$(NODEDIR)"

# Unsupported as 12/2018 -- should be improved
XSLT_FLAGS    ?= --nonet --xinclude \
  --path "/usr/share/sgml/docbook/xsl-stylesheets" \
  --encoding utf-8 --timing \

# Turn on final version of the document
ifdef PROD
undefine VERBOSE
undefine DRAFT
undefine KEEP_TEMP
SASS_FLAGS += --style=compressed
endif
# Manage quiet/verbose mode
ifndef VERBOSE
QUIET  := @
endif

ifneq ($(QUIET),)
MAKEFLAGS   += --silent
else
VERBOSE     ?= 1
endif
ifdef VERBOSE
#TEXFLAGS    += -interaction=nonstopmode
PANDOC_FLAGS+= --verbose
RSYNC_FLAGS += --verbose -h --progress
WRITE_LOG   ?= 1
else
#TEXFLAGS    += -interaction=batchmode -file-line-error
BIBTEX      += -terse
PANDOC_FLAGS+= --quiet
SASS_FLAGS  += --quiet
RSYNC_FLAGS += --quiet
endif

# Turn on shell debugging with SHELL_DEBUG=1
# (EVERYTHING is echoed, even $(shell ...) invocations)
ifdef SHELL_DEBUG
SHELL       += -x
WRITE_LOG   ?= 1
endif

# Get the name of this makefile (always right in 3.80, often right in 3.79)
# This is only really used for documentation, so it isn't too serious.
ifdef MAKEFILE_LIST
this_file  := $(firstword $(MAKEFILE_LIST))
else
this_file  := $(wildcard GNUmakefile makefile Makefile)
endif

###############################################################################
# Utility Functions and Definitions
#

# Clear out the standard interfering make suffixes
.SUFFIXES:


# Turn off forceful rm (RM is usually mapped to rm -f)
ifdef SAFE_RM
RM  := rm
endif

# Don't call this directly - it is here to avoid calling wildcard more than
# once in remove-files.
remove-files-helper = $(if $1,$(RM) $1,:)

# $(call remove-files,source destination)
remove-files        = $(call remove-files-helper,$(wildcard $1))

# Removes all cleanable files in the given list
# $(call clean-files,source destination file3 ...)
# Works exactly like remove-files, but filters out files in $(neverclean)
clean-files    = \
  $(if $(VERBOSE),\
  $(echo_dt) "$(C_WARNING)Clean files '$1'$(reset)",:); \
  $(call remove-files,$(call cleanable-files,$(wildcard $1)))

# $(call remove-temporary-files,filenames)
remove-temporary-files  = $(if $(KEEP_TEMP),:,$(call clean-files,$1))

# Test that a file exists
# $(call test-exists,file)
test-exists               = [ -e '$1' ]
# $(call test-not-exists,file)
test-not-exists           = [ ! -e '$1' ]

# Note that $(DIFF) returns success when the files are the SAME....
# $(call test-different,source,destination)
test-different            = ! $(DIFF) -q '$1' '$2' >/dev/null 2>&1
test-exists-and-different = $(call test-exists,$2) && $(call test-different,$1,$2)

# $(call move-files,source,destination)
move-if-exists            = $(call test-exists,$1) && $(MV) '$(strip $1)' '$(strip $2)'

# Use RSYNC instead of simple cp to allow remote copying
# If no RSYNC is available back to cp
USE_RSYNC := $(call have-cmd,$(RSYNC))
define copy-helper
$(if $(USE_RSYNC),\
  $(RSYNC) $(RSYNC_FLAGS) '$(strip $1)' '$(strip $2)',\
  $(CP) '$(strip $1)' '$(strip $2)' )
endef

# Copy source to destination only if source exist
define copy-if-exists
$(call test-exists,$1) && $(call copy-helper,$1,$2) || \
  $(call echo-error, " '$1' does not exist and cannot be copied to '$2'")
endef

# Copy source to destination only if they are different
# $(call copy-if-different,source,destination)
copy-if-different  = $(call test-different,$1,$2) && $(call copy-helper,$1,$2)

# Move source to destination only if file
move-if-different  = $(call test-different,$1,$2) && $(MV) '$(strip $1)' '$(strip $2)'

# Replace destination by source only if they are different, and remove source
# $(call replace-if-different-and-remove,source,destination)
define replace-if-different-and-remove
$(call test-different,$1,$2) && $(MV) '$(strip $1)' '$(strip $2)' || \
  $(call remove-files,'$(strip $1)')
endef

define replace-temporary-if-different-and-remove
 $(if $(KEEP_TEMP),:,$(call replace-if-different-and-remove, $1,$2))
endef

# Return value 1, or value 2 if value 1 is empty
# $(call get-default,<possibly empty arg>,<default value if empty>)
get-default  = $(if $1,$1,$2)
# Utility function for creating larger lists of files
# $(call concat-files,suffixes,[prefix])
concat-files  = $(foreach s,$1,$($(if $2,$2_,)files.$s))

# Utility function for obtaining all files not specified in $(neverclean)
# $(call cleanable-files,source destination file3 ...)
# Returns the list of files that is not in $(wildcard $(neverclean))
cleanable-files = $(filter-out $(wildcard $(neverclean)), $1)

# Find files
# $(call find-files,in_dir,with_pattern)
find-files=$(FIND) $1 -name $2 -type f -prune  -print| $(SORT) | $(UNIQ)

# Terminal color definitions
REAL_TPUT := $(if $(NO_COLOR),,$(shell $(WHICH) $(TPUT)))

# $(call get-term-code,codeinfo)
# e.g.,
# $(call get-term-code,setaf 0)
get-term-code = $(if $(REAL_TPUT),$(shell $(REAL_TPUT) $1),)

black   := $(call get-term-code,setaf 0)
red     := $(call get-term-code,setaf 1)
green   := $(call get-term-code,setaf 2)
yellow  := $(call get-term-code,setaf 3)
blue    := $(call get-term-code,setaf 4)
magenta := $(call get-term-code,setaf 5)
cyan    := $(call get-term-code,setaf 6)
white   := $(call get-term-code,setaf 7)
bg_black   := $(call get-term-code,setab 0)
bg_red     := $(call get-term-code,setab 1)
bg_green   := $(call get-term-code,setab 2)
bg_yellow  := $(call get-term-code,setab 3)
bg_blue    := $(call get-term-code,setab 4)
bg_magenta := $(call get-term-code,setab 5)
bg_cyan    := $(call get-term-code,setab 6)
bg_white   := $(call get-term-code,setab 7)
bold    := $(call get-term-code,bold)
uline   := $(call get-term-code,smul)
reset   := $(call get-term-code,sgr0)

# STANDARD COLORS
C_ERROR     := $(red)$(bold)
C_WARNING   := $(magenta)
C_INFO      := $(green)
C_BOLD      := $(bold)

# date-time
get_date_time   = $(DATE) +"%F %T"

# Display information about what is being done
echo_dt       = $(ECHO) -e "$(white)$(shell $(get_date_time))$(reset)"
# $(call echo-error,<msg>)
echo-error    = $(echo_dt) "$(C_ERROR)**ERROR** $1$(reset)"
echo-warning  = $(echo_dt) "$(C_WARNING)**WARNING** $1$(reset)"
echo-info     = $(echo_dt) "$(C_INFO)$1$(reset)"
echo-success  = $(echo_dt) "$(green)$(bold)$1$(reset)"
echo-failure  = $(echo_dt) "$(red)$(bold)$1$(reset)"


# $(call echo-build,<type>,<target>,[<run number>])
echo-build    = $(echo_dt) "\t$(blue)$(bold)==Build==$(reset)$(blue)\t$1$(if $2, $2,)$(if $3, ($3),)...$(reset)"
# $(call echo-run,<prog>,<arg>)
echo-run      = $(echo_dt) "\t$(cyan)>>$(bold)Run $1$(reset)$(cyan)$(if $3,  $3-->, on )$(if $2, $2,...)$(reset)"
# $(call echo-copy,src,dest)
echo-copy     = $(echo_dt) "\t$(cyan)>>Copy $1$(if $2,\t$2 $(if $3,--> $3,),)...$(reset)"
# $(call echo-copy,src,dest)
echo-fig      = $(echo_dt) "$(yellow)++Gen. Fig.++$(reset)\t$1 --> $2$(reset)"
echo-dep      = $(echo_dt) "$(yellow)//Deps//$(reset)\t$1$(if $2,\t$2,)$(reset)"

# Display a list of something
# $(call echo-list,<list>)
echo-list  = for x in $1; do $(ECHO) "$$x"; done

# Display success/failure at end target
define echo-end-target
$(call test-exists,$1)&& \
  $(call echo-success,Successfully generated $1) ||\
  $(call echo-failure,Fail to generate $1!!!)
endef

#
# EXTERNAL PROGRAM DOCUMENTATION SCRIPT
#

# If cygpath is present, then we create a path-norm function that uses it,
# otherwise the function is just a no-op.  Issue 112 has details.
USE_CYGPATH := $(call have-cmd,$(CYGPATH))
define path-norm
$(if $(USE_CYGPATH),$(shell $(CYGPATH) -u "$1"),$1)
endef

# $(call output-all-programs,[<output file>])
define output-all-programs
  [ -f '$(this_file)' ] && \
  $(SED) \
    -e '/^[[:space:]]*#[[:space:]]*EXTERNAL PROGRAMS:/,/^$$/!d' \
    -e '/EXTERNAL PROGRAMS/d' \
    -e '/^$$/d' \
    -e '/^[[:space:]]*#/i\ '\
    -e 's/REQUIRED/$(bold)$(red)REQUIRED$(reset)/g' \
    -e 's/RECOMMANDED/$(bold)$(magenta)RECOMMANDED$(reset)/g' \
    -e 's/optional/$(cyan)optional$(reset)/g' \
    $(this_file) $(if $1,> '$1',) || \
  $(call echo-error,Cannot determine the name of this makefile.)
endef

WRITE_LOG ?=
# Helper to get pandoc log
get-pandoc-log =$(if $(WRITE_LOG),--log=$(ROOTDIR)/$(LOGDIR)/pandoc_$1.log)
ifdef WRITE_LOG
clean_log += $(wildcard $(ROOTDIR)/$(LOGDIR)/pandoc_*.log)
endif

# Pandoc invocation
#$(call run-pandoc-from-md,<file_from>,<file_to>,<dialect>)
define run-pandoc-from-md
$(PANDOC) --from markdown$(PANDOC_MDEXT) $(PANDOC_FLAGS) \
	$(PANDOC_$(3)_FLAGS) $1 $(VARSDATA) --to $3 --output=$2 \
	$(call get-pandoc-log,$3)
endef
# PP+Pandoc invocation
#$(call run-pp-pandoc,<file_from>,<file_to>,<mode>)
define run-pp-pandoc
$(PP) $(PP_FLAGS) -D$(3) -import=$(PP_MACROS) $1 | \
	$(PANDOC) --from markdown$(PANDOC_MDEXT) $(PANDOC_FLAGS) \
	$(PANDOC_$(3)_FLAGS)	--to markdown$(PANDOC_MDEXT) --output=$2
endef


# Log command to a log file
# $(call output-to-log,log)
define output-to-log
$(if $(WRITE_LOG),>> $1,>/dev/null)
endef

TEXLOG    ?=$(ROOTDIR)/$(LOGDIR)/build_tex.log
ifdef WRITE_LOG
clean_log += $(TEXLOG)
endif

# LaTeX invocations
#
# Note that we use
#
#  -recorder: generates .fls files for things that are input and output
#  -jobname: to make sure that .fls files are named after the source that created them
#  -file-line-error: to make sure that we have good line information for error output
#  -interaction=batchmode: so that we don't stop on errors (we'll parse logs for that)
#
# $(call run-latex,<tex file stem, e.g., $*>,[extra LaTeX args])
define run-latex
$(call echo-run,$(latex_build_program),$1); \
$(latex_build_program) $(TEXFLAGS) -jobname='$(notdir $1)'\
  -interaction=batchmode -file-line-error \
  $(if $2,$2,) $1 $(call output-to-log,$(TEXLOG))
endef
# -output-directory='$(TEXDIR)'

# Colorizes real, honest-to-goodness LaTeX errors that can't be overcome with
# recompilation.
#
# Note that we only ignore file not found errors for things that we know how to
# build, like graphics files.
#
# Also note that the output of this is piped through sed again to escape any
# backslashes that might have made it through.  This is to avoid sending things
# like "\right" to echo, which interprets \r as LF.  In bash, we could just do
# ${var//\\/\\\\}, but in other popular sh variants (like dash), this doesn't
# work.
#
# $(call colorize-latex-errors,<log file>)
define colorize-latex-errors
$(SED) \
-e '$${' \
-e '  /^$$/!{' \
-e '    H' \
-e '    s/.*//' \
-e '  }' \
-e '}' \
-e '/^$$/!{' \
-e '  H' \
-e '  d' \
-e '}' \
-e '/^$$/{' \
-e '  x' \
-e '  s/^\(\n\)\(.*\)/\2\1/' \
-e '}' \
-e '/^::P\(P\{1,\}\)::/{' \
-e '  s//::\1::/' \
-e '  G' \
-e '  h' \
-e '  d' \
-e '}' \
-e '/^::P::/{' \
-e '  s//::0::/' \
-e '  G' \
-e '}' \
-e 'b start' \
-e ':needonemore' \
-e 's/^/::P::/' \
-e 'G' \
-e 'h' \
-e 'd' \
-e ':needtwomore' \
-e 's/^/::PP::/' \
-e 'G' \
-e 'h' \
-e 'd' \
-e ':needthreemore' \
-e 's/^/::PPP::/' \
-e 'G' \
-e 'h' \
-e 'd' \
-e ':start' \
-e '/^! LaTeX Error: File /{' \
-e '  s/\n//g' \
-e '  b needtwomore' \
-e '}' \
-e 's/^[^[:cntrl:]:]*:[[:digit:]]\{1,\}:/!!! &/' \
-e 's/^\(.*\n\)\([^[:cntrl:]:]*:[[:digit:]]\{1,\}: .*\)/\1!!! \2/' \
-e '/^!!! .*[[:space:][:cntrl:]]LaTeX[[:space:][:cntrl:]]Error:[[:space:][:cntrl:]]*File /{' \
-e '  s/\n//g' \
-e '  b needonemore' \
-e '}' \
-e '/^::0::! LaTeX Error: File .*/{' \
-e '  /\n\n$$/{' \
-e '    s/^::0:://' \
-e '    b needonemore' \
-e '  }' \
-e '  s/^::0::! //' \
-e '  s/^\(.*not found.\).*Enter file name:.*\n\(.*[[:digit:]]\{1,\}\): Emergency stop.*/\2: \1/' \
-e '  b error' \
-e '}' \
-e '/^::0::!!! .*LaTeX Error: File .*/{' \
-e '  /\n\n$$/{' \
-e '    s/^::0:://' \
-e '    b needonemore' \
-e '  }' \
-e '  s/::0::!!! //' \
-e '  /File .*\.e\{0,1\}ps'"'"' not found/b skip' \
-e '  /could not locate.*any of these extensions:/{' \
-e '    b skip' \
-e '  }' \
-e '  s/\(not found\.\).*/\1/' \
-e '  s/^/!!! /' \
-e '  b error' \
-e '}' \
-e '/^\(.* LaTeX Error: Missing .begin.document.\.\).*/{' \
-e '  s//\1 --- Are you trying to build an include file?/' \
-e '  b error' \
-e '}' \
-e '/.*\(!!! .*Undefined control sequence\)[^[:cntrl:]]*\(.*\)/{' \
-e '  s//\1: \2/' \
-e '  s/\nl\.[[:digit:]][^[:cntrl:]]*\(\\[^\\[:cntrl:]]*\).*/\1/' \
-e '  b error' \
-e '}' \
-e '/^\(!pdfTeX error:.*\)s*/{' \
-e '  b error' \
-e '}' \
-e '/.*\(!!! .*\)/{' \
-e '  s//\1/' \
-e '  s/[[:cntrl:]]//' \
-e '  s/[[:cntrl:]]$$//' \
-e '  /Cannot determine size of graphic .*(no BoundingBox)/b skip' \
-e '  b error' \
-e '}' \
-e ':skip' \
-e 'd' \
-e ':error' \
-e 's/^!\(!! \)\{0,1\}\(.*\)/$(C_ERROR)\2$(reset)/' \
-e 'p' \
-e 'd' \
'$1' | $(SED) -e 's/\\\\/\\\\\\\\/g'
endef


# Checks for the existence of a .aux file, and dies with an error message if it
# isn't there.  Note that we pass the file stem in, not the full filename,
# e.g., to check for foo.aux, we call it thus: $(call die-on-no-aux,foo)
#
# $(call die-on-no-aux,aux)
define die-on-no-aux
if $(call test-not-exists,$1.aux); then \
	$(call colorize-latex-errors,$1.log); \
	$(call echo-error,Error: unable to create $1.aux); \
	exit 1; \
fi
endef

# Outputs all index files to stdout.  Arg 1 is the source file stem, arg 2 is
# the list of targets for the discovered dependency.
#
# $(call get-log-index,<log>,<target files>)
define get-log-index
$(SED) \
-e 's/^No file \(.*\.ind\)\.$$/TARGETS=\1/' \
-e 's/^No file \(.*\.[gn]ls\)\.$$/TARGETS=\1/' \
-e 's/[[:space:]]/\\&/g' \
-e '/^TARGETS=/{' \
-e '  h' \
-e '  s!^TARGETS=!$2: !p' \
-e '  g' \
-e '  s!^TARGETS=\(.*\)!\1: $1.tex!p' \
-e '}' \
-e 'd' \
'$1.log' | $(SORT) | $(UNIQ)
endef

# Get BUILD_BIB_STRATEGY from tex file
define get-bib-strategy
 $(shell $(EGREP) -q '^[^%]*\\usepackage\[.*backend=biber.*\]{biblatex}' $1 && $(ECHO) "biber" || $(ECHO) bibtex )
endef
# Colorize BibTeX output.
color_bib := \
$(SED) \
-e 's/^Warning--.*/$(C_WARNING)&$(reset)/' \
-e 't' \
-e '/---/,/^.[^:]/{' \
-e '  H' \
-e '  /^.[^:]/{' \
-e '    x' \
-e '    s/\n\(.*\)/$(C_ERROR)\1$(reset)/' \
-e '    p' \
-e '    s/.*//' \
-e '    h' \
-e '    d' \
-e '  }' \
-e '  d' \
-e '}' \
-e '/(.*error.*)/s//$(C_ERROR)&$(reset)/' \
-e 'd'

# BibTeX invocations
# $(call run-bibtex,<tex >)# by default "bibtex"
run-bibtex  = $(call echo-run,$(BIBTEX),$1); $(BIBTEX) $1 | $(color_bib)

ifeq "$(strip $(TEX_BIB_STRATEGY))" "natbib"
BUILD_BIB_STRATEGY  := bibtex
endif

ifeq "$(strip $(BUILD_BIB_STRATEGY))" "biber"
run-bibtex  =  $(call echo-run,$(BIBER),$1); $(BIBER) $1 | $(color_bib)
endif

# Outputs all bibliography files to stdout.
# $(call get-bibs,<aux file>)
define get-bibs
$(shell $(SED) \
  -e '/^\\\(bibliography\|addbibresource\){/!d' \
  -e 's/\\addbibresource{\([^}]*\)}/\1 /' \
  -e 's/\\bibliography{\([^}]*\)}/\1 /' \
  -e 's/,/ /'\
'$1' | $(SORT) | $(UNIQ) )
endef
#   -e 's/,/.bib /g' \
#  -e 's/[[:space:]]/\\&/g' \

USE_NPX :=$(call have-cmd,$(NPX))
define run-npx
$(if $(USE_NPX),$(NPX) $1,$1)
endef
define run-sass
$(if $(USE_SASS),\
  $(call run-npx,$(notdir $(SASS)) $(SASS_FLAGS) $1 $2),\
  $(warning "no SASS suppot? check your installation"))
endef

# Figures conversion
#
# If they misspell gray, it should still work.
GRAY	?= $(call get-default,$(GREY),)

# Creation from  raw image, .jpg/.jpeg/.png/.tif/etc. files
#
# $(call convert-raw,<raw>,<out_fig>, $(GRAY))
define convert-raw
$(CONVERT) '$(strip $1)' $(if $(filter-out ,$3$(GRAY)),-type Grayscale,) '$(strip $2)'
endef

USE_INKSCAPE :=$(call have-cmd,$(INKSCAPE))
ifeq ($(USE_INKSCAPE),:)
define get-inkscape-export
--export-$(strip $(if $(filter %.pdf,$1),pdf,$(if $(filter %.emf,$1),emf,$(if $(filter %.eps,$1),eps,\
$(if $(filter %.svg,$1),plain-svg,\
$(error "$(C_ERROR)Unsupported $(INKSCAPE) export '$1'$(reset)"))))))
endef
INKSCAPE_FLAGS  +=--without-gui --vacuum-defs --export-area-page
# Creation from svg files
# $(call convert-svg,<svg>,<out_fig>, $(GRAY))
define convert-svg
$(INKSCAPE) $(INKSCAPE_FLAGS) '$(strip $1)' $(call get-inkscape-export,$2)='$(strip $2)'
endef
else
define convert-svg
$(call convert-raw,$1,$2,$3)
endef
endif

###############################################################################
# VARIABLE DECLARATIONS
#

ifeq "$(strip $(BUILD_TEX_STRATEGY))" "pdflatex"
latex_build_program		    ?= $(PDFLATEX)
endif

ifeq "$(strip $(BUILD_TEX_STRATEGY))" "xelatex"
latex_build_program		    ?= $(XELATEX)
endif

ifeq "$(strip $(BUILD_TEX_STRATEGY))" "lualatex"
latex_build_program		    ?= $(LUALATEX)
endif

###############################################################################
# Files of interest / Sources files searched in INDIR

# Utility function for getting only selected source to build
# if BUILD_ONLY is empty 'all' list is returned
get-only          :=$(if $(BUILD_ONLY),$(filter $(BUILD_ONLY),$1),$1)

# Utility function for getting all files that are to be excluded
# if BUILD_EXCLUDE is empty 'empty' list is returned
get-excluded      :=$(if $(BUILD_EXCLUDE),$(filter $(BUILD_EXCLUDE),$1),)

files_all         ?= $(wildcard $(INDIR)/*.md)
files_all_noext   := $(basename $(files_all))
files_excludes    := $(call get-excluded,$(files_all_noext))
files_sources     ?= $(if $(BUILD_ONLY),\
  $(call get-only,$(files_all_noext)),\
  $(if $(files_excludes),$(filter-out $(files_excludes),$(files_all_noext)),$(files_all_noext)))
#$(if $(BUILD_ONLY),$(filter $(BUILD_ONLY),$(files_all)),$(files_all))

files_noext       := $(basename $(files_all))

# MDT/TEX files
files_mdt         := $(files_noext:$(INDIR)/%=$(MDTDIR)/%.mdt)
files_tex         := $(files_noext:$(INDIR)/%=$(MDTDIR)/%.tex)
files_sty         := $(wildcard $(TEMPLATEDIR)/*.sty)
tex_sty           := $(files_sty:$(TEMPLATEDIR)/%=$(TEXDIR)/%)

# MDH files
files_mdh         := $(files_noext:$(INDIR)/%=$(MDHDIR)/%.mdh)
files_html        := $(files_noext:$(INDIR)/%=$(HTMLDIR)/%.html)
files_epub        := $(files_noext:$(INDIR)/%=$(EPUBDIR)/%.epub)
files_docx        := $(files_noext:$(INDIR)/%=$(DOCXDIR)/%.docx)
files_odt         := $(files_noext:$(INDIR)/%=$(ODTDIR)/%.odt)

# MDX files
files_mdx         := $(files_noext:$(INDIR)/%=$(MDTDIR)/%.mdx)
files_tex         := $(files_noext:$(INDIR)/%=$(TEXDIR)/%.tex)
files_pdf         := $(files_noext:$(INDIR)/%=$(PDFDIR)/%.pdf)

# SCSS/CSS files
ifdef USE_SASS
files_scss        := $(filter-out $(SCSSDIR)/_%.scss,$(wildcard $(SCSSDIR)/*.scss))
files_css         := $(patsubst $(SCSSDIR)/%.scss,$(CSS_BUILDDIR)/%.css,$(files_scss))
prepare_targets   += $(NODEDIR)/bootstrap/
else
files_css         := $(patsubst $(CSS_DISTDIR)/%.css,$(CSS_BUILDDIR)/%.css,$(wildcard $(CSS_DISTDIR)/*.css))
endif

## Figures
figures     != $(EGREP) -sho '($(FIGDIR)/[^{}\"\)]*)' $(files_all) | $(UNIQ)
#figures     =
mediafiles  := $(patsubst $(FIGDIR)/%,$(MEDIADIR)/%,$(figures))
#mediafiles  != $(FIND) $(MEDIADIR)
fig_svg     := $(figures:%=$(OUTDIR)/%.svg)
fig_pdf     := $(figures:%=$(OUTDIR)/%.pdf)
fig_png     := $(figures:%=$(OUTDIR)/%.png)
fig_emf     := $(figures:%=$(OUTDIR)/%.emf)

md_fig_grep = $(EGREP) -sho '($(FIGDIR)/[^{}\")]*)'
get-md-fig  = $(shell $(md_fig_grep) $1 | $(UNIQ))
################################################################################
# Dependancies
dir_deps  += $(OUTDIR) $(OUT_ASSETSDIR) $(OUT_BIBDIR) $(OUT_FIGDIR)
dir_deps  += $(MDHDIR) $(HTMLDIR) $(CSS_BUILDDIR) $(CSS_DISTDIR)
dir_deps  += $(MDXDIR) $(XMLDIR)
dir_deps  += $(EPUBDIR) $(DOCXDIR) $(ODTDIR)
dir_deps  += $(MDTDIR) $(TEXDIR) $(PDFDIR)

base_deps += clean-files $(METADATA) $(VARSDATA) $(PP_MACROS)

bib_deps  += $(CSL) $(BIBFILES)
bibtex_deps+= $(BIBFILES) $(BIBFILES:$(BIBDIR)/%=$(OUT_BIBDIR)/%)

mdt_deps  += $(files_mdt) $(base_deps) $(PP_latex_MACROS) $(bib_deps)
tex_deps  += $(mdt_deps) $(TEMPLATEDIR)/template.latex $(tex_sty)
tex_deps  += $(bibtex_deps)
#tex_deps  += $(fig_pdf)
pdf_deps  += $(base_deps)

mdh_deps  += $(base_deps) $(PP_html5_MACROS) $(bib_deps)
html_deps += $(mdh_deps)
html_deps += $(filter %html.css,$(files_css))
#html_deps += $(fig_svg)
html_deps += $(TEMPLATEDIR)/template.html5

epub_deps += $(mdh_deps) $(TEMPLATEDIR)/template.epub3
epub_deps += $(filter %epub.css,$(files_css))
#pub_deps += $(fig_svg)

docx_deps += $(mdh_deps) $(TEMPLATEDIR)/template.docx
#docx_deps += $(fig_emf)
odt_deps  += $(mdh_deps) $(TEMPLATEDIR)/template.odt
#odt_deps  += $(fig_png)

mdx_deps  += $(files_mdx) $(base_deps) $(PP_docbook5_MACROS)  $(bib_deps)
xml_deps  += $(mdx_deps) $(TEMPLATEDIR)/template.docbook5
xml_deps  += $(filter %docbook.css,$(files_css))
#xml_deps  += $(fig_svg)

ifdef USE_SASS
css_deps  += $(foreach d,$(SCSSINCS), $(wildcard $(d)/*.scss))
css_ddeps += $(patsubst $(CSS_BUILDDIR)/%.css,$(CSS_DISTDIR)/%.css,$(wildcard $(CSS_BUILDDIR)/*.css))
html_deps += $(css_deps) $(css_ddeps)
epub_deps += $(css_deps) $(css_ddeps)
xml_deps  += $(css_deps) $(css_ddeps)
endif

################################################################################
# clean
clean_subdirs       += $(MDDIR) $(DATADIR) $(BIBDIR) $(FIGDIR) $(HTMLDIR) $(TEXDIR)
clean_patterns      += *~ *.bak *.backup *.bck
clean_files         += $(foreach d,. $(clean_subdirs),$(addprefix $(d)/,$(clean_patterns))) $(BIB)
clean_css_files     += $(files_css) $(patsubst %.css,/%.css.map,$(files_css))
clean_fig           += $(fig_svg) $(fig_pdf) $(fig_png) $(fig_emf)
clean_mdt_files     += $(files_mdt)

## Core latex/pdflatex auxiliary files:
clean_tex_aux_pattern+=*.aux *.cb *.cb2 *.fls *.fmt \
  *.fot *.lof *.log *.lol *.lot  *.out *.toc  *.upa *.upb\
  *.idx *.ind *.ilg *.glg *.glo *.gls *.nls *.nlo *.nlg \
  *.xmpdata
clean_tex_aux_files += $(addprefix $(TEXDIR)/,$(clean_tex_aux_pattern)))
## Bibliography auxiliary files (bibtex/biblatex/biber):
clean_tex_bib_pattern+=*.bbl *.bcf *.blg *-blx.aux *-blx.bib *.run.xml
clean_tex_bib_files += $(addprefix $(TEXDIR)/,$(clean_tex_bib_pattern)))

clean_tex_files     += $(files_tex)
clean_mdh_files     += $(files_mdh)
clean_mdx_files     += $(files_mdx)
clean_html_files    += $(wildcard $(HTMLDIR)/*.html)
clean_epub_files    += $(wildcard $(EPUBDIR)/*.epub)
clean_docx_files    += $(wildcard $(HTMLDIR)/*.docx)
clean_odt_files     += $(wildcard $(HTMLDIR)/*.odt)
clean_xml_files     += $(wildcard $(HTMLDIR)/*.xml)

# distclean
distclean_subdirs   +=$(NODEDIR) $(HTMLDIR) $(TEXDIR)

###############################################################################
# DEFAULT TARGET
#
.PHONY: all
all: $(BUILD_DEFAULT_TARGETS)

WATCH			?=./pandoc-watch.sh
WATCTHED 	+= $(sort  $(INDIR) $(DATADIR) $(ASSETSDIR) $(TEMPLATEDIR))
ifdef WATCH
watch-html:
	$(QUIET)$(WATCH) html $(WATCTHED)
watch-xml:
	$(QUIET)$(WATCH) xml $(WATCTHED)
watch-pdf:
	$(QUIET)$(WATCH) pdf $(WATCTHED)
endif

test:
	$(QUIET)$(ECHO) "A $(this_file) MAKEFLAGS: $(MAKEFLAGS)"
	$(QUIET)$(ECHO) "get bibs" $(patsubst ../%,%,$(call get-bibs,build/tex/01_article.tex))
################################################################################
# MAIN TARGETS
#

## HTML Output target
.PHONY: html
html:$(html_deps) $(files_html)
html-deps:
	$(QUIET)$(call echo-dep,html,$(html_deps))
	$(QUIET)$(call echo-list,$(sort $(files_css)))

.PRECIOUS: $(files_mdh)
$(HTMLDIR)/%.html:$(MDHDIR)/%.mdh $(html_deps) | $(HTMLDIR)
	$(QUIET)$(call echo-build,HTML,$@)
	$(QUIET)$(MAKE) $(addprefix $(OUTDIR)/,$(addsuffix .svg,$(call get-md-fig,$<)))
	$(QUIET)$(call echo-run,$(PANDOC),$@,$<)
	$(call run-pandoc-from-md,$<,$@,html5)
	$(call echo-end-target,$@)

# from Pandoc Manual:
# The metadata fields will be combined through a left-biased union:
# if two metadata blocks attempt to set the same field, the value from the
# first block will be taken.


## EPUB Output target
.PHONY: epub
epub:$(epub_deps) $(files_epub)
$(EPUBDIR)/%.epub:$(MDHDIR)/%.mdh $(epub_deps) | $(EPUBDIR)
	$(QUIET)$(call echo-build,EPUB,$@)
	$(QUIET)$(MAKE) $(addprefix $(OUTDIR)/,$(addsuffix .svg,$(call get-md-fig,$<)))
	$(QUIET)$(call echo-run,$(PANDOC),$@,$<)
	$(call run-pandoc-from-md,$<,$@,epub3)
	$(call echo-end-target,$@)


## DOCX Output target
.PHONY: docx
docx:$(docx_deps) $(files_docx)
$(DOCXDIR)/%.docx:$(MDHDIR)/%.mdh $(docx_deps) | $(DOCXDIR)
	$(QUIET)$(call echo-build,DOCX,$@)
	$(QUIET)$(MAKE) $(addprefix $(OUTDIR)/,$(addsuffix .emf,$(call get-md-fig,$<)))
	$(QUIET)$(call echo-run,$(PANDOC),$@,$<)
	$(call run-pandoc-from-md,$<,$@,docx)
	$(call echo-end-target,$@)

## ODT Output target
.PHONY: odt
odt:
	$(QUIET)$(echo_dt) "Make odt ... has to be ruled"

# XML/DocBook Output target
.PHONY: xml
xml:
	$(QUIET)$(call echo-warning,"XML/DocBook outputs are unmaintened")
	$(QUIET)$(echo_dt) "Make xml ... has to be ruled"
xml-chunk:
	$(QUIET)$(echo_dt) "Make xml-chunk ... has to be ruled"

# TeX/PDF Output target
.PHONY: pdf
pdf:$(pdf_deps) $(files_pdf)

$(PDFDIR)/%.pdf:$(TEXDIR)/%.pdf
	$(QUIET)$(call echo-build,PDF,$@,dist)
	$(QUIET)$(call echo-copy,$<,$@)
	$(call replace-temporary-if-different-and-remove,$<,$@)
	$(call echo-end-target,$@)

$(TEXDIR)/%.pdf:$(call path-norm,$(TEXDIR)/%.tex)
	$(QUIET)$(call echo-build,PDF,$@,prep)
	$(QUIET)$(MAKE) $(addprefix $(OUTDIR)/,$(call get-md-fig,$<))
	$(QUIET)$(MAKE) $(patsubst ../$(BIBDIR)/%,$(OUT_BIBDIR)/%,$(call get-bibs,$<))
	$(QUIET)cd $(TEXDIR) && \
	 $(MAKE) -f $(PWD)/$(this_file) $(REMAKE_FLAGS) \
	 BUILD_BIB_STRATEGY='$(strip $(call get-bib-strategy,$<))' "$(notdir $@)"\
	 && cd -
	$(call echo-end-target,$@)


define REMAKE_FLAGS
ROOTDIR='$(ROOTDIR)' \
files_all='$(strip $(files_all))'\
files_sources='$(strip $(files_sources))'
endef

tex:$(tex_deps) $(files_tex)
#$(TEXDIR)/%.tex:$(MDTDIR)/%.mdt $(tex_deps) | $(TEXDIR)
#	$(QUIET)$(echo_dt) "Make $@ ... has to be ruled"

# Merge all bibliography in BIB
#
.PHONY: biblio $(BIB)
biblio:$(BIB)
$(BIB):$(BIBFILES)
	$(QUIET)$(call echo-build,"Merge",$(BIBFILES),$@)
	$(QUIET)$(CAT) $(BIBFILES) > $(BIB)

$(OUT_BIBDIR)/%.bib:$(BIBDIR)/%.bib | $(OUT_BIBDIR)
	$(QUIET)$(call echo-copy,bib,$<,$@)
	$(QUIET)$(call copy-if-exists,$<,$@)

$(ROOTDIR)/$(OUT_BIBDIR)/%.bib:$(ROOTDIR)/$(BIBDIR)/%.bib
	$(QUIET)$(call echo-copy,bib+,$<,$@)
	$(QUIET)$(call copy-if-exists,$<,$@)
#########################
# Intermediate MDT rules for LaTeX/PDF
# Keep the generated .tex files around for debugging if needed.

# $(call test-run-again,<source stem>)
define test-run-again
$(EGREP) '^(.*Rerun .*|No file $1\.[^.]+\.)$$' $1.log \
| $(EGREP) -q -v '^(Package: rerunfilecheck.*Rerun checks for auxiliary files.*)$$'
endef

.PRECIOUS: %.aux %.bbl
# Build pdf from LaTeX files:
%.pdf:%.tex %.bbl %.aux
	$(QUIET)fatal=`$(call colorize-latex-errors,$*.log)`; \
	if [ x"$$fatal" != x"" ]; then \
		$(ECHO) "$$fatal"; \
		exit 1; \
	fi; \
	for i in 2 3 4; do \
		if $(call test-run-again,$*); then \
	    $(echo_dt) "$(C_INFO)Need to re-run LaTeX...$(reset)";\
			$(call echo-build,$<,$*.pdf,$$i); \
			$(call run-latex,$*); \
		else \
			break; \
    fi; \
  done

#biblio

ifeq "$(strip $(TEX_BIB_STRATEGY))" "biblatex"
%.bbl:%.bcf %.aux
	$(QUIET)$(call echo-build,$<,$@); \
	$(call run-bibtex,$<,$@,$*.bcf) ;\
	$(call echo-end-target,$@)
else
#default bibtex!
%.bbl:%.aux %.tex
	$(QUIET)$(call echo-build,BBL? $@,$*)
	$(call run-bibtex,$*)
	if $(EGREP) -q 'Citation.*(undef)' $*.log ; then \
    $(echo_dt) "$(C_INFO)Need to re-run LaTeX for citation...$(reset)";\
		$(call echo-build,$<,$*.bbl); \
		$(call run-latex,$*); \
	fi
	$(call echo-end-target,$@)
endif

%.aux %.bcf %.fls:%.tex
	$(QUIET)$(call echo-build,$<,$*.pdf,1);\
	$(echo_dt) "$(C_INFO)Create/Update $*.aux $*.bcf and $*.fls$(reset)";\
	$(call run-latex,$*,-recorder)|| : ; \
	$(call die-on-no-aux,$*) ;\
	fatal=`$(call colorize-latex-errors,$*.log)`; \
	if [ x"$$fatal" != x"" ]; then \
		$(ECHO) "$$fatal"; \
		exit 1; \
	fi;

#.INTERMEDIATE: $(files_mdt)
$(MDTDIR)/%.mdt:$(MDDIR)/%.md | $(MDTDIR)
	$(QUIET)$(call echo-run,$(PANDOC),$@,$<)
	$(call run-pp-pandoc,$<,$@,MDT)
	$(QUIET)$(SED)  -e 's/}\s*\\cite{/,/g' -e 's/}\s*\\cref{/,/g'  < $@ > $@.sed
	$(call replace-temporary-if-different-and-remove,$@.sed,$@)

$(TEXDIR)/%.tex:$(MDTDIR)/%.mdt $(tex_deps)| $(TEXDIR)
	$(QUIET)$(call echo-build,TeX,$@,$<)
	$(QUIET)$(call echo-run,$(PANDOC),$@,$<)
	$(call run-pandoc-from-md,$<,$@,latex)
	$(call echo-end-target,$@);
#	$(QUIET)$(PANDOC) -f markdown$(PANDOC_MDEXT) $(PANDOC_FLAGS) \
	 $(VARSDATA) $(PANDOC_latex_FLAGS) $<  -t latex -o $@

$(TEXDIR)/%.sty:$(TEMPLATEDIR)/%.sty
	$(QUIET)$(call echo-copy,sty,$<,$@)
	$(QUIET)$(call copy-if-exists,$<,$@)

# Intermediate MDH rules for html/epub/docx/odt
#.INTERMEDIATE: $(files_mdh)
.PHONY: mdh
mdh: $(files_mdh)
$(MDHDIR)/%.mdh:$(MDDIR)/%.md $(mdh_deps)| $(MDHDIR)
	$(QUIET)$(call echo-run,$(PANDOC),$@,$<)
	$(call run-pp-pandoc,$<,$@,MDH)
	$(QUIET)$(SED)  -e 's/\]\s*\[@/; @/g' < $@ > $@.sed
	$(PANDOC) -f markdown$(PANDOC_MDEXT) $(PANDOC_FLAGS) $@.sed -t markdown \
		--toc --template=$(TEMPLATEDIR)/template.toc.md -o "$@.toc"
	$(call replace-temporary-if-different-and-remove,$@.sed,$@)

# Intermediate MDX rules for xml/docbook
#.INTERMEDIATE: $(files_mdx)
$(MDXDIR)/%.mdx:$(MDDIR)/%.md | $(MDXDIR)
	$(QUIET)$(call echo-run,$(PANDOC),$@,$<)
	$(call run-pp-pandoc,$<,$@,MDX)
	$(QUIET)$(SED)  -e 's/\]\s*\[@/; @/g' < $@ > $@.sed && \
	  $(call replace-temporary-if-different-and-remove,$@.sed,$@)

########################
# Intermediate CSS rules
#.SECONDARY: $(files_css)


.PHONY: css_dist
ifdef USE_SASS
$(CSS_BUILDDIR)/%.css:$(SCSSDIR)/%.scss $(css_deps) | $(CSS_BUILDDIR) $(SASS)
	$(QUIET)$(call echo-run,$(SASS),$<,$@)
	$(call run-sass,$<,$@)

css_dist: $(patsubst $(CSS_BUILDDIR)/%.css,$(CSS_DISTDIR)/%.css,$(wildcard $(CSS_BUILDDIR)/*.css))
$(CSS_DISTDIR)/%.css:$(CSS_BUILDDIR)/%.css | $(CSS_DISTDIR)
	$(QUIET)$(call echo-copy,CSS dist,$<,$@)
	$(QUIET)$(call copy-if-exists,$<,$@)
else
css_dist:
	$(QUIET)$(call echo-error,USE_SASS is disabled we cannot use css_dist rule)

$(CSS_BUILDDIR)/%.css:$(CSS_DISTDIR)/%.css| $(CSS_BUILDDIR)
	$(QUIET)$(call echo-copy,CSS dist,$<,$@)
	$(QUIET)$(call copy-if-exists,$<,$@)
endif

ifdef VERBOSE
define echo-node
	if [ $(VERBOSE) -gt 1 ]; then \
	  $(ECHO) "$(C_INFO) $1 is  in '$(NODEDIR)/$1'$(reset)";\
	  $(QUIET)$(ECHO) "$(C_INFO) You may manually perform: $(NPM) update $1$(reset)" ;\
	fi
endef
endif

#.SECONDARY:  $(NODEDIR)/bootstrap/scss
$(NODEDIR)/bootstrap/scss: $(NODEDIR)/bootstrap/
	$(QUIET)$(call echo-node,bootstrap)

$(SASS):$(NODEDIR)/sass
	$(call echo-node,sass)

################################################################################
#  Intermediate Figures rules
# Converts svg files into .eps files
#
.PHONY: svg
svg:$(fig_svg) $(OUT_FIGDIR)
$(OUT_FIGDIR)/%.svg:$(MEDIADIR)/%.svg
	$(QUIET)$(call echo-fig,$^,$<,$@)
	$(QUIET)$(call convert-svg,$<,$@)
ifeq "$(if $(call real-cmd,$(SVGO)),1,)" "1"
	$(QUIET)$(SVGO) --enable={cleanupIDs,collapseGroups,removeUnusedNS,removeUselessStrokeAndFill,removeUselessDefs,removeComments,removeMetadata,removeEmptyAttrs,removeEmptyContainers} $@
endif
ifeq "$(if $(call real-cmd,$(SCOUR)),1,)" "1"
	$(QUIET)$(SCOUR) --enable-viewboxing --enable-id-stripping \
		--enable-comment-stripping --shorten-ids --indent=none \
		-i $@ -o $@o
	 $(call replace-temporary-if-different-and-remove,$@o,$@)
endif

$(OUT_FIGDIR)/%.svg:$(MEDIADIR)/%.png
	$(QUIET)$(call echo-fig,$^,$@)
	$(QUIET)$(call convert-raw,$<,$@,$(GRAY))
$(OUT_FIGDIR)/%.svg:$(MEDIADIR)/%.jpg
	$(QUIET)$(call echo-fig,$^,$@)
	$(QUIET)$(call convert-raw,$<,$@,$(GRAY))
$(OUT_FIGDIR)/%.svg:$(MEDIADIR)/%.tif
	$(QUIET)$(call echo-fig,$^,$@)
	$(QUIET)$(call convert-raw,$<,$@,$(GRAY))

$(OUT_FIGDIR)/%.pdf:$(MEDIADIR)/%.svg
	$(QUIET)$(call echo-fig,$^,$@)
	$(QUIET)$(call convert-svg,$<,$@)

$(OUT_FIGDIR)/%.pdf:$(OUT_FIGDIR)/%.svg
	$(QUIET)$(call echo-fig,$^,$@)
	$(QUIET)$(call convert-svg,$<,$@)

$(OUT_FIGDIR)/%.emf:$(MEDIADIR)/%.svg
	$(QUIET)$(call echo-fig,$^,$@)
	$(QUIET)$(call convert-svg,$<,$@)

$(OUT_FIGDIR)/%.emf:$(OUT_FIGDIR)/%.svg
	$(QUIET)$(call echo-fig,$^,$@)
	$(QUIET)$(call convert-svg,$<,$@)

################################################################################
# PREPARE TARGETS
#
dir_prep += $(sort  $(OUTDIR)/ $(dir_deps))
ifeq ($(BUILD_OUTPUT_MODE),multi)
dir_prep += $(htmlmuli_temp)
endif
.PHONY: dirs
dirs: $(dir_prep)

.PRECIOUS:$(OUTDIR)%/ $(dir_prep) $(NODEDIR)/%/

$(dir_prep):
	$(QUIET)$(call echo-run,Make dir_prep,$@); $(MKDIR) $@

$(OUTDIR)%/:
	$(QUIET)$(call echo-run,Make dir,$@); $(MKDIR) $@

# Install a npm module
$(NODEDIR)/%/:
	$(QUIET)$(ECHO) "$(C_INFO) $* will be installed in the local folder$(reset)"
	$(QUIET)$(call echo-run,$(NPM)++,$*,$@)
	$(QUIET)$(NPM) install $*
	$(QUIET)$(ECHO) "$(C_INFO) $* now in '$@'$(reset)"

################################################################################
# CLEAN TARGETS
#
.PHONY: clean-all clean-html
clean: clean-files clean-aux clean-bib clean-mdt clean-mdh clean-css clean-fig ;
clean-files: clean-log
	$(QUIET)$(echo_dt) "$(C_WARNING) Cleaning unnecessary documents...$(reset)"
	$(call clean-files,$(clean_files))

clean-log:
	$(QUIET)$(echo_dt) "$(C_WARNING) Cleaning Log intermediates...$(reset)"
	$(call clean-files,$(clean_log))
clean-aux:
	$(QUIET)$(echo_dt) "$(C_WARNING) Cleaning LaTeX intermediates...$(reset)"
	$(call clean-files,$(clean_tex_aux_files))
clean-bib:
	$(QUIET)$(echo_dt) "$(C_WARNING) Cleaning Bib intermediates...$(reset)"
	$(call clean-files,$(clean_tex_bib_files))

clean-mdt:
	$(QUIET)$(echo_dt) "$(C_WARNING) Cleaning Markdown/Tex intermediates...$(reset)"
	$(call clean-files,$(clean_mdt_files))

clean-tex: clean-aux clean-mdt
	$(QUIET)$(echo_dt) "$(C_WARNING) Cleaning LaTeX intermediates...$(reset)"
	$(call clean-files,$(clean_tex_files))

clean-mdh:
	$(QUIET)$(echo_dt) "$(C_WARNING) Cleaning Markdown/Html intermediates...$(reset)"
	$(call clean-files,$(clean_mdh_files))

clean-html: clean-mdh clean-css
	$(QUIET)$(echo_dt) "$(C_WARNING) Clean HTML $(clean_html_files)...$(reset)"
	$(call clean-files,$(clean_html_files))

clean-epub: clean-mdh  clean-css
	$(QUIET)$(echo_dt) "$(C_WARNING) Clean EPUB $(clean_epub_files)...$(reset)"
	$(call clean-files,$(clean_epub_files))

clean-css:
	$(QUIET)$(echo_dt) "$(C_WARNING) Clean CSS intermediates...$(reset)"
	$(call clean-files,$(clean_css_files))

clean-fig:
	$(QUIET)$(echo_dt) "$(C_WARNING) Clean figures intermediates...$(reset)"
	$(call clean-files,$(clean_fig))

# DISTCLEAN TARGETS
# Remove all intermediate
.PHONY: distclean
distclean: clean
	$(QUIET)$(echo_dt) "$(C_ERROR) Distclean unnecessary subdirs:'$(distclean_subdirs)'$(reset)"
	$(QUIET)$(call clean-files,$(distclean_files))
	$(QUIET)$(RM) -r $(distclean_subdirs)

# make a compressed archive
# $(call make_archive,<compressed_file>,dir)
define make_archive
$(ZIP) -r -T -q $1 $2
endef
#

.PHONY:dist
dist: distclean archive
archive:zip;
zip:
	$(QUIET)$(call echo-run,$(ZIP),$(DISTNAME),../$(TODAY)_$(MAIN_DOC_BASENAME).zip)
	$(call make_archive,../$(TODAY)_$(MAIN_DOC_BASENAME).zip,*)

tbz:
	$(QUIET)$(call echo-run,$(TAR),$(DISTNAME),../$(TODAY)_$(MAIN_DOC_BASENAME).tbz)
	cd .. &&$(TAR) cjf $(TODAY)_$(MAIN_DOC_BASENAME).tbz $(DISTNAME) && cd -
################################################################################
# HELPFUL PHONY TARGETS
#

.PHONY: _all_programs
_all_programs:
	$(QUIET)$(echo_dt) "# All External Programs Used\n"
	$(QUIET)$(call output-all-programs)

.PHONY: _check_programs
_check_programs:
	$(QUIET)$(echo_dt) "== Checking Makefile Dependencies ==\n";
	$(QUIET) \
	allprogs=`\
	 ($(call output-all-programs)) | \
	 $(SED) \
	 -e 's/^[[:space:]]*//' \
	 -e '/^#/d' \
	 -e 's/[[:space:]]*#.*//' \
	 -e '/^=/s/[[:space:]]/_/g' \
	 -e '/^[[:space:]]*$$/d' \
	 -e 's/^[^=].*=[[:space:]]*\([^[:space:]]\{1,\}\).*$$/\\1/' \
	 `; \
	spaces='                             '; \
	for p in $${allprogs}; do \
	case $$p in \
		=*) $(ECHO); $(ECHO) "$$p";; \
		'$$(NODEDIR)'*)\
		  node=`$(ECHO) $$p| $(SED) -e 's|\$$(NODEDIR)|$(NODEDIR)|g'`;\
		  np=`basename $$node`;\
		   $(ECHO) -n "$$np:$$spaces" | $(SED) -e 's/^\(.\{0,20\}\).*$$/\1/'; \
			loc=`$(WHICH) $$node 2>/dev/null`; \
			if [ x"$$?" = x"0" ]; then \
				$(ECHO) "$(bold)$(green)Found:$(reset) $$loc"; \
			else \
				$(ECHO) "$(bold)$(red)Not Found$(reset)"; \
			fi; \
			;; \
		*) \
			$(ECHO) -n "$$p:$$spaces" | $(SED) -e 's/^\(.\{0,20\}\).*$$/\1/'; \
			loc=`$(WHICH) $$p`; \
			if [ x"$$?" = x"0" ]; then \
				$(ECHO) "$(bold)$(green)Found:$(reset) $$loc"; \
			else \
				$(ECHO) "$(bold)$(red)Not Found$(reset)"; \
			fi; \
			;; \
	esac; \
	done

#.PHONY:_check_pp
#_check_pp:
#	$(QUIET)$(ECHO) "== Checking Makefile Dependencies =="; $(ECHO)

.PHONY: _show_all
_show_dirs:
	$(QUIET)$(echo_dt) "== DIRS =="
	$(QUIET)$(call echo-list,$(dir_prep))
_show_sources:
	$(QUIET)$(echo_dt) "== All Sources =="
	$(QUIET)$(call echo-list,$(sort $(files_all)))
	$(QUIET)$(echo_dt) "== Sources =="
	$(QUIET)$(call echo-list,$(sort $(files_sources)))

_show_ignored:
	$(QUIET)$(echo_dt) "== Ignored =="
	$(QUIET)$(call echo-list,$(sort $(files_excludes)))

_show_css:
	$(QUIET)$(echo_dt) "== CSS == $(css_ddeps)"
#	$(QUIET)$(call echo-dep,css_deps,$(css_deps))
#	$(QUIET)$(call echo-dep,css_ddeps,$(css_ddeps))
	$(QUIET)$(call echo-list,$(sort $(files_css)))

_show_fig:
	$(QUIET)$(echo_dt) "== Figures? =="
	$(QUIET)$(call echo-list,$(sort $(figures)))
	$(QUIET)$(echo_dt) "== Mediafiles =="
	$(QUIET)$(call echo-list,$(sort $(mediafiles)))

_show_html:
	$(QUIET)$(echo_dt) "== HTML =="
	$(QUIET)$(call echo-list,$(sort $(files_html)))

_show_tex:
	$(QUIET)$(echo_dt) "== TeX =="
	$(QUIET)$(call echo-list,$(sort $(files_tex)))

_show: _show_sources _show_ignored
#	$(QUIET)$(echo_dt) "== files_noext =="
#	$(QUIET)$(call echo-list,$(sort $(files_noext)))
_show_all: _show _show_css _show_fig _show_html _show_tex



VERS_FILE=$(ROOTDIR)/VERSION
VERSION !=$(CAT) $(VERS_FILE)
version: VERSION
	$(QUIET)$(echo_dt) "version: v$(VERSION)"
#	$(SED) -i 's/"version": .*/"version": "$(VERSION)",/' package.json
#	$(SED) -i 's/version: .*/version: $(VERSION)/' $(VARSDATA)
#
# HELP TEXT
#

define help_text
% MAKE(1) Make for pandoc-df-thesis-template
% D. Folio
% November 26, 2018

# NAME

make - make utility to build a pandoc-df-thesis-template dissertation

 Generates a number of possible output files from Pandoc document and its
 various dependencies.

# SYNOPSIS

make [GRAY=1] [VERBOSE=1] [SHELL_DEBUG=1] <target(s)>

# DESCRIPTION

This Makefile allows to generate  pandoc-df-thesis-template dissertation in
various output format, and its necessary materials.

Once you have edited the `Makefile` (optional), the `_data/variables.yml` (advised), and  written some elements in the sources directory:  `_md/`, run this simple shell command:

  make

# STANDARD TARGETS

all
:  Make default targets (defined with `BUILD_DEFAULT_TARGETS`), e.g.: html, pdf

pdf
:  Build the PDF output document from LaTeX generated files.

     **Note**: the PDF is generated using the `BUILD_TEX_STRATEGY`, set with one of: lualatex, pdflatex or xelatex

html
:  Build the HTML(5) output document:

   -  If `BUILD_OUTPUT_MODE=single`: a single HTML(5) document are generated using Pandoc.
   -  If `BUILD_OUTPUT_MODE=htmlmulti`: multiple HTML(5) documents are  generated using Jekyll.

docx
:  Build the MS Word output document

odt
:  Build the LibreOffice/OpenOffice output document

epub
:  Build the EPUB(v3) output document

xml
:  Build the DocBook(v5) output document

clean
:  Remove ALL generated files, leaving only sources and "important" intermediates
   intact. This will *always* skip files mentioned in the "neverclean" variable,
   either in this file or specified in Makefile.ini, e.g.:

   ```
     neverclean := *.pdf *.svg
   ```

distclean
:  *Remove ALL generated files!!!* (e.g. 'build/' is removed!!!).


dist
:  Create an archive file for the dissertation.

    - **Note 1**: the *distclean* target are called before creating the archive!
    - **Note 2**: the archive are place in the parent folder with the following
      format: `<TODAY>_<MAIN_DOC_BASENAME>.zip`

# STANDARD OPTIONS:

VERBOSE
:  This turns off all @ prefixes for commands invoked by make.  Thus,
    you get to see all of the gory details of what is going on.

SHELL_DEBUG
:  This enables the -x option for sh, meaning that everything it does is
    echoed to stderr.  This is particularly useful for debugging
    what is going on in $$(shell ...) invocations.  One of my favorite
    debugging tricks is to do this:

    make -d SHELL_DEBUG=1 VERBOSE=1 2>&1 | less

KEEP_TEMP
:  When set, this allows .make and other temporary files to stick around
    long enough to do some debugging.  This can be useful when trying to
    figure out why gnuplot is not doing the right things, for example.

# Minor Issue

In case of troubleshooting, first hit:

```{sh}
make _check_programs
```

and look for "Not Found" programs: some of them are mandatory!

# See Also

- The [GitHub](https//github.com) repository: <https://github.com/dfolio/pandoc-df-thesis-template>
- The [GitHub](https//github.com) wiki: <https://github.com/dfolio/pandoc-df-thesis-template/wiki>


endef

#
# HELP TARGETS
#
export help_text
.PHONY: help
help:
	$(ECHO) "$$help_text" | $(PANDOC) -s  -f markdown -t man | man -l -

#$(call path-norm,)
.SECONDEXPANSION:
$(MAIN_DOC_BASENAME).aux $(MAIN_DOC_BASENAME).bbl:$(BIBFILES:$(BIBDIR)/%=$(ROOTDIR)/$(OUT_BIBDIR)/%)
