String[] introTexts = {
  "ここは、とある田んぼの世界。",
  "毎年、美味しいお米を育てるために\n農家たちは大忙し。",
  "でもーーー",
  "泥の化け物、暴風、作物を狙う\n害虫たちが田んぼに現れた。"
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
