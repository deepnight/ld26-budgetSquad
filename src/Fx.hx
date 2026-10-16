import mt.deepnight.Particle;
import mt.deepnight.Color;
import mt.deepnight.Lib;
import flash.display.BlendMode;

class Fx implements haxe.Public {
	var game		: Game;
	public function new() {
		game = Game.ME;
	}
	
	inline function register(p:Particle, ?b:BlendMode) {
		Particle.LIMIT = 200;
		game.sdm.add(p, Const.DP_FX);
		p.blendMode = b!=null ? b : BlendMode.ADD;
	}

	inline function rnd(min:Float, max:Float, ?sign) { return Lib.rnd(min,max,sign); }
	inline function irnd(min, max,?sign) { return Lib.irnd(min,max,sign); }
	inline function rad(a) { return Lib.rad(a); }
	inline function deg(a) { return Lib.deg(a); }
	
	
	public function lightDust(x,y,col:Int) {
		var p = new Particle(x+rnd(0,2,true), y+rnd(0,2,true));
		p.drawBox(1,1,col, rnd(0.2,0.6));
		p.moveAng(rnd(0,6.28), rnd(0.03,0.8));
		p.life = rnd(20,40);
		p.frictX = 0.96;
		p.frictY = 0.96;
		p.filters = [ new flash.filters.GlowFilter(col,0.5, 2,2,4) ];
		//p.gy = -0.03;
		p.onUpdate = function() {
			if( p.y<=Const.WATER_LEVEL_F )
				p.destroy();
		}
		register(p);
	}
	
	
	public function lazerHit(x,y, ?col=0xFFEC00) {
		var p = new Particle(x+rnd(0,2,true), y+rnd(0,2,true));
		p.drawBox(1,1,col, rnd(0.2,0.6));
		p.moveAng(rnd(0,6.28), rnd(0.02,0.5));
		p.life = rnd(20,40);
		p.frictX = 0.96;
		p.frictY = 0.96;
		p.filters = [ new flash.filters.GlowFilter(col,0.5, 2,2,4) ];
		p.onUpdate = function() {
			if( p.y<=Const.WATER_LEVEL_F )
				p.destroy();
		}
		register(p);
	}
	
	public function bubbles(x,y,spawnRadius:Float, ?strength=0.1) {
		if( Const.LOWQ && Std.random(100)<70 )
			return;
		if( Particle.ALL.length>70 )
			return;
		var p = new Particle(x+rnd(0,spawnRadius*0.66,true), y+rnd(0,spawnRadius*0.66,true));
		p.graphics.lineStyle(1, 0xFFFFFF, rnd(0.6, 0.8)*strength);
		p.graphics.drawCircle(0,0, rnd(0.5+strength,2));
		p.moveAng(rnd(0,6.28), rnd(0.5, 2)*strength);
		p.life = rnd(20,40);
		p.frictX = 0.96;
		p.frictY = 0.96;
		p.life = rnd(10,40);
		p.gy = -rnd(0.05, 0.06);
		p.onUpdate = function() {
			if( p.y<=Const.WATER_LEVEL_F )
				p.destroy();
		}
		register(p);
	}
	
	public function plankton() {
		var p = new Particle( -game.scroll.x+rnd(0,game.buffer.width), -game.scroll.y+rnd(0,game.buffer.height) );
		p.drawBox(rnd(1,3),1,0x9FD0E8, rnd(0.03, 0.2));
		p.moveAng(rnd(0,6.28), rnd(0.01, 0.10));
		p.dx+=0.1;
		p.dr = rnd(0,4,true);
		p.alpha = 0;
		p.da = rnd(0.02, 0.05);
		p.life = rnd(60,90);
		if( p.y<=Const.WATER_LEVEL_F )
			p.destroy();
		//p.filters = [ new flash.filters.GlowFilter(0x9FD0E8,0.7, 4,4,2) ];
		register(p);
	}
	
