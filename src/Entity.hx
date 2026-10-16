import mt.deepnight.SpriteLibBitmap;

class Entity {
	static var UNIQ = 0;
	public static var ALL : Array<Entity> = [];
	public static var LIGHTS : Array<Entity> = [];
	var game				: Game;
	var level				: Level;
	public var uid			: Int;
	public var sprite		: BSprite;
	
	public var cd			: mt.deepnight.Cooldown;
	
	public var cx			: Int;
	public var cy			: Int;
	public var xr			: Float;
	public var yr			: Float;
	
	var oscillo				: Float;
	
	public var life			: Int;
	
	public var dx			: Float;
	public var dy			: Float;
	public var xx			: Float;
	public var yy			: Float;
	public var frict		: Float;
	public var weight		: Float;
	public var hitWeight	: Float;
	public var radius(default,setRadius)		: Float;
	public var collides		: Bool;
	public var collidesWalls: Bool;
	public var unmovable	: Bool;
	
	public var killed		: Bool;
	public var lightPower	: Float;
	public var lightScale	: Float;
	
	var autoKill			: Int;
	
	public function new() {
		uid = UNIQ++;
		autoKill = 0;
		game = Game.ME;
		level = game.level;
		cd = new mt.deepnight.Cooldown();
		unmovable = false;
		cx = cy = 5;
		xr = yr = 0.5;
		radius = 2;
		dx = dy = 0;
		killed = false;
		frict = 0.96;
		lightPower = 0;
		lightScale = 0;
		oscillo = 1;
		collides = false;
		collidesWalls = true;
		weight = 1;
		hitWeight = 1;
		setLife(5);
		
		sprite = new mt.deepnight.BSprite(game.tiles);
		sprite.setCenter(0.5,0.5);
		//sprite.graphics.beginFill(0xFF0000,1);
		//sprite.graphics.drawCircle(0,0,radius);
		
		game.sdm.add(sprite, Const.DP_ENTITY);
		ALL.push(this);
	}
	
	public function onTouch(e:Entity) {
		dx*=0.95;
		dy*=0.95;
	}
	
	public function setRadius(r) {
		radius = r;
		#if debug
		//if( sprite!=null ) {
			//sprite.graphics.lineStyle(1, 0x00FF00, 1);
			//sprite.graphics.drawCircle(0,0,r);
		//}
		#end
		return r;
	}
	
	public function setLife(n) {
		life = n;
	}
	
	public function hit(dmg:Int, from:Entity) {
		if( cd.has("shield") )
			return;
			
		if( dmg<0 )
			dmg = 0;
			
		var pow = Math.max(0, dmg*0.05 - hitWeight*0.025);
		var a = Math.atan2(yy-from.yy, xx-from.xx);
		dx+=Math.cos(a)*pow;
		dy+=Math.sin(a)*pow;
		life-=dmg;
		game.fx.blink(this, dmg<=0 ? 0xFFFFFF : null);
		if( life<=0 && !killed ) {
			life = 0;
			onDie();
		}
	}
	
	public function onDie() {
		destroy();
		game.fx.explode(xx,yy, radius);
	}
	
	inline function rnd(min,max,?sign) { return mt.deepnight.Lib.rnd(min,max,sign); }
	inline function irnd(min,max,?sign) { return mt.deepnight.Lib.irnd(min,max,sign); }
	
	public inline function distance(e:Entity) {
		return mt.deepnight.Lib.distance(e.xx, e.yy, xx,yy);
	}
	public inline function checkDistance(e:Entity, d:Float) {
		var d2 = mt.deepnight.Lib.distanceSqr(xx,yy, e.xx,e.yy);
		if( d2<=d*d )
			return Math.sqrt(d2)<=d;
		else
			return false;
	}
	
	public function setLight() {
		lightPower = lightScale = 1;
		LIGHTS.remove(this);
		LIGHTS.push(this);
	}
	
	public function hits(e:Entity) {
		return checkDistance(e, radius+e.radius);
	}
	
	public function updateFromScreenCoords() {
		cx = Std.int(xx/Const.GRID);
		cy = Std.int(yy/Const.GRID);
		xr = (xx-cx*Const.GRID) / Const.GRID;
		yr = (yy-cy*Const.GRID) / Const.GRID;
	}
	
