package en;

class HeroGunner extends Hero {
	public var shootPower		: Int;
	
	public function new(x,y) {
		super(x,y);
		radius = 6;
		weight = 1;
		shootPower = 0;
		setLife(1);
		#if debug
		setLife(10000);
		#end
		
		character = Game.Talker.T_Malism;
		
		sprite.swap(game.tiles, "minnie");
		sprite.setCenter(0.5,0.5);
		sprite.playAnim("heli");
		sprite.scaleX = -1;
		
		setLight();
	}
	
	override function update() {
		super.update();
		//var df = Math.min(1, Math.max(0, (yy-Const.WATER_LEVEL_F)/(50+Const.WATER_LEVEL_F)));
		//lightPower = 1-df*0.6;
		//lightScale = 1-df*0.6;
		var df = Math.max(0, 1 - distance(game.lighter)/250);
		lightPower = 0.7 + df*0.3;
		lightScale = 0.3 + df*0.7;
		#if debug
		lightPower = lightScale = 1;
		#end
		
		var range = 110;
		if( !cd.has("shoot") ) {
			var dir = Std.int(-sprite.scaleX);
			for(e in Mob.ALL)
				if( (e.xx>=xx && e.xx-xx<=range && dir==1 || e.xx<=xx && xx-e.xx<=range && dir==-1) && Math.abs(cy-e.cy)<=1 ) {
					Game.SFX.shoot2().play(0.1);
					cd.set("shoot", 6);
					for(i in 0...shootPower+1)
						new Torpedo(xx,yy - shootPower*5*0.5 + i*5,dir);
					break;
				}
		}
	}
}