	public function explode(x,y, ?radius=10., ?explosions=1) {
		for(i in 0...8)
			bubbles(x,y, radius, 0.7);
		
		if( !Const.LOWQ )
			for(i in 0...4) {
				var p = new Particle(x+rnd(0,4,true), y+rnd(0,4,true));
				p.drawCircle(rnd(4,7), 0x0,rnd(0.2, 0.4));
				p.moveAng(rnd(0,6.28), rnd(0,0.3));
				p.filters = [ new flash.filters.BlurFilter(8,8) ];
				p.life = rnd(40,90);
				register(p, BlendMode.NORMAL);
			}
		
		for(i in 0...explosions) {
			var variant = i>1 ? 1 : 0;
			var p = new Particle(x + variant*rnd(5,10,true), y + variant*rnd(5,10,true));
			p.drawCircle(radius*2-variant*rnd(2,10), 0xFFFF64, 1);
			p.ds = -0.03;
			p.delay = i+rnd(0,1);
			p.life = 5;
			p.filters = [
				new flash.filters.BlurFilter(4,4),
				new flash.filters.GlowFilter(0xFFD900,1, 8,8,1),
				new flash.filters.GlowFilter(0xFFEF97,0.2, 8,8,4),
			];
			register(p);
		}
	}
	
	public function pickUp(e:Entity) {
		for(i in 0...15) {
			var p = new Particle(e.xx, e.yy);
			p.drawBox(1,1, 0xffffff, rnd(0.5,1));
			p.moveAng(rnd(0,6.28), rnd(2,5));
			p.life = rnd(10,30);
			p.frictX = p.frictY = 0.96;
			p.filters = [new flash.filters.GlowFilter(0xB1DEDE,1, 4,4,4)];
			register(p);
		}
	}
	
	
	public function splashIn(e:Entity) {
		for(i in 0...15) {
			var p = new Particle(e.xx+rnd(0,18,true), e.yy);
			p.drawBox(1,2, 0xA39FCC, rnd(0.5,1));
			p.dx = rnd(0,1,true);
			p.dy = -rnd(1,5);
			p.groundY = p.y;
			p.ds = -0.02;
			p.life = rnd(40,60);
			p.frictX = p.frictY = 0.96;
			p.gy = 0.2;
			p.onBounce = function() p.destroy();
			if( !Const.LOWQ )
				p.filters = [new flash.filters.GlowFilter(0xFFFFFF,0.8, 4,4,4)];
			register(p);
		}
		
		if( e.dy>=0.2 )
			for(i in 0...35) {
				var p = new Particle(e.xx+rnd(0,9,true), e.yy);
				p.drawBox(1,rnd(1,4), 0xA39FCC, rnd(0.5,1));
				p.dy = rnd(0,5);
				p.ds = -0.02;
				p.life = rnd(16,50);
				p.frictX = p.frictY = 0.96;
				//p.gy = 0.1;
				p.filters = [new flash.filters.GlowFilter(0xFFFFFF,1, 4,8,4)];
				register(p);
			}
			
		e.cd.set("emitBubbles", 10);
			
		//for(i in 0...7) {
			//var p = new Particle(e.xx+1+rnd(0,16,true), Const.WATER_LEVEL_F+rnd(0,3));
			//p.drawBox(rnd(8,16), rnd(1,2), 0xFFFFFF, rnd(0.8,1));
			//p.dx = rnd(0.1,0.4,true);
			//p.scaleY = 0.2;
			//p.groundY = p.y;
			//p.filters = [ new flash.filters.BlurFilter(4,0) ];
			//p.life = rnd(20,40);
			//register(p);
		//}
	}
	
	public function splashOut(e:Entity) {
		for(i in 0...20) {
			var p = new Particle(e.xx+rnd(0,18,true), e.yy);
			p.drawBox(1,2, 0xA39FCC, rnd(0.5,1));
			p.dx = rnd(0,1,true);
			p.dy = -rnd(1,5);
			p.groundY = p.y;
			p.ds = -0.02;
			p.life = rnd(40,60);
			p.frictX = p.frictY = 0.96;
			p.gy = 0.2;
			p.onBounce = function() p.destroy();
			if( !Const.LOWQ )
				p.filters = [new flash.filters.GlowFilter(0xFFFFFF,0.8, 4,4,4)];
			register(p);
		}
	}
	
	public function shield(e:Entity) {
		blink(e, 0xFFFFFF);
		var p = new Particle(e.xx,e.yy);
		p.drawCircle(e.radius*2, 0x0, 1);
		//p.ds = -0.03;
		//p.da = 0.3;
		//p.alpha = 0;
		p.life = 4;
		p.filters = [
			//new flash.filters.BlurFilter(2,2),
			new flash.filters.GlowFilter(0xB1E4E4,0.4, 16,16,1, 1,true,true),
		];
		p.onUpdate = function() {
			p.x = e.xx;
			p.y = e.yy;
		}
		register(p);
	}
	
