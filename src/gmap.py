################################################
# from TreeNode import TreeNode
import pygame
import sys, time, random
from pyswip import Prolog, Functor, Variable, Query
from queue import PriorityQueue
import pathlib

import pathlib
current_path = str(pathlib.Path().resolve())

elapsed_time = 0
auto_play_tempo = 0.5
auto_play = True # desligar para controlar manualmente
show_map = False

scale = 60
size_x = 12
size_y = 12
width = size_x * scale  #Largura Janela
height = size_y * scale #Altura Janela

player_pos = (1,1,'norte')
energia = 0
pontuacao = 0
fila_acoes = []
DIRS = ["norte", "leste", "sul", "oeste"]  # Índices 0 a 3
DELTA = [(0, 1), (1, 0), (0, -1), (-1, 0)] # Vetores de movimento
LEFT = lambda d: (d + 3) % 4
RIGHT = lambda d: (d + 1) % 4


mapa=[['','','','','','','','','','','',''],
      ['','','','','','','','','','','',''],
      ['','','','','','','','','','','',''],
      ['','','','','','','','','','','',''],
      ['','','','','','','','','','','',''],
      ['','','','','','','','','','','',''],
      ['','','','','','','','','','','',''],
      ['','','','','','','','','','','',''],
      ['','','','','','','','','','','',''],
      ['','','','','','','','','','','',''],
      ['','','','','','','','','','','',''],
      ['','','','','','','','','','','','']]

visitados = []
certezas = []

pl_file = (current_path + '\\prolog/main.pl').replace('\\','/')
prolog = Prolog()
prolog.consult(pl_file)

last_action = ""

def decisao():

    acao = ""    
    
    acoes = list(prolog.query("executa_acao(X)"))
    if len(acoes) > 0:
        acao = acoes[0]['X']

    return acao


# def get_fronteira_segura():
#     alvos = []
#     # Busca todas as casas que o Prolog já mapeou e tem certeza
#     for x, y in certezas:
#         if (x, y) not in visitados:
#             conteudo = mapa[12-y][x-1] # Ajuste de coordenada visual do Python
#             # Só aceita a casa como destino se não tiver perigo nela
#             if 'P' not in conteudo and 'D' not in conteudo and 'd' not in conteudo and 'T' not in conteudo:
#                 alvos.append((x, y))
#     return alvos

# def heuristica(a, b):
#     # Calcula a distância em linha reta (Manhattan)
#     return abs(a[0] - b[0]) + abs(a[1] - b[1])

# def buscar_caminho_astar(inicio, destino):
#     open_list = [TreeNode(inicio, heuristica(inicio, destino), 0)]
#     closed_list = set()
    
#     while open_list:
#         open_list.sort(key=lambda n: n.get_priority())
#         atual = open_list.pop(0)
        
#         if atual.get_coord() == destino:
#             caminho = []
#             while atual:
#                 caminho.append(atual.get_coord())
#                 atual = atual.get_parent()
#             return caminho[::-1] # Inverte para ficar da origem ao destino
        
#         closed_list.add(atual.get_coord())
#         cx, cy = atual.get_coord()
        
#         vizinhos = [(cx, cy+1), (cx, cy-1), (cx+1, cy), (cx-1, cy)]
#         for vx, vy in vizinhos:
#             if 1 <= vx <= 12 and 1 <= vy <= 12:
#                 if (vx, vy) in closed_list: continue
                
#                 # REGRA DE OURO: Para não morrer, o GPS só traça rotas por casas que o agente já VISITOU!
#                 if (vx, vy) not in visitados and (vx, vy) != destino:
#                     continue
                    
#                 gx = atual.get_value_gx() + 1
#                 hx = heuristica((vx, vy), destino)
#                 novo_no = TreeNode((vx, vy), gx + hx, gx)
#                 novo_no.set_parent(atual)
#                 open_list.append(novo_no)
#     return []

# def converter_rota_em_acoes(rota, dir_atual):
#     acoes = []
#     direcao = dir_atual
    
