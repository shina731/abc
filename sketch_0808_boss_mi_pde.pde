boolean gameStarted = false; // ← ゲームが開始されたかどうか
boolean countdownStarted = false;   // カウントダウンが始まったか
int countdownStartTime = 0;         // カウントダウン開始時刻（ミリ秒）
int countdownDuration = 4000;       // カウントダウン全体（約4秒）
boolean played3 = false;
boolean played2 = false;
boolean played1 = false;
boolean playedGo = false;

// プレイヤー変数
float playerX = 100;
float playerY = 0;
float playerW = 100;
float playerH = 90;
float velocityX = 0;
float velocityY = 0;
float gravity = 0.8;
float jumpPower = -15;
float highJumpPower = -20;
boolean onGround = false;
boolean playerFacingRight = true;
int playerHP = 100;        // 初期HP
int maxplayerHP = 100;     // 最大HP（表示用）
int bossTouchCooldown = 0;  // ボス接触後に移動禁止にする時間（フレーム数）

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
float bossW = 210;
float bossH =290;
float bossSpeedX = 0;
float bossSpeedY = 0;
int bossMoveTimer = 0; // 次の行動までのカウントダウン
int bossHP = 100;
int maxBossHP = 100;
boolean bossDefeated = false;

PImage playerTexture;
PImage playerAttackImageR;   
PImage playerAttackImageL;
PImage bossImage;  // 通常ボス画像
PImage bossLightningImage;//雷攻撃中のボス
PImage lightningImage;//雷画像

//サウンド
import ddf.minim.*;//Minimライブラリのインポート、サウンド関連のクラスを使えるようにする
Minim minim;//Minimのメインオブジェクト、サウンドファイルの読み込みや再生、初期化してから音声をロード
AudioPlayer jumpSound;//飛んだ時の効果音
AudioPlayer enterSound;//Enterキーを押したときの効果音
AudioPlayer attackSound;//攻撃時の効果音
AudioPlayer missattackSound;//空振りしたときの効果音
AudioPlayer goSound; //goの時の音
AudioPlayer lightningWarningSound; // 雷警告音
AudioPlayer lightningSound;//雷落下

ArrayList<Missile> bossMissiles = new ArrayList<Missile>();
int missileTimer = 0;

//ボス雷
int lightningInterval = 10000; // 10秒ごと
int lastLightningTime = 0;
boolean showLightning = false;
boolean isLightningActive = false;
int lightningX = 0;
int lightningDuration = 20; // フレーム数で表示時間
int lightningTimer = 0;
int lightningWarningLeadTime = 2000; // 2秒前に警告音
boolean lightningWarningPlayed = false;
boolean isChargingLightning = false;
boolean lightningEnabled = false;
int lightningCancelHits = 0;           // 雷をキャンセルするための攻撃回数
boolean lightningCanceled = false;     // 雷がキャンセルされたかどうか


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
  
  playerTexture = loadImage("player.png");
  playerAttackImageR = loadImage("player_attack_R.png");
  playerAttackImageL = loadImage("player_attack_R.png");
  bossImage = loadImage("boss.png");
  bossLightningImage = loadImage("boss_lightning.png");
  lightningImage = loadImage("lightning.png");
  
   //日本語対応_字体「メイリオ」
  PFont font = createFont("Meiryo", 30);
  textFont(font);
  
   //サウンドsetup
  minim = new Minim(this);
  jumpSound = minim.loadFile("jump.mp3");
  enterSound = minim.loadFile("enter.mp3");
  goSound = minim.loadFile("go.mp3"); 
  attackSound = minim.loadFile("attack.mp3");
  missattackSound = minim.loadFile("missattack.mp3");
  lightningWarningSound = minim.loadFile("lightning_warning.mp3");
  lightningSound = minim.loadFile("lightning.mp3");
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
  
  // スタート画面
  if (!gameStarted) {
    if (countdownStarted) {
    int elapsed = millis() - countdownStartTime;

    fill(255);
    textAlign(CENTER, CENTER);
    textSize(80);

     if (elapsed < 1000) {
      text("3", width / 2, height / 2);
      if (!played3 && enterSound != null) {
        enterSound.rewind();
        enterSound.play();
        played3 = true;
      }
    } else if (elapsed < 2000) {
      text("2", width / 2, height / 2);
      if (!played2 && enterSound != null) {
        enterSound.rewind();
        enterSound.play();
        played2 = true;
      }
    } else if (elapsed < 3000) {
      text("1", width / 2, height / 2);
      if (!played1 && enterSound != null) {
        enterSound.rewind();
        enterSound.play();
        played1 = true;
      }
    } else if (elapsed < 4000) {
      text("GO!", width / 2, height / 2);
      if (!playedGo && goSound != null) {
       goSound.rewind();
       goSound.play();
       playedGo = true;
     }
    } else {
      gameStarted = true; // カウントダウン終了→ゲーム開始
    }

    return; // カウントダウン中は他の処理を止める
    } else {
    fill(255);
    textSize(48);
    textAlign(CENTER, CENTER);
    text("ボスステージスタート！", width / 2, height / 2);
    textSize(24);
    text("Enterキーでスタート", width / 2, height / 2 + 40);
    return;
  }
  }
  
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
  // 雷画像の表示
