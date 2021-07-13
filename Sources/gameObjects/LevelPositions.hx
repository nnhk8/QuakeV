package gameObjects;

import paths.Path;
import states.GlobalGameData;
import paths.Linear;
import paths.Complex;
import kha.math.FastVector2;

class LevelPositions
{
	public static function getSpawnPoints():Array<FastVector2>
	{
		var spawnPosList:Array<FastVector2> = new Array<FastVector2>();
		spawnPosList.push(new FastVector2(0, 0));
		spawnPosList.push(new FastVector2(1280, 0));
		spawnPosList.push(new FastVector2(0, 1280));
		spawnPosList.push(new FastVector2(1280, 715));
		
		return spawnPosList;
	}
	
	public static function getRectangularPath(a:FastVector2,b:FastVector2,c:FastVector2,d:FastVector2):Path
	{
		var path1 = new Linear(a,b);
        var path2 = new Linear(b,c);
		var path3 = new Linear(c,d);
		var path4 = new Linear(d,a);
		var complexPath=new Complex([path1,path2,path3,path4]);
			
		return complexPath;
	}
}
