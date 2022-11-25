<h1> pandoc-thesis <a href="https://github.com/andros21/pandoc-thesis/actions/workflows/build.yml">
    <img src="https://img.shields.io/github/workflow/status/andros21/pandoc-thesis/build%20pandoc-thesis/master?label=build&logo=github" alt="build">
</a>
</h1>

A Template for Thesis Documents written in Markdown

### Prerequisites

* container engine
    * [`docker`](https://www.docker.com/) - most popular container engine
    * [`podman`](https://podman.io/) - a daemonless container engine
* [`make`](https://www.gnu.org/s/make/manual/make.html) command - build automation tool

> **Warning:** supported platforms
>  * `aarch64-unknown-linux`
>  * `x86_64-unknown-linux`
>  * `aarch64-apple-darwin`
>  * `x86_64-apple-darwin`

### Usage

* Maintain your references in [`md/references.bib`](md/references.bib)
* Put the title of your thesis, your name and other meta information in [`metadata.yaml`](metadata.yaml)
*  Adjust optional definitions in [`metadata.yaml`](metadata.yaml) to your needs:

    > **Note:** want an `abstract` or `acknowledgements` page uncomment and fill them

* Fill the markdown files under [`md/`](md) with your content, the default files in the folder [`md/`](md) \
    correspond to a typical structure of a scientific thesis

    > **Hint:** you will find some help regarding the use of Markdown in [`md/introduction.md`](md/introduction.md)\
    > as well as typical number of pages for each chapter in the comment section of each file

    > **Warning:** do not forget to reflect the changed filenames in [`Makefile`](Makefile)

* Create `pandoc-thesis` container with everything you need to build thesis: `make container`
* Build the thesis: `make`
* Clean up
    * to remove temporary (generated) filed: `make clean`
    * to also remove the generated thesis (PDF): `make distclean`
    * to remove container: `make containerclean`
    * to remove image: `make imageclean`

> **Note:** the above mentioned files constitute a minimal working example\
> To start your own project, simply clone this project and customize the files mentioned above.

> **Note:** to upgrade to latest `pandoc-thesis` image `make containerupgrade`

### Pandoc filters

Inside markdown source is possible to insert code-blocks of these available tools:
* [`gnuplot`](http://www.gnuplot.info/) - a portable command-line driven graphing utility
* [`graphviz`](https://graphviz.org/) - open source graph visualization software
* [`plantuml`](https://plantuml.com/) - easily create beautiful uml diagrams from simple text

thanks to [`pandocfilters`](https://github.com/jgm/pandocfilters) and [`imagine`](https://github.com/andros21/imagine) are rendered as image inside final pdf

> **Hint:** there is a special section inside [`md/introduction.md`](md/introduction.md)\
> for better understanding how it work and how to use it

> **Note:** `imagine` global configuration inside [`metadata.yaml`](metadata.yaml) or\
> config per block inside code-block header

> **Note:** `gnuplot` global configuration inside [`.gnuplot`](.gnuplot) loaded at startup

### Acknowledgements

Forked from work of [Carsten Gips](https://github.com/cagix) and [contributors](https://github.com/cagix/pandoc-thesis/graphs/contributors) licensed [MIT](https://opensource.org/licenses/MIT)
