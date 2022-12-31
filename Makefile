####################
## Setup (public) ##
####################

## pandoc-thesis official image
## Verify its signature before run `make container` ;)
OCI ?= ghcr.io/andros21/pandoc-thesis:latest

## Container engine to use
## Choose between docker or podman (rootless)
## (Defaults to docker)
CE := $(shell basename `which docker 2>/dev/null ||\
                        which podman 2>/dev/null || echo docker`)
docker_flags =
podman_flags = --userns keep-id
ifeq ($(CE), podman)
	optional_flags=$(podman_flags)
else
	optional_flags=$(docker_flags)
endif

## Working directory
## In case this doesn't work, set the path manually (use absolute paths).
WORKDIR  = $(CURDIR)

## User id and group id using stat command
## In case this doesn't work, set your UID and GID
UID := $(shell id -u)
GID := $(shell id -g)

## Check OS (supported Linux, Darwin aka Mac)
## Disable selinux volume mount remap on Mac
UNAME := $(shell uname -s)
default_remap =
selinux_remap = :Z
ifeq ($(UNAME), Linux)
	remap=$(selinux_remap)
else
	remap=$(default_remap)
endif

## Pandoc
## (Defaults to docker/podman. To use pandoc and TeX-Live directly, create an
## environment variable `PANDOC` pointing to the location of your
## pandoc installation.)
PANDOC  ?= $(CE) exec pandoc-thesis pandoc

## Source files
## (Adjust to your needs. Order of markdown files in $(SRC) matters!)
META     = metadata.yaml

SRC      = md/introduction.md \
           md/relatedwork.md  \
           md/concept.md      \
           md/realisation.md  \
           md/conclusion.md

BIBFILE  = md/references.bib

APPENDIX = md/appendix.md

TARGET   = thesis.pdf

####################
## Internal setup ##
####################

## Auxiliary files
TITLEPAGE   = titlepage.tex
FRONTMATTER = frontmatter.tex
BACKMATTER  = backmatter.tex
REFERENCES  = tex/references.tex

TMP1 = tex/$(TITLEPAGE:%.tex=__%.filled.tex)
TMP2 = tex/$(FRONTMATTER:%.tex=__%.filled.tex)
TMP3 = tex/$(BACKMATTER:%.tex=__%.filled.tex)
TMP  = $(TMP1) $(TMP2) $(TMP3)

## Pandoc options
AUX_OPTS  = --wrap=preserve

OPTIONS   = -f markdown
OPTIONS  += --pdf-engine=latexmk
OPTIONS  += --pdf-engine-opt=-outdir=build
OPTIONS  += --pdf-engine-opt=--shell-escape
OPTIONS  += --standalone

OPTIONS  += -M lang=en-EN
OPTIONS  += --metadata-file=$(META)
OPTIONS  += --filter pandoc-imagine
OPTIONS  += --filter pandoc-minted

OPTIONS  += --include-in-header=$(TMP1)
OPTIONS  += --include-before-body=$(TMP2)
OPTIONS  += --include-after-body=$(TMP3)

OPTIONS  += --citeproc
OPTIONS  += -M bibliography=$(BIBFILE)
OPTIONS  += -M link-citations=true
## download from https://www.zotero.org/styles
## cf. https://pandoc.org/MANUAL.html#citations
#OPTIONS += --csl=chicago-author-date-de.csl
#OPTIONS += --csl=chicago-note-bibliography.csl
#OPTIONS += --csl=ieee.csl
#OPTIONS += --csl=oxford-university-press-note.csl

OPTIONS  += --listings

OPTIONS  += -V documentclass=book
OPTIONS  += -V papersize=a4
OPTIONS  += -V fontsize=11pt
## uncomment and edit to change line stretch
#OPTIONS  += -V linestretch=1.5

OPTIONS  += -V classoption:open=right
OPTIONS  += -V classoption:twoside=true
OPTIONS  += -V classoption:cleardoublepage=empty
OPTIONS  += -V classoption:clearpage=empty

OPTIONS  += -V geometry:top=30mm
OPTIONS  += -V geometry:left=25mm
OPTIONS  += -V geometry:bottom=30mm
OPTIONS  += -V geometry:width=150mm
OPTIONS  += -V geometry:bindingoffset=6mm

OPTIONS  += --toc
OPTIONS  += --toc-depth=3
OPTIONS  += --number-sections

