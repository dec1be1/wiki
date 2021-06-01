Shellcoding
===========

Une page regroupant quelques éléments concernant les shellcodes.

## Dans un shell

Pour imprimer un shellcode binaire sous la forme `\xXX\xXX...` :
```
$ cat shellcode | hexdump -ve '/1 "\\x%02x"'
```

Pour créer un shellcode binaire à partir d'une chaîne de caractères de la
forme `\xXX\xXX...` :
```
$ echo -ne "\xXX\xXX..." > shellcode
```

## Assemblage

Pour créer un shellcode binaire à partir d'un code en assembleur
`shellcode.s` (c'est-à-dire pour assembler) :
```
$ nasm shellcode.s
```

Pour créer à la fois le shellcode et un fichier de listing avec les opcodes :
```
$ nasm shellcode.s -l listing.txt
```

## Compilation

Pour créer un fichier objet de type *elf64* à partir d'un code en
assembleur *x64* :
```
$ nasm -f elf64 -o shellcode.o shellcode.s
```

## Edition de liens

Pour linker le fichier objet et créer un exécutable :
```
$ ld -o shellcode shellcode.o
```

## Python 3

Pour imprimer des octets dans stdout en python3 :
```
$ python3 -c 'import sys;sys.stdout.buffer.write(payload)'
```
avec `payload` un objet de type `bytes` (par exemple : `b"\xde\xad\xbe\xef"`).
