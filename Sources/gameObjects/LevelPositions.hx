package gameObjects;

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
	
	public static function getLevelPathPoints():Array<FastVector2>
	{
		var vPoints:Array<FastVector2> = new Array<FastVector2>();
		vPoints.push(new FastVector2(696, 208));
		vPoints.push(new FastVector2(641, 209));
		vPoints.push(new FastVector2(580, 209));
		vPoints.push(new FastVector2(533, 205));
		vPoints.push(new FastVector2(515, 189));
		vPoints.push(new FastVector2(501, 143));
		vPoints.push(new FastVector2(492, 109));
		vPoints.push(new FastVector2(464, 92));
		vPoints.push(new FastVector2(412, 91));
		vPoints.push(new FastVector2(382, 107));
		vPoints.push(new FastVector2(370, 137));
		vPoints.push(new FastVector2(365, 170));
		vPoints.push(new FastVector2(352, 199));
		vPoints.push(new FastVector2(312, 210));
		vPoints.push(new FastVector2(266, 219));
		vPoints.push(new FastVector2(225, 221));
		vPoints.push(new FastVector2(183, 245));
		vPoints.push(new FastVector2(173, 276));
		vPoints.push(new FastVector2(186, 315));
		vPoints.push(new FastVector2(227, 332));
		vPoints.push(new FastVector2(293, 328));
		vPoints.push(new FastVector2(350, 318));
		vPoints.push(new FastVector2(415, 323));
		vPoints.push(new FastVector2(453, 352));
		vPoints.push(new FastVector2(449, 397));
		vPoints.push(new FastVector2(417, 424));
		vPoints.push(new FastVector2(360, 436));
		vPoints.push(new FastVector2(319, 458));
		vPoints.push(new FastVector2(309, 493));
		vPoints.push(new FastVector2(310, 630));
		
		return vPoints;
	}
}
