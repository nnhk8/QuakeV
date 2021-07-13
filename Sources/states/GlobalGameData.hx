package states;

import com.collision.platformer.CollisionGroup;
import paths.Path;
import gameObjects.Player;
import com.gEngine.display.Layer;

class GlobalGameData {
	public static var simulationLayer:Layer;
	public static var player:Player;
	public static var winState:Bool;

	public static var levelPath:Path;
	public static var sawCollisions:CollisionGroup;
	public static var enemyCollisions:CollisionGroup;
	

	static public function destroy() {
		simulationLayer = null;
		player=null;
		winState=true;
		levelPath = null;
		sawCollisions = null;
	}
	
}
