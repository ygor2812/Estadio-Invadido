## Aula 08 -- 07/10 (feito dia 21/10/2026)
O que fiz: arena vista de cima com muros e blocos com colisão, jogador andando nas quatro direções, bolas quicantes (RigidBody2D) e zona que muda de lugar.

O que travou: o script não rodava (`:=` no preload e caminho `res://Scripts/` errado na cena) e depois a tela ficou cinza porque o script não estava anexado ao nó Main.

Como resolvi: troquei `:=` por `=` nos preload, corrigi o caminho e anexei o `main.gd` ao nó Main.

## Aula 09 -- 21/10
O que fiz: dei vida ao jogador (3 de vida) com uma Hurtbox que sente as bolas, 1 s de invencibilidade piscando ao tomar bolada, e o fim da partida, vence ao somar 60 s dentro da zona (tela "Voce venceu!") e perde quando a vida acaba (tela "Voce perdeu!"), com Enter para recomecar. Pus a vida no HUD, ao lado do contador da zona. Nomeei as camadas de fisica (1 mundo, 2 jogador, 3 bola).
O que travou: as bolas atravessavam o jogador sem tirar vida, porque a Hurtbox nao enxergava a camada das bolas e o corpo do jogador bloqueava a bola antes de ela chegar na Hurtbox.
Como resolvi: separei as camadas, jogador na 2, bola na 3 e deixei a Hurtbox com a Mask só na camada 3; o corpo do jogador só enxerga o mundo (camada 1), entao a bola passa por dentro e quem sente o toque é a Hurtbox.

## Aula 10 --28/10
O que fiz: Foi feito uma maquina de estado de comportamentos (surgindo, quicando, caçando e cansada), quando longe do jogador elas quicam normalmelmente, quando chegam perto do jogador elas vao perseguir ele por um tempo e depois vao entrar em um estado de cansaço (a bola desacelera e para de perseguir)
o que travou: A caçada acabava quase que instantaneamente, a bola entrava em caça em 200px de distancia e ao se mover um pouco ja saia do estado de caça.
como resolvi: Foi usado distancias diferentes para começar e para desistir, a bola começa a caça a 200px e só desiste quando o jogador escapa para 340px.
