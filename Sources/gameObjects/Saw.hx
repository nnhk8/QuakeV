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

	public function new(path:Path) {
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
		collision.width = 40;
		collision.height = 40;


		GlobalGameData.sawCollisions.add(collision);
		GlobalGameData.simulationLayer.addChild(display);
		pathWalker = new PathWalker(path, 10, PlayMode.Loop);
	}

	override public function update(dt:Float):Void {
		super.update(dt);
		pathWalker.update(dt);
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
}
