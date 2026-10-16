package en;

class Torpedo extends Entity {
	public static var ALL : Array<Entity> = [];
	
	public function new(x:Float,y:Float,dir:Int) {
		super();
		frict = 1;
		radius = 2;
		collides = false;
		collidesWalls = false;
		oscillo = 0;
		
		var s = 0.3;
		dx = dir>0 ? s : -s;
		xx = x;
		yy = y;
		updateFromScreenCoords();
		
		sprite.graphics.clear();
		sprite.swap("torpedo");
		sprite.scaleX = dir;
		autoKill = 40;
	}
	
	override function update() {
		super.update();
		
		//if( hits(game.lighter) ) {
			//game.lighter.hit(0, this);
			//destroy();
		//}
			
		for(e in Mob.ALL)
			if( hits(e) ) {
				e.hit(1, this);
				destroy();
				return;
			}
		
		if( !isUnderwater() )
			destroy();
		else
			if( game.time%4==0 )
				game.fx.bubbles(xx,yy, 1);
				
		if( getCol(cx,cy) )
			destroy();
	}
}