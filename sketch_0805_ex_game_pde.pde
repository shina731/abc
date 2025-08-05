int gameState = 0; // 0 チュートリアル、1: タイトル画面、2: ゲーム本編
int previousGameState = -1;

import ddf.minim.*;//Minimライブラリのインポート、サウンド関連のクラスを使えるようにする
Minim minim;//Minimのメインオブジェクト、サウンドファイルの読み込みや再生、初期化してから音声をロード
AudioPlayer tutorialMusic;
AudioPlayer game1Music;

void setup() {
  size(800, 400);
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
  if (gameState == 0 || gameState == 1) {
    if (!tutorialMusic.isPlaying()) {
      game1Music.pause();
      game1Music.rewind();
      tutorialMusic.loop();
    }
  } else if (gameState == 2) {
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
    drawTitleScreen();
  } else if (gameState == 2) {
    drawGame();
  }
}

void keyPressed() {
  if (gameState == 0) {
    handleIntroKey();
  } else if (gameState == 1) {
    handleTitleKey();
  } else if (gameState == 2) {
    handleGameKey();
  }
}

void keyReleased() {
  if (gameState == 2) {
    handleGameKeyReleased();
  }
}
