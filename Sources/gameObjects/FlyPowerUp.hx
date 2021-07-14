package gameObjects;

import states.GlobalGameData;
import com.collision.platformer.CollisionBox;
import com.gEngine.display.Sprite;
import com.framework.utils.Entity;


class FlyPowerUp extends Entity {

	var display:Sprite;
	public var collision:CollisionBox;

	public function new(x:Float, y:Float) {
		super();
		display = new Sprite("flying");
		display.smooth = false;
		display.timeline.playAnimation("fly", true);
		display.timeline.frameRate = 1 / 10;
		display.x = x;
		display.y = y;
		GlobalGameData.simulationLayer.addChild(display);

		collision = new CollisionBox();
		collision.width = 32;
		collision.height = 32;
		collision.x = x;
		collision.y = y;
		collision.userData = this;
		GlobalGameData.flyPowerUpCollisions.add(collision);
	}

	override public function update(dt:Float) {
		collision.update(dt);
		super.update(dt);
	}

	override function render() {
		super.render();
	}

	override function destroy() {
		super.destroy();
		display.removeFromParent();
		collision.removeFromParent();

	}
}