#     for i in range(len(rota) - 1):
#         atual = rota[i]
#         prox = rota[i+1]
#         dx = prox[0] - atual[0]
#         dy = prox[1] - atual[1]
        
#         if dx == 1: dir_desejada = 'leste'
#         elif dx == -1: dir_desejada = 'oeste'
#         elif dy == 1: dir_desejada = 'norte'
#         elif dy == -1: dir_desejada = 'sul'
        
#         if direcao != dir_desejada:
#             if direcao == 'norte':
#                 if dir_desejada == 'leste': acoes.append('virar_direita')
#                 elif dir_desejada == 'oeste': acoes.append('virar_esquerda')
#                 elif dir_desejada == 'sul': acoes.extend(['virar_direita', 'virar_direita'])
#             elif direcao == 'sul':
#                 if dir_desejada == 'leste': acoes.append('virar_esquerda')
#                 elif dir_desejada == 'oeste': acoes.append('virar_direita')
#                 elif dir_desejada == 'norte': acoes.extend(['virar_direita', 'virar_direita'])
#             elif direcao == 'leste':
#                 if dir_desejada == 'sul': acoes.append('virar_direita')
#                 elif dir_desejada == 'norte': acoes.append('virar_esquerda')
#                 elif dir_desejada == 'oeste': acoes.extend(['virar_direita', 'virar_direita'])
#             elif direcao == 'oeste':
#                 if dir_desejada == 'sul': acoes.append('virar_esquerda')
#                 elif dir_desejada == 'norte': acoes.append('virar_direita')
#                 elif dir_desejada == 'leste': acoes.extend(['virar_direita', 'virar_direita'])
#             direcao = dir_desejada
            
#         acoes.append('andar')
#     return acoes

def get_map_perceived_detailed(input_map):
    # Consulta o Prolog para saber quais casas ele tem 100% de CERTEZA que são seguras
    x, y = Variable(), Variable()
    seguro_fun = Functor("seguro", 2)
    query_s = Query(seguro_fun(x, y))
    while query_s.nextSolution():
        row = y.value - 1
        col = x.value - 1
        input_map[row][col] = "."
    query_s.closeQuery()
    return input_map

def grid_livre():
    # Cria uma cópia virtual do mapa só com as casas seguras deduzidas pelo Prolog
    g = [row[:] for row in mapa]
    g = get_map_perceived_detailed(g)
    for y in range(len(g)):
        for x in range(len(g[0])):
            if g[y][x] in ("O", "U"):
                g[y][x] = "."
    return g

def get_neighbours(grid, x, y, d):
    # Retorna os movimentos possíveis e SEUS CUSTOS reais (Girar = 1, Andar = 1)
    yield (x, y, LEFT(d)), 1, "virar_esquerda"
    yield (x, y, RIGHT(d)), 1, "virar_direita"
    dx, dy = DELTA[d]
    nx, ny = x + dx, y + dy
    if 0 <= nx < 12 and 0 <= ny < 12 and grid[ny][nx] == ".":
        yield (nx, ny, d), 1, "andar"

def A_star(grid, start, goal):
    # O novo algoritmo A* que avalia (X, Y, Direção)
    pq = PriorityQueue()
    g = {start: 0}
    prev, act = {start: None}, {start: None}
    h0 = abs(start[0] - goal[0]) + abs(start[1] - goal[1])
    pq.put((h0, start))

    while not pq.empty():
        _, cur = pq.get()
        cx, cy, cd = cur
        if (cx, cy) == goal:
            return g, prev, act
        for nxt, cost, op in get_neighbours(grid, cx, cy, cd):
            new_g = g[cur] + cost
            if new_g < g.get(nxt, 1e9):
                g[nxt] = new_g
                prev[nxt], act[nxt] = cur, op
                h = abs(nxt[0] - goal[0]) + abs(nxt[1] - goal[1])  # Distância Manhattan
                pq.put((new_g + h, nxt))
    return None, None, None

