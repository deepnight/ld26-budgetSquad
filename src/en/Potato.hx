package en;

class Potato extends Entity {
	public function new(x,y) {
		super();
		cx = x;
		cy = y;
		radius = 10;
		collides = true;
		oscillo = 0.2;
		
		sprite.swap("potato");
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
		game.addScore(1000, this);
		destroy();
		Game.SFX.pick3().play();
		game.cm.create({
			game.paused = true;
			game.talk(game.hero.character, "Woot! An abyssal Potato!")>end;
			game.hideTalk();
			game.paused = false;
		});
	}
}