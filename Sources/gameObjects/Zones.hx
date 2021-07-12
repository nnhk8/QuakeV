package gameObjects;

import format.tmx.Data.TmxObject;
import com.collision.platformer.CollisionGroup;
import states.GlobalGameData;
import kha.math.FastVector2;
import com.gEngine.display.Layer;
import com.collision.platformer.CollisionBox;
import com.gEngine.helpers.RectangleDisplay;
import com.framework.utils.Entity;

class Zones extends Entity {

	var collision:CollisionBox;


	public function new( object:TmxObject, collisionGroup:CollisionGroup) {
		super();
		collision = new CollisionBox();
		collision.width = object.width;
		collision.height = object.height;
		collision.x = object.x;
		collision.y = object.y;
        collision.userData=this;
		collisionGroup.add(collision);
	}

	override function update(dt:Float) {
		super.update(dt);
		collision.update(dt);
	}

	override function render() {
		super.render();
	}

	override function destroy() {
		super.destroy();
        collision.removeFromParent();
	}
}