def extrai_caminho(g, prev, act, goal):
    # Transforma o caminho numérico em palavras lógicas (andar, virar)
    end = min(
        ((goal[0], goal[1], d) for d in range(4) if (goal[0], goal[1], d) in g),
        key=lambda st: g[st],
    )
    seq = []
    node = end
    while act[node]:
        seq.append(act[node])
        node = prev[node]
    return list(reversed(seq))

def go_to(target_xy):
    # A função principal que tenta traçar a rota ou coloca na Lista Negra
    global fila_acoes
    grid = grid_livre()

    sx, sy, sdir = player_pos
    start = (sx - 1, sy - 1, DIRS.index(sdir))
    goal = (target_xy[0] - 1, target_xy[1] - 1)

    g, prev, act = A_star(grid, start, goal)

    if g is not None:
        # A* ACHOU UM CAMINHO! Avisa o Prolog para esquecer a Lista Negra e adiciona à fila de ações
        list(prolog.query("clear_blocked"))
        for step in extrai_caminho(g, prev, act, goal):
            fila_acoes.append(step)
        return

    # A* FALHOU! Alvo inalcançável (preso por paredes ou escuridão) -> Bloqueia o alvo.
    print("go_to: sem caminho, marcando alvo como bloqueado!")
    list(prolog.query(f"add_blocked({target_xy[0]},{target_xy[1]})"))

def exec_prolog(a):
    global last_action
    if a != "":
        list(prolog.query(a))
    last_action = a


def gerar_mapa_aleatorio(caminho_arquivo):
    # Lista com todas as posições possíveis de 1 a 12
    posicoes_livres = [(x, y) for x in range(1, 13) for y in range(1, 13)]

    posicoes_livres.remove((1, 1))
    
    elementos = {} 
    elementos['P'] = random.sample(posicoes_livres, 8) # 8 Poços
    [posicoes_livres.remove(p) for p in elementos['P']]
    elementos['O'] = random.sample(posicoes_livres, 3) # 3 Ouros
    [posicoes_livres.remove(p) for p in elementos['O']]
    elementos['U'] = random.sample(posicoes_livres, 3) # 3 Powerups
    [posicoes_livres.remove(p) for p in elementos['U']]
    elementos['T'] = random.sample(posicoes_livres, 4) # 4 Morcegos
    [posicoes_livres.remove(p) for p in elementos['T']]
    elementos['d'] = random.sample(posicoes_livres, 2) # 2 Inimigos Pequenos
    [posicoes_livres.remove(p) for p in elementos['d']]
    elementos['D'] = random.sample(posicoes_livres, 2) # 2 Inimigos Grandes
    [posicoes_livres.remove(p) for p in elementos['D']]


    mapa_gerado = {}
    for simbolo, lista_posicoes in elementos.items():
        for pos in lista_posicoes:
            mapa_gerado[pos] = simbolo

    try:
        with open(caminho_arquivo, 'w') as file:
            file.write(":-dynamic tile/3.\n")
            file.write("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n")
            file.write("%% Definição do mapa aleatório\n")
            file.write("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n\n")
            file.write("map_size(12,12).\n\n")

            for y in range(12, 0, -1):
                for x in range(1, 13):
                    simbolo = mapa_gerado.get((x, y), '')
                    file.write(f"tile({x},{y},'{simbolo}').\n")
                file.write("\n")
    except Exception as e:
        print(f"Erro ao gerar o mapa: {e}")


