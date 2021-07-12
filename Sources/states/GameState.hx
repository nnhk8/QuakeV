package states;

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
import gameObjects.ChivitoBoy;
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
	var chivito:ChivitoBoy;
	var simulationLayer:Layer;
	var touchJoystick:VirtualGamepad;
	var room:Int;
	var winZone:CollisionBox;
	var spawnZones:CollisionGroup=new CollisionGroup();

	var enemyCollision:CollisionGroup = new CollisionGroup();

	public function new(room:Int) {
		super();
		if (room == null || room > 3) {
			room = 1;
		}
		this.room = room;
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

		atlas.add(new SpriteSheetLoader("ghost", 44, 30, 0, [
			new Sequence("idle", [0,1,2,3,4,5,6,7,8,9]),
			new Sequence("appear",[15,16,17,18]),
			new Sequence("desappear",[19,20,21,22])
			]));
			
		atlas.add(new SpriteSheetLoader("explosion", 52, 65, 0, [
			new Sequence("bullet", [0]),
			new Sequence("boom",[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18])
			]));

		
		resources.add(atlas);
	}

	override function init() {
		stageColor(0.5, .5, 0.5);

		simulationLayer = new Layer();
		stage.addChild(simulationLayer);
		GlobalGameData.simulationLayer = simulationLayer;

		worldMap = new Tilemap("lvl" + room + "_tmx");
		worldMap.init(parseTileLayers, parseMapObjects);
		var ghost = new Ghost(300, 300, enemyCollision);
		addChild(ghost);

		stage.defaultCamera().limits(32 * 2, 0, worldMap.widthIntTiles * 32, worldMap.heightInTiles * 32);
		createTouchJoystick();
	}

	function parseTileLayers(layerTilemap:Tilemap, tileLayer:TmxTileLayer) {
		if (!tileLayer.properties.exists("noCollision")) {
			layerTilemap.createCollisions(tileLayer);
		}
		simulationLayer.addChild(layerTilemap.createDisplay(tileLayer, new Sprite("tiles2")));
	}

	function parseMapObjects(layerTilemap:Tilemap, object:TmxObject) {
		if (compareName(object, "playerPosition")) {
			if (chivito == null) {
				chivito = new ChivitoBoy(object.x, object.y, simulationLayer);
				addChild(chivito);
				GlobalGameData.chivito = chivito;
			}
		} else if (compareName(object, "winZone")) {
			winZone = new CollisionBox();
			winZone.x = object.x;
			winZone.y = object.y;
			winZone.width = object.width;
			winZone.height = object.height;
		} else if (compareName(object, "powerFlower")) {
			var sprite = new Sprite("tiles2");
			sprite.x = object.x;
			sprite.y = object.y - object.height;
			sprite.timeline.gotoAndStop(1);
			stage.addChild(sprite);
		} else if (compareName(object, "spawnZone")) {
			new Zones(object,this.spawnZones);
		}
	}

	inline function compareName(object:TmxObject, name:String) {
		return object.name.toLowerCase() == name.toLowerCase();
	}

	override function update(dt:Float) {
		super.update(dt);

		stage.defaultCamera().setTarget(chivito.collision.x, chivito.collision.y);

		CollisionEngine.collide(chivito.collision, worldMap.collision);
		if (CollisionEngine.overlap(chivito.collision, winZone)) {
			changeState(new GameState(++room));
		}
		CollisionEngine.overlap(chivito.bulletsCollision, worldMap.collision, bulletVsWorld);
		CollisionEngine.overlap(chivito.collision, spawnZones, playerVsSpawnZone);
		CollisionEngine.overlap(chivito.collision, enemyCollision, playerVsGhost);
		CollisionEngine.overlap(chivito.bulletsCollision, enemyCollision, bulletVsGhost);
	}

	function playerVsGhost(playerC:ICollider, ghostC:ICollider) {
		changeState(new EndGame(8));
	}

	function playerVsSpawnZone(playerC:ICollider, spawnZoneC:ICollider) {
		var spawnPositions = LevelPositions.getSpawnPoints();
		for (pos in spawnPositions) {
			addChild(new Ghost(pos.x, pos.y, this.enemyCollision));
		}
		var zone:Zones = spawnZoneC.userData;
		zone.destroy();
	}

	function bulletVsGhost(bulletC:ICollider, ghostC:ICollider) {
		var enemey:Ghost = ghostC.userData;
		enemey.damage();
		var bullet:Bullet = cast bulletC.userData;
		bullet.die();
	}


	function bulletVsWorld(bulletC:ICollider, worldMapC:ICollider) {
		var bullet:Bullet = cast bulletC.userData;
		bullet.die();
	}

	function createTouchJoystick() {
		touchJoystick = new VirtualGamepad();
		touchJoystick.addKeyButton(XboxJoystick.LEFT_DPAD, KeyCode.Left);
		touchJoystick.addKeyButton(XboxJoystick.RIGHT_DPAD, KeyCode.Right);
		touchJoystick.addKeyButton(XboxJoystick.UP_DPAD, KeyCode.Up);
		touchJoystick.addKeyButton(XboxJoystick.DOWN_DPAD, KeyCode.Down);
		touchJoystick.addKeyButton(XboxJoystick.A, KeyCode.Space);
		touchJoystick.addKeyButton(XboxJoystick.X, KeyCode.X);

		touchJoystick.notify(chivito.onAxisChange, chivito.onButtonChange);

		var gamepad = Input.i.getGamepad(0);
		gamepad.notify(chivito.onAxisChange, chivito.onButtonChange);
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
}
