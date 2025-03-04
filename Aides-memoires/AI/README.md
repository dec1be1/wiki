# AI

## Hugging Face

On va récupérer les modèles sur Hugging Face. Il faut donc d'abord créer un 
compte, puis aller accepter les conditions générales pour les modèles qu'on 
va utiliser.

Par exemple, [les modèles Mistral AI](https://huggingface.co/mistralai).

## MLX (pour CPU Apple Silicon)

Les modèles suffisamment petits peuvent tourner directement sur un macbook 
pro avec une puce Apple Silicon. Ca fonctionne très bien à partir du moment 
où le modèle peut tenir en entier en RAM. 
Par exemple, le modèle 7B de Mistral AI tourne bien avec 32GB de RAM.

### Installation

On peut installer [MLX](https://github.com/ml-explore/) via un package Python standalone `mlx-lm` :
```
python -m venv mlx-lm
source mlx-lm/bin/activate
pip install mlx-lm
```

### Téléchargement modèle

Exemple pour le modèle Mistral AI [Mistral-7B-Instruct-v0.3](https://huggingface.co/mistralai/Mistral-7B-Instruct-v0.3) :
```
python -m mlx_lm.generate --model mistralai/Mistral-7B-Instruct-v0.3
```

On peut tester avec : 
```
python -m mlx_lm.generate --model mistralai/Mistral-7B-Instruct-v0.3 --prompt "hello"
```

> Les modèles sont stockés dans `~/.cache/huggingface`.

### Inférence

Il faut lancer le serveur (joignable sur localhost sur le port 8080) : 
```
python -m mlx_lm.server --model mistralai/Mistral-7B-Instruct-v0.3
```

Ensuite on peut utiliser un client interactif en lançant :
```
python -m mlx_lm.chat --model mistralai/Mistral-7B-Instruct-v0.3
```

On peut aussi utiliser un [chatbot](./chatbot.py) en python qui fait 
simplement des requêtes POST au serveur.

## Sources

- [Hugging Face](https://huggingface.co)
- [MLX](https://github.com/ml-explore/)
- [MLX avec Hugging Face](https://huggingface.co/docs/hub/en/mlx)
- [Tuto sur Medium](https://medium.com/@manuelescobar-dev/running-large-language-models-llama-3-on-apple-silicon-with-apples-mlx-framework-4f4ee6e15f31)
