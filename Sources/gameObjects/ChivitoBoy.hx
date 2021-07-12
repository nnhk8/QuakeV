package gameObjects;

import kha.input.KeyCode;
import kha.math.FastVector2;
import com.collision.platformer.CollisionGroup;
import com.framework.utils.Input;
import com.collision.platformer.Sides;
import com.framework.utils.XboxJoystick;
import com.gEngine.display.Layer;
import com.collision.platformer.CollisionBox;
import com.gEngine.display.Sprite;
import com.framework.utils.Entity;

class ChivitoBoy extends Entity {
	public var display:Sprite;
	public var collision:CollisionBox;
	public var fly:Bool = false;

	public var bulletsCollision:CollisionGroup;

	var maxSpeed = 200;

	var lastWallGrabing:Float = 0;
	var sideTouching:Int;

	var speed:Float = 100;
	var facingDir:FastVector2 = new FastVector2(1, 0);

	public function new(x:Float, y:Float, layer:Layer) {
		super();
		display = new Sprite("hero");
		display.smooth = false;
		layer.addChild(display);
		collision = new CollisionBox();
		collision.width = display.width();
		collision.height = display.height() * 0.5;
		display.pivotX = display.width() * 0.5;
		display.offsetY = -display.height() * 0.5;

		display.scaleX = display.scaleY = 1;
		collision.x = x;
		collision.y = y;

		collision.userData = this;

		collision.accelerationY = 2000;
		collision.maxVelocityX = 500;
		collision.maxVelocityY = 800;
		collision.dragX = 0.9;
		collision.dragY = 0.9;

		bulletsCollision = new CollisionGroup();
	}

	override function update(dt:Float) {
		if (isWallGrabing()) {
			lastWallGrabing = 0;
			if (collision.isTouching(Sides.LEFT)) {
				sideTouching = Sides.LEFT;
			} else {
				sideTouching = Sides.RIGHT;
			}
		} else {
			lastWallGrabing += dt;
		}
		if (Input.i.isKeyCodePressed(KeyCode.X)) {
			var bullet:Bullet = new Bullet(collision.x + collision.width * 0.5, collision.y + collision.height * 0.5,facingDir,bulletsCollision);
			addChild(bullet);
		}
		collision.update(dt);

		super.update(dt);
	}

	override function render() {
		var s = Math.abs(collision.velocityX / collision.maxVelocityX);
		display.timeline.frameRate = (1 / 24) * s + (1 - s) * (1 / 10);
		if (isWallGrabing()) {
			display.timeline.playAnimation("wallGrab");
		} else if (collision.isTouching(Sides.BOTTOM) && collision.velocityX * collision.accelerationX < 0) {
			display.timeline.playAnimation("slide");
		} else if (collision.isTouching(Sides.BOTTOM) && collision.velocityX == 0) {
			display.timeline.playAnimation("idle");
		} else if (collision.isTouching(Sides.BOTTOM) && collision.velocityX != 0) {
			display.timeline.playAnimation("run");
		} else if (!collision.isTouching(Sides.BOTTOM) && collision.velocityY > 0) {
			display.timeline.playAnimation("fall");
		} else if (!collision.isTouching(Sides.BOTTOM) && collision.velocityY < 0) {
			display.timeline.playAnimation("jump");
		}
		display.x = collision.x;
		display.y = collision.y;
	}

	public function onButtonChange(id:Int, value:Float) {
		var dir:FastVector2 = new FastVector2();
		if (id == XboxJoystick.LEFT_DPAD) {
			dir.x += -1;
			if (value == 1) {
				collision.accelerationX = -maxSpeed * 4;
				display.scaleX = Math.abs(display.scaleX);
			} else {
				if (collision.accelerationX < 0) {
					collision.accelerationX = 0;
				}
			}
		}
		if (id == XboxJoystick.RIGHT_DPAD) {
			dir.x += 1;
			if (value == 1) {
				collision.accelerationX = maxSpeed * 4;
				display.scaleX = -Math.abs(display.scaleX);
			} else {
				if (collision.accelerationX > 0) {
					collision.accelerationX = 0;
				}
			}
		}
		if (id == XboxJoystick.UP_DPAD) {
			dir.y += -1;
		}
		if (id == XboxJoystick.DOWN_DPAD) {
			dir.y += 1;
		}
		
		if (id == XboxJoystick.A) {
			if (value == 1) {
				if (fly) {
					collision.velocityY = -300;
				} else {
					if (collision.isTouching(Sides.BOTTOM)) {
						collision.velocityY = -500;
					} else if (isWallGrabing() || lastWallGrabing < 0.2) {
						if (sideTouching == Sides.LEFT) {
							collision.velocityX = 400;
						} else {
							collision.velocityX = -400;
						}
						collision.velocityY = -700;
					}
				}
			}
		}
		if (dir.length != 0) {
			var normalizeDir = dir.normalized();
			facingDir.x = normalizeDir.x;
			facingDir.y = normalizeDir.y;
		}
	}

	inline function isWallGrabing():Bool {
		return !collision.isTouching(Sides.BOTTOM) && (collision.isTouching(Sides.LEFT) || collision.isTouching(Sides.RIGHT));
	}

	public function onAxisChange(id:Int, value:Float) {}


	override function destroy() {
		super.destroy();
		display.removeFromParent();
	}
}




