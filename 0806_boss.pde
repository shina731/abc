// プレイヤー変数
float playerX = 100;
float playerY = 0;
float playerW = 47;
float playerH = 70;
float velocityX = 0;
float velocityY = 0;
float gravity = 0.8;
float jumpPower = -15;
float highJumpPower = -19;
boolean onGround = false;
boolean playerFacingRight = true;
int playerHP = 100;        // 初期HP
int maxplayerHP = 100;     // 最大HP（表示用）

boolean gameOverDisplayed = false;
boolean isGameOver = false;

float knockbackX = 0;
float knockbackY = 0;
boolean isKnockback = false;
int knockbackDuration = 15;  // 吹き飛ばし時間（フレーム数）
int knockbackTimer = 0;

boolean isEdgePushed = false;
int edgePushTimer = 0;

//キー状態管理
boolean leftPressed = false;
boolean rightPressed = false;
boolean shiftPressed = false;
boolean jumpPressed = false;

boolean isAttacking = false;
int attackTimer = 0;
int attackDuration = 10;
boolean attackRight = true;

// ボス関連
float bossX = 500;
float bossY = 0;
float bossW = 220;
float bossH =300;
float bossSpeedX = 0;
float bossSpeedY = 0;
int bossMoveTimer = 0; // 次の行動までのカウントダウン
int bossHP = 100;
int maxBossHP = 100;
boolean bossDefeated = false;
PImage bossImage;  // ボス画像
ArrayList<Missile> bossMissiles = new ArrayList<Missile>();
int missileTimer = 0;

// プレイヤーとボスの当たり判定（矩形判定）
boolean isOverlap(float x1, float y1, float w1, float h1,
                  float x2, float y2, float w2, float h2) {
           int margin = 7;
           return !(x1 + w1 < x2 + margin ||   // 右端が敵の左端より左
           x1 > x2 + w2 - margin ||   // 左端が敵の右端より右
           y1 + h1 < y2 + margin ||   // 下端が敵の上端より上
           y1 > y2 + h2 - margin);    // 上端が敵の下端より下
}

// アイテム数（前ステージで取得した数）
int itemCount = 3;

void setup() {
  size(800, 400);
  textAlign(CENTER, CENTER);
  textSize(20);
  
  // Y座標は地面に立たせる
  playerY = height - playerH;
  bossY = height - bossH;
  
  bossImage = loadImage("boss.png");
  
   //日本語対応_字体「メイリオ」
  PFont font = createFont("Meiryo", 30);
  textFont(font);
}

class Missile {
  float x, y;
  float speedX, speedY;
  float w = 20;
  float h = 8;

  Missile(float x, float y, float speedX, float speedY) {
    this.x = x;
    this.y = y;
    this.speedX = speedX;
    this.speedY = speedY;
  }

  void update() {
    x += speedX;
    y += speedY;
  }

  void display() {
    fill(255, 50, 50);
    rect(x, y, w, h);
  }

  boolean isOffScreen() {
    return x < -w || x > width + w || y < -h || y > height + h;
  }
}

void draw() {
  background(0);
  
  // ゲームクリア表示
  if (bossDefeated) {
    fill(255, 255, 0);
    textSize(60);
    textAlign(CENTER, CENTER); 
    text("ボス撃破！", width / 2, height / 2);
    return;
  }
  
  if (isGameOver) {
    fill(255, 0, 0);
        textSize(60);
    textAlign(CENTER, CENTER); 
    text("ゲームオーバー\nEnterキーで終了", width / 2, height / 2);
    gameOverDisplayed = true;
    return;
  }

  handlePlayerMovement();

  drawPlayer();
  drawPlayerStatus();
  drawBoss();
  drawBossHPBar();
  
  if (!isGameOver){
    updateBossMovement();
    updateBossAttack();   // ← bossの動きの下
    updateMissiles();     // ← ミサイルの表示
  }

  // 攻撃中のタイマー更新
  if (isAttacking) {
    attackTimer--;
    if (attackTimer <= 0) {
      isAttacking = false;
    }
  }
}

