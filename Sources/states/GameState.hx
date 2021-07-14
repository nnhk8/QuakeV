package states;

import paths.PathWalker.PlayMode;
import com.soundLib.SoundManager;
import com.loading.basicResources.SoundLoader;
import kha.Color;
import com.gEngine.helpers.Screen;
import com.gEngine.display.Text;
import com.loading.basicResources.FontLoader;
import com.gEngine.display.StaticLayer;
import gameObjects.GhostBulletPowerUp;
import js.lib.webassembly.Global;
import gameObjects.FlyPowerUp;
import gameObjects.Saw;
import kha.math.FastVector2;
import com.loading.basicResources.SparrowLoader;
import gameObjects.Zones;
import gameObjects.LevelPositions;
import gameObjects.Bullet;
import gameObjects.Ghost;
import com.collision.platformer.ICollider;
import com.collision.platformer.CollisionGroup;
import com.gEngine.display.Sprite;
import format.tmx.Data.TmxTileLayer;
import com.collision.platformer.CollisionBox;
import com.gEngine.display.extra.TileMapDisplay;
import com.collision.platformer.Sides;
import com.framework.utils.XboxJoystick;
import com.framework.utils.VirtualGamepad;
import format.tmx.Data.TmxObject;
import kha.input.KeyCode;
import com.framework.utils.Input;
import com.collision.platformer.CollisionEngine;
import gameObjects.Player;
import com.loading.basicResources.TilesheetLoader;
import com.loading.basicResources.SpriteSheetLoader;
import com.gEngine.display.Layer;
import com.loading.basicResources.DataLoader;
import com.collision.platformer.Tilemap;
import com.loading.basicResources.JoinAtlas;
import com.loading.Resources;
import com.framework.utils.State;

class GameState extends State {
	var worldMap:Tilemap;
	var player:Player;
	var simulationLayer:Layer;
	var staticLayer:StaticLayer;
	var touchJoystick:VirtualGamepad;
	var winZone:CollisionBox;
	var spawnZones:CollisionGroup = new CollisionGroup();
	var deathZones:CollisionGroup = new CollisionGroup();

	var room:Int;

	var lifeText:Text;
	var levelText:Text;
	var flyPowerUpText:Text;
	var ghostBulletPowerUpText:Text;

	var enemyCollision:CollisionGroup = new CollisionGroup();
	var sawCollisions:CollisionGroup = new CollisionGroup();
	var flyPowerUpCollisions:CollisionGroup = new CollisionGroup();
	var ghostBulletsCollisions:CollisionGroup = new CollisionGroup();

	public function new(room:Int) {
		this.room = room;
		super();
	}

	override function load(resources:Resources) {
		resources.add(new DataLoader("lvl" + room + "_tmx"));
		var atlas = new JoinAtlas(2048, 2048);

		atlas.add(new TilesheetLoader("tiles2", 32, 32, 0));
		atlas.add(new SpriteSheetLoader("hero", 45, 60, 0, [
			new Sequence("fall", [0]),
			new Sequence("slide", [0]),
			new Sequence("jump", [1]),
			new Sequence("run", [2, 3, 4, 5, 6, 7, 8, 9]),
			new Sequence("idle", [10]),
			new Sequence("wallGrab", [11])
		]));

		atlas.add(new SpriteSheetLoader("flying", 32, 32, 0, [new Sequence("fly", [0, 1, 2, 3, 4, 5, 6, 7, 8])]));

		atlas.add(new SpriteSheetLoader("ghostBullet", 52, 54, 0, [new Sequence("ghostBullet", [0, 1, 2, 3, 4, 5, 6, 7])]));

		atlas.add(new SpriteSheetLoader("ghost", 44, 30, 0, [
			new Sequence("idle", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]),
			new Sequence("appear", [15, 16, 17, 18]),
			new Sequence("desappear", [19, 20, 21, 22])
		]));