if (showLightning && lightningImage != null) {
  image(lightningImage, lightningX - 25, 0, 200, height);  
}

  drawBossHPBar();
  
  if (showLightning) {

  lightningTimer--;
  if (lightningTimer <= 0) {
    showLightning = false;
  }
  strokeWeight(1);
}
  
  if (!isGameOver){
    updateBossMovement();
    updateBossAttack();   // ← bossの動きの下
    updateLightning();  // ← 毎フレーム雷処理
    updateMissiles();     // ← ミサイルの表示
  }

  // 攻撃中のタイマー更新
  if (isAttacking) {
    attackTimer--;
    if (attackTimer <= 0) {
      isAttacking = false;
    }
    if (attackTimer == attackDuration - 1) {
      if (checkBossHit()) {
        applyDamageToBoss();
      }
    }
  }
}

// プレイヤーの動き（左右移動、重力）
void handlePlayerMovement() {
  float nextX = playerX;
  float nextY = playerY;

// クールダウン減少
  if (bossTouchCooldown > 0) {
    bossTouchCooldown--;
  }
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
    
    if (edgePushTimer > 0) {
      edgePushTimer--;
      return;  // 押し戻し後、一定時間は移動させない
    }
    
// ボスとの接触チェック 
    boolean currentlyTouchingBoss = isOverlap(playerX, playerY, playerW, playerH, bossX, bossY, bossW, bossH);

    // 左右移動は「接触していない」かつ「クールダウン中でない」場合のみ可能
    boolean canMoveHorizontally = (!currentlyTouchingBoss && bossTouchCooldown == 0);
    
    if (canMoveHorizontally) {
      if (leftPressed && !rightPressed) {
        nextX -= 5;
        playerFacingRight = false;
      } else if (rightPressed && !leftPressed) {
        nextX += 5;
        playerFacingRight = true;
      }
    }

    // 重力処理
    velocityY += gravity;
    nextY += velocityY;

    // 地面との判定
    if (nextY >= height - playerH) {
      nextY = height - playerH;
      velocityY = 0;
      onGround = true;
      jumpCount = 0; 
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
      
      if (atLeftEdge) {
        // 左端とボスに挟まれたら右に強制押し戻し
        playerX = constrain(playerX + 50, 0, width - playerW);
        isEdgePushed = true;
        edgePushTimer = 15;  // 約10フレーム動けなくする
      } else if (atRightEdge) {
        // 右端とボスに挟まれたら左に強制押し戻し
        playerX = constrain(playerX - 50, 0, width - playerW);
        isEdgePushed = true;
        edgePushTimer = 15;
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
       
       bossTouchCooldown = 15; 
     }
         // プレイヤーが画面外に出ないよう制限
       playerX = constrain(playerX, 0, width - playerW);
       playerY = constrain(playerY, 0, height - playerH);  // ← これを追加

    }
}

