import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pong/scorescreen.dart';
import 'ball.dart';
import 'brick.dart';
import 'coverscreen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

enum direction { UP, DOWN, LEFT, RIGHT }

class _HomePageState extends State<HomePage> {
  double playerx = -0.2;
  double brickWidth = 0.4;
  int playerScore = 0;

  double enemyx = -0.2;
  int enemyScore = 0;

  double ballx = 0;
  double bally = 0;
  var ballYDirection = direction.DOWN;
  var ballXDirection = direction.LEFT;

  bool gameHasStarted = false;

  void startGame() {
    gameHasStarted = true;
    Timer.periodic(Duration(milliseconds: 1), (timer) {
      updateDirection();

      moveBall();
      moveEnemy();

      if (isPlayerDead()) {
        enemyScore++;
        timer.cancel();
        _showDialog(false);
      }
      if (isEnemyDead()) {
        playerScore++;
        timer.cancel();
        _showDialog(true);
      }
    });
  }

  isEnemyDead() {
    if (bally <= -1) {
      return true;
    }
    return false;
  }

  void moveEnemy() {
    setState(() {
      enemyx = ballx;
    });
  }

  void _showDialog(bool enemyDied) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.deepPurple,
            title: Center(
              child: Text(
                enemyDied ? "PINK WIN" : "PURPLE WIN",
                style: TextStyle(color: Colors.white),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: resetGame,
                child: ClipRRect(
                  borderRadius: BorderRadiusDirectional.circular(5),
                  child: Container(
                    padding: EdgeInsets.all(7),
                    color:
                        enemyDied ? Colors.pink[100] : Colors.deepPurple[100],
                    child: Text(
                      'PLAY AGAIN',
                      style: TextStyle(
                          color: enemyDied
                              ? Colors.pink[800]
                              : Colors.deepPurple[800]),
                    ),
                  ),
                ),
              )
            ],
          );
        });
  }

  void resetGame() {
    Navigator.pop(context);
    setState(() {
      gameHasStarted = false;
      ballx = 0;
      bally = 0;
      playerx = -0.2;
      enemyx = -0.2;
    });
  }

  bool isPlayerDead() {
    if (bally >= 1) {
      return true;
    }
    return false;
  }

  void updateDirection() {
    setState(() {
      if (bally >= 0.9 && playerx + brickWidth >= ballx && playerx <= ballx) {
        ballYDirection = direction.UP;
      } else if (bally <= -0.9) {
        ballYDirection = direction.DOWN;
      }
      if (ballx >= 1) {
        ballXDirection = direction.LEFT;
      } else if (ballx <= -1) {
        ballXDirection = direction.RIGHT;
      }
    });
  }

  void moveBall() {
    if (ballYDirection == direction.DOWN) {
      bally += 0.005;
    } else if (ballYDirection == direction.UP) {
      bally -= 0.005;
    }

    if (ballXDirection == direction.LEFT) {
      ballx -= 0.005;
    } else if (ballXDirection == direction.RIGHT) {
      ballx += 0.005;
    }
  }

  void moveLeft() {
    setState(() {
      if (!(playerx - 0.05 <= -1)) {
        playerx -= 0.05;
      }
    });
  }

  void moveRight() {
    setState(() {
      if (!(playerx + brickWidth >= 1)) {
        playerx += 0.05;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: startGame,
      onHorizontalDragUpdate: (details) {
        if (details.delta.dx < 0) {
          moveLeft();
        } else if (details.delta.dx > 0) {
          moveRight();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[900],
        body: Center(
          child: Stack(
            children: [
              CoverScreen(
                gameHasStarted: gameHasStarted,
              ),

              ScoreScreen(
                gameHasStarted: gameHasStarted,
                enemyScore: enemyScore,
                playerScore: playerScore,
              ),
              MyBrick(
                x: enemyx,
                y: -0.9,
                brickWidth: brickWidth,
                thisIsEnemy: true,
              ),

              // bottom
              MyBrick(
                x: playerx,
                y: 0.9,
                brickWidth: brickWidth,
                thisIsEnemy: false,
              ),
              MyBall(
                x: ballx,
                y: bally,
                gameHasStarted: gameHasStarted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
