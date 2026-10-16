package en;

class SeekingMine extends Mob {
	public static var ALL : Array<Entity> = [];
	
	public function new(x,y) {
		super();
		cx = x;
		cy = y;
		score = 20;
		setLife(3);
		radius = 9;
		frict = 0.98;
		
		sprite.swap("mine",1);
	}
	
	//override function onTouch(e:Entity) {
		//e.hit(1, this);
	//}
	
	override function unregister() {
		super.unregister();
		ALL.remove(this);
	}
	
	function aim(e:Entity) {
		var a = Math.atan2(e.yy-yy, e.xx-xx);
		var s = 0.008;
		dx+=Math.cos(a)*s;
		dy+=Math.sin(a)*s;
		game.fx.bubbles(xx,yy, radius);
	}
	
	override function update() {
		super.update();
		var range = 140;
		if( (uid+game.time)%5==0 ) {
			if( checkDistance(game.gunner,range) )
				aim(game.gunner);
			if( checkDistance(game.lighter,range) )
				aim(game.lighter);
		}
	}
}