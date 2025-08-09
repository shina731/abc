int gameState = 0; // 0 チュートリアル、1: ゲーム本編
int previousGameState = -1;

AudioPlayer tutorialMusic;
AudioPlayer game1Music;
AudioPlayer bossMusic;

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
  
  bossMusic = minim.loadFile("bossbattle.mp3");
  bossMusic.setGain(-15);
  
  initGame();
  bossGame();

}

void draw() {
  // BGMの切り替え処理
  if (gameState != previousGameState) {
    if (gameState == 0) {
      game1Music.pause(); game1Music.rewind();
      bossMusic.pause(); bossMusic.rewind();
    tutorialMusic.loop();
    } else if (gameState == 1) {
      tutorialMusic.pause(); tutorialMusic.rewind();
      bossMusic.pause(); bossMusic.rewind();
      game1Music.loop();
    } else if (gameState == 2) {
      tutorialMusic.pause(); tutorialMusic.rewind();
      game1Music.pause(); game1Music.rewind();
      bossMusic.loop();
    }
    previousGameState = gameState; // 状態を更新
  }
  background(0);
  if (gameState == 0) {
    drawIntroText();
  } else if (gameState == 1) {
    drawGame();
  }
  else if (gameState ==2){
    drawBossGame();
  }
}

void drawPlayer() {
  if (gameState == 1) {
    handledrawPlayer();
  }
  else if (gameState == 2){
    handleBossdrawPlayer();
  }
}

void keyPressed() {
  if (gameState == 0) {
    handleIntroKey();
  } else if (gameState == 1) {
    handleGameKey();
  } else if (gameState ==2){
    handleBossKey();
  }
}

void keyReleased() {
  if (gameState == 1) {
    handleGameKeyReleased();
  }
  else if (gameState == 2){
    handleBossKeyReleased();
  }
}
