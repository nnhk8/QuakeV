package gameObjects;

import com.gEngine.display.Sprite;
import paths.Path;
import states.GlobalGameData;
import com.collision.platformer.CollisionBox;
import paths.PathWalker;
import com.framework.utils.Entity;

class Saw extends Entity {
	private var pathWalker:PathWalker;
	var display:Sprite;
	var collision:CollisionBox;

	public var damage:Bool = true;
	public var noDamageTime:Float = 0;
	public var noDamageTimeMax:Float = 5;

	public function new(path:Path, speed:Int, playMode:PlayMode) {
		super();
		display = new Sprite("chain");
		display.timeline.playAnimation("spin");
		display.timeline.frameRate = 1 / 30;
		display.pivotX = display.width();
		display.offsetY = -display.height();
		display.scaleX = 2;
		display.scaleY = 2;

		collision = new CollisionBox();
		collision.userData = this;
		collision.width = 50;
		collision.height = 50;

		GlobalGameData.sawCollisions.add(collision);
		GlobalGameData.simulationLayer.addChild(display);
		pathWalker = new PathWalker(path, speed, playMode);
	}

	override public function update(dt:Float):Void {
		super.update(dt);
		pathWalker.update(dt);
		if(!damage){
			noDamageTime+=dt;
			if (noDamageTime>noDamageTimeMax) {
				damage = true;
				noDamageTime = 0;
			}
		}
		collision.x = pathWalker.x;
		collision.y = pathWalker.y;
		collision.update(dt);
	}

	override function destroy() {
		display.removeFromParent();
		collision.removeFromParent();
	}

	override function render() {
		display.x = collision.x + collision.width * 0.5;
		display.y = collision.y + collision.height * 0.5;
		super.render();
	}
	public function noDamage()
	{
		damage=false;
	}
}
