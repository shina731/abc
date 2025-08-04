// プレイヤー変数
float playerX = 100;
float playerY = 0;
float playerW = 40;
float playerH = 60;
float velocityX = 0;
float velocityY = 0;
float gravity = 0.8;
float jumpPower = -15;
float highJumpPower = -25;
boolean onGround = false;
float knockbackX = 0;
float knockbackY = 0;
boolean playerFacingRight = true;

boolean isAttacking = false;
int attackDuration = 10;  // 攻撃の持続時間（フレーム数）
int attackTimer = 0;

// スクロール
float cameraX = 0;

// キー状態管理
boolean leftPressed = false;
boolean rightPressed = false;
boolean shiftPressed = false;

// ゲーム状態
boolean gameStarted = false;
boolean gameOver = false;
int gameOverTimer = 0;
int timeLimit = 60 * 30; // 30秒（60フレーム × 秒数）
boolean deathAnimationPlaying = false;
int deathAnimationTimer = 0;

// 地面とブロック
ArrayList<Platform> platforms;

// 敵（動かない1体）
Enemy enemy;
PImage enemyTexture;  // 敵画像をグローバルで保持

PImage playerTexture;

PImage bg;

// ライフ管理
int life = 3;
boolean invincible = false;
int invincibleTimer = 0;

//サウンド
import ddf.minim.*;
Minim minim;
AudioPlayer footSound;

float healX = 800;  // 回復ポイントの位置（X座標）
float healY = height - 100; // Y座標（地面の上）
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
  platforms = new ArrayList<Platform>();
  bg=loadImage("haikei.png");
 
  itemTexture = loadImage("item.png"); // dataフォルダに item.png を置く（任意）

  items = new ArrayList<Item>();
  collectedItems = new ArrayList<Item>();

  // 空中にアイテムを設置
  items.add(new Item(420, height - 160, 30, 30, itemTexture));
  items.add(new Item(610, height - 220, 30, 30, itemTexture));

  // 地面
  for (int i = 0; i < 50; i++) {
    platforms.add(new Platform(i * 80, height - 40, 80, 40));
  }

  // 空中ブロック
  platforms.add(new Platform(400, height - 120, 80, 20));
  platforms.add(new Platform(600, height - 180, 80, 20));
  platforms.add(new Platform(900, height - 150, 80, 20));

  // 敵初期化（画像渡す）
  enemy = new Enemy(500, height - 100, 40, 60, enemyTexture);

   //日本語対応_字体「メイリオ」
  PFont font = createFont("Meiryo", 50);
  textFont(font);
  
  //サウンドsetup
  minim = new Minim(this);
  footSound = minim.loadFile("ニュッ2.mp3");
}

