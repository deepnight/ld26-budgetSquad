package en;

import flash.display.Sprite;

class Breakable extends Mob {
	public function new(x,y) {
		super();
		cx = x;
		cy = y;
		setLife(3);
		score = 5;
		radius = 14;
		//collides = false;
		unmovable = true;
		hitWeight = 99;
		oscillo = 0;
		
		sprite.swap("breakable");
	}
	
	override function onTouch(e) {
	}
}