def update_prolog():
    global player_pos, mapa, energia, pontuacao,visitados, show_map

    list(prolog.query("atualiza_obs, verifica_player"))

    x = Variable()
    y = Variable()
    visitado = Functor("visitado", 2)
    visitado_query = Query(visitado(x,y))
    visitados.clear()
    while visitado_query.nextSolution():
        visitados.append((x.value,y.value))
    visitado_query.closeQuery()

    x = Variable()
    y = Variable()
    certeza = Functor("certeza", 2)
    certeza_query = Query(certeza(x,y))
    certezas.clear()
    while certeza_query.nextSolution():
        certezas.append((x.value,y.value))
    certeza_query.closeQuery()
        
    if show_map:    
        x = Variable()
        y = Variable()
        z = Variable()    
        tile = Functor("tile", 3)
        tile_query = Query(tile(x,y,z))
        while tile_query.nextSolution():
            mapa[y.get_value()-1][x.get_value()-1] = str(z.value)
        tile_query.closeQuery()

    else:

        y = 0
        for j in mapa:
            x = 0
            for i in j:
                mapa[y][x] = ''
                x  += 1
            y +=  1

        x = Variable()
        y = Variable()
        z = Variable()    
        memory = Functor("memory", 3)
        memory_query = Query(memory(x,y,z))
        while memory_query.nextSolution():
            for s in z.value:
                
                if str(s) == 'brisa':
                    mapa[y.get_value()-1][x.get_value()-1] += 'P'
                elif str(s) == 'palmas':
                    mapa[y.get_value()-1][x.get_value()-1] += 'T'
                elif str(s) == 'passos':
                    mapa[y.get_value()-1][x.get_value()-1] += 'D'
                elif str(s) == 'reflexo':
                    mapa[y.get_value()-1][x.get_value()-1] += 'U'
                elif str(s) == 'brilho':
                    mapa[y.get_value()-1][x.get_value()-1] += 'O'
            
        memory_query.closeQuery()

    x = Variable()
    y = Variable()
    z = Variable()

    posicao = Functor("posicao", 3)
    position_query = Query(posicao(x,y,z))
    position_query.nextSolution()
    player_pos = (x.value,y.value,str(z.value))
    position_query.closeQuery()

    x = Variable()
    energia = Functor("energia", 1)
    energia_query = Query(energia(x))
    energia_query.nextSolution()
    energia = x.value
    energia_query.closeQuery()

    x = Variable()
    pontuacao = Functor("pontuacao", 1)
    pontuacao_query = Query(pontuacao(x))
    pontuacao_query.nextSolution()
    pontuacao = x.value
    pontuacao_query.closeQuery()

    #print(mapa)
    #print(player_pos)


def load():
    global sys_font, clock, img_wall, img_grass, img_start, img_finish, img_path
    global img_gold,img_health, img_pit, img_bat, img_enemy1, img_enemy2,img_floor
    global bw_img_gold,bw_img_health, bw_img_pit, bw_img_bat, bw_img_enemy1, bw_img_enemy2,bw_img_floor
    global img_player_up, img_player_down, img_player_left, img_player_right, img_tomb

    sys_font = pygame.font.Font(pygame.font.get_default_font(), 20)
    clock = pygame.time.Clock() 

    img_wall = pygame.image.load('assets/wall.jpg')
    #img_wall2_size = (img_wall.get_width()/map_width, img_wall.get_height()/map_height)
    img_wall_size = (width/size_x, height/size_y)
    
    img_wall = pygame.transform.scale(img_wall, img_wall_size)

    
    img_player_up = pygame.image.load('assets/player_up.png')
    img_player_up_size = (width/size_x, height/size_y)
    img_player_up = pygame.transform.scale(img_player_up, img_player_up_size)

    img_player_down = pygame.image.load('assets/player_down.png')
    img_player_down_size = (width/size_x, height/size_y)
    img_player_down = pygame.transform.scale(img_player_down, img_player_down_size)

    img_player_left = pygame.image.load('assets/player_left.png')
    img_player_left_size = (width/size_x, height/size_y)
    img_player_left = pygame.transform.scale(img_player_left, img_player_left_size)

    img_player_right = pygame.image.load('assets/player_right.png')
    img_player_right_size = (width/size_x, height/size_y)
    img_player_right = pygame.transform.scale(img_player_right, img_player_right_size)


    img_tomb = pygame.image.load('assets/tombstone.png')
    img_tomb_size = (width/size_x, height/size_y)
    img_tomb = pygame.transform.scale(img_tomb, img_tomb_size)



    img_grass = pygame.image.load('assets/grass.jpg')
    img_grass_size = (width/size_x, height/size_y)
    img_grass = pygame.transform.scale(img_grass, img_grass_size)

    img_floor = pygame.image.load('assets/floor.png')
    img_floor_size = (width/size_x, height/size_y)
    img_floor = pygame.transform.scale(img_floor, img_floor_size)

    img_gold = pygame.image.load('assets/gold.png')
    img_gold_size = (width/size_x, height/size_y)
    img_gold = pygame.transform.scale(img_gold, img_gold_size)

    img_pit = pygame.image.load('assets/pit.png')
    img_pit_size = (width/size_x, height/size_y)
    img_pit = pygame.transform.scale(img_pit, img_pit_size)

    img_enemy1 = pygame.image.load('assets/enemy1.png')
    img_enemy1_size = (width/size_x, height/size_y)
    img_enemy1 = pygame.transform.scale(img_enemy1, img_enemy1_size)

    img_enemy2 = pygame.image.load('assets/enemy2.png')
    img_enemy2_size = (width/size_x, height/size_y)
    img_enemy2 = pygame.transform.scale(img_enemy2, img_enemy2_size)

    img_bat = pygame.image.load('assets/bat.png')
    img_bat_size = (width/size_x, height/size_y)
    img_bat = pygame.transform.scale(img_bat, img_bat_size)

    img_health = pygame.image.load('assets/health.png')
    img_health_size = (width/size_x, height/size_y)
    img_health = pygame.transform.scale(img_health, img_health_size)    
    
    bw_img_floor = pygame.image.load('assets/bw_floor.png')
    bw_img_floor_size = (width/size_x, height/size_y)
    bw_img_floor = pygame.transform.scale(bw_img_floor, bw_img_floor_size)

    bw_img_gold = pygame.image.load('assets/bw_gold.png')
    bw_img_gold_size = (width/size_x, height/size_y)
    bw_img_gold = pygame.transform.scale(bw_img_gold, bw_img_gold_size)

    bw_img_pit = pygame.image.load('assets/bw_pit.png')
    bw_img_pit_size = (width/size_x, height/size_y)
    bw_img_pit = pygame.transform.scale(bw_img_pit, bw_img_pit_size)

    bw_img_enemy1 = pygame.image.load('assets/bw_enemy1.png')
    bw_img_enemy1_size = (width/size_x, height/size_y)
    bw_img_enemy1 = pygame.transform.scale(bw_img_enemy1, bw_img_enemy1_size)

    bw_img_enemy2 = pygame.image.load('assets/bw_enemy2.png')
    bw_img_enemy2_size = (width/size_x, height/size_y)
    bw_img_enemy2 = pygame.transform.scale(bw_img_enemy2, bw_img_enemy2_size)

    bw_img_bat = pygame.image.load('assets/bw_bat.png')
    bw_img_bat_size = (width/size_x, height/size_y)
    bw_img_bat = pygame.transform.scale(bw_img_bat, bw_img_bat_size)

    bw_img_health = pygame.image.load('assets/bw_health.png')
    bw_img_health_size = (width/size_x, height/size_y)
    bw_img_health = pygame.transform.scale(bw_img_health, bw_img_health_size)  

# def update(dt, screen):
    
#     global elapsed_time
    
#     elapsed_time += dt
    
#     if (elapsed_time / 1000) > auto_play_tempo:
        
#         if auto_play and player_pos[2] != 'morto':
#             exec_prolog(decisao())
#             update_prolog()
       
#         elapsed_time = 0


# def update(dt, screen):
#     global elapsed_time, fila_acoes
    
#     elapsed_time += dt
    
#     if (elapsed_time / 1000) > auto_play_tempo:
#         if auto_play and player_pos[2] != 'morto':
            
#             # 1. Se tem GPS traçado, segue a rota até o fim
#             if fila_acoes:
#                 acao = fila_acoes.pop(0)
#                 exec_prolog(acao)
#                 update_prolog()
#             else:
#                 # 2. Se não tem GPS, pergunta ao Prolog o que fazer
#                 acao = decisao()
#                 acao_str = str(acao)
                    
#                 # 3. Se o Prolog pedir para o Python usar o GPS (A*):
#                 if "go_to" in acao_str:
#                     # Extrai as coordenadas X e Y da string, ex: "go_to(5, 5)"
#                     coords = acao_str.replace("go_to(", "").replace(")", "").split(",")
#                     tx = int(coords[0].strip())
#                     ty = int(coords[1].strip())
                    
#                     inicio = (player_pos[0], player_pos[1])
#                     destino = (tx, ty)
                    
#                     if inicio != destino:
#                         rota = buscar_caminho_astar(inicio, destino)
#                         if rota:
#                             exec_prolog("clear_blocked")
#                             fila_acoes = converter_rota_em_acoes(rota, player_pos[2])
#                         else:
#                             # A* FALHOU: Manda para a lista negra
#                             exec_prolog(f"add_blocked({tx},{ty})")
#                     else:
#                         # Se já chegou no destino (ex: voltou pra 1,1 no fim do jogo)
#                         exec_prolog("virar_direita")
#                         update_prolog()
                
#                 # 4. SE FOR UMA AÇÃO NORMAL (andar, virar, pegar), EXECUTA DIRETO!
#                 elif acao_str != "":
#                     exec_prolog(acao)
#                     update_prolog()
       
#         elapsed_time = 0
    
def update(dt, screen):
    global elapsed_time, fila_acoes
    
    elapsed_time += dt
    
    if (elapsed_time / 1000) > auto_play_tempo:
        if auto_play and player_pos[2] != 'morto':
            
            # 1. Se tem GPS traçado (na fila de ações), segue a rota um passo por vez
            if fila_acoes:
                acao = fila_acoes.pop(0)
                exec_prolog(acao)
                update_prolog()
            else:
                # 2. Se não tem rota, o cérebro Prolog decide a ação
                acao = decisao()
                acao_str = str(acao)
                    
                # 3. Prolog pediu para o GPS traçar caminho para (X,Y)
                if "go_to" in acao_str:
                    coords = acao_str.replace("go_to(", "").replace(")", "").split(",")
                    tx = int(coords[0].strip())
                    ty = int(coords[1].strip())
                    
                    if (player_pos[0], player_pos[1]) != (tx, ty):
                        go_to([tx, ty]) # Usa o novo A* tridimensional!
                    else:
                        exec_prolog("virar_direita")
                        update_prolog()
                
                # 4. Ação normal (andar, virar, pegar)
                elif acao_str != "":
                    exec_prolog(acao)
                    update_prolog()
       
        elapsed_time = 0


def key_pressed(event):
    
    global show_map
    #leitura do teclado
    if event.type == pygame.KEYDOWN:
        
        if not auto_play and player_pos[2] != 'morto':
            if event.key == pygame.K_LEFT: #tecla esquerda
                exec_prolog("virar_esquerda")
                update_prolog()

            elif event.key == pygame.K_RIGHT: #tecla direita
                exec_prolog("virar_direita")
                update_prolog()

            elif event.key == pygame.K_UP: #tecla  cima
                exec_prolog("andar")
                update_prolog()

            if event.key == pygame.K_SPACE:
                exec_prolog("pegar")
                update_prolog()
    
        if event.key == pygame.K_m:
            show_map = not show_map
            update_prolog()