## default links color
## set new colors inside `tex/extra.tex`
## and change with your
OPTIONS  += -V citecolor=darkred
OPTIONS  += -V linkcolor=darkred
OPTIONS  += -V urlcolor=darkblue

OPTIONS  += -V book=true
OPTIONS  += -V titlepage=true
OPTIONS  += -V toc-own-page=true

##################
## Main targets ##
##################

## Simple book layout
simple: containerstart $(TARGET)

## Open thesis after build it
thesis: simple
	xdg-open ${TARGET} > /dev/null 2>&1 &

example: containerstart example.pdf

## Create "pandoc-thesis" container with pandoc and TeX-Live
container:
	$(CE) run \
		--detach \
		--env HOME="/pandoc_thesis" \
		--interactive \
		--name pandoc-thesis \
		--user $(UID):$(GID) \
		$(optional_flags) \
		--volume "$(WORKDIR)":/pandoc_thesis$(remap) $(OCI)
	$(CE) exec -u 0 -w /tmp pandoc-thesis sh -c 'curl -sSf $$TEXLIVE_TRIGGER_URL | sh'
	$(CE) exec -u 0 -w /tmp pandoc-thesis sh -c 'curl -sSf $$JAVA_TRIGGER_URL | sh'
	$(CE) exec -u 0 -w /tmp pandoc-thesis dot -c
	$(CE) exec -u 0 -w /tmp pandoc-thesis python3 -m venv --system-site-packages /opt/imagine
	$(CE) exec -u 0 -w /tmp pandoc-thesis sh -c '/opt/imagine/bin/pip install \
		--no-cache-dir --disable-pip-version-check \
		git+$$PANDOC_FILTERS_REPO@$$PANDOC_FILTERS_VERSION'
	$(CE) exec -u 0 -w /tmp pandoc-thesis sh -c '/opt/imagine/bin/pip install \
		--no-cache-dir --disable-pip-version-check \
		git+$$PANDOC_IMAGINE_REPO@$$PANDOC_IMAGINE_VERSION'

#######################
## Auxiliary targets ##
#######################

## Build thesis
${TARGET}: $(SRC) $(REFERENCES) $(APPENDIX) $(META) $(BIBFILE) $(TMP)
	$(PANDOC) ${OPTIONS} -o $@ $(SRC) $(REFERENCES) $(APPENDIX)

## Build example
SRC_EXAMPLE      = example/introduction.md \
                   example/relatedwork.md  \
                   example/concept.md      \
                   example/realisation.md  \
                   example/conclusion.md
BIBFILE_EXAMPLE  = example/references.bib
APPENDIX_EXAMPLE = example/appendix.md
example.pdf: $(SRC_EXAMPLE) $(REFERENCES_EXAMPLE) $(APPENDIX_EXAMPLE) $(META) $(BIBFILE_EXAMPLE) $(TMP)
	$(PANDOC) ${OPTIONS} -M bibliography=$(BIBFILE_EXAMPLE) -o $@ $(SRC_EXAMPLE) $(REFERENCES) $(APPENDIX_EXAMPLE)

## Build auxiliary files (title page, frontmatter, backmatter, references)
$(TMP): tex/__%.filled.tex: tex/%.tex $(META)
	$(PANDOC) $(AUX_OPTS) --template=$< --metadata-file=$(META) -o $@ $<

## Start container or advice to setup it
containerstart:
	@$(CE) start pandoc-thesis \
		|| (printf 'Error: no container `pandoc-thesis` found, run `make container` before\n' && exit 1)

## Upgrade "pandoc-thesis" image and setup new container
containerupgrade: containerclean imageclean container

## Clean-up: Remove temporary (generated) files
clean:
	rm -rf $(TMP) \?/ .cache/ pd-images/ .java/

## Clean-up: Remove also generated thesis
distclean: clean
	rm -fr $(TARGET) build/

## Clean-up: Stop and remove "pandoc-thesis" container
containerclean:
	$(CE) stop pandoc-thesis || exit 0
	$(CE) rm pandoc-thesis || exit 0

## Clean-up: Remove "pandoc-thesis" image
imageclean:
	$(CE) rmi $(OCI) || exit 0

##################################
## Declaration of phony targets ##
##################################

.PHONY: simple container containerstart containerupgrade clean distclean containerclean imageclean
