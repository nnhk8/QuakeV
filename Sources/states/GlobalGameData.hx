package states;

import gameObjects.ChivitoBoy;
import com.gEngine.display.Layer;

class GlobalGameData {
	public static var simulationLayer:Layer;
	public static var chivito:ChivitoBoy;
	public static var winState:Bool;

	static public function destroy() {
		simulationLayer = null;
		chivito=null;
		winState=true;
	}

	
}
