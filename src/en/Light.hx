package en;

class Light extends Entity {
	static var SIZE = 1.2;
	
	var stopped		: Bool;
	
	public function new() {
		super();
		stopped = false;
		weight = 1;
		frict = 1;
		lightPower = 0;
		
		sprite.graphics.clear();
		sprite.graphics.beginFill(0xFFFF80,1);
		sprite.graphics.drawCircle(0,0,2);
		//sprite.filters = [ new flash.filters.GlowFilter(0xFFDF00,1, 8,8,2) ];
		//ALL.push(this);
		setLight();
		sprite.blendMode = flash.display.BlendMode.ADD;
		cd.set("pick", 30);
	}
	
	public function stop() {
		stopped = true;
		for(i in 0...10)
			game.fx.bubbles(xx,yy,5);
	}
	override function onHitWall() {
		super.onHitWall();
		dx = dy = 0;
	}
	
	override function update() {
		super.update();
		lightScale = SIZE * rnd(0.9,1);
		
		if( !stopped ) {
			game.fx.lightDust(xx,yy, 0xFFCC00);
			if( lightPower<1 ) {
				lightPower+=0.03;
				sprite.filters = [ new flash.filters.GlowFilter(0xFFCD22,1, 4,4,2) ];
			}
			else {
				sprite.filters = [
					new flash.filters.GlowFilter(0xFFC600,1, 4,4,2),
					new flash.filters.GlowFilter(0xFF9300,1, 16,16,3, 2)
				];
			}
		}
		else
			if( lightPower>0 ) {
				lightPower-=0.05;
				sprite.filters = [ new flash.filters.GlowFilter(0xFFEC62,rnd(0.3,0.5), 8,8,2) ];
			}
			else {
				destroy();
				return;
			}
	
		if( !stopped && !cd.has("pick") && checkDistance(game.hero, Const.GRID*0.5) )
			stop();
	}
}