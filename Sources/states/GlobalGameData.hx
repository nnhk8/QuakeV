package states;

import gameObjects.Player;
import com.gEngine.display.Layer;

class GlobalGameData {
	public static var simulationLayer:Layer;
	public static var player:Player;
	public static var winState:Bool;

	static public function destroy() {
		simulationLayer = null;
		player=null;
		winState=true;
	}

	
}
