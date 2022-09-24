
###############################################################################
## Setup (public)
###############################################################################

## pandoc-thesis official image
## Verify its signature before run `make container` ;)
OCI = ghcr.io/andros21/pandoc-thesis:master


## Container engine to use
## Choose between docker or podman (rootless)
CE = $$(type -p docker 2>/dev/null || type -p podman 2>/dev/null)


## Working directory
## In case this doesn't work, set the path manually (use absolute paths).
WORKDIR                 = $(CURDIR)


## Pandoc
## (Defaults to docker/podman. To use pandoc and TeX-Live directly, create an
## environment variable `PANDOC` pointing to the location of your
## pandoc installation.)
PANDOC                 ?= $(CE) exec pandoc-thesis pandoc


## Source files
## (Adjust to your needs. Order of markdown files in $(SRC) matters!)
META                    = metadata.yaml

SRC                     = md/introduction.md       \
                          md/relatedwork.md        \
                          md/concept.md            \
                          md/realisation.md        \
                          md/conclusion.md

BIBFILE                 = md/references.bib

APPENDIX                = md/appendix.md

TARGET                  = thesis.pdf





###############################################################################
## Internal setup (do not change)
###############################################################################


## Auxiliary files
## (Do not change!)
TITLEPAGE               = titlepage.tex
FRONTMATTER             = frontmatter.tex
BACKMATTER              = backmatter.tex
REFERENCES              = tex/references.tex

TMP1                    = tex/$(TITLEPAGE:%.tex=__%.filled.tex)
TMP2                    = tex/$(FRONTMATTER:%.tex=__%.filled.tex)
TMP3                    = tex/$(BACKMATTER:%.tex=__%.filled.tex)
TMP                     = $(TMP1) $(TMP2) $(TMP3)


## Pandoc options
AUX_OPTS                = --wrap=preserve

OPTIONS                 = -f markdown
OPTIONS                += --pdf-engine=pdflatex
OPTIONS                += --standalone

OPTIONS                += -M lang=en-EN
OPTIONS                += --metadata-file=$(META)
OPTIONS                += --filter pandoc-imagine

OPTIONS                += --include-in-header=$(TMP1)
OPTIONS                += --include-before-body=$(TMP2)
OPTIONS                += --include-after-body=$(TMP3)

OPTIONS                += --citeproc
OPTIONS                += -M bibliography=$(BIBFILE)
OPTIONS                += -M link-citations=true
## download from https://www.zotero.org/styles
## cf. https://pandoc.org/MANUAL.html#citations
#OPTIONS                += --csl=chicago-author-date-de.csl
#OPTIONS                += --csl=chicago-note-bibliography.csl
#OPTIONS                += --csl=ieee.csl
#OPTIONS                += --csl=oxford-university-press-note.csl

OPTIONS                += --listings

OPTIONS                += -V documentclass=book
OPTIONS                += -V papersize=a4
OPTIONS                += -V fontsize=11pt

OPTIONS                += -V classoption:open=right
OPTIONS                += -V classoption:twoside=true
OPTIONS                += -V classoption:cleardoublepage=empty
OPTIONS                += -V classoption:clearpage=empty

OPTIONS                += -V geometry:top=30mm
OPTIONS                += -V geometry:left=25mm
OPTIONS                += -V geometry:bottom=30mm
OPTIONS                += -V geometry:width=150mm
OPTIONS                += -V geometry:bindingoffset=6mm

OPTIONS                += --toc
OPTIONS                += --toc-depth=3
OPTIONS                += --number-sections

OPTIONS                += -V citecolor=darkred
OPTIONS                += -V linkcolor=darkred
OPTIONS                += -V urlcolor=darkblue

OPTIONS                += -V book=true
OPTIONS                += -V titlepage=true
OPTIONS                += -V toc-own-page=true


## Container script/repo setup variables
TEXLIVE_TRIGGER_URL     = https://git.alpinelinux.org/aports/plain/community/texlive/texlive.trigger
TEXLIVE_TRIGGER         = /tmp/texlive.trigger.sh

JAVA_TRIGGER_URL        = https://git.alpinelinux.org/aports/plain/community/java-common/java-common.trigger
JAVA_TRIGGER            = /tmp/java.trigger.sh

PANDOC_FILTERS_REPO     = https://github.com/jgm/pandocfilters.git
PANDOC_FILTERS_VERSION  = 1beda668a764c8aa8e1c4e0cebce4323d4181f92

PANDOC_IMAGINE_REPO     = https://github.com/andros21/imagine
PANDOC_IMAGINE_VERSION  = dea560e1da35b1590b07ad5bcdb08535199e61dd



###############################################################################
## Main targets (do not change)
###############################################################################


## Simple book layout
simple: $(TARGET)


## Pull, run and setup "pandoc-thesis" image containing pandoc and TeX-Live
container:
	$(CE) run -it --detach --name pandoc-thesis -v $(WORKDIR):/pandoc_thesis:Z $(OCI)
	$(CE) exec -w / pandoc-thesis curl -sSf $(TEXLIVE_TRIGGER_URL) --output $(TEXLIVE_TRIGGER)
	$(CE) exec -w / pandoc-thesis curl -sSf $(JAVA_TRIGGER_URL) --output $(JAVA_TRIGGER)
	$(CE) exec -w / pandoc-thesis sh /tmp/texlive.trigger.sh
	$(CE) exec -w / pandoc-thesis dot -c
	$(CE) exec -w / pandoc-thesis sh /tmp/java.trigger.sh
	$(CE) exec -w / pandoc-thesis python3 -m pip install --root-user-action=ignore \
		git+$(PANDOC_FILTERS_REPO)@$(PANDOC_FILTERS_VERSION)
	$(CE) exec -w / pandoc-thesis python3 -m pip install --root-user-action=ignore \
		git+$(PANDOC_IMAGINE_REPO)@$(PANDOC_IMAGINE_VERSION)
	$(CE) exec -w / pandoc-thesis rm -fr .cache


## Upgrade "pandoc-thesis" image and setup new container
containerupgrade: containerclean imageclean container


## Clean-up: Remove temporary (generated) files
clean:
	rm -rf $(TMP)


## Clean-up: Remove also generated thesis and temp files
distclean: clean
	rm -f $(TARGET)
	rm -fr pd-images/ \?/


## Clean-up: Stop and remove "pandoc-thesis" container
containerclean:
	$(CE) stop pandoc-thesis
	$(CE) rm pandoc-thesis


## Clean-up: Remove "pandoc-thesis" image
imageclean:
	$(CE) rmi $(OCI)



###############################################################################
## Auxiliary targets (do not change)
###############################################################################


## Build thesis
${TARGET}: $(SRC) $(REFERENCES) $(APPENDIX) $(META) $(BIBFILE) $(TMP)
	$(PANDOC) ${OPTIONS} -o $@ $(SRC) $(REFERENCES) $(APPENDIX)


## Build auxiliary files (title page, frontmatter, backmatter, references)
$(TMP): tex/__%.filled.tex: tex/%.tex $(META)
	$(PANDOC) $(AUX_OPTS) --template=$< --metadata-file=$(META) -o $@ $<





###############################################################################
## Declaration of phony targets
###############################################################################


.PHONY: simple container clean distclean containerclean imageclean
