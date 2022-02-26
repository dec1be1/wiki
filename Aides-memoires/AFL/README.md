# American Fuzzy Lop (AFL)

Cet article constitue mon aide-mémoire pour *AFL* (fuzzer d'applications
userland).

## Installation

L'installation d'AFL est très simple. On suit les indications de la
documentation officielle :
```
git clone https://github.com/google/AFL.git
cd AFL
make
sudo make install
```

## Fuzzing par instrumentation du binaire

Pour profiter de ce mode, il faut disposer du code source du programme qu'on
veut instrumenter. Le principe est de le compiler avec `afl-gcc` qui va
insérer des instructions assembleur permettant de tracer le programme et
notamment d'identifier les chemins d'exécution empruntés (*path*) selon
l'entrée fournie.

### Configuration & compilation de la cible

La configuration se fait à l'aide de variables d'environnement :

* `CC` : le chemin (et éventuellement les options de compilation) du
  compilateur C. Au choix : `afl-gcc`, `afl-clang` ou `afl-clang-fast`
  (support *LLVM* à installer dans ce cas).
* `CXX` : idem pour le compilateur C++ : `afl-g++`, `afl-clang++`
  ou `afl-clang-fast++`.
* `AFL_INST_RATIO` : le pourcentage d'instrumentation du binaire. On met
  généralement `100` mais on peut vouloir diminuer pour diverses raisons
  (performances, ...).
* `AFL_HARDEN` : permet d'ajouter des options de durcissement du code. Ca
  augmente les chances de crash ;)

De plus, les options de compilation suivantes peuvent être utiles :

* `-ggdb` : permet d'avoir plus d'informations lors d'une future session de
  debug avec *gdb*.
* `-disable-shared` : désactive l'utilisation des bibliothèques partagées.
* `-m32` : permet de compiler un binaire 32 bits sur une machine 64 bits.

Un exemple typique :
```
export CC="afl-gcc -ggdb"
export CXX="afl-g++ -ggdb"
export CFLAGS="-ggdb -fsanitize=address"
export CXXFLAGS="-ggdb -fsanitize=address"
export AFL_INST_RATIO=100
export AFL_HARDEN=1
./configure
make
```

### Préparation des dossiers et testcases

On crée deux dossiers dans le répertoire de travail. Par exemple :

* `afl_in` : on y place les éléments qu'on va donner au binaire à tester
  (*testcases*). Privilégier les testcases les plus petits possibles.
* `afl_out` : les informations fournies par AFL pendant le fuzzing seront
  stockées ici. Consultable en temps réel pendant le fuzzing.

AFL propose deux outils pour optimiser les testcases :

* `afl_cmin` : pour minimiser le nombre de testcases.
* `afl_tmin` : pour minimiser les testcases eux-mêmes.

> Note : Attention aux formats qui intègrent des champs de checksum ou de
  taille (par exemple *png*). Ca peut gâcher beaucoup de puissance de calcul
  car lorsqu'un checksum sera mauvais, le fichier passera potentiellement par
  un path très court (rejet rapide du parser) d'où de mauvais résultats. Pour
  le cas de *png*, cf. `libpng_no_checksum`.

### Fuzzing

On peut ensuite lancer `afl-fuzz`. La variable d'envrionnement
`AFL_SKIP_CPUFREQ` permet de désactiver le système de régulation de la
fréquence du CPU (qui, sous GNU/Linux, ne fait pas bon ménage avec AFL).
Par exemple :
```
export AFL_SKIP_CPUFREQ=1
afl-fuzz -i afl_in -o afl_out <afl-fuzz_options> -- <targeted_binary> <options_for_targeted_binary> @@
```

Le `@@` indique, dans le cas où le binaire prend des fichiers en entrée,
l'emplacement du fichier dans la ligne de commande. Les éventuels paramètres
de la ligne de commande sont évidemment à indiquer également.

On peut ajouter des options, notamment :

* `-m <megabytes>` pour spécifier une limite de taille pour les processus
  forkés. `-m none` permet de s'affranchir complètement des limitations
  mémoire (attention quand même avec cette option).
* `-t <milliseconds>` pour spécifier le timeout à prendre en compte pour
  qualifier qu'un testcase provoque un *hang* dans l'application.

Pour arrêter une session : `CTRL+C`.

#### Parallélisation du fuzzing

Pour lancer plusieurs opération de fuzzing en parallèle (chacune va occuper
un coeur du CPU) :
```
afl-fuzz -i afl_in -o afl_out -M fuzzer01 -- <targeted_binary> <options_for_targeted_binary> @@
afl-fuzz -i afl_in -o afl_out -S fuzzer02 -- <targeted_binary> <options_for_targeted_binary> @@
[...]
afl-fuzz -i afl_in -o afl_out -S fuzzer0n -- <targeted_binary> <options_for_targeted_binary> @@
```

On a un processus maître (`-M`) et des processus esclaves (`-S`).
Ils vont partager les testcases mutés et ranger les résultats dans des
sous-dossiers distincts (`afl_out/fuzzer01`, ...).

On peut utiliser l'outil `afl-gotcpu` pour connaître le nombre de coeurs
disponibles pour fuzzer.

Il existe également `afl-whatsup -s <sync_output_dir>` pour avoir un résumé
des processus qui tournent en parallèle.

