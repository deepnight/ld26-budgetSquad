package en;

class LightEcho extends Entity {
	static var SIZE = 1.2;
	
	var stopped		: Bool;
	
	public function new(x,y) {
		super();
		xx=x;
		yy=y;
		updateFromScreenCoords();
		stopped = false;
		weight = 1;
		frict = 1;
		
		setLight();
		cd.set("running", 30);
	}
	
	
	override function update() {
		super.update();
		lightScale-=0.01;
		
		if( !cd.has("running") && lightPower>0 ) {
			lightPower-=0.05;
			sprite.filters = [ new flash.filters.GlowFilter(0xFFEC62,rnd(0.3,0.5), 8,8,2) ];
		}
		if( lightPower<=0 )
			destroy();
	}
}