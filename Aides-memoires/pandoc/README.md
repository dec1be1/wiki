pandoc
======

## Manuel en ligne

<https://pandoc.org/MANUAL.html>

## Markdown vers Latex

La conversion se fait ici directement en pdf.

Pour faire une conversion rapide (en modifiant les énormes marges par défaut de *Latex*) :
```
$ pandoc -V geometry:margin=1.2cm -f markdown -t pdf -o doc.pdf doc.md
```

On peut aussi mettre un entête *YAML* pour spécifier plus d'options (liste non exhaustive). Dans ce cas, on aura une page de garde avec beaucoup plus d'informations ainsi qu'une table des matières :
```
---
title: "Mon titre"
author: [Auteur 1, Auteur 2]
date: "04/04/2004"
keywords: [keyword1, keywork2, keyword3]
subtitle: "Sous-titre"
abstract: ""
subject: ""
description: ""
category: ""
documentclass: "article"
logo: "./img/logo.png"
papersize: "A4"
margin-left: "2cm"
margin-right: "2cm"
margin-top: "2cm"
margin-bottom: "2.2cm"
fontsize: "10pt"
linkcolor: "blue"
toc: true
toc-title: "Table des matières"
lang: fr-FR
...
```

