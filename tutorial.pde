String[] introTexts = {
  "ここは、とある田んぼの世界。",
  "毎年、美味しいお米を育てるために\n農家たちは大忙し。",
  "でもーーー",
  "泥の化け物、暴風、作物を狙う\n害虫たちが田んぼに現れた。"
};

int currentTextIndex = 0;
int gameState = -1;  // -1: テロップ中, 0: ゲームやタイトル画面など

void setup() {
  size(800, 600);
  textAlign(CENTER, CENTER);
  textSize(28);
  
   //日本語対応_字体「メイリオ」
  PFont font = createFont("Meiryo", 50);
  textFont(font);
}

void draw() {
  background(0);

  if (gameState == -1) {
    drawIntroText();
  } else if (gameState == 0) {
    drawTitleScreen();  // ← あとで作る
  }
}

void drawIntroText() {
  fill(255);
  textSize(40);
  text(introTexts[currentTextIndex], width/2, height/2);

  textSize(25);
  fill(200);
  text("Enterキーで進む", width/2, height - 40);
}

void keyPressed() {
  if (gameState == -1 && keyCode == ENTER) {
    currentTextIndex++;
    
    if (currentTextIndex >= introTexts.length) {
      gameState = 0;  // テロップ終了 → 次の画面へ
    }
  }
}

// テロップ終了後に表示される画面（仮）
void drawTitleScreen() {
  background(30, 60, 90);
  fill(255);
  textSize(32);
  text("タイトル画面 または ゲームスタート！", width/2, height/2);
}