	public function unregister() {
		LIGHTS.remove(this);
		ALL.remove(this);
		sprite.parent.removeChild(sprite);
	}
	
	public function destroy() {
		if( !killed ) {
			killed = true;
			game.killList.push(this);
		}
	}
	
	public function updateScreenCoords() {
		xx = Std.int((cx+xr)*Const.GRID);
		yy = Std.int((cy+yr)*Const.GRID);
	}
	
	public inline function getCol(cx,cy) {
		return level.getCol(cx,cy);
	}
	
	public function isUnderwater() {
		return cy>=Const.WATER_LEVEL;
	}
	
	public function onHitWall() {
	}
	
	public inline function inDarkness() {
		return false;
	}
	
	public function update() {
		cd.update();
		
		if( killed )
			return;
			
		// Entity collisions
		if( collides )
			for(e in ALL)
				if( e!=this && e.collides && Math.abs(e.cx-cx)<=2 && Math.abs(e.cy-cy)<=2 ) {
					var d = distance(e);
					var overlap = radius+e.radius - d;
					if( overlap>0 ) {
						var a = Math.atan2(e.yy-yy, e.xx-xx);
						var cos = Math.cos(a);
						var sin = Math.sin(a);
						var gover = overlap/Const.GRID;
						xr -= cos*gover*(unmovable?0:(e.unmovable?1:0.5));
						yr -= sin*gover*(unmovable?0:(e.unmovable?1:0.5));
						e.xr += cos*gover*(e.unmovable?0:(unmovable?1:0.5));
						e.yr += sin*gover*(e.unmovable?0:(unmovable?1:0.5));
						onTouch(e);
						e.onTouch(this);
					}
				}
			
		if( !unmovable ) {
			// X component
			var repelX = 0.007;
			xr+=dx;
			dx*=frict;
			if( collidesWalls ) {
				if( getCol(cx-1,cy) && xr<=0.4 ) {
					dx += repelX;
					if( xr<0.3 )
						xr = 0.3;
					onHitWall();
				}
				if( getCol(cx+1,cy) && xr>=0.6 ) {
					dx -= repelX;
					if( xr>0.7 )
						xr = 0.7;
					onHitWall();
				}
			}
			while( xr<0 ) {
				cx--;
				xr++;
			}
			while( xr>1 ) {
				cx++;
				xr--;
			}
			
			// Forces
			var wasUnderwater = isUnderwater();
			if( isUnderwater() ) {
				dy+= -0.003 + 0.003*weight; // archimede
				dy+= oscillo * Math.cos((uid*99+game.time)*0.01*3.14)*0.001; // floating
			}
			else
				if( !cd.has("gravity") && (!getCol(cx,cy+1) || yr<0.6) )
					dy+=0.025; // gravity
				
				
			// Y component
			var repelY = 0.007;
			yr+=dy;
			dy*=frict;
			if( collidesWalls ) {
				if( getCol(cx,cy-1) && yr<=0.5 ) {
					dy += repelY;
					if( yr<0.4 )
						yr = 0.4;
					onHitWall();
				}
				if( getCol(cx,cy+1) && yr>=0.5 ) {
					dy -= repelY;
					if( yr>0.6 )
						yr = 0.6;
					onHitWall();
				}
			}
			while( yr<0 ) {
				cy--;
				yr++;
			}
			while( yr>1 ) {
				cy++;
				yr--;
			}
			
			// leaves water
			if( !isUnderwater() && wasUnderwater && dy<-0.1 ) {
				game.fx.splashOut(this);
				dx*=1.3;
				dy*=2;
			}
			
			// enters water
			if( !wasUnderwater && isUnderwater() ) {
				if( Math.abs(dy)>=0.1 && (this==game.gunner || this==game.lighter) )
					Game.SFX.splash3().play( 0.5 * Math.min(1, Math.abs(dy)/0.4) );
				game.fx.splashIn(this);
			}
		}
			
		updateScreenCoords();
		sprite.x = xx;
		sprite.y = yy;
		
		if( autoKill>0 ) {
			autoKill--;
			if( autoKill<=0 )
				destroy();
		}
		
		if( cd.has("emitBubbles") )
			for(i in 0...3 )
				game.fx.bubbles(xx,yy, radius, 0.3);
	}
	
}
