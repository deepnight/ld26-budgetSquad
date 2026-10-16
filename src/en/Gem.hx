package en;

class Gem extends Entity {
	public function new(x,y) {
		super();
		cx = x;
		cy = y;
		radius = 9;
		collides = true;
		oscillo = 0.5;
		
		sprite.swap("gem");
	}
	
	override function onTouch(e:Entity) {
		super.onTouch(e);
		if( e==game.gunner )
			onPickUp();
		if( e==game.lighter )
			onPickUp();
	}
	
	function onPickUp() {
		game.fx.pickUp(this);
		game.addScore(200, this);
		destroy();
		Game.SFX.pick1().play(0.6);
	}
}