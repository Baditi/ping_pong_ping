import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:ping_pong_ping/pong_menu.dart';

void main() {
  runApp(const PongGame());
}

class PongGame extends StatelessWidget {
  const PongGame({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pong Game',
      home: StartScreen(),
    );
  }
}
class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: GestureDetector(onTap: (){
         Navigator.of(context).push(MaterialPageRoute(builder: (context){
           return const GameScreen();
        },));
      },
      child:const Center(
          child: Text('TAP TO START!!',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),)
      ),
      ),
    );
  }
}
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final ballSize=20.0;
  final racketWidth=120.0;
  final racketHeight=25.0;
  final racketBottomOffset=100.0;

  final initialSpeed=5.0;

  double ballX=0;
  double ballY=0;
  double ballSpeedX=0;
  double ballSpeedY=0;
  double racketX=20;
  int score=0;

  late Ticker ticker;
   double ballSpeedMultiplier=2.5;

  void initState(){
    super.initState();
    startGame();
  }
  void dispose(){
    super.dispose();
  }
  void startGame(){
    final random=Random();
    ballX=0;
    ballY=0;
    ballSpeedX= initialSpeed;
    ballSpeedY=initialSpeed;
    racketX=100;
    score=0;

    if(random.nextBool()) ballSpeedX=-ballSpeedX;
    if(random.nextBool()) ballSpeedY=-ballSpeedY;

    Future.delayed(const Duration (seconds: 1),(){
      ticker=Ticker((elapsed){
        setState(() {
          moveBall(ballSpeedMultiplier);
        });
      });
      ticker.start();
    });
  }
  void stopGame(){
    ticker.dispose();
  }
  void continueGame(){
    Future.delayed(const Duration (seconds: 1),(){
      ticker=Ticker((elapsed){
        setState(() {
          moveBall(ballSpeedMultiplier);
        });
      });
      ticker.start();
    });
  }
  void moveBall(double ballSpeedMultiplier){
    ballX += ballSpeedX*ballSpeedMultiplier;
    ballY +=ballSpeedY *ballSpeedMultiplier;
    final Size size=MediaQuery.of(context).size;

    if(ballY<0){
      ballSpeedY=-ballSpeedY;
      setState(() {
        score+=1;
        ballSpeedMultiplier=ballSpeedMultiplier*1.1;
        debugPrint('ballSpeedMultiplier: $ballSpeedMultiplier');
      });
    }
    if(ballX<0||ballX>size.width-ballSize){
      ballSpeedX=-ballSpeedX;
    }
    if(ballY>size.height-ballSize-racketHeight-racketBottomOffset&& ballX>=racketX&& ballX<=racketX-racketWidth){
      ballSpeedY=-ballSpeedY;
    }
    else if(ballY>size.height-ballSize){
      debugPrint('Game Over');
      stopGame();
      
      showDialog(
          context: context,
          barrierDismissible: false,
          builder:(BuildContext context){
            return PongMenu(
              title: 'Game Over!',
              subtitle: 'Your score is: $score',
              child: CupertinoButton(
                child: const Text('Play Again'),
                onPressed: (){
                  Navigator.of(context).pop();
                  startGame();
                },
              ),
            );
          },
      );
    }
  }

  moveRacket(double x){
    setState(() {
      racketX=x-racketWidth/2;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onHorizontalDragUpdate: (details){
              moveRacket(details.globalPosition.dx);
            },
            child: CustomPaint(
              painter: PongGamePainter(
                  racketX: racketX,
                  racketHeight: racketHeight,
                  racketWidth: racketWidth,
                  racketBottomOffset:racketBottomOffset,
                  ballSize: 20,
                  ballX: ballX,
                  ballY: ballY
              ),
              size:Size.infinite,
            ),
          ),
          Center(
            child: Text('Score: $score',
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            top: 40,
              right: 20,
              child:IconButton(
                icon: Icon(CupertinoIcons.pause,
                  size: 30,
                ),
                onPressed: (){
                  stopGame();
                  showDialog(
                      context: context,
                      builder: (context){
                        return PongMenu(
                          title: 'Pause',
                          subtitle: 'Your Score: $score', child: CupertinoButton(
                          onPressed: (){
                            Navigator.of(context).pop();
                            continueGame();
                          },
                          child: const Text('Continue'),
                        ) ,
                        );
                      },
                  );
                },
              ),
          ),
        ],
      ),
    );
  }

}



class PongGamePainter extends CustomPainter {
  final double ballSize;
  final double ballX;
  final double ballY;
  final double racketX;
  final double racketWidth;
  final double racketHeight;
  final double racketBottomOffset;

  PongGamePainter({required this .ballSize,required this.ballY,required this.ballX,required this.racketX, required this.racketWidth, required this.racketHeight,required this.racketBottomOffset}) : super(); // Add a semicolon here

  @override
  void paint(Canvas canvas, Size size) {
    final racketpaint = Paint()..color = Colors.black;
    final ballPaint =Paint()..color=Colors.black;
    final backgraoundPaint =Paint()..color=Colors.white; // Correct the Paint assignment
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        backgraoundPaint);


    canvas.drawOval(Rect.fromLTWH(ballX, ballY, ballSize, ballSize),
        ballPaint
    );
    canvas.drawRect(
      Rect.fromLTWH(
        racketX,
        size.height - racketHeight-racketBottomOffset,
        racketWidth,
        racketHeight,
      ),
      racketpaint,
    );
  }

  @override
  bool shouldRepaint(covariant PongGamePainter oldDelegate) {
    return ballX != oldDelegate.ballX ||
        ballY != oldDelegate.ballY ||
        racketX != oldDelegate.racketX;
  }
}




