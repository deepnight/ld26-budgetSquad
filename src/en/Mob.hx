package en;

class Mob extends Entity {
	public static var ALL : Array<Mob> = [];
	var score			: Int;
	
	public function new() {
		super();
		cx = 10;
		cy = 12;
		setLife(5);
		score = 5;
		radius = 9;
		collides = true;
		
		ALL.push(this);
	}
	
	override function onTouch(e:Entity) {
		super.onTouch(e);
		if( e==game.gunner || e==game.lighter )
			e.hit(1, this);
	}
	
	override function hit(d,from) {
		super.hit(d,from);
		if( life>0 )
			Game.SFX.hit3().play(0.6);
	}
	
	override function onDie() {
		super.onDie();
		game.addScore(score, this);
		game.addCombo();
		Game.SFX.explode2().play();
	}
	
	override function unregister() {
		super.unregister();
		ALL.remove(this);
	}
}