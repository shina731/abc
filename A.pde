// プレイヤー変数
float playerX = -90;
float playerY = 0;
float playerW = 47;
float playerH = 60;
float velocityX = 0;
float velocityY = 0;
float gravity = 0.8;
float jumpPower = -15;
float highJumpPower = -19;
boolean onGround = false;
float knockbackX = 0;
float knockbackY = 0;
boolean playerFacingRight = true;
float checkpointX = 2250;
float checkpointY;
PImage tyuukann;
boolean reachedCheckpoint = false;
boolean isAttacking = false;
boolean attackRight = true;
int attackDuration = 10;  // 攻撃の持続時間（フレーム数）
int attackTimer = 0;
ArrayList<Enemy> enemies;


// スクロール
float cameraX = 0;
// ボスエリア制御用の変数
boolean inBossArea = false;
float bossAreaStartX = 4800;
float bossAreaEndX = 5620;
float bossCameraX = bossAreaStartX - (width / 2);  // ボスエリアの左端を画面の中心に合わせる

// キー状態管理
boolean leftPressed = false;
boolean rightPressed = false;
boolean shiftPressed = false;

// ゲーム状態
boolean gameStarted = false;
boolean gameOver = false;
int gameOverTimer = 0;
int totalTimeMillis = 5 * 60 * 1000;  // 5分（ミリ秒）
int startTime;  // ゲーム開始時刻を記録
boolean deathAnimationPlaying = false;
int deathAnimationTimer = 0;

// 地面とブロック
ArrayList<Platform> platforms;

Enemy enemy;
PImage enemyTexture;  // 敵画像をグローバルで保持


PImage playerTexture;
PImage playerAttackImageR;
PImage playerAttackImageL;
PImage bg;

// ライフ管理
int maxHP = 100;
int currentHP = maxHP;
boolean invincible = false;
int invincibleTimer = 0;

//サウンド
import ddf.minim.*;//Minimライブラリのインポート、サウンド関連のクラスを使えるようにする
Minim minim;//Minimのメインオブジェクト、サウンドファイルの読み込みや再生、初期化してから音声をロード
AudioPlayer jumpSound;//飛んだ時の効果音
AudioPlayer damageSound;//ダメージを受けたときの効果音
AudioPlayer enterSound;//Enterキーを押したときの効果音
AudioPlayer fallingSound;//落下によるゲームオーバーの効果音
AudioPlayer itemgetSound;//アイテム獲得時の効果音
AudioPlayer lifeitemgetSound;//ライフアイテム獲得時の効果音
AudioPlayer bgm;//BGM
AudioPlayer attackSound;//攻撃時の効果音
AudioPlayer runSound;//足音の効果音
boolean isRunSoundPlaying = false;//再生管理フラグ
boolean jumpPressed = false;//スペースキーの状態　足音再生用
AudioPlayer missattackSound;//空振りしたときの効果音
boolean attackHit = false;//攻撃が当たったかどうか
AudioPlayer gameoverSound;//ゲームオーバーした際の効果音
boolean gameOverSoundPlayed = false;//ゲームオーバーサウンドが再生済みか
AudioPlayer bossbattleBGM;//ボス戦でのBGM
boolean bossBGMPlaying = false;

float healX = 2250;  // 回復ポイントの位置（X座標）
float healY = 300; // Y座標（地面の上）
float healW = 40;
float healH = 60;
boolean healed = false;

ArrayList<Item> items;             // ゲーム上にあるアイテム
ArrayList<Item> collectedItems;    // ゲットしたアイテム
PImage itemTexture;                // アイテム画像（任意）

void setup() {
  size(800, 400);
  playerY = height - 100;

  // 敵画像読み込み（dataフォルダに enemy.png を置く）
  enemyTexture = loadImage("enemy.png");
  playerTexture = loadImage("player.png");
  playerAttackImageR = loadImage("player_attack_R.png");
  playerAttackImageL = loadImage("player_attack_R.png");
  platforms = new ArrayList<Platform>();
  bg=loadImage("haikei.png");
  tyuukann = loadImage("tyuukann.png");
  itemTexture = loadImage("item.png"); // dataフォルダに item.png を置く（任意）

  items = new ArrayList<Item>();
  collectedItems = new ArrayList<Item>();

  // 空中にアイテムを設置
  items.add(new Item(630, height - 270, 30, 30, itemTexture));
  items.add(new Item(1880, height - 350, 30, 30, itemTexture));
  items.add(new Item(4700, height - 400, 30, 30, itemTexture));
  // 地面
  for (int i = -10; i < 70; i++) {
    if (i >= 20 && i <= 27) continue; // index 20〜29 = x:1600〜2400 の地面を空ける（穴）
    platforms.add(new Platform(i * 80, height - 40, 80, 40));
  }
  checkpointY = height - 100;  // 最初の開始地点

  // 空中ブロック
  platforms.add(new Platform(200, height - 120, 80, 20));
  platforms.add(new Platform(400, height - 180, 80, 20));
  platforms.add(new Platform(600, height - 240, 80, 20));
  platforms.add(new Platform(950, height - 250, 40, 250));
  platforms.add(new Platform(1650, height - 150, 50, 20));
  platforms.add(new Platform(1760, height - 225, 50, 20));
  platforms.add(new Platform(1870, height - 300, 50, 20));
  platforms.add(new Platform(1980, height - 225, 50, 20));
  platforms.add(new Platform(2090, height - 150, 50, 20));
  platforms.add(new Platform(3000, height - 125,30, 20));
  platforms.add(new Platform(3100, height - 125,30, 20));
  platforms.add(new Platform(3200, height - 125,30, 20));
  platforms.add(new Platform(3300, height - 125,30, 20));
  platforms.add(new Platform(3400, height - 125,30, 20));
  platforms.add(new Platform(4000, height - 120, 100, 20));
  platforms.add(new Platform(4250, height - 180, 100, 20));
  platforms.add(new Platform(4500, height - 240, 100, 20));
  
  
  
  enemies = new ArrayList<Enemy>(); // ★ enemiesリストを初期化
  // setup()などで敵追加
enemies.add(new Enemy(1400, height - 100, 40, 60,enemyTexture));


  //日本語対応_字体「メイリオ」
  PFont font = createFont("Meiryo", 50);
  textFont(font);

  //サウンドsetup
  minim = new Minim(this);
  jumpSound = minim.loadFile("jump.mp3");
  damageSound = minim.loadFile("damage.mp3");
  enterSound = minim.loadFile("enter.mp3");
  fallingSound = minim.loadFile("falling.mp3");
  itemgetSound = minim.loadFile("item.mp3");
  lifeitemgetSound = minim.loadFile("lifeitem.mp3");
  attackSound = minim.loadFile("attack.mp3");
  runSound = minim.loadFile("run.mp3");
  missattackSound = minim.loadFile("missattack.mp3");
  gameoverSound = minim.loadFile("gameover.mp3");
  bossbattleBGM = minim.loadFile("bossbattle.mp3");//ボス戦でのBGM
  bgm = minim.loadFile("bgm2.mp3");
  bgm.loop();
  bgm.setGain(-15);

  startTime = millis();
}

void drawPlayer() {
  if (invincible && (invincibleTimer / 5) % 2 != 0) {
    return; // 何も描画しない（点滅）
  }
  PImage currentImage;

  if (isAttacking) {
    currentImage = playerAttackImageR; // 常に右向き画像
  } else {
    currentImage = playerTexture; // 通常画像（今は反転不要としておきます）
  }

  pushMatrix();
  boolean drawFacingRight = isAttacking ? attackRight : playerFacingRight;

  if (!drawFacingRight) {
    translate(playerX + playerW, playerY);
    scale(-1, 1);
    image(currentImage, 0, 0, 70, 60);
  } else {
    image(currentImage, playerX, playerY, 70, 60);
  }

  popMatrix();
}

