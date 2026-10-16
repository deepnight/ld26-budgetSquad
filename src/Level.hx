import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import mt.deepnight.Lib;

@:bitmap("gfx/levels.png") class GfxLevels extends BitmapData {}

class Level {
	var game				: Game;
	var pt0					: flash.geom.Point;
	
	public var wid			: Int;
	public var hei			: Int;
	var colMap				: Array<Array<Bool>>;
	var metalMap			: Array<Array<Bool>>;
	
	public var sky			: Sprite;
	public var waves		: Sprite;
	public var waves2		: Sprite;
	public var rays			: Sprite;
	public var walls		: Bitmap;
	public var backPerlin	: Bitmap;
	//public var oceanBg		: mt.deepnight.SpriteLibBitmap.BSprite;
	var plants				: Array<mt.deepnight.SpriteLibBitmap.BSprite>;
	var corals				: Array<mt.deepnight.SpriteLibBitmap.BSprite>;
	public var spots		: Hash<Array<{cx:Int, cy:Int}>>;
	
	public function new() {
		game = Game.ME;
		wid = 5*16;
		hei = 5*16;
		plants = [];
		corals = [];
		spots = new Hash();
		pt0 = new flash.geom.Point(0,0);

		metalMap = [];
		colMap = [];
		for(x in 0...wid) {
			colMap[x] = [];
			metalMap[x] = [];
		}

		var source = new GfxLevels(0,0);
		for(x in 0...wid)
			for(y in 0...hei) {
				var p = source.getPixel(x,y);
				if( p==0xFFFFFF ) colMap[x][y] = true;
				if( p==0xb2b2b2 ) {
					colMap[x][y] = true;
					metalMap[x][y] = true;
				}
				if( p==0xFF0000 ) addSpot("seekMine", x,y);
				if( p==0x3d3d3d ) addSpot("mine", x,y);
				if( p==0xff9c00) addSpot("turret", x,y);
				if( p==0x1b46ff) addSpot("gem", x,y);
				if( p==0xff00f0) addSpot("lazer", x,y);
				if( p==0xdfd28c) addSpot("potato", x,y);
				if( p==0x00fcff) addSpot("breakable", x,y);
				if( p==0x875e45) addSpot("crystal", x,y);
				if( p==0x4bc02f ) {
					colMap[x][y] = true;
					addSpot("coral", x,y);
				}
			}
				
		sky = new Sprite();
		sky.graphics.beginFill(0x1C1841,1);
		sky.graphics.beginBitmapFill( game.tiles.getBitmapData("sky"), true, false );
		sky.graphics.drawRect(0,0,wid*Const.GRID, Const.WATER_LEVEL*Const.GRID);
		
		waves = new Sprite();
		waves.y = Const.WATER_LEVEL_F-13;
		
		waves2 = new Sprite();
		waves2.y = Const.WATER_LEVEL_F-18;
		
		rays = new Sprite();
		rays.graphics.beginBitmapFill( game.tiles.getBitmapData("rays"), true, false );
		rays.graphics.drawRect(0,0,wid*Const.GRID, 43);
		rays.y = waves.y;
		
		//oceanBg = game.tiles.get("oceanBg");
		//oceanBg.y = Const.WATER_LEVEL_F;
		var s = 2;
		backPerlin = new Bitmap( new BitmapData(Math.ceil(game.buffer.width/s), Math.ceil(game.buffer.height/s), false, 0x00FF00) );
		backPerlin.scaleX = backPerlin.scaleY = s;
		backPerlin.blendMode = flash.display.BlendMode.OVERLAY;
		backPerlin.alpha = 0.25;
		
		walls = new Bitmap( new BitmapData(wid*Const.GRID, hei*Const.GRID, true, 0x0) );
		for(x in 0...wid)
			for(y in 0...hei)
				if( getCol(x,y) ) {
					var k = y>=Const.WATER_LEVEL ? "wall" : "wallOut";
					if( isMetal(x,y) )
						k = "metal";
					game.tiles.drawIntoBitmap(walls.bitmapData, x*Const.GRID-8, y*Const.GRID-8, k, game.tiles.getRandomFrame(k), 0,0);
					if( y>=Const.WATER_LEVEL && Std.random(100)<=66 && (!getCol(x-1,y) || !getCol(x+1,y) || !getCol(x,y-1) || !getCol(x,y+1) ) ) {
						var s = game.tiles.get("plant");
						s.setCenter(0.5,0.5);
						s.x = (x+0.5)*Const.GRID;
						s.y = (y+0.5)*Const.GRID;
						s.rotation = Lib.rnd(0,360);
						game.sdm.add(s, Const.DP_BEHIND_WALLS);
						plants.push(s);
					}
				}
		for(x in 0...wid)
			for(y in 0...hei)
				if( Std.random(3)==0 &&getCol(x,y) && y>=Const.WATER_LEVEL )
					game.tiles.drawIntoBitmap(walls.bitmapData, x*Const.GRID-8+Lib.irnd(0,3,true), y*Const.GRID-8+Lib.irnd(0,3,true), "rock", game.tiles.getRandomFrame("rock"), 0,0);
			
		var bd = walls.bitmapData;
		bd.applyFilter(bd, bd.rect, pt0, new flash.filters.GlowFilter( Const.BG, 0.8, 64,64,2, 2, true));
		bd.applyFilter(bd, bd.rect, pt0, new flash.filters.GlowFilter( 0x274252, 0.5, 4,4,3, 2, true));
		bd.applyFilter(bd, bd.rect, pt0, new flash.filters.DropShadowFilter( 4,-90, Const.BG, 0.4, 2,2,1, 1, true));
		bd.applyFilter(bd, bd.rect, pt0, new flash.filters.GlowFilter( 0x0, 0.4, 128,128,1));

		for(pt in spots.get("coral")) {
			var s = game.tiles.getRandom("coral");
			s.setCenter(0.5,0.5);
			s.x = (pt.cx+0.5)*Const.GRID;
			s.y = (pt.cy+0.5)*Const.GRID-16;
			game.sdm.add(s, Const.DP_BEHIND_WALLS);
			corals.push(s);
			
			//game.tiles.drawIntoBitmap(walls.bitmapData, pt.cx*Const.GRID-8, pt.cy*Const.GRID-24, "coral", game.tiles.getRandomFrame("coral"), 0,0);
		}
	}
	
