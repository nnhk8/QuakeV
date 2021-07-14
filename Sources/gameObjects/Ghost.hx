package gameObjects;

import com.gEngine.display.Sprite;
import states.GlobalGameData;
import kha.math.FastVector2;
import com.collision.platformer.CollisionGroup;
import com.collision.platformer.CollisionBox;
import com.gEngine.display.Layer;
import com.helpers.Rectangle;
import com.gEngine.helpers.RectangleDisplay;
import com.framework.utils.Entity;

class Ghost extends Entity {
	var display:Sprite;

	public var collision:CollisionBox;
	public var facingDir:FastVector2;
	public var SPEED:Float = 80;
	public var dying:Bool = false;

	public function new(x:Float, y:Float) {
		super();
		display = new Sprite("ghost");
		display.smooth = false;
		display.timeline.playAnimation("appear", false);
		display.timeline.frameRate = 1 / 10;
		display.scaleX = 2;
		display.scaleY = 2;
		display.pivotX = display.width();
		display.offsetY = -display.height();
		display.x = x;
		display.y = y;
		GlobalGameData.simulationLayer.addChild(display);

		collision = new CollisionBox();
		collision.width = 40;
		collision.height = 40;
		collision.x = x;
		collision.y = y;
		GlobalGameData.enemyCollisions.add(collision);
		collision.userData = this;
		facingDir = new FastVector2(1, 0);
	}

	override function update(dt:Float) {
		if (dying) {
			if (!display.timeline.playing) {
				die();
			}
		} else {
			if (!display.timeline.playing) {
				display.timeline.playAnimation("idle", true);
			}
			super.update(dt);
			collision.update(dt);
			facingDir.x = GlobalGameData.player.collision.x - collision.x;
			facingDir.y = GlobalGameData.player.collision.y - collision.y;
			facingDir.setFrom(facingDir.normalized());
		}
		collision.velocityX = facingDir.x * SPEED;
		collision.velocityY = facingDir.y * SPEED;
	}

	override function render() {
		super.render();
		display.x = collision.x + collision.width * 0.5;
		display.y = collision.y + collision.height * 0.5;
	}

	public function damage():Void {
		display.timeline.playAnimation("desappear", false);
		collision.removeFromParent();
		dying = true;
	}

	override function destroy() {
		super.destroy();
		display.removeFromParent();
		collision.removeFromParent();
	}
}