void draw() {
  background(0); // 空色
  noStroke();
  if (bg != null) {
    image(bg, 0, 0, width, height);
  }


  // スタート画面
  if (!gameStarted) {
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(48);
    text("マリオ風ゲーム", width / 2, height / 2 - 40);
    textSize(24);
    text("Enterキーでスタート", width / 2, height / 2 + 20);
    return;
  }
onGround = false;
  // ゲームオーバー処理
  if (deathAnimationPlaying) {
    deathAnimationTimer--;
    if (deathAnimationTimer <= 0) {
      gameOver = true;
      gameOverTimer = 20;
      deathAnimationPlaying = false;
    }
  }

  if (gameOver) {
    if (gameOverTimer > 0) {
      gameOverTimer--;
    } else {
      fill(0);
      textAlign(CENTER, CENTER);
      textSize(48);
      text("GAME OVER", width / 2, height / 2 - 40);
      textSize(24);
      text("Enterキーで再スタート", width / 2, height / 2 + 20);
    }
    return;
  }

  // 横移動
  if (leftPressed && !rightPressed) {
    velocityX = -5;
  } else if (rightPressed && !leftPressed) {
    velocityX = 5;
  } else {
    velocityX = 0;
  }
  if (playerX < -100) {
    playerX = -100;
  }
  // 重力
  velocityY += gravity;


  if (inBossArea) {
    cameraX = bossAreaStartX;

    // 左に出られないように制限
    if (playerX < bossAreaStartX) {
      playerX = bossAreaStartX;
      velocityX = max(0, velocityX); // 左向きの速度を止める
    }

    // 右に出られないように制限
    if (playerX + playerW > bossAreaEndX) {
      playerX = bossAreaEndX - playerW;
      velocityX = min(0, velocityX); // 右向きの速度を止める
    }
  }

  
  // ノックバック加算
 // 横方向：velocityX分の移動判定と移動
float nextX = playerX + velocityX;
boolean collidedX = false;
for (Platform p : platforms) {
  if (playerY + playerH > p.y && playerY < p.y + p.h) {
    if (velocityX > 0 && nextX + playerW > p.x && playerX + playerW <= p.x) {
      collidedX = true;
      playerX = p.x - playerW;
      velocityX = 0;
      break;
    }
    if (velocityX < 0 && nextX < p.x + p.w && playerX >= p.x + p.w) {
      collidedX = true;
      playerX = p.x + p.w;
      velocityX = 0;
      break;
    }
  }
}
if (!collidedX) {
  playerX = nextX;
}

// 横方向：knockbackX分の移動判定と移動
float nextKnockX = playerX + knockbackX;
boolean collidedKnockX = false;
for (Platform p : platforms) {
  if (playerY + playerH > p.y && playerY < p.y + p.h) {
    if (knockbackX > 0 && nextKnockX + playerW > p.x && playerX + playerW <= p.x) {
      collidedKnockX = true;
      playerX = p.x - playerW;
      knockbackX = 0;
      break;
    }
    if (knockbackX < 0 && nextKnockX < p.x + p.w && playerX >= p.x + p.w) {
      collidedKnockX = true;
      playerX = p.x + p.w;
      knockbackX = 0;
      break;
    }
  }
}
if (!collidedKnockX) {
  playerX = nextKnockX;
}

// 縦方向：velocityY分の移動判定と移動
float nextY = playerY + velocityY;
boolean collidedY = false;
for (Platform p : platforms) {
  // 足場に着地判定
  if (velocityY >= 0 && 
      playerX + playerW > p.x && playerX < p.x + p.w &&
      nextY + playerH > p.y && playerY + playerH <= p.y) {
    collidedY = true;
    playerY = p.y - playerH;
    velocityY = 0;
    knockbackY = 0;
    onGround = true;
   // 着地時ノックバックリセットも多い
    break;
  }
  // 天井にぶつかる判定
  if (velocityY < 0 &&
      playerX + playerW > p.x && playerX < p.x + p.w &&
      nextY < p.y + p.h && playerY >= p.y + p.h) {
    collidedY = true;
    playerY = p.y + p.h;
    velocityY = 0;
    knockbackY = 0;
    break;
  }
}
if (!collidedY) {
  playerY = nextY;
}

// 縦方向：knockbackY分の移動判定と移動
float nextKnockY = playerY + knockbackY;
boolean collidedKnockY = false;
for (Platform p : platforms) {
  // 足場にぶつかる判定
  if (knockbackY > 0 &&
      playerX + playerW > p.x && playerX < p.x + p.w &&
      nextKnockY + playerH > p.y && playerY + playerH <= p.y) {
    collidedKnockY = true;
    playerY = p.y - playerH;
    knockbackY = 0;
    break;
  }
  // 天井にぶつかる判定
  if (knockbackY < 0 &&
      playerX + playerW > p.x && playerX < p.x + p.w &&
      nextKnockY < p.y + p.h && playerY >= p.y + p.h) {
    collidedKnockY = true;
    playerY = p.y + p.h;
    knockbackY = 0;
    break;
  }
}
if (!collidedKnockY) {
  playerY = nextKnockY;
}



  // ノックバック減衰
  knockbackX *= 0.9;
  knockbackY *= 0.9;

  // 落下によるゲームオーバー
  if (playerY > height + 100 && !deathAnimationPlaying && !gameOver) {
     currentHP = 0;
     deathAnimationPlaying = true;
    deathAnimationTimer = 10;
  }
  int elapsed = millis() - startTime;
  int remaining = max(0, totalTimeMillis - elapsed);

  // 秒数として表示
  int secondsLeft = remaining / 1000;

  // 時間切れによるゲームオーバー
  if (remaining <= 0 && !deathAnimationPlaying && !gameOver) {
    currentHP = 0;
    deathAnimationPlaying = true;
    deathAnimationTimer = 10;
  }


  // 足場との判定
  for (Platform p : platforms) {
    if (velocityY >= 0 &&
      playerX + playerW > p.x &&
      playerX < p.x + p.w &&
      playerY + playerH > p.y &&
      playerY + playerH - velocityY <= p.y) {
      playerY = p.y - playerH;
      velocityY = 0;
      knockbackY = 0;
      onGround = true;
    }

    // 壁の横からの衝突を防ぐ
    if (playerY + playerH > p.y && playerY < p.y + p.h) {
      // 横から右にぶつかったとき
      if (velocityX > 0 &&
        playerX + playerW <= p.x + velocityX &&
        playerX + playerW > p.x &&
        playerX < p.x) {
        playerX = p.x - playerW;
        velocityX = 0;
      }
      // 横から左にぶつかったとき
      if (velocityX < 0 &&
        playerX >= p.x + p.w + velocityX &&
        playerX < p.x + p.w &&
        playerX + playerW > p.x + p.w) {
        playerX = p.x + p.w;
        velocityX = 0;
      }
    }

    if (velocityY < 0 &&
      playerX + playerW > p.x &&
      playerX < p.x + p.w &&
      playerY < p.y + p.h &&
      playerY > p.y) {
      playerY = p.y + p.h;
      velocityY = 0;
      knockbackY = 0;
    }
  }

  for (Enemy e : enemies) {
  if (!e.isDead &&
      playerX + playerW > e.x &&
      playerX < e.x + e.w &&
      playerY + playerH > e.y &&
      playerY < e.y + e.h) {

    int damageAmount = 20;
currentHP -= damageAmount;
invincible = true;
invincibleTimer = 60;

if (damageSound != null && !damageSound.isPlaying()) {
  damageSound.rewind();
  damageSound.play();
}

if (currentHP <= 0) {
  deathAnimationPlaying = true;
  deathAnimationTimer = 60;
}


    // ノックバック（敵の反対方向へ）
    if (playerX + playerW / 2 < e.x + e.w / 2) {
      knockbackX = -7;
    } else {
      knockbackX = 7;
    }
    knockbackY = -5;

    println("ダメージ！ hp：" + currentHP);

    if ( currentHP <= 0) {
      deathAnimationPlaying = true;
      deathAnimationTimer = 60; // 余韻
    }
    break;  // １体の敵だけで処理終了
  }
}


  // 無敵時間カウント
  if (invincible) {
    invincibleTimer--;
    if (invincibleTimer <= 0) {
      invincible = false;
    }
  }

  if (!healed &&
    playerX + playerW > healX &&
    playerX < healX + healW &&
    playerY + playerH > healY &&
    playerY < healY + healH) {

    currentHP = maxHP;

    healed = true;   // 一度だけ回復
    println("hpが全回復した！");
    if (lifeitemgetSound != null&&//音声を再生
      !lifeitemgetSound.isPlaying()) {
      lifeitemgetSound.rewind();
      lifeitemgetSound.play();
    }
  }

  // 回復ポイントの範囲に入ったらチェックポイント登録
  if (!reachedCheckpoint &&
    playerX + playerW > healX && playerX < healX + healW &&
    playerY + playerH > healY && playerY < healY + healH) {
    checkpointX = healX;
    checkpointY = healY - playerH;
    reachedCheckpoint = true;
    println("チェックポイント到達！");
  }

  for (int i = items.size() - 1; i >= 0; i--) {
    Item item = items.get(i);
    if (playerX + playerW > item.x &&
      playerX < item.x + item.w &&
      playerY + playerH > item.y &&
      playerY < item.y + item.h) {

      // アイテムを取得済みリストへ移動
      collectedItems.add(item);

      // アイテムをフィールドから削除
      items.remove(i);

      println("アイテムをゲット！");
      if (itemgetSound != null&&//音声を再生
        !itemgetSound.isPlaying()) {
        itemgetSound.rewind();
        itemgetSound.play();
      }
    }
  }

  // 敵との通り抜け防止（押し戻し）
 for (Enemy e : enemies) {
  if (e.isDead) continue;  // 死んだ敵は無視する
  
  if (playerX + playerW > e.x &&
      playerX < e.x + e.w &&
      playerY + playerH > e.y &&
      playerY < e.y + e.h) {

    float overlapLeft = (playerX + playerW) - e.x;
    float overlapRight = (e.x + e.w) - playerX;
    float overlapTop = (playerY + playerH) - e.y;
    float overlapBottom = (e.y + e.h) - playerY;

    float minOverlap = min(min(overlapLeft, overlapRight), min(overlapTop, overlapBottom));

    if (minOverlap == overlapLeft) {
      playerX -= overlapLeft;
    } else if (minOverlap == overlapRight) {
      playerX += overlapRight;
    } else if (minOverlap == overlapTop) {
      playerY -= overlapTop;
      velocityY = 0;
      onGround = true;
    } else if (minOverlap == overlapBottom) {
      playerY += overlapBottom;
      velocityY = 0;
    }
  }
}


  // カメラ位置
  cameraX = playerX - width / 2;

  // ボスエリア制御
  if (playerX >= bossAreaStartX) {
    inBossArea = true;
  }

  if (inBossArea) {
    // カメラをボスエリアに固定（強制スクロール）
    cameraX = bossCameraX;
     if (inBossArea && !bossBGMPlaying) {
      if (bgm != null && bgm.isPlaying()) {
        bgm.pause(); // 通常BGMを止める（pause or close)
      }
      if (bossbattleBGM != null) {
        bossbattleBGM.rewind(); // 先頭から再生
        bossbattleBGM.loop();   // ループさせたい場合
        bossbattleBGM.setGain(-15);
      }
      bossBGMPlaying = true;
    }
  } else {
    // 通常時はプレイヤーを中心に追従
    cameraX = playerX - width / 2;
  }



  // 描画
  pushMatrix();
  translate(-cameraX, 0);

  drawPlayer();

  if (isAttacking) {
  attackTimer--;
  if (attackTimer <= 0) {
    isAttacking = false;
  }

  float axeX, axeY, axeW, axeH;
  axeW = 20;
  axeH = 40;
  axeY = playerY + playerH / 2 - axeH / 2;
  axeX = playerFacingRight ? playerX + playerW : playerX - axeW;

  fill(255, 255, 0, 0);
  rect(axeX, axeY, axeW, axeH);

  for (Enemy e : enemies) {
    if (!e.isDead &&
        axeX + axeW > e.x &&
        axeX < e.x + e.w &&
        axeY + axeH > e.y &&
        axeY < e.y + e.h &&
        !e.isInvincible) {

      e.hp -= 10;

      if (e.hp <= 0) {
        e.isDead = true;
      } else {
        e.isInvincible = true;
        e.invincibleTimer = 60;
      }

      attackHit = true;
      e.charging = false;
      e.chargeCooldown = 60;
      e.pauseTimer = 30;

      println("攻撃成功！ 残りHP：" + e.hp);
      if (attackSound != null && !attackSound.isPlaying()) {
        attackSound.rewind();
        attackSound.play();
      }

      break; // 多段ヒット防止
    }
  }

  if (!attackHit && missattackSound != null && !missattackSound.isPlaying()) {
    missattackSound.rewind();
    missattackSound.play();
  }
  attackHit = false;
}


  // 足場描画
  for (Platform p : platforms) {
    p.display();
  }

// 敵描画
for (Enemy e : enemies) {
  if (abs(e.x - playerX) < width * 1.5) { // プレイヤーの近くのみ更新
    e.update();
    e.display();
  }
}




  // アイテム描画
  for (Item item : items) {
    item.display();
  }

  // 回復ポイント描画
  image(tyuukann, checkpointX, checkpointY, 40, 40);
popMatrix();
 
  // 更新





  // HPバー表示
int barWidth = 200;
int barHeight = 20;
int barX = 10;
int barY = 10;

fill(0);
rect(barX - 2, barY - 2, barWidth + 4, barHeight + 4); // 黒い枠
fill(255, 0, 0);
float hpRatio = float(currentHP) / maxHP;
rect(barX, barY, barWidth * hpRatio, barHeight);

  fill(0);
  textSize(20);
  textAlign(RIGHT, TOP);
  text("Time: " + nf(secondsLeft, 2) + "s", width - 10, 10);

  
  // ゲットしたアイテムを小さく表示
  for (int i = 0; i < collectedItems.size(); i++) {
    Item item = collectedItems.get(i);
    float displaySize = 20;
    float x = 10 + i * (displaySize + 5);
    float y = 40;

    if (item.texture != null) {
      image(item.texture, x, y, displaySize, displaySize);
    } else {
      fill(255, 255, 0);
      rect(x, y, displaySize, displaySize);
    }
  }
  //足音
  if ((leftPressed || rightPressed) && onGround && !keyPressed || (keyPressed && key != ' ')) {
    if (!isRunSoundPlaying && runSound != null) {
      runSound.loop();  // ループ再生
      isRunSoundPlaying = true;
    }
  } else {
    if (isRunSoundPlaying && runSound != null) {
      runSound.pause(); // 停止ではなく pause にすることでループの頭で止める
      isRunSoundPlaying = false;
    }
  }
  boolean movingHorizontally = leftPressed || rightPressed;
  boolean shouldPlayRunSound = movingHorizontally && onGround && !jumpPressed;

  if (shouldPlayRunSound) {
    if (!isRunSoundPlaying && runSound != null) {
      runSound.loop();
      isRunSoundPlaying = true;
    }
  } else {
    if (isRunSoundPlaying && runSound != null) {
      runSound.pause();
      isRunSoundPlaying = false;
    }
  }
}
// 入力処理
void keyPressed() {
  if (!gameStarted && keyCode == ENTER) {
    gameStarted = true;
    if (enterSound != null) {
      enterSound.rewind();
      enterSound.play();
    }
    return;
  }

  if (gameOver && gameOverTimer <= 0 && keyCode == ENTER) {
    resetGame();
    if (enterSound != null) {
      enterSound.rewind();
      enterSound.play();
    }
    return;
  }

  if (key == 'a' || key == 'A') {
    leftPressed = true;
    playerFacingRight = false;  // ← 左向きにセット
  }
  if (key == 'd' || key == 'D') {
    rightPressed = true;
    playerFacingRight = true;   // ← 右向きにセット
  }
  if (key == CODED && keyCode == SHIFT) {
    shiftPressed = true;
  }
  if (key == 'k' || key == 'K') {
    isAttacking = true;
    attackTimer = attackDuration;
    attackRight = true;
  }

  if (key == 'h' || key == 'H') {
    isAttacking = true;
    attackTimer = attackDuration;
    attackRight = false;
  }

  if (key == ' ') {
    jumpPressed = true;
    if (onGround) {
      velocityY = shiftPressed ? highJumpPower : jumpPower;
      onGround = false;
      if (jumpSound != null && !jumpSound.isPlaying()) {
        jumpSound.rewind();
        jumpSound.play();
      }
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
  if (key == CODED && keyCode == SHIFT) {
    shiftPressed = false;
  }
  if (key ==' ') {
    jumpPressed = false;
  }
}

// Platformクラス
class Platform {
  float x, y, w, h;
  Platform(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }

  void display() {
    fill(100, 60, 20);
    rect(x, y, w, h);
  }
}





// Enemyクラス（画像対応）
class Enemy {
  float x, y, w, h;
  float speed = 2;
  float detectRange = 270;
  boolean charging = false;
  int chargeCooldown = 0;
  int pauseTimer = 0;
  int direction = -1;
  PImage texture;

  int chasingTimer = 0;
  final int maxChasingTime = 50;

  float velocityY = 0;
  float gravity = 0.8;
  boolean onGround = false;
  boolean isInvincible = false;
  int invincibleTimer = 0;

  int hp = 30;
  boolean isDead = false;

  Enemy(float x, float y, float w, float h, PImage texture) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.texture = texture;
  }

  void update() {
    if (isDead) return;

    if (isInvincible) {
      invincibleTimer--;
      if (invincibleTimer <= 0) {
        isInvincible = false;
      }
    }

    // --- 落下処理 ---
    if (!onGround) {
      velocityY += gravity;
    }
    y += velocityY;

    onGround = false;
    for (Platform p : platforms) {
      if (
        velocityY >= 0 &&
        x + w > p.x &&
        x < p.x + p.w &&
        y + h > p.y &&
        y + h - velocityY <= p.y
      ) {
        y = p.y - h;
        velocityY = 0;
        onGround = true;
      }
    }

    if (pauseTimer > 0) {
      pauseTimer--;
      return;
    }
    if (chargeCooldown > 0) {
      chargeCooldown--;
      return;
    }

    float pxCenter = playerX + playerW / 2;
    float exCenter = x + w / 2;

    boolean playerInRange = abs(pxCenter - exCenter) < detectRange;
    boolean sameHeight = abs(playerY - y) < 40;

    if (!charging && playerInRange && sameHeight) {
      charging = true;
      chasingTimer = 0;
      direction = (pxCenter > exCenter) ? 1 : -1;
    }

   if (charging) {
  chasingTimer++;

  float nextX = x + direction * speed * 2;
  boolean hitWall = false;

  for (Platform p : platforms) {
    if (nextX + w > p.x && nextX < p.x + p.w &&
        y + h > p.y && y < p.y + p.h) {
      hitWall = true;
      break;
    }
  }

  if (!hitWall) {
    x = nextX;
  } else {
    // 壁にぶつかったので突進停止
    charging = false;
    pauseTimer = 30;
    chargeCooldown = 60;
    direction *= -1;
  }
// プレイヤーと当たったら突進中止（任意）
if (collidesWith(playerX, playerY, playerW, playerH)) {
  charging = false;
  pauseTimer = 30;
  direction *= -1;
  chargeCooldown = 60;
}

  float pxCenterNow = playerX + playerW / 2;
  float exCenterNow = x + w / 2;
  if (abs(pxCenterNow - exCenterNow) < 10) {
    charging = false;
    pauseTimer = 30;
    direction *= -1;
    chargeCooldown = 60;
  } else if (chasingTimer > maxChasingTime) {
    charging = false;
    pauseTimer = 30;
    chargeCooldown = 60;
  }
}

  }

  void display() {
    if (isDead) return;

    if (texture != null) {
      pushMatrix();
      translate(x + w / 2, y);
      scale(direction, 1);

      if (isInvincible) {
        if (frameCount % 6 < 3) {
          image(texture, -w/2, 0, w, h);
        }
      } else {
        image(texture, -w/2, 0, w, h);
      }

      popMatrix();
    } else {
      fill(0, 0, 255);
      rect(x, y, w, h);
    }
  }

  void takeDamage(int damage) {
  if (isInvincible || isDead) return;
  hp -= damage;
  if (hp <= 0 && !isDead) {
    isDead = true;
  } else {
    isInvincible = true;
    invincibleTimer = 30;
  }
}


  boolean collidesWith(float px, float py, float pw, float ph) {
    if (isDead) return false;
    return px < x + w && px + pw > x && py < y + h && py + ph > y;
  }
}




  class Item {
    float x, y, w, h;
    PImage texture;

    Item(float x, float y, float w, float h, PImage texture) {
      this.x = x;
      this.y = y;
      this.w = w;
      this.h = h;
      this.texture = texture;
    }

    void display() {
      if (texture != null) {
        image(texture, x, y, w, h);
      } else {
        fill(255, 255, 0); // 黄色い四角で代用
        rect(x, y, w, h);
      }
    }
  }

  // ゲームリセット
  void resetGame() {
    if (reachedCheckpoint) {
      playerX = checkpointX;
      playerY = checkpointY;
    } else {
      playerX = -90;
      playerY = height - 100;
    }
    velocityX = 0;
    velocityY = 0;
    knockbackX = 0;
    knockbackY = 0;
    currentHP = 100;
    totalTimeMillis = 5 * 60 * 1000;
    invincible = false;
    invincibleTimer = 0;
    gameOver = false;
    gameOverTimer = 0;
    deathAnimationPlaying = false;
    deathAnimationTimer = 0;
   enemies.clear();
  enemies.add(new Enemy(1500, height - 100, 40, 60, enemyTexture));
    healed = false; // 回復状態を初期化
    items.clear();
    items.add(new Item(630, height - 270, 30, 30, itemTexture));
    items.add(new Item(1880, height - 350, 30, 30, itemTexture));
    items.add(new Item(4700, height - 400, 30, 30, itemTexture));
    collectedItems.clear();
    startTime = millis();  // ゲームリセット時にも時間をリセット
  }

  //サウンド停止
  void stop() {
    if (bgm != null) {
      bgm.close();
    }
    jumpSound.close();
    damageSound.close();
    enterSound.close();
    itemgetSound.close();
    lifeitemgetSound.close();
    attackSound.close();
    runSound.close();
    missattackSound.close();
    gameoverSound.close();
    bossbattleBGM.close();
    minim.stop();
    super.stop();
  }
