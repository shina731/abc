String[] introTexts = {
  "あなたは新米農家\n稲を育て、迫りくる災いを乗り越えろ",
  "A：左移動\nD：右移動\nW：攻撃\nSpace：ジャンプ\n長押し+SpaceまたはSpace二回押し：二段ジャンプ"
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