// プレイヤーの動き（左右移動、重力）
void handlePlayerMovement() {
  if (isKnockback) {
    // 吹き飛ばし中の移動処理
    playerX += knockbackX;
    playerY += knockbackY;

    knockbackY += gravity; // 重力適用

    knockbackTimer--;
    if (knockbackTimer <= 0) {
      isKnockback = false;
      knockbackX = 0;
      knockbackY = 0;
    }
  } else {
    
    float nextX = playerX;
    float nextY = playerY;
    // 左右移動
    if (leftPressed && !rightPressed) {
      nextX = playerX - 5;
      playerFacingRight = false;
    } else if (rightPressed && !leftPressed) {
      nextX = playerX + 5;
      playerX += 5;
      playerFacingRight = true;
    }

    velocityY += gravity;
    nextY = playerY + velocityY;

    // 地面との判定
    if (nextY >= height - playerH) {
      nextY = height - playerH;
      velocityY = 0;
      onGround = true;
    }else {
      onGround = false;
    }
    
    boolean blockedByBoss = isOverlap(nextX, nextY, playerW, playerH, bossX, bossY, bossW, bossH);
    boolean atLeftEdge = nextX <= 0;
    boolean atRightEdge = nextX >= width - playerW;
    
    if (!blockedByBoss) {
      playerX = nextX;
      playerY = nextY;
    } else {
      velocityY = 0; // ジャンプをキャンセル
      
      if (atLeftEdge && blockedByBoss) {
        // 左端とボスに挟まれたら右に強制押し戻し
        playerX = constrain(playerX + 10, 0, width - playerW);
      } else if (atRightEdge && blockedByBoss) {
        // 右端とボスに挟まれたら左に強制押し戻し
        playerX = constrain(playerX - 10, 0, width - playerW);
      } else {
      if (playerX < bossX) {
        // プレイヤーがボスの左にいる場合 → 左へ押し戻す
         playerX = bossX - playerW - 1;
       } else {
        // プレイヤーがボスの右にいる場合 → 右へ押し戻す
         playerX = bossX + bossW + 1;
       }
      }

      // Y座標は無理に動かさない（床上にいればそのまま）
       playerY = nextY;
     }
    // プレイヤーが画面外に出ないよう制限
    playerX = constrain(playerX, 0, width - playerW);
    }
}

// プレイヤーを描画
void drawPlayer() {
  fill(0, 200, 255);
  rect(playerX, playerY, playerW, playerH);

  // 攻撃エリア表示（デバッグ用）
  if (isAttacking) {
    fill(255, 0, 0, 100);
    float attackX = attackRight ? playerX + playerW : playerX - 30;
    rect(attackX, playerY + 10, 30, playerH - 20);
  }
}

void drawPlayerStatus() {
  fill(255); // 文字色：白
  textSize(17);
  textAlign(LEFT, TOP);  // 左上揃えに設定
  text("プレーヤーHP: "  + playerHP + " / "+ maxplayerHP, 25, 15);  // 数字で表示

  // HPバー（赤いゲージ）
  float barWidth = 230;
  float barHeight = 20;
  float x = 25; 
  float y = 40;
  
  noFill();
  stroke(255);  // 赤
  rect(x, y, barWidth, barHeight);
  
  // 枠線
  noStroke();
  fill(255, 0, 0);
  float hpRatio = (float)playerHP / maxplayerHP;
  rect(x, y, barWidth * hpRatio, barHeight);
}

// ボスを描画
void drawBoss() {
  if (!bossDefeated) {
    image(bossImage, bossX, bossY, bossW, bossH);  // 画像で描画
  }
}

// ボスのHPバー
void drawBossHPBar() {
  fill(255);
  textAlign(RIGHT, TOP);  // 右上に揃える
  textSize(20);
  text("ボスHP: " + bossHP + " / " + maxBossHP, width -40, 10);

  float barWidth = 230;
  float barHeight = 20;
  float x = width - barWidth - 10; 
  float y = 40;

  stroke(255);
  noFill();
  rect(x, y, barWidth, barHeight);

  noStroke();
  fill(255, 0, 0);
  float hpRatio = (float) bossHP / maxBossHP;
  rect(x, y, barWidth * hpRatio, barHeight);
}

void updateBossMovement() {
  if (bossDefeated) return;

  // 一定間隔でランダムな速度に変更（例：60フレームごと）
  bossMoveTimer--;
  if (bossMoveTimer <= 0) {
    bossSpeedX = random(-2, 2);  // 左右移動の速さ
    bossSpeedY = random(-3, 3);  // 上下移動の速さ
    bossMoveTimer = int(random(240, 300)); // 次の行動までの時間
  }

  // 移動予定位置を計算
  float nextX = bossX + bossSpeedX;
  float nextY = bossY + bossSpeedY;

  // 画面内に収めるため制限
  nextX = constrain(nextX, -15, width - bossW + 15);
  nextY = constrain(nextY, 20, height - bossH + 45);

  // 移動予定位置とプレイヤーの当たり判定をチェック
  if (!isOverlap(nextX, nextY, bossW, bossH, playerX, playerY, playerW, playerH)) {
    // 重ならなければ移動
    bossX = nextX;
    bossY = nextY;
  } else {
    // 重なるなら移動しないか、動きをリセットしてみる
    bossSpeedX = 0;
    bossSpeedY = 0;
  }
}

int missileCooldown = 0;