	public function addSpot(k:String, cx,cy) {
		if( !spots.exists(k) )
			spots.set(k, []);
		spots.get(k).push({cx:cx,cy:cy});
	}
	
	public function getSpots(k:String) {
		if( spots.exists(k) )
			return spots.get(k);
		else
			return [];
	}
	
	public inline function getCol(cx,cy) {
		if( cx<0 || cx>=wid || cy>=hei )
			return true;
		else
			return colMap[cx][cy]==true;
	}
	
	public inline function isMetal(cx,cy) {
		if( cx<0 || cx>=wid || cy>=hei )
			return false;
		else
			return metalMap[cx][cy]==true;
	}
	
	public function update() {
		if( !Const.LOWQ ) {
			var i = 0;
			for(s in plants) {
				if( (i+game.time)%2==0 ) {
					s.rotation+=Math.cos((i*50+game.time)*0.01)*0.4;
					s.scaleX = 1 + 0.1 * Math.cos((i*50+game.time)*0.03);
					s.scaleY = 1 + 0.1 * Math.cos(5+(i*50+game.time)*0.04);
					if( s.rotation>=360 )
						s.rotation -= 360;
				}
				i++;
			}
			
			var i = 0;
			for(s in corals) {
				s.scaleX = 1.1 + 0.1 * Math.cos((i*50+game.time)*0.03);
				s.scaleY = 1.1 + 0.1 * Math.cos(5+(i*50+game.time)*0.04);
				i++;
			}
			
			
			var s1 = 0.8;
			var s2 = 0.61;
			backPerlin.bitmapData.perlinNoise(
				64,16,2, 1867, false, true, 1, true,
				[
					new flash.geom.Point(game.time*s1-game.scroll.x*0.1, game.time*s1*0.17-game.scroll.y*0.1),
					new flash.geom.Point(-game.time*s2-game.scroll.x*0.2, -game.time*s2*0.3-game.scroll.y*0.2),
				]
			);
		}
		
		var m = new flash.geom.Matrix();
		m.translate(game.time*0.5, Math.sin(game.time*0.1)*1);
		waves.graphics.clear();
		waves.graphics.beginBitmapFill( game.tiles.getBitmapData("waves"), m, true, false );
		waves.graphics.drawRect(0,0,wid*Const.GRID, 43);
		
		if( !Const.LOWQ ) {
			var m = new flash.geom.Matrix();
			m.translate(30+game.time*0.25, Math.cos(game.time*0.1)*1);
			waves2.graphics.clear();
			waves2.graphics.beginBitmapFill( game.tiles.getBitmapData("waves"), m, true, false );
			waves2.graphics.drawRect(0,0,wid*Const.GRID, 43);
		}
	}
}

