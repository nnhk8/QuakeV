package paths;

import kha.math.FastVector2;

class Complex implements Path {
	private var paths:Array<Path>;
	private var length:Float = 0;

	public function new(paths:Array<Path>) {
		this.paths = paths;
		for (path in paths) {
			length += path.getLength();
		}
	}

	public function getPos(s:Float):FastVector2 {
		var targetLegth = getLength() * s;
		var currentLegnth = 0.0;
		for (path in paths) {
			if (path.getLength() + currentLegnth >= targetLegth) {
                return path.getPos((targetLegth-currentLegnth)/path.getLength());
            } 
            else {
				currentLegnth += path.getLength();
			}
		}
		return null;
	}

	public function getLength():Float {
		return length;
	}
}