// プレイヤーを描画
void drawPlayer() {
  PImage currentImage;

  if (isAttacking) {
    currentImage = playerAttackImageR; // 常に右向き画像
  } else {
    currentImage = playerTexture; // 通常画像（今は反転不要としておきます）
  }

   pushMatrix();
   boolean drawFacingRight =isAttacking ? attackRight : playerFacingRight;

 if (!drawFacingRight) {
    translate(playerX + playerW, playerY);
    scale(-1, 1);
    image(currentImage, 0, 0,playerW, playerH);
  } else {
    image(currentImage, playerX, playerY, playerW, playerH);
  }

  popMatrix();
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
    if (showLightning) {
      image(bossLightningImage, bossX, bossY, bossW, bossH);  // 雷用の画像
    } else {
      image(bossImage, bossX, bossY, bossW, bossH);  // 通常の画像
    }
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
  
  // ミサイル攻撃処理 
  if (!isChargingLightning) {
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
      // --- HPに応じた速度とクールダウン設定 ---
    float speed;
    int cooldownMin, cooldownMax;

    if (bossHP > 70) {
      speed = 2;
      cooldownMin = 80;
      cooldownMax = 120;
    } else if (bossHP > 40) {
      speed = 4;
      cooldownMin = 60;
      cooldownMax = 100;
    } else if (bossHP > 20) {
      speed = 6;
      cooldownMin = 40;
      cooldownMax = 80;
    } else {
      speed = 8;
      cooldownMin = 20;
      cooldownMax = 50;
    }
      // 単位ベクトルにして速度ベクトルを計算
      float speedX = speed * dx / dist;
      float speedY = speed * dy / dist;

      // ミサイル追加
      bossMissiles.add(new Missile(startX, startY, speedX, speedY));
      missileCooldown = int(random(40, 100)); // 次の発射までの間隔
    
      // 次の発射までの間隔を設定
    missileCooldown = int(random(cooldownMin, cooldownMax));
    }
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

void updateLightning() {
  if (bossHP > 40) return; // 条件を満たさなければ何もしない

  if (!lightningEnabled) {
    lightningEnabled = true;
    lastLightningTime = millis();  // タイマーをリセット
    println("雷有効化タイマー開始！");
  }

  // 雷の警告音（2秒前）
  if (!lightningWarningPlayed && millis() - lastLightningTime > lightningInterval - lightningWarningLeadTime) {
    if (lightningWarningSound != null) {
      lightningWarningSound.rewind();
      lightningWarningSound.play();
      println("雷の警告音！");
    }
    lightningWarningPlayed = true;
    isChargingLightning = true;
    lightningCancelHits = 0;        // カウントをリセット
    lightningCanceled = false;      // フラグもリセット
  }
  
  // 雷チャージ中に2回攻撃されていればキャンセル
  if (isChargingLightning && lightningCancelHits >= 2 && !lightningCanceled) {
    lightningCanceled = true;
    isChargingLightning = false;
    lightningWarningPlayed = false;
    lightningEnabled = false;
    println("雷キャンセル成功！");
    if (lightningWarningSound != null && lightningWarningSound.isPlaying()) {
      lightningWarningSound.pause();
    }
    return;
  }

  // 実際に雷が発生
  if (millis() - lastLightningTime > lightningInterval) {
    if (lightningWarningSound != null && lightningWarningSound.isPlaying()) {
      lightningWarningSound.pause();
      println("警告音を停止");
    }

    if (lightningSound != null) {
      lightningSound.rewind();
      lightningSound.play();
      println("雷の音再生！");
    }

    lastLightningTime = millis();
    showLightning = true;
    lightningTimer = lightningDuration;
    isLightningActive = true;
    lightningWarningPlayed = false;
    isChargingLightning = false;

    // 落雷位置とダメージ処理
    lightningX = int(playerX + playerW / 2 + random(-3, 3));
    if (lightningX >= playerX && lightningX <= playerX + playerW) {
      playerHP -= 15;
      playerHP = max(playerHP, 0);
      println("プレイヤーに15ダメージ！（雷）残りHP: " + playerHP);

      if (playerHP <= 0) {
        isGameOver = true;
      }
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

int jumpCount = 0;
int maxJumpCount = 2;  // 2段ジャンプまで許可

// キー押し処理
void keyPressed() {
  
  // ゲーム開始前に Enter を押したらスタート
  if (!gameStarted && keyCode == ENTER) {
    countdownStartTime = millis();  // 現在時刻を記録
    countdownStarted = true;
    
    played3 = false;
    played2 = false;
    played1 = false;
    playedGo = false;
  }
  if (key == 'a' || key == 'A') {
    leftPressed = true;
    playerFacingRight = false;
  }
  if (key == 'd' || key == 'D') {
    rightPressed = true;
    playerFacingRight = true;
  }
 if (key == ' ') {
     if (jumpCount < maxJumpCount) {
      velocityY = jumpPower;
      onGround = false;
      jumpCount++;
      if (jumpSound != null && !jumpSound.isPlaying()) {
        jumpSound.rewind();
        jumpSound.play();
      }
    }
     jumpPressed = true;
       }
  if (key == 'w' || key == 'W') {
     isAttacking = true;
    attackTimer = attackDuration;
     attackRight = playerFacingRight;  // 向いている方向に攻撃
  }
  if (gameOverDisplayed && key == ENTER) {
    exit();
    if (enterSound != null) {
      enterSound.rewind();
      enterSound.play();
    }
  }
}

void keyReleased() {
  if (key == 'a' || key == 'A') {
    leftPressed = false;
  }
  if (key == 'd' || key == 'D') {
    rightPressed = false;
  }
  if (key ==' ') {
    jumpPressed = false;
  }
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
  switch (itemCount) {
  case 5:
    damage = 12;
    break;
  case 4:
    damage = 10;
    break;
  case 3:
    damage = 8;
    break;
  case 2:
    damage = 6;
    break;
  case 1:
    damage = 4;
    break;
  default:
    damage = 2;
    break;
}

  if (attackSound != null) {
    attackSound.rewind();  // 毎回先頭から再生するため
    attackSound.play();
  }
  if (!isAttacking && missattackSound != null && !missattackSound.isPlaying()) {
      missattackSound.rewind();
      missattackSound.play();
  }
  isAttacking = false; // リセット
  
  bossHP -= damage;
  bossHP = max(bossHP, 0);

  println("ボスに " + damage + " ダメージ！ 残りHP: " + bossHP);
  
  // 雷チャージ中なら、キャンセル用ヒットカウントを増やす
  if (isChargingLightning) {
    lightningCancelHits++;
    println("⚡雷キャンセルのための攻撃！ 現在: " + lightningCancelHits + "回");
  }


  if (bossHP <= 0) {
    bossDefeated = true;
  }
}
