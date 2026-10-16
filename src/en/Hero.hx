package en;

class Hero extends Entity {
	public var speed		: Float;
	public var engine		: Bool;
	public var character	: Game.Talker;
	public function new(x,y) {
		super();
		cx = x;
		cy = y;
		engine = false;
		collides = true;
		speed = 0.020;
		weight = 1;
	}
	
	override function hit(dmg,from) {
		if( game.paused )
			dmg = 0;
		super.hit(dmg,from);
	}
	
	override function onDie() {
		if( !killed ) {
			super.onDie();
			game.fx.explode(xx,yy, radius, 16);
			new LightEcho(xx,yy);
			game.gameOver();
			Game.SFX.die2().play();
			Game.SFX.explode3().play();
		}
	}
	
	override function update() {
		super.update();
		if( engine && game.time%3==0 || Std.random(8)==0 )
			game.fx.bubbles(xx+12*sprite.scaleX, yy, 3);
			
		engine = false;
		if( isUnderwater() )
			sprite.alpha = this==game.hero ? 1 : 0.38;
	}
}
