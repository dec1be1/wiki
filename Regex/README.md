# Quelques exemples de regex

Cette page centralise quelques exemples d'expressions régulières (regex)
de type PCRE.

Numéro de téléphone français : `#^0[0-9]([-. ]?[0-9]{2}){4}$#`

Adresse email :```#^[a-zA-Z0-9._-]+@[a-zA-Z0-9._-]{2,}\.[a-zA-Z]{2,5}$#```

Code postal en France :```#^[0-9]{5,5}$#```

Base64 :```#(?:[A-Za-z0-9+/]{4}){2,}(?:[A-Za-z0-9+/]{2}[AEIMQUYcgkosw048]=|[A-Za-z0-9+/][AQgw]==)#```
