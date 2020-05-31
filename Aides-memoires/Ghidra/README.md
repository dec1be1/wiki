Ghidra
======

# FunctionID
Cette fonctionnalité de *Ghidra* permet d'identifier dans un programme les fonctions d'une librairie connue (dont les hashs ont préalablement été calculés et importés dans une base de données spécifique).

> Note : la fonctionnalité n'est pas nécessairement activée par défaut. Il faut aller dans *File/Configure* puis l'activer. Il faut également activer le plugin *FunctionID* dans les les options expérimentales.

## Création d'une nouvelle base de données
Menu *Tools/Function ID/Create new empty FidDb*. On choisit alors un nouveau fichier qui va héberger cette base de données. Ce fichier aura l'extension `.fidb`.
Typiquement, on peut créer un fichier *fidb* par librairie.

> A la création d'une nouvelle base, cette dernière est automatiquement attachée au projet.

## Ajouter des éléments à la base
Il faut que les infos de deboguage contenues dans le programme ouvert (ou la lib) aient permis à Ghidra de reconnaître les signatures de fonctions. Dans ce cas, on peut ajouter ces signatures à la base avec le menu *Tools/Function ID/Populate FidDb from programs*.
On peut vérifier que les signatures ont bien été importées avec le menu *Tools/Function ID/Table Viewer*.

## Identification des fonctions
Il suffit d'ouvrir le fichier comportant des fonctions à identifier. On regarde si la base de données précédemment remplie est attachée (menu *Tools/Function ID/Choose active FidDbs*). Si elle ne l'est pas, on l'attache via le menu *Tools/Function ID/Attach existing FidDb*.
On lance l'analyse en prenant soin de vérifier que l'analyseur *FunctionID* est bien sélectionné.