	public function blink(e:Entity, ?col=0xFF822F) {
		var o = {t:0.0};
		var a = game.tw.create(o, "t", 1, TEaseIn, 200);
		a.onUpdateT = function(t) {
			e.sprite.transform.colorTransform = Color.getColorizeCT(col, (1-t)*0.7);
		}
		a.onEnd = function() {
			e.sprite.transform.colorTransform = new flash.geom.ColorTransform();
		}
	}
	
	public function glow(e:Entity, ?col=0xFFC600) {
		var o = {t:0.0};
		var a = game.tw.create(o, "t", 1, TEaseIn, 600);
		a.onUpdateT = function(t) {
			e.sprite.filters = [ new flash.filters.GlowFilter(col,0.6*(1-t),8,8,1, 2) ];
		}
		a.onEnd = function() {
			e.sprite.filters = [];
		}
	}
	
	public function blood(?d=1000) {
		var s = new flash.display.Sprite();
		s.graphics.beginFill(0xFF0000,1);
		s.graphics.drawRect(0,0,Const.WID, Const.HEI);
		s.blendMode = BlendMode.OVERLAY;
		game.root.addChild(s);
		game.tw.create(s, "alpha", 0, TEaseIn, d).onEnd = function() {
			s.parent.removeChild(s);
		}
	}
	
	public function fadeIn(?d=1000, ?fadeOut=false) {
		var s = new flash.display.Sprite();
		s.graphics.beginFill(0x0,1);
		s.graphics.drawRect(0,0,Const.WID, Const.HEI);
		game.root.addChild(s);
		if( fadeOut ) {
			s.alpha = 0;
			game.tw.create(s, "alpha", 1, TLoop, d*2).onEnd = function() {
				s.parent.removeChild(s);
			}
		}
		else
			game.tw.create(s, "alpha", 0, TEaseIn, d).onEnd = function() {
				s.parent.removeChild(s);
			}
	}
	
	public function pop(x:Float,y:Float, str:Dynamic) {
		var tf = game.createField(str,true);
		tf.filters = [];
		tf.textColor = 0xFFC600;
		tf.filters = [ new flash.filters.GlowFilter(0xFFC600,0.15, 8,8,8) ];
		
		
		var bmp = Lib.flatten(tf, 8);
		game.root.addChild(bmp);
		bmp.scaleX = bmp.scaleY = Const.UPSCALE;

		var p = new Particle(x,y);
		register(p);
		p.onUpdate = function() {
			bmp.x = Std.int( (p.x+game.scroll.x)*Const.UPSCALE - bmp.width*0.5+2 );
			bmp.y = Std.int( (p.y+game.scroll.y)*Const.UPSCALE - bmp.height*0.5 );
		}
		p.onKill = function() {
			bmp.parent.removeChild(bmp);
			bmp.bitmapData.dispose();
		}
	}
	
	public function point(e:Entity, txt:String) {
		if( game.cm.turbo )
			return;
		var p = new Particle(e.xx,e.yy-5);
		
		var s = game.tiles.get("arrow");
		s.setCenter(0.5,1);
		p.addChild(s);
		
		var tf = game.createField(txt, true);
		tf.x = Std.int(-tf.width*0.5);
		tf.y = -33;
		p.addChild(tf);
		
		p.alpha = 0;
		p.da = 0.1;
		p.life = 60;
		p.onUpdate = function() {
			p.x = e.xx;
			p.y = e.yy-5;
		}
		p.onKill = function() {
			s.destroy();
		}
		register(p, BlendMode.NORMAL);
	}
	
	public function cloud(cont:flash.display.DisplayObjectContainer) {
		var p = new Particle(-50, rnd(0,game.buffer.height));
		var s = game.tiles.get("cloud");
		s.setCenter(0.5,0.5);
		p.addChild(s);
		p.dx = rnd(10,30);
		p.scaleX = rnd(0.2, 2);
		p.scaleY = p.scaleX * rnd(0.3,0.6);
		p.alpha = rnd(0.2, 0.8);
		p.life = 30;
		p.filters = [
			new flash.filters.BlurFilter(32,32),
		];
		p.onKill = function() {
			s.destroy();
		}
		cont.addChild(p);
	}
	
	public function update() {
		Particle.update();
	}
	
}