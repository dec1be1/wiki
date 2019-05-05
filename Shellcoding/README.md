Shellcoding
===========

Une page regroupant quelques éléments concernant les shellcodes.

Pour imprimer un shellcode binaire sous la forme `\xXX\xXX...` :
```
$ cat shellcode | hexdump -ve '/1 "\\x%02x"'
```

Pour créer un shellcode binaire à partir d'une chaîne de caractères de la forme `\xXX\xXX...` :
```
$ echo -ne "\xXX\xXX..." > shellcode
```

Pour créer un shellcode binaire à partir d'un code en assembleur `shellcode.s` (c'est-à-dire pour assembler) :
```
$ nasm shellcode.s
```

Pour créer à la fois le shellcode et un fichier de listing avec les opcodes :
```
$ nasm shellcode.s -l listing.txt
```

Pour créer un fichier objet de type *elf64* à partir d'un code en assembleur *x64* :
```
$ nasm -f elf64 -o shellcode.o shellcode.s
```

Pour linker le fichier objet et créer un exécutable :
```
$ ld -o shellcode shellcode.o
```
