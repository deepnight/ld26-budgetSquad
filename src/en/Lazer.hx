package en;

import flash.display.Sprite;

class Lazer extends Mob {
	var beam		: Sprite;
	var dir			: Int;
	var horizontal	: Bool;
	var blocked		: Bool;
	var sound		: mt.deepnight.Sfx;
	
	public function new(x,y) {
		super();
		cx = x;
		cy = y;
		setLife(999);
		score = 0;
		blocked = false;
		radius = 9;
		//collides = false;
		unmovable = true;
		hitWeight = 99;
		oscillo = 0;
		
		horizontal = !getCol(cx+1,cy) || !getCol(cx-1,cy);
		if( horizontal )
			dir = getCol(cx-1,cy) ? 1 : -1;
		else
			dir = getCol(cx,cy-1) ? 1 : -1;
		
		beam = new Sprite();
		sprite.addChild(beam);
		beam.graphics.beginFill(0xFFFFC1, 1);
		beam.graphics.drawRect(0,0,Const.GRID,3);
		beam.filters = [ new flash.filters.BlurFilter(2,2), new flash.filters.GlowFilter(0xFFBF00,1,8,8,2) ];
		beam.blendMode = flash.display.BlendMode.ADD;
		beam.scaleX = dir;
		if( !horizontal )
			beam.rotation = 90;
		
		sprite.swap("lazer",0);
		sound = Game.SFX.lazer();
	}
	
	override function destroy() {
		super.destroy();
		sound.stop();
	}
	
	override function hit(d,from) {
		if( cd.hasSet("lhit",5) )
			Game.SFX.shield1().play(0.1);
	}
	
	
	override function update() {
		super.update();
		
		if( (uid+game.time)%3==0 ) {
			blocked = false;
			var x = cx;
			var y = cy;
			var len = 0.;
			while( !getCol(x,y) ) {
				if( game.gunner.cx==x && game.gunner.cy==y )
					game.gunner.hit(1, this);
				if( horizontal ) {
					if( game.lighter.cx==x && Math.abs(game.lighter.yy-yy)<Const.GRID*0.6 ) {
						len+= dir*(game.lighter.xr-0.5);
						//game.lighter.hit(1, this);
						game.fx.lazerHit(game.lighter.xx, yy);
						blocked = true;
						break;
					}
					x+=dir;
				}
				else {
					if( game.lighter.cy==y && Math.abs(game.lighter.xx-xx)<Const.GRID*0.8 ) {
						len+= dir*(game.lighter.yr-0.5);
						//game.lighter.hit(1, this);
						game.fx.lazerHit(xx, game.lighter.yy);
						blocked = true;
						break;
					}
					y+=dir;
				}
				len++;
			}
			beam.scaleX = dir * len;
		}
		if( blocked && !sound.isPlaying() )
			sound.playLoop(99999,0.2);
		if( !blocked && sound.isPlaying() )
			sound.stop();
	}
}
