package paths;

import kha.math.FastVector2;

class Linear implements Path {
	var start:FastVector2;
	var end:FastVector2;

	var temp:FastVector2;

	public function new(start:FastVector2, end:FastVector2) {
		this.start = start;
		this.end = end;
		temp = new FastVector2();
	}

	public function getPos(s:Float):FastVector2 {
		var result = start.add(end.sub(start).mult(s));
		temp.setFrom(result);
		return temp;
	}

	public function getLength():Float {
		return end.sub(start).length;
	}
}
