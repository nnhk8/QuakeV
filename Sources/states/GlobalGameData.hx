package states;

import com.gEngine.display.StaticLayer;
import com.collision.platformer.CollisionGroup;
import paths.Path;
import gameObjects.Player;
import com.gEngine.display.Layer;

class GlobalGameData {
	public static var simulationLayer:Layer;
	public static var staticLayer:StaticLayer;
	public static var player:Player;
	public static var winState:Bool;

	public static var sawCollisions:CollisionGroup;
	public static var enemyCollisions:CollisionGroup;
	public static var flyPowerUpCollisions:CollisionGroup;
	public static var ghostBulletsCollisions:CollisionGroup;

	public static var ghostBullets:Bool = false;
	public static var ghostBulletsTime:Float = 0;
	public static var ghostBulletsTimeMax:Float = 20;

	static public function destroy() {
		simulationLayer = null;
		player = null;
		winState = true;
		sawCollisions = null;
		flyPowerUpCollisions = null;
		ghostBulletsCollisions = null;
		staticLayer=null;
	}
}
