int gameState = 0; // 0 チュートリアル、1: タイトル画面、2: ゲーム本編
int previousGameState = -1;

AudioPlayer tutorialMusic;
AudioPlayer game1Music;

  void setup() {
  size(800, 400);
　frameRate(60);
  textAlign(CENTER, CENTER);
  textSize(28);

  minim = new Minim(this);
  tutorialMusic = minim.loadFile("bgm1.mp3");
  tutorialMusic.setGain(-15);
  
  game1Music = minim.loadFile("bgm2.mp3");
  game1Music.setGain(-15);
  
  initGame();
 
}

void draw() {
  
  // BGMの切り替え処理
if (gameState != previousGameState) {
  if (gameState == 0 ) {
    if (!tutorialMusic.isPlaying()) {
      game1Music.pause();
      game1Music.rewind();
      tutorialMusic.loop();
    }
  } else if (gameState == 1) {
    if (!game1Music.isPlaying()) {
      tutorialMusic.pause();
      tutorialMusic.rewind();
      game1Music.loop();
    }
  }

  previousGameState = gameState; // 状態を更新
}

  
  background(0);
  
  if (gameState == 0) {
    drawIntroText();
  } else if (gameState == 1) {
    drawGame();
  }
}

void keyPressed() {
  if (gameState == 0) {
    handleIntroKey();
  } else if (gameState == 1) {
    handleGameKey();
  }
}

void keyReleased() {
  if (gameState == 1) {
    handleGameKeyReleased();
  }
}