void updateBossAttack() {
  if (bossDefeated) return;

  missileCooldown--;
  if (missileCooldown <= 0) {
    float startX = bossX + bossW / 2;
    float startY = bossY + bossH / 3;
    // プレイヤー座標
    float targetX = playerX + playerW / 2;
    float targetY = playerY + playerH / 2;

    // 目標方向ベクトル
    float dx = targetX - startX;
    float dy = targetY - startY;
     // ベクトルの長さを求める
    float dist = sqrt(dx*dx + dy*dy);
    // 速度の大きさ（ミサイルの速さ）
    float speed = 6;
    // 単位ベクトルにして速度ベクトルを計算
    float speedX = speed * dx / dist;
    float speedY = speed * dy / dist;

    // ミサイル追加
    bossMissiles.add(new Missile(startX, startY, speedX, speedY));
    missileCooldown = int(random(40, 100)); // 次の発射までの間隔
  }

  // ミサイルの移動と描画
  for (int i = bossMissiles.size() - 1; i >= 0; i--) {
    Missile m = bossMissiles.get(i);
    m.update();
    m.display();
    
    // 当たり判定（矩形同士の簡単な判定）
  if (playerX < m.x + m.w &&
      playerX + playerW > m.x &&
      playerY < m.y + m.h &&
      playerY + playerH > m.y) {

    // ミサイルを消す
    bossMissiles.remove(i);
    
    if (!isKnockback && !isGameOver) {
       // 吹き飛ばしをプレイヤーに適用
    float knockbackForceX = (playerX < m.x) ? -8 : 8;  // ミサイルの位置に応じて左右反転
    float knockbackForceY = -10; // 上方向にも吹き飛ばす
    applyKnockback(knockbackForceX, knockbackForceY);
    playerHP -= 5;
    playerHP = max(playerHP, 0);
    println("プレイヤーに5ダメージ！ 残りHP: " + playerHP);

    if (playerHP <= 0) {
      isGameOver = true;
    }
  }
  
  }else if (m.isOffScreen()) {
    bossMissiles.remove(i);
   }
  }
}


void updateMissiles() {
  for (int i = bossMissiles.size() - 1; i >= 0; i--) {
    Missile m = bossMissiles.get(i);
    m.update();
    m.display();
    if (m.isOffScreen()) {
      bossMissiles.remove(i);
    }
  }
}

void applyKnockback(float forceX, float forceY) {
  knockbackX = forceX;
  knockbackY = forceY;
  isKnockback = true;
  knockbackTimer = knockbackDuration;
  onGround = false; // 吹き飛び中は空中扱いにする場合
}


// キー押し処理
void keyPressed() {
  if (key == 'a' || key == 'A') {
    leftPressed = true;
    playerFacingRight = false;
  }
  if (key == 'd' || key == 'D') {
    rightPressed = true;
    playerFacingRight = true;
  }
  if (key == CODED && keyCode == SHIFT) {
    shiftPressed = true;
  }
  if (gameOverDisplayed && key == ENTER) {
    exit();
  }

  // ジャンプ
  if (key == ' ') {
    jumpPressed = true;
    if (onGround) {
      velocityY = shiftPressed ? highJumpPower : jumpPower;
      onGround = false;
    }
  }

  // 攻撃（右）
  if (key == 'k' || key == 'K') {
    isAttacking = true;
    attackTimer = attackDuration;
    attackRight = true;

    if (checkBossHit()) {
      applyDamageToBoss();
    }
  }

  // 攻撃（左）
  if (key == 'h' || key == 'H') {
    isAttacking = true;
    attackTimer = attackDuration;
    attackRight = false;

    if (checkBossHit()) {
      applyDamageToBoss();
    }
  }
}

void keyReleased() {
  if (key == 'a' || key == 'A') leftPressed = false;
  if (key == 'd' || key == 'D') rightPressed = false;
  if (key == CODED && keyCode == SHIFT) shiftPressed = false;
}

// 攻撃が当たっているか判定
boolean checkBossHit() {
  if (bossDefeated) return false;

  float attackX = attackRight ? playerX + playerW : playerX - 30;
  float attackY = playerY + 10;
  float attackW = 30;
  float attackH = playerH - 20;

  return (attackX < bossX + bossW &&
          attackX + attackW > bossX &&
          attackY < bossY + bossH &&
          attackY + attackH > bossY);
}

// ボスにダメージを与える
void applyDamageToBoss() {
  int damage = 0;
  if (itemCount >= 3) {
    damage = 30;
  } else if (itemCount == 2) {
    damage = 15;
  } else if (itemCount == 1) {
    damage = 10;
  } else {
    damage = 5;
  }

  bossHP -= damage;
  bossHP = max(bossHP, 0);

  println("ボスに " + damage + " ダメージ！ 残りHP: " + bossHP);

  if (bossHP <= 0) {
    bossDefeated = true;
  }
}
