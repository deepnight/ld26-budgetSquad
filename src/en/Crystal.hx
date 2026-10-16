package en;

class Crystal extends Entity {
	public function new(x,y) {
		super();
		cx = x;
		cy = y;
		radius = 9;
		oscillo = 0;
		collides = true;
		
		sprite.swap("crystal");
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
		game.addScore(2000, this);
		Game.SFX.pick3().play();
		destroy();
		var c = game.hero.character;
		game.cm.create({
			game.paused = true;
			game.talk(c, "General! We found the BIG CRYSTAL!")>end;
			game.talk(Game.Talker.T_General, "Well done soldier!")>end;
			game.hideTalk();
			game.credits();
		});
	}
}