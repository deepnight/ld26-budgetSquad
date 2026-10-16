package en;

class HeroLighter extends Hero {
	var spot		: mt.deepnight.SpriteLibBitmap.BSprite;
	
	public function new(x,y) {
		super(x,y);
		weight = 1;
		setLight();
		//speed *= 0.65;
		setLife(999999);
		lightPower = 1;
		lightScale = 1.3;
		radius = 12;
		oscillo = 0.3;
		character = Game.Talker.T_Minnie;
		
		sprite.swap(game.tiles, "malism");
		sprite.setCenter(0.5,0.5);
		sprite.playAnim("heli");
		sprite.scaleX = -1;
		
		spot = game.tiles.get("spotLight");
		spot.setCenter(0.5,0.5);
		sprite.addChild(spot);
		spot.blendMode = flash.display.BlendMode.ADD;
		spot.x = -7;
		spot.y = -9;
	}
	
	override public function hit(dmg, from) {
		if( cd.has("shield") )
			return;
		cd.set("shield", 12);
		game.fx.shield(this);
		if( game.hero==this )
			Game.SFX.shield1().play(0.1);
		else
			Game.SFX.shield1().play(0.01);
		dmg = 0;
		super.hit(dmg, from);
	}
	
	override function update() {
		super.update();
		spot.filters = [ new flash.filters.GlowFilter(0xFFFF00,rnd(0.8,1), 8,8,3, 2) ];
		//#if debug
		//lightPower = lightScale = 1;
		//#end
	}
}
