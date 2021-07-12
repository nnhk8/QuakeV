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

	public function new(x:Float, y:Float, layer:Layer, collisionGroup:CollisionGroup) {
		super();
		display = new Sprite("ghost");
		display.smooth =false;
		display.timeline.playAnimation("idle",true);
		display.timeline.frameRate = 1/10;
		display.scaleX = 4;
		display.scaleY = 4;
		display.pivotX = 19;
		display.pivotY = 39;
		display.offsetX = -19;
		display.offsetY = -39;
		display.x = x;
		display.y = y;
		layer.addChild(display);

		collision = new CollisionBox();
		collision.width = 40;
		collision.height = 40;
		collision.x = x;
		collision.y = y;
		collisionGroup.add(collision);
		collision.userData = this;
		facingDir = new FastVector2(1, 0);
	}

	override function update(dt:Float) {
		super.update(dt);
		collision.update(dt);
		facingDir.x = GlobalGameData.chivito.collision.x - collision.x;
		facingDir.y = GlobalGameData.chivito.collision.y - collision.y;
		facingDir.setFrom(facingDir.normalized());

		collision.velocityX = facingDir.x * SPEED;
		collision.velocityY = facingDir.y * SPEED;

		display.rotation = Math.atan2(facingDir.y, facingDir.x);
	}

	override function render() {
		super.render();
		display.x = collision.x + collision.width * 0.5;
		display.y = collision.y + collision.height * 0.5;
	}

	override function destroy() {
		super.destroy();
		display.removeFromParent();
		collision.removeFromParent();
	}
}
