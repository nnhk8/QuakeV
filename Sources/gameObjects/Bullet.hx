package gameObjects;

import com.gEngine.display.Sprite;
import com.collision.platformer.CollisionGroup;
import states.GlobalGameData;
import kha.math.FastVector2;
import com.gEngine.display.Layer;
import com.collision.platformer.CollisionBox;
import com.gEngine.helpers.RectangleDisplay;
import com.framework.utils.Entity;

class Bullet extends Entity {
	var display:Sprite;
	var collision:CollisionBox;
	var width:Int = 10;
	var height:Int = 10;
	var speed:Float = 1000;
	var time:Float = 0;
	public var dying:Bool = false;


	public function new(x:Float, y:Float, dir:FastVector2,collisionGroup:CollisionGroup) {
		super();
		display = new Sprite("explosion");
		display.smooth = false;
		display.timeline.playAnimation("bullet", false);
		display.timeline.frameRate = 1 / 20;
		display.scaleX = 2;
		display.scaleY = 2;
		display.pivotX = display.width();
		display.offsetY = -display.height();
		display.x = x;
		display.y = y;
		GlobalGameData.simulationLayer.addChild(display);

		collision = new CollisionBox();
		collision.width = width;
		collision.height = height;
		collision.x = x;
		collision.y = y;
		collision.velocityX = dir.x * speed;
		collision.velocityY = dir.y * speed;
        collision.userData=this;
        collisionGroup.add(collision);
	}

	override function update(dt:Float) {
		if (dying) {
			if (!display.timeline.playing) {
				die();
			}
		} else {
			time += dt;
			display.x = collision.x;
			display.y = collision.y-height*3;
			super.update(dt);
			collision.update(dt);
			if (time > 4) {
				die();
			}
		}

	}

	override function render() {
		super.render();
		display.x = collision.x;
		display.y = collision.y;
	}

	override function destroy() {
		super.destroy();
		display.removeFromParent();
        collision.removeFromParent();
	}

	public function damage():Void {
		display.timeline.playAnimation("boom", false);
		collision.removeFromParent();
		dying = true;
	}
}
