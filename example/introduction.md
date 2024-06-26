# Einleitung

<!--
*   Worum geht es hier? Was ist das betrachtete Problem bzw. die Fragestellung der Arbeit?
*   Darstellung der Bedeutung und Relevanz: Warum sollte die Fragestellung bearbeitet werden?
*   Einordnung in den Kontext
*   Abgrenzung: Welche Probleme werden im Rahmen der Arbeit *nicht* gelöst?
*   Zielsetzung: Möglichst genaue Beschreibung der Ziele der Arbeit, etwa erwarteter Nutzen oder wissenschaftlicher Beitrag

Umfang: typisch ca. 8% ... 10% der Arbeit
-->


## Markdown und -Erweiterungen durch Pandoc

Für eine Einführung in (Pandoc-) Markdown vgl. [pandoc.org/MANUAL.html](https://pandoc.org/MANUAL.html).

Da als Backend \LaTeX{} zum Einsatz kommt, können alle entsprechenden Befehle und Umgebungen ebenfalls
genutzt werden (ggf. muss noch das jeweilige Paket importiert werden).

**Tipp**: Für eine schnelle Übersicht einfach den Quelltext ansehen (`./md/introduction.md`).


## Zitieren

Einfach den Bibtex-Key mit einem `@` davor in eckigen Klammern schreiben: Aus `[@Dietz2018]` wird [@Dietz2018] ...
Mit Seiten- oder Kapitelangabe: Aus `[@Dietz2018, Seite 111]` oder `[@Dietz2018, Kapitel 111]` wird
[@Dietz2018, Seite 111] oder [@Dietz2018, Kapitel 111] ...

Pandoc (bzw. `pandoc-citeproc`) nutzt per Default den *Chicago Manual of Style*-Stil^[vgl.
[pandoc.org/MANUAL.html#citations](https://pandoc.org/MANUAL.html#citations)].
Für andere Zitierstile (etwa numerisch oder als Fußnote) sind auf [zotero.org/styles](https://www.zotero.org/styles)
die passenden CSL-Dateien zum Download zu finden. Die Aktivierung erfolgt über die Option
`--csl=XXX.csl` in der Datei `Makefile`.

**Tipp**: Unter [editor.citationstyles.org/searchByName/](https://editor.citationstyles.org/searchByName/)
können Sie sich die Wirkung der jeweiligen Zitierstile/CSL-Definitionen anschauen.


## Abbildungen

![Hier steht die Bildunterschrift, Quelle: [@Dietz2018] \label{fig:foo}](figs/wuppie.png){width=80%}


## Source-Code

```{.python caption="The preprocessing step" #lst:huh style=friendly}
def foo():
  """ Wuppie! """
  pass
```

## Mathe

Display-Math geht wie in \LaTeX{} mit einem doppelten Dollarzeichen (entspricht der `equation`-Umgebung):

$$
    \label{eq:wuppie}
    \nabla E(\mathbf{w}) = \left( \frac{\partial E}{\partial w_{0}}, \frac{\partial E}{\partial w_{1}}, \ldots, \frac{\partial E}{\partial w_{n}} \right)^T
$$

Inline-Math geht mit einem einfachen Dollar-Zeichen: $\mathbf{w} \gets \mathbf{w} + \Delta\mathbf{w}$ ...


## Tabellen

| Rechtsbündig | Linksbündig | Default | Zentriert |
|-------------:|:------------|---------|:---------:|
|          foo | foo         | foo     |    foo    |
|          123 | 123         | 123     |    123    |
|          bar | bar         | bar     |    bar    |

: Tabelle als Markdown-Pipe-Table, vgl. [@Dietz2018] \label{tab:ugh}


Leider gibt es derzeit einen Bug (siehe [github.com/Wandmalfarbe/pandoc-latex-template/issues/29](https://github.com/Wandmalfarbe/pandoc-latex-template/issues/29)
bzw. [github.com/jgm/pandoc/issues/3929](https://github.com/jgm/pandoc/issues/3929)), wodurch die Breite beim Einfärben der
Tabellenzeilen etwas zu breit wird. Wenn das stört, kann man immer noch normale \LaTeX{}-Tabellen nutzen (siehe
Tabelle \ref{tab:ieks}).

\begin{longtable}[]{rllc}
\caption{Tabelle als \LaTeX{}-Table \label{tab:ieks}} \\
\toprule
Rechtsbündig & Linksbündig & Default & Zentriert \tabularnewline
\midrule
\endhead
foo & foo & foo & foo \tabularnewline
123 & 123 & 123 & 123 \tabularnewline
bar & bar & bar & bar \tabularnewline
\bottomrule
\end{longtable}


## Querverweise

Querverweise funktionieren in Markdown leider nicht so richtig wie von \LaTeX{} gewohnt.

Hier kann aber einfach auf die ensprechenden \LaTeX{}-Pendants ausgewichen werden:

*   Definieren einer Referenz mit `\label{<id>}`{.latex} (beispielsweise in den jeweiligen Unterschriften
    unter einer Abbildung/Tabelle/Code-Schnipsel), und
*   Bezugnahme auf eine Referenz im Text mit `\ref{<id>}`{.latex}.

Vgl. Abbildung \ref{fig:foo} oder Tabelle \ref{tab:ugh} oder Listing \ref{lst:huh} ...

Wer mehr braucht, kann sogenannte Filter^[vgl. [pandoc.org/filters.html](https://pandoc.org/filters.html)
bzw. [pandoc.org/lua-filters.html](https://pandoc.org/lua-filters.html)] einsetzen, beispielsweise
[github.com/lierdakil/pandoc-crossref](https://github.com/lierdakil/pandoc-crossref).


## Hinweise zum generierten PDF

Das generierte PDF ist für den **doppelseitigen** Ausdruck gedacht. Wie bei einem Buch fangen neue Kapitel
immer auf einer neuen rechten Seite an, d.h. es kann passieren, dass am Ende eines Kapitels ggf. eine leere
Seite erzeugt wird. Dies ist durchaus beabsichtigt.

\newpage

# Let's test pandoc-filters

## Gnuplot

Digital display exbibit a non linear emission behaviour, in relation to characteristic parameter $\gamma$,
see \ref{fig:gamma}:

```{.gnuplot caption="Different emission responses" #fig:gamma}
set size 0.8,0.8
set key left top
set format '$%g$'
set xlabel "Normalized input"
set ylabel "Normalized output"
plot [0:1] x with lines t '$\gamma = 1.0$' lt rgb "#ad3434" lw 3.5, \
           x**1.6 with lines t '$\gamma = 1.6$' lt rgb "#34ad34" lw 3.5, \
           x**2.2 with lines t '$\gamma = 2.2$' lt rgb "#3434ad" lw 3.5
```

## Graphviz

Internally a generic compiler can be viewed as \ref{fig:compiler}

```{.graphviz caption="General compiler pipe" #fig:compiler}
graph "" {
    rankdir="LR";
    source [label="source code" shape=ellipse];
    lexer [label="lexer" shape=box];
    parser [label="parser" shape=box];
    AST [label="AST builder" shape=box];
    optimizer [label="optimizer" shape=box];
    executable [label="executable" shape=ellipse];

    source -- lexer;
    lexer -- parser;
    parser -- AST;
    AST -- optimizer;
    optimizer -- executable;
}
```

\newpage

## Plantuml

Two web apps behind a dmz see \ref{fig:dmz}

```{.plantuml caption="web01 backend web02 frontend" #fig:dmz}
@startuml
nwdiag {
  network dmz {
      address = "210.x.x.x/24"

      web01 [address = "210.x.x.1"];
      web02 [address = "210.x.x.2"];
  }
}
@enduml
```

## Minted

```{.bash caption="Hello world bash script" #lst:bash xleftmargin=20pt,linenos}
#!/bin/bash

echo "Hello, World!"
```
With line numbers enabled and I can reference it too \ref{lst:bash}

## Matplotlib

```{.matplotlib caption="Matplotlib pgfplot backend" #fig:matplotlib}
x = np.linspace(0, 10)

fig, ax = plt.subplots()
for k in np.arange(1, 4):
   V = np.exp(-k*x)
   ax.plot(x, V, label=f"V(x)=-{k}x")

ax.set_xlabel('x')
ax.set_ylabel('p(x)')
ax.legend()
```
And obviously I can reference it too \ref{fig:matplotlib}
