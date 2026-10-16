package en;

class Bullet extends Entity {
	public static var ALL : Array<Entity> = [];
	
	public function new(from:Mob, to:Entity) {
		super();
		frict = 1;
		radius = 2;
		autoKill = 90;
		collides = false;
		oscillo = 0;
		
		xx = from.xx;
		yy = from.yy;
		updateFromScreenCoords();
		
		var a = Math.atan2(to.yy-from.yy, to.xx-from.xx);
		var s = 0.09;
		dx = Math.cos(a)*s;
		dy = Math.sin(a)*s;
		
		sprite.graphics.clear();
		sprite.swap("bullet");
		sprite.blendMode = flash.display.BlendMode.ADD;
	}
	
	override function onHitWall() {
		super.onHitWall();
		destroy();
	}
	
	override function update() {
		super.update();
		
		if( hits(game.gunner) ) {
			game.gunner.hit(1, this);
			destroy();
			return;
		}
		if( hits(game.lighter) ) {
			game.lighter.hit(1, this);
			destroy();
			return;
		}
		
		if( !isUnderwater() )
			destroy();
	}
}