		atlas.add(new SpriteSheetLoader("explosion", 51, 64, 0, [
			new Sequence("bullet", [0]),
			new Sequence("boom", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17])
		]));
		atlas.add(new SpriteSheetLoader("chain", 38, 38, 0, [new Sequence("spin", [0, 1, 2, 3, 4, 5, 6, 7])]));

		atlas.add(new FontLoader("Kenney_Thick", 20));

		resources.add(atlas);
		resources.add(new SoundLoader("sound1", false));
		resources.add(new SoundLoader("sound2", false));
		resources.add(new SoundLoader("sound3", false));
	}

	override function init() {
		stageColor(0.5, .5, 0.5);
		GlobalGameData.sawCollisions = this.sawCollisions;
		GlobalGameData.flyPowerUpCollisions = this.flyPowerUpCollisions;
		GlobalGameData.ghostBulletsCollisions = this.ghostBulletsCollisions;
		simulationLayer = new Layer();
		staticLayer = new StaticLayer();
		stage.addChild(simulationLayer);
		stage.addChild(staticLayer);
		GlobalGameData.staticLayer = staticLayer;
		GlobalGameData.simulationLayer = simulationLayer;
		worldMap = new Tilemap("lvl" + room + "_tmx");

		worldMap.init(parseTileLayers, parseMapObjects);
		stage.defaultCamera().limits(32, 0, worldMap.widthIntTiles * 32, worldMap.heightInTiles * 32);
		createTouchJoystick();
		this.buildLevel();

		
		lifeText = new Text("Kenney_Thick");
		lifeText.smooth = false;
		lifeText.x = Screen.getWidth() * 0.1;
		lifeText.y = Screen.getHeight() * 0.1;
		lifeText.text = "Lifes "+GlobalGameData.playerLifes;
		lifeText.set_color(Color.Red);
		staticLayer.addChild(lifeText);

		levelText = new Text("Kenney_Thick");
		levelText.smooth = false;
		levelText.x = Screen.getWidth() * 0.9;
		levelText.y = Screen.getHeight() * 0.1;
		levelText.text = "Level "+room;
		levelText.set_color(Color.Blue);
		staticLayer.addChild(levelText);

		flyPowerUpText = new Text("Kenney_Thick");
		flyPowerUpText.smooth = false;
		flyPowerUpText.x = Screen.getWidth() * 0.01;
		flyPowerUpText.y = Screen.getHeight() * 0.94;
		flyPowerUpText.text = "Fly PowerUp ";
		flyPowerUpText.set_color(Color.Green);
		staticLayer.addChild(flyPowerUpText);

		ghostBulletPowerUpText = new Text("Kenney_Thick");
		ghostBulletPowerUpText.smooth = false;
		ghostBulletPowerUpText.x = Screen.getWidth() * 0.01;
		ghostBulletPowerUpText.y = Screen.getHeight() * 0.97;
		ghostBulletPowerUpText.text = "Ghost Bullet Damage PowerUp ";
		ghostBulletPowerUpText.set_color(Color.Green);
		staticLayer.addChild(ghostBulletPowerUpText);
	}

	function parseTileLayers(layerTilemap:Tilemap, tileLayer:TmxTileLayer) {
		if (!tileLayer.properties.exists("noCollision")) {
			layerTilemap.createCollisions(tileLayer);
		}
		simulationLayer.addChild(layerTilemap.createDisplay(tileLayer, new Sprite("tiles2")));
	}

	function parseMapObjects(layerTilemap:Tilemap, object:TmxObject) {
		if (compareName(object, "playerPosition")) {
			if (player == null) {
				player = new Player(object.x, object.y, simulationLayer);
				addChild(player);
				GlobalGameData.player = player;
				GlobalGameData.playerLifes=3;
			}
		} else if (compareName(object, "winZone")) {
			winZone = new CollisionBox();
			winZone.x = object.x;
			winZone.y = object.y;
			winZone.width = object.width;
			winZone.height = object.height;
		} else if (compareName(object, "flyPowerUp")) {
			new FlyPowerUp(object.x, object.y);
		} else if (compareName(object, "ghostPowerUp")) {
			new GhostBulletPowerUp(object.x, object.y);
		} else if (compareName(object, "spawnZone")) {
			new Zones(object, this.spawnZones);
		} else if (compareName(object, "deathZone")) {
			new Zones(object, this.deathZones);
		}
	}

	inline function compareName(object:TmxObject, name:String) {
		return object.name.toLowerCase() == name.toLowerCase();
	}

	override function update(dt:Float) {
		super.update(dt);
		lifeText.text = "Lifes "+GlobalGameData.playerLifes;
		flyPowerUpText.text = "Fly PowerUp "+Std.string(player.flyTime).charAt(0)+ " of " + player.flyTimeMax;
		ghostBulletPowerUpText.text = "Ghost Bullet Damage PowerUp "+Std.string(GlobalGameData.ghostBulletsTime).charAt(0) + " of " + GlobalGameData.ghostBulletsTimeMax;

		if (GlobalGameData.ghostBullets) {
			GlobalGameData.ghostBulletsTime += dt;
			if (GlobalGameData.ghostBulletsTime > GlobalGameData.ghostBulletsTimeMax) {
				GlobalGameData.ghostBulletsTime = 0;
				GlobalGameData.ghostBullets = false;
			}
		}

		stage.defaultCamera().setTarget(player.collision.x, player.collision.y);

		CollisionEngine.collide(player.collision, worldMap.collision);
		if (CollisionEngine.overlap(player.collision, winZone)) {
			room++;
			if (room == 4) {
				changeState(new EndGame(8, room, true));
			} else {
				changeState(new GameState(room));
			}
		}
		CollisionEngine.overlap(player.collision, spawnZones, playerVsSpawnZone);
		CollisionEngine.overlap(player.collision, deathZones, playerVsDeathZone);

		CollisionEngine.overlap(worldMap.collision, player.bulletsCollision, bulletVsWorld);
		CollisionEngine.overlap(player.collision, enemyCollision, playerVsGhost);
		CollisionEngine.overlap(player.bulletsCollision, enemyCollision, bulletVsGhost);
		CollisionEngine.overlap(player.collision, sawCollisions, playerVsSaw);

		CollisionEngine.overlap(player.collision, flyPowerUpCollisions, playerVsFlyPowerUp);
		CollisionEngine.overlap(player.collision, ghostBulletsCollisions, playerVsGhostBulletPowerUp);
	}

	function playerVsGhost(playerC:ICollider, ghostC:ICollider) {
		GlobalGameData.playerLifes--;
		if (GlobalGameData.playerLifes < 1) {
			changeState(new EndGame(8, room));
		} else {
			var enemey:Ghost = ghostC.userData;
			enemey.damage();
		}
	}

	function playerVsSaw(playerC:ICollider, sawC:ICollider) {
		var saw:Saw = sawC.userData;
		if (saw.damage){
			GlobalGameData.playerLifes--;
			if (GlobalGameData.playerLifes < 1) {
				changeState(new EndGame(8, room));
			} else {
				saw.noDamage();
			}
		}
	}

	function playerVsSpawnZone(playerC:ICollider, spawnZoneC:ICollider) {
		var spawnPositions = LevelPositions.getSpawnPoints();
		for (pos in spawnPositions) {
			addChild(new Ghost(pos.x, pos.y, this.enemyCollision));
		}
		var zone:Zones = spawnZoneC.userData;
		zone.destroy();
	}

	function playerVsDeathZone(playerC:ICollider, spawnZoneC:ICollider) {
		changeState(new EndGame(8, room));
	}

	function playerVsFlyPowerUp(playerC:ICollider, flyPowerUpC:ICollider) {
		player.activateFly();
		var fly:FlyPowerUp = cast flyPowerUpC.userData;
		fly.destroy();
	}

	function playerVsGhostBulletPowerUp(playerC:ICollider, ghostBulletPowerUpC:ICollider) {
		GlobalGameData.ghostBullets = true;
		var ghostBullet:GhostBulletPowerUp = cast ghostBulletPowerUpC.userData;
		ghostBullet.destroy();
	}

	function bulletVsGhost(bulletC:ICollider, ghostC:ICollider) {
		var enemey:Ghost = ghostC.userData;
		enemey.damage();
		var bullet:Bullet = cast bulletC.userData;
		bullet.die();
	}

	function bulletVsWorld(worldMapC:ICollider, bulletC:ICollider) {
		if (!GlobalGameData.ghostBullets) {
			var bullet:Bullet = cast bulletC.userData;
			bullet.damage();
		}
	}

	function createTouchJoystick() {
		touchJoystick = new VirtualGamepad();
		touchJoystick.addKeyButton(XboxJoystick.LEFT_DPAD, KeyCode.Left);
		touchJoystick.addKeyButton(XboxJoystick.RIGHT_DPAD, KeyCode.Right);
		touchJoystick.addKeyButton(XboxJoystick.UP_DPAD, KeyCode.Up);
		touchJoystick.addKeyButton(XboxJoystick.DOWN_DPAD, KeyCode.Down);
		touchJoystick.addKeyButton(XboxJoystick.A, KeyCode.Space);
		touchJoystick.addKeyButton(XboxJoystick.X, KeyCode.X);

		touchJoystick.notify(player.onAxisChange, player.onButtonChange);

		var gamepad = Input.i.getGamepad(0);
		gamepad.notify(player.onAxisChange, player.onButtonChange);
	}

	#if DEBUGDRAW
	override function draw(framebuffer:kha.Canvas) {
		super.draw(framebuffer);
		var camera = stage.defaultCamera();
		CollisionEngine.renderDebug(framebuffer, camera);
	}
	#end

	override function destroy() {
		super.destroy();
		GlobalGameData.destroy();
	}

	private function buildLevel() {
		switch (room) {
			case 1:
				var a = new FastVector2(1230, 332);
				var b = new FastVector2(1555, 332);
				var c = new FastVector2(1555, 500);
				var d = new FastVector2(1230, 500);
				var saw1 = new Saw(LevelPositions.getRectangularPath(a, b, c, d), 10, PlayMode.Loop);
				addChild(saw1);
				var saw2 = new Saw(LevelPositions.getRectangularPath(c, d, a, b), 10, PlayMode.Loop);
				addChild(saw2);
				SoundManager.playMusic("sound1");
			case 2:
				SoundManager.playMusic("sound2");
			case 3:
				SoundManager.playMusic("sound3");

				var beginLong = new FastVector2(325, 645);
				var endLong = new FastVector2(1780, 645);

				var bottom = 720;
				var top = 540;
				var a = new FastVector2(515, top);
				var b = new FastVector2(515, bottom);

				var c = new FastVector2(772, bottom);
				var d = new FastVector2(772, top);

				var e = new FastVector2(995, top);
				var f = new FastVector2(995, bottom);

				var g = new FastVector2(1220, bottom);
				var h = new FastVector2(1220, top);

				var left = 1545;
				var right = 1780;
				var i = new FastVector2(left, 455);
				var j = new FastVector2(right, 455);
				var k = new FastVector2(right, 298);
				var l = new FastVector2(left, 298);
				var m = new FastVector2(left, 171);
				var n = new FastVector2(right, 171);

				var saw1 = new Saw(LevelPositions.getLinearPath(beginLong, endLong), 10, PlayMode.Loop);
				addChild(saw1);
				var saw2 = new Saw(LevelPositions.getLinearPath(a, b), 5, PlayMode.Pong);
				addChild(saw2);
				var saw3 = new Saw(LevelPositions.getLinearPath(c, d), 5, PlayMode.Pong);
				addChild(saw3);
				var saw4 = new Saw(LevelPositions.getLinearPath(e, f), 5, PlayMode.Pong);
				addChild(saw4);
				var saw5 = new Saw(LevelPositions.getLinearPath(g, h), 5, PlayMode.Pong);
				addChild(saw5);
				var saw6 = new Saw(LevelPositions.getLinearPath(i, j), 5, PlayMode.Pong);
				addChild(saw6);
				var saw7 = new Saw(LevelPositions.getLinearPath(k, l), 5, PlayMode.Pong);
				addChild(saw7);
				var saw8 = new Saw(LevelPositions.getLinearPath(m, n), 5, PlayMode.Pong);
				addChild(saw8);
		}
	}
}
