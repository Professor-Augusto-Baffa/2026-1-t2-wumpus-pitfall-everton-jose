# 2026-1-t2-wumpus-pitfall-everton-jose

---

### Nomes: Everton Pereira Militao - 2320462; Jose Carlos de Sampaio Neto - 2320465

**Link**: 

## Organizacao do Projeto

```text
T2/
|
|- src/                  # Interface e controle em Python (Pygame + A*)
|  |- gmap.py            # Loop principal, renderizacao, update, integracao com Prolog
|  |- TreeNode.py        # Estrutura auxiliar para busca (quando aplicavel)
|
|- prolog/               # Regras logicas do agente
|  |- main.pl            # Base de conhecimento, percepcoes e tomada de decisao
|
|- mapas/                # Mapas do ambiente (fixos e variantes)
|  |- mapa.pl
|  |- mapa_facil.pl
|  |- mapa_medio.pl
|  |- mapa_dificil.pl
|  |- ...
|
|- assets/               # Sprites e imagens usadas na interface
|
|- docs/                 # Documentacao auxiliar
|  |- INF1771_trabalho_2_pitfall.pdf
|
|- requirements.txt
|- README.md
```

## Como rodar o projeto

### Windows

Abra o terminal na pasta raiz do projeto.

1. Criar ambiente virtual:

```bash
python -m venv venv
```

2. Ativar ambiente:

```bash
.\venv\Scripts\activate
```

3. Instalar dependencias:

```bash
pip install -r requirements.txt
```

4. Executar:

```bash
python src/gmap.py
```

### Linux/macOS (ou WSL)

1. Criar ambiente virtual:

```bash
python3 -m venv venv
```

2. Ativar ambiente:

```bash
source venv/bin/activate
```

3. Instalar dependencias:

```bash
pip install -r requirements.txt
```

4. Executar:

```bash
python src/gmap.py
```


## Configuracao de mapa

1. Para alterar o mapa fixo consultado pelo Prolog:
  edite `prolog/main.pl` na linha 19 (predicado `consult`).

2. Para gerar mapa aleatorio pelo Python:
  use `src/gmap.py` na linha 653 (chamada de geracao de mapa aleatorio).