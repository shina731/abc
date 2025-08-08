String[] introTexts = {
  "米作りは戦いだ\n今日も田んぼは、敵に囲まれている",
};

int currentTextIndex = 0;

void drawIntroText() {
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(40);
  text(introTexts[currentTextIndex], width/2, height/2);

  textSize(25);
  fill(200);
  text("Enterキーで進む", width/2, height - 40);
}


void handleIntroKey() {
  if (keyCode == ENTER) {
    currentTextIndex++;
    if (currentTextIndex >= introTexts.length) {
      gameState = 1; // タイトル画面へ
    }
  }
}