Le plus simple est de créer un petit script bash qui utilise `screen` :
```bash
#!/usr/bin/bash
screen -dmS fuzzer1 /usr/bin/bash -c "afl-fuzz -i afl_in -o afl_out -M fuzzer1 -- ./binary @@"
screen -dmS fuzzer2 /usr/bin/bash -c "afl-fuzz -i afl_in -o afl_out -S fuzzer2 -- ./binary @@"
screen -dmS fuzzer3 /usr/bin/bash -c "afl-fuzz -i afl_in -o afl_out -S fuzzer3 -- ./binary @@"
screen -dmS fuzzer4 /usr/bin/bash -c "afl-fuzz -i afl_in -o afl_out -S fuzzer3 -- ./binary @@"
```

Après avoir lancer ce script, on accède alors aux différents processus
(ici `fuzzer1`) :
```
screen -rd fuzzer1
```

#### Reprise d'une session existante

Il est possible de reprendre une session existante. Il faut relancer la ligne
de commande en remplaçant `-i afl_in` par `-i-`.

## Mode *blackbox*

Pour compiler, voir :

* <https://github.com/qemu/qemu/commit/71ba74f67eaca21b0cc9d96f534ad3b9a7161400?diff=split>
* <https://github.com/NixOS/nixpkgs/issues/82232>

A compléter.


## Misc

### Address/Memory Sanitizer (A/MSAN)

Il s'agit de fonctionnalités des compilateurs *gcc* et *llvm* qui permettent
d'identifier des cas de corruption mémoire :

* *ASAN* : Permet d'identifier des accès invalides à la mémoire
  (UAF, Heap/Stack BOF).
* *MSAN* : Permet d'identifier l'utilisation de mémoire non-initialisée.

Pour l'activer à la compilation, on ajoute les options de compilation :

* `-fsanitize=address` pour ASAN
* `-fsanitize=memory` pour MSAN

L'activation de ces fonctionnalités améliore généralement l'efficacité d'AFL.

> Note : *ASAN* n'est utilisable que pour fuzzer des binaires 32 bits car il
  requiert beaucoup trop de mémoire pour les binaires 64 bits (ce qui rend
  difficile de distinguer un comportement normal d'un crash). Attention donc
  si on compile sur un système 64 bits (utilisation du flag `-m32` notamment).
  Par ailleurs, *ASAN* est incompatible avec `-static`.

Sinon, une solution alternative est d'ajouter la variable d'environnement
`AFL_USE_ASAN=1` à la compilation :
```
export AFL_USE_ASAN=1
[...]
./configure
make
```

Enfin, *ASAN* est gourmand en mémoire. Il peut être avantage (mais dangereux
aussi !) de débloquer la limite de mémoire utilisée par AFL avec l'option
`-m none` (option d'`afl-fuzz`).

Plus d'informations ici : <https://fuzzing-project.org/tutorial2.html>

### Préserver son SSD

On va créer un ramdisk pour éviter de solliciter le SSD car AFL fait beaucoup
de lecture/écriture qui pourrait l'user prématurément.
```
sudo mkdir /media/ramdisk
sudo chmod user:user /media/ramdisk
sudo mount -t tmpfs -o size=4096M tmpfs /media/ramdisk
```

On peut maintenant travailler dans le ramdisk.

**Ne pas oublier de sauvegarder ses résultats avant de rebooter !**

<http://www.cipherdyne.org/blog/2014/12/ram-disks-and-saving-your-ssd-from-afl-fuzzing.html>

### Coredumps

Avant de commencer, on peut demander au système de sauvegarder les coredumps
dans un fichier plutôt que de les passer à un handler spécifique (sur ma
Debian Buster de test, c'était déjà comme ça par défaut) :
```
echo core | sudo tee /proc/sys/kernel/core_pattern
```

### Fréquence du CPU

Comme on l'a vu, il est préférable de désactiver le système de régulation de
la fréquence du processeur. On peut utiliser pour ça la variable
d'environnement `AFL_SKIP_CPUFREQ`.

Une solution alternative est de forcer tous les coeurs en mode *performance* :
```
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
```

## Ressources

### Documentation

* <https://github.com/google/AFL>
* <https://lcamtuf.coredump.cx/afl/>
* <https://fuzzing-project.org/tutorial3.html>
* <https://blog.f-secure.com/super-awesome-fuzzing-part-one/>
* <https://research.aurainfosec.io/hunting-for-bugs-101/>

### Cas pratiques

* <https://www.evilsocket.net/2015/04/30/fuzzing-with-afl-fuzz-a-practical-example-afl-vs-binutils/>
* <https://countuponsecurity.com/2018/03/07/intro-to-american-fuzzy-lop-fuzzing-in-5-steps/>
* <https://countuponsecurity.com/2018/04/24/intro-to-american-fuzzy-lop-fuzzing-with-asan-and-beyond/>
* <https://github.com/mykter/afl-training>

### Talks

* <https://www.youtube.com/watch?v=DFQT1YxvpDo>
* <https://www.youtube.com/watch?v=4IrYczT5YFs>
* <https://www.youtube.com/watch?v=KFmeHz_vxfo>
* <https://www.youtube.com/watch?v=rUOQE-2NG3Y> (à 2h12)
* <https://www.youtube.com/watch?v=SngK4W4tVc0>

### Funny stuff

* <https://lcamtuf.blogspot.com/2014/11/pulling-jpegs-out-of-thin-air.html>

### To read

* <https://lcamtuf.coredump.cx/afl/technical_details.txt>
* <https://blog.hboeck.de/archives/868-How-Heartbleed-couldve-been-found.html>
* <https://blog.cloudflare.com/a-gentle-introduction-to-linux-kernel-fuzzing/>
* <https://www.fastly.com/blog/how-fuzz-server-american-fuzzy-lop>
* <https://www.youtube.com/user/SECConsult/videos>
* <https://www.youtube.com/channel/UCUB9vOGEUpw7IKJRoR4PK-A/videos>
