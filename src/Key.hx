class Key {

	static var tmod = 1.0;
	static var kcodes = new Array<Null<Float>>();

	static var ktime = 0.;
	static var stack : Array<{k:Int, t:Float}> = new Array();

	public static function init() {
		var stage = flash.Lib.current.stage;
		stage.addEventListener(flash.events.KeyboardEvent.KEY_DOWN,callback(onKey,true));
		stage.addEventListener(flash.events.KeyboardEvent.KEY_UP,callback(onKey,false));
		stage.addEventListener(flash.events.Event.DEACTIVATE,function(_) kcodes = new Array());
		stage.addEventListener(flash.events.Event.ENTER_FRAME,onEnterFrame);
	}

	static function onEnterFrame(_) {
		ktime+=tmod;
		if( stack.length>0 && ktime-stack[stack.length-1].t>=64 )
			stack = new Array();
	}

	static function onKey( down, e : flash.events.KeyboardEvent ) {
		event(e.keyCode,down);
	}

	public static function event( code, down ) {
		if( down && kcodes[code]==null )
			stack.push( {k:code, t:ktime} );
		kcodes[code] = down ? ktime : null;
	}
	
	public static function combo(combo:Array<Int>, ?maxDelay=8.0) {
		var i = 0;
		var t = ktime;
		if( !isDown(combo[combo.length-1]) )
			return false;
		while( i<combo.length && i<stack.length ) {
			var k = combo[combo.length-1-i];
			var s = stack[stack.length-1-i];
			if( k!=s.k || t-s.t>maxDelay )
				return false;
			t = s.t;
			i++;
		}
		return i==combo.length;
	}


	public static function isDown(c) {
		return kcodes[c] != null;
	}

	public static function isToggled(c) {
		return kcodes[c] == ktime;
	}
}