def draw_screen(screen):
    
    screen.fill((0,0,0))
 
    y = 0
    for j in mapa:
        x = 0
        for i in j:

            if (x+1,12-y) in visitados:
                screen.blit(img_floor, (x * img_floor.get_width(), y * img_floor.get_height()))
            else:
                screen.blit(bw_img_floor, (x * bw_img_floor.get_width(), y * bw_img_floor.get_height()))

            if mapa[11-y][x].find('P') > -1:
                if (x+1,12-y) in certezas:
                    screen.blit(img_pit, (x * img_pit.get_width(), y * img_pit.get_height()))                            
                else:
                    screen.blit(bw_img_pit, (x * bw_img_pit.get_width(), y * bw_img_pit.get_height()))                            

            if mapa[11-y][x].find('T') > -1:
                if (x+1,12-y) in certezas:
                    screen.blit(img_bat, (x * img_bat.get_width(), y * img_bat.get_height()))
                else:
                    screen.blit(bw_img_bat, (x * bw_img_bat.get_width(), y * bw_img_bat.get_height()))

            if mapa[11-y][x].find('D') > -1:
                if (x+1,12-y) in certezas:
                    screen.blit(img_enemy1, (x * img_enemy1.get_width(), y * img_enemy1.get_height()))                                               
                else:
                    screen.blit(bw_img_enemy1, (x * bw_img_enemy1.get_width(), y * bw_img_enemy1.get_height()))                                               
                            
            if mapa[11-y][x].find('d') > -1:
                if (x+1,12-y) in certezas:
                    screen.blit(img_enemy2, (x * img_enemy2.get_width(), y * img_enemy2.get_height()))                                               
                else:
                    screen.blit(bw_img_enemy2, (x * bw_img_enemy2.get_width(), y * bw_img_enemy2.get_height()))                                               

            if mapa[11-y][x].find('U') > -1:
                if (x+1,12-y) in certezas:
                    screen.blit(img_health, (x * img_health.get_width(), y * img_health.get_height()))                               
                else:
                    screen.blit(bw_img_health, (x * bw_img_health.get_width(), y * bw_img_health.get_height()))                               

            if mapa[11-y][x].find('O') > -1:
                if (x+1,12-y) in certezas:
                    screen.blit(img_gold, (x * img_gold.get_width(), y * img_gold.get_height()))                
                else:
                    screen.blit(bw_img_gold, (x * bw_img_gold.get_width(), y * bw_img_gold.get_height()))                
            
            if x == player_pos[0] - 1  and  y == 12 - player_pos[1]:
                if player_pos[2] == 'norte':
                    screen.blit(img_player_up, (x * img_player_up.get_width(), y * img_player_up.get_height()))                                               
                elif player_pos[2] == 'sul':
                    screen.blit(img_player_down, (x * img_player_down.get_width(), y * img_player_down.get_height()))                                               
                elif player_pos[2] == 'leste':
                    screen.blit(img_player_right, (x * img_player_right.get_width(), y * img_player_right.get_height()))                                               
                elif player_pos[2] == 'oeste':
                    screen.blit(img_player_left, (x * img_player_left.get_width(), y * img_player_left.get_height()))                                                                                                           
                else:
                    screen.blit(img_tomb, (x * img_tomb.get_width(), y * img_tomb.get_height()))                                                                                                           
            x  += 1
        y +=  1

    t = sys_font.render("Pontuação: " + str(pontuacao), False, (255,255,255))
    screen.blit(t, t.get_rect(top = height + 5, left=40))

    t = sys_font.render(last_action, False, (255,255,255))
    screen.blit(t, t.get_rect(top = height + 5, left=width/2-40))
    
    t = sys_font.render("Energia: " + str(energia), False, (255,255,255))
    screen.blit(t, t.get_rect(top = height + 5, left=width-140))

def main_loop(screen):  
    global clock
    running = True
    
    while running:
        for e in pygame.event.get(): 
            if e.type == pygame.QUIT:
                running = False
                break
            
            key_pressed(e)
            
        # Calcula tempo transcorrido desde
        # a última atualização 
        dt = clock.tick()
        
        
        # Atualiza posição dos objetos da tela
        update(dt, screen)
        
        # Desenha objetos na tela 
        draw_screen(screen)

        # Pygame atualiza o seu estado
        pygame.display.update() 


#############################################################
## BLOCO PRINCIPAL:
############################################################
update_prolog()

pygame.init()
pygame.display.set_caption('INF1771 Trabalho 2 - Agente Lógico')
screen = pygame.display.set_mode((width, height+30))
load()

main_loop(screen)
pygame.quit()

# Gera o mapa aleatoriamente e salva no arquivo correto ANTES de iniciar
# gerar_mapa_aleatorio('mapas/mapa.pl')

# update_prolog()

# pygame.init()
# pygame.display.set_caption('INF1771 Trabalho 2 - Agente Lógico')
# screen = pygame.display.set_mode((width, height+30))
# load()

# main_loop(screen)
# pygame.quit()