void draw() {
  background(0); // 空色

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

  // 重力
  velocityY += gravity;

  // ノックバック加算
  playerX += velocityX + knockbackX;
  playerY += velocityY + knockbackY;

  // ノックバック減衰
  knockbackX *= 0.9;
  knockbackY *= 0.9;
  
  // 落下によるゲームオーバー
  if (playerY > height + 100 && !deathAnimationPlaying && !gameOver) {
    life = 0;
    deathAnimationPlaying = true;
    deathAnimationTimer = 10;
  }
  
  // 時間切れによるゲームオーバー
  timeLimit--;
  if (timeLimit <= 0 && !deathAnimationPlaying && !gameOver) {
    life = 0;
    deathAnimationPlaying = true;
    deathAnimationTimer = 10;
  }

  onGround = false;

  // 足場との判定
  for (Platform p : platforms) {
    if (velocityY >= 0 &&
        playerX + playerW > p.x &&
        playerX < p.x + p.w &&
        playerY + playerH > p.y &&
        playerY + playerH < p.y + p.h + 10) {
      playerY = p.y - playerH;
      velocityY = 0;
      knockbackY = 0;
      onGround = true;
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

  // 敵との衝突（ダメージ）
   enemy.update();
  
  if (!invincible &&
      playerX + playerW > enemy.x &&
      playerX < enemy.x + enemy.w &&
      playerY + playerH > enemy.y &&
      playerY < enemy.y + enemy.h) {

    life--;
    invincible = true;
    invincibleTimer = 60;

    // ノックバック（敵の反対方向へ）
    if (playerX + playerW / 2 < enemy.x + enemy.w / 2) {
      knockbackX = -7;
    } else {
      knockbackX = 7;
    }
    knockbackY = -5;

    println("ダメージ！ ライフ：" + life);

    if (life <= 0) {
      deathAnimationPlaying = true;
      deathAnimationTimer = 60; // 余韻
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

  life = 3;        // ライフ全回復
  healed = true;   // 一度だけ回復
  println("ライフが全回復した！");
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
    }
  }

  // 敵との通り抜け防止（押し戻し）
  if (playerX + playerW > enemy.x &&
      playerX < enemy.x + enemy.w &&
      playerY + playerH > enemy.y &&
      playerY < enemy.y + enemy.h) {

    float overlapLeft = (playerX + playerW) - enemy.x;
    float overlapRight = (enemy.x + enemy.w) - playerX;
    float overlapTop = (playerY + playerH) - enemy.y;
    float overlapBottom = (enemy.y + enemy.h) - playerY;

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

  // カメラ位置
  cameraX = playerX - width / 2;

  // 描画
  pushMatrix();
  translate(-cameraX, 0);

  // プレイヤー描画（点滅）
  if (!invincible || (invincibleTimer / 5) % 2 == 0) {
    if (playerTexture != null) {
      pushMatrix();
      // 左向きなら反転表示
      if (!playerFacingRight) {
        translate(playerX + playerW, playerY);
        scale(-1, 1);
        image(playerTexture, 0, 0, playerW, playerH);
      } else {
       image(playerTexture, playerX, playerY, playerW, playerH);
      }
    popMatrix();
    } else {
      fill(255, 0, 0);
      rect(playerX, playerY, playerW, playerH);
    }
  }

  // クワ（攻撃）ヒットボックス
  if (isAttacking) {
    attackTimer--;
    if (attackTimer <= 0) {
      isAttacking = false;
    }

    float axeX, axeY, axeW, axeH;
    axeW = 20;
    axeH = 40;
    axeY = playerY + playerH / 2 - axeH / 2;

    if (playerFacingRight) {
      axeX = playerX + playerW;
    } else {
      axeX = playerX - axeW;
    }

    // 攻撃描画（見た目用）
    fill(255, 255, 0);
    rect(axeX, axeY, axeW, axeH);

    // 敵に当たったか判定
    if (axeX + axeW > enemy.x &&
        axeX < enemy.x + enemy.w &&
        axeY + axeH > enemy.y &&
        axeY < enemy.y + enemy.h) {
      enemy.charging = false;  // 攻撃キャンセル！
      enemy.chargeCooldown = 60;
      enemy.pauseTimer = 30;
      println("攻撃成功！");
    }
  }

  // 足場描画
  for (Platform p : platforms) {
    p.display();
  }

  // 敵描画
  enemy.display();
  
  popMatrix();

  // アイテム描画
  for (Item item : items) {
    item.display();
  }

  // 回復ポイント描画
  fill(0, 255, 0); // 緑色
  rect(healX, healY, healW, healH);
  popMatrix();

    // ライフ表示
  fill(0);
  textSize(20);
  textAlign(RIGHT, TOP);
  text("Time: " + nf(timeLimit / 60, 2) + "s", width - 10, 10);

  for (int i = 0; i < life; i++) {
    fill(255, 0, 0);
    rect(10 + i * 30, 10, 20, 20);
  }
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
}

// 入力処理
void keyPressed() {
  if (!gameStarted && keyCode == ENTER) {
    gameStarted = true;
    return;
  }

  if (gameOver && gameOverTimer <= 0 && keyCode == ENTER) {
    resetGame();
    return;
  }

  if (key == 'a' || key == 'A') {
    leftPressed = true;
    playerFacingRight = true;  // ← 左向きにセット
  }
  if (key == 'd' || key == 'D') {
    rightPressed = true;
    playerFacingRight = false;   // ← 右向きにセット
  }
  if (key == CODED && keyCode == SHIFT) {
    shiftPressed = true;
  }
  if (key == 'k' || key == 'K') {
    isAttacking = true;
    attackTimer = attackDuration;
    playerFacingRight = true;
  }

  if (key == 'h' || key == 'H') {
    isAttacking = true;
    attackTimer = attackDuration;
    playerFacingRight = false;
  }

  if (key == 'h' || key == 'H') {
    // クワを左に出す
    float axeX = playerX - 20; // ←左に出す
    float axeY = playerY + playerH / 2 - 10;
    float axeW = 20;
    float axeH = 20;
  if (enemy != null &&
      axeX < enemy.x + enemy.w &&
      axeX + axeW > enemy.x &&
      axeY < enemy.y + enemy.h &&
      axeY + axeH > enemy.y) {
      println("敵に左から攻撃成功！");
      // 攻撃が成功 → 敵のダメージ無効 or 敵を倒す処理
  }
}
  
  if (key == ' ') {
    footSound.rewind();
    footSound.play();
    if (onGround) {
      velocityY = shiftPressed ? highJumpPower : jumpPower;
      onGround = false;
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
  float speed = 3;
  float detectRange = 200;
  boolean charging = false;
  int chargeCooldown = 0;
  int pauseTimer = 0;
  int direction = -1;
  PImage texture;
  
  int chasingTimer = 0;           // 追跡中の経過フレーム数
  final int maxChasingTime = 50;  // 追跡最大時間（60フレーム＝約1秒)

  Enemy(float x, float y, float w, float h, PImage texture) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.texture = texture;
  }
  
  void update() {
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
      // プレイヤーの左右どちらにいても追跡開始
      charging = true;
      chasingTimer = 0;

      // プレイヤーの方向を向いて突進
      direction = (pxCenter > exCenter) ? 1 : -1;
    }


    if (charging) {
      chasingTimer++;
      x += direction * speed * 2;

      if (abs(pxCenter - exCenter) < 10) {
        // プレイヤーに追いついた場合
        charging = false;
        pauseTimer = 30;
        direction *= -1;
        chargeCooldown = 60;
      } else if (chasingTimer > maxChasingTime) {
        // 1秒追いつけなかった場合追跡終了
        charging = false;
        pauseTimer = 30;
        chargeCooldown = 60;
      }
    }
  }
  
  void display() {
    if (texture != null) {
      pushMatrix();
      translate(x + w / 2, y);
      scale(direction, 1);
      image(texture, -w/2, 0, w, h);
    } else {
      fill(0, 0, 255);
      rect(x, y, w, h);
    }
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
  playerX = 100;
  playerY = height - 100;
  velocityX = 0;
  velocityY = 0;
  knockbackX = 0;
  knockbackY = 0;
  life = 3;
  timeLimit = 60 * 30;
  invincible = false;
  invincibleTimer = 0;
  gameOver = false;
  gameOverTimer = 0;
  deathAnimationPlaying = false;
  deathAnimationTimer = 0;
  
 healed = false; // 回復状態を初期化
  
  items.clear();
  collectedItems.clear();
  items.add(new Item(425, height - 150, 30, 30, itemTexture));
  items.add(new Item(700, height - 250, 30, 30, itemTexture));
}
