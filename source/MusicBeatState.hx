package;

import flixel.input.keyboard.FlxKey;
import flixel.input.actions.FlxAction;
import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.FlxState;
import flixel.FlxCamera;
import flixel.FlxBasic;
import flixel.input.FlxInput;
import Controls;

using StringTools;

class MusicBeatState extends FlxUIState
{
	private var curSection:Int = 0;
	private var stepsToDo:Int = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;

	private var curDecStep:Float = 0;
	private var curDecBeat:Float = 0;
	private var controls(get, never):Controls;

	public static var camBeat:FlxCamera;

	public var camConsole:FlxCamera;
	public var console:ConsoleSubState;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function create() {
		camBeat = FlxG.camera;
		var skip:Bool = FlxTransitionableState.skipNextTransOut;
		super.create();

		if(!skip) {
			openSubState(new CustomFadeTransition(0.7, true));
		}
		FlxTransitionableState.skipNextTransOut = false;

		camConsole = new FlxCamera();
		camConsole.bgColor.alpha = 0;
		FlxG.cameras.add(camConsole, false);
		console = new ConsoleSubState(0, 0, controls);
		console.openedCallback = function (newValue:Bool) {
			// for block input when console opened
			blockInput(newValue);
		};
		console.cameras = [camConsole];
		add(console);
	}

	override function update(elapsed:Float)
	{
		//everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep)
		{
			if(curStep > 0)
				stepHit();

			if(PlayState.SONG != null)
			{
				if (oldStep < curStep)
					updateSection();
				else
					rollbackSection();
			}
		}

		if(FlxG.save.data != null) FlxG.save.data.fullscreen = FlxG.fullscreen;
		if (FlxG.keys.justPressed.F8) console.opened = !console.opened;

		super.update(elapsed);
	}

	private function updateSection():Void
	{
		if(stepsToDo < 1) stepsToDo = Math.round(getBeatsOnSection() * 4);
		while(curStep >= stepsToDo)
		{
			curSection++;
			var beats:Float = getBeatsOnSection();
			stepsToDo += Math.round(beats * 4);
			sectionHit();
		}
	}

	private function rollbackSection():Void
	{
		if(curStep < 0) return;

		var lastSection:Int = curSection;
		curSection = 0;
		stepsToDo = 0;
		for (i in 0...PlayState.SONG.notes.length)
		{
			if (PlayState.SONG.notes[i] != null)
			{
				stepsToDo += Math.round(getBeatsOnSection() * 4);
				if(stepsToDo > curStep) break;
				
				curSection++;
			}
		}

		if(curSection > lastSection) sectionHit();
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
		curDecBeat = curDecStep/4;
	}

	private function updateCurStep():Void
	{
		var lastChange = Conductor.getBPMFromSeconds(Conductor.songPosition);

		var shit = ((Conductor.songPosition - ClientPrefs.noteOffset) - lastChange.songTime) / lastChange.stepCrochet;
		curDecStep = lastChange.stepTime + shit;
		curStep = lastChange.stepTime + Math.floor(shit);
	}

	public static function switchState(nextState:FlxState) {
		// Custom made Trans in
		var curState:Dynamic = FlxG.state;
		var leState:MusicBeatState = curState;
		if(!FlxTransitionableState.skipNextTransIn) {
			leState.openSubState(new CustomFadeTransition(0.6, false));
			if(nextState == FlxG.state) {
				CustomFadeTransition.finishCallback = function() {
					FlxG.resetState();
				};
				//trace('resetted');
			} else {
				CustomFadeTransition.finishCallback = function() {
					FlxG.switchState(nextState);
				};
				//trace('changed state');
			}
			return;
		}
		FlxTransitionableState.skipNextTransIn = false;
		FlxG.switchState(nextState);
	}

	public static function resetState() {
		MusicBeatState.switchState(FlxG.state);
	}

	public static function getState():MusicBeatState {
		var curState:Dynamic = FlxG.state;
		var leState:MusicBeatState = curState;
		return leState;
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		//trace('Beat: ' + curBeat);
	}

	public function sectionHit():Void
	{
		//trace('Section: ' + curSection + ', Beat: ' + curBeat + ', Step: ' + curStep);
	}

	function getBeatsOnSection()
	{
		var val:Null<Float> = 4;
		if(PlayState.SONG != null && PlayState.SONG.notes[curSection] != null) val = PlayState.SONG.notes[curSection].sectionBeats;
		return val == null ? 4 : val;
	}

	private function blockInput(block:Bool)
	{
		if (block)
		{
			@:privateAccess controls._ui_up.removeAll();
			@:privateAccess controls._ui_left.removeAll();
			@:privateAccess controls._ui_right.removeAll();
			@:privateAccess controls._ui_down.removeAll();
			@:privateAccess controls._ui_upP.removeAll();
			@:privateAccess controls._ui_leftP.removeAll();
			@:privateAccess controls._ui_rightP.removeAll();
			@:privateAccess controls._ui_downP.removeAll();
			@:privateAccess controls._ui_upR.removeAll();
			@:privateAccess controls._ui_leftR.removeAll();
			@:privateAccess controls._ui_rightR.removeAll();
			@:privateAccess controls._ui_downR.removeAll();
			@:privateAccess controls._note_up.removeAll();
			@:privateAccess controls._note_left.removeAll();
			@:privateAccess controls._note_right.removeAll();
			@:privateAccess controls._note_down.removeAll();
			@:privateAccess controls._note_upP.removeAll();
			@:privateAccess controls._note_leftP.removeAll();
			@:privateAccess controls._note_rightP.removeAll();
			@:privateAccess controls._note_downP.removeAll();
			@:privateAccess controls._note_upR.removeAll();
			@:privateAccess controls._note_leftR.removeAll();
			@:privateAccess controls._note_rightR.removeAll();
			@:privateAccess controls._note_downR.removeAll();
			@:privateAccess controls._accept.removeAll();
			@:privateAccess controls._back.removeAll();
			@:privateAccess controls._pause.removeAll();
			@:privateAccess controls._reset.removeAll();

			FlxG.sound.muteKeys = [];
			FlxG.sound.volumeDownKeys = [];
			FlxG.sound.volumeUpKeys = [];
		}
		else
		{
			if (ClientPrefs.keyBinds.get("ui_up")[0] != NONE) @:privateAccess controls._ui_up.addKey(ClientPrefs.keyBinds.get("ui_up")[0], PRESSED);
			if (ClientPrefs.keyBinds.get("ui_up")[1] != NONE) @:privateAccess controls._ui_up.addKey(ClientPrefs.keyBinds.get("ui_up")[1], PRESSED);
			if (ClientPrefs.keyBinds.get("ui_left")[0] != NONE) @:privateAccess controls._ui_left.addKey(ClientPrefs.keyBinds.get("ui_left")[0], PRESSED);
			if (ClientPrefs.keyBinds.get("ui_left")[1] != NONE) @:privateAccess controls._ui_left.addKey(ClientPrefs.keyBinds.get("ui_left")[1], PRESSED);
			if (ClientPrefs.keyBinds.get("ui_right")[0] != NONE) @:privateAccess controls._ui_right.addKey(ClientPrefs.keyBinds.get("ui_right")[0], PRESSED);
			if (ClientPrefs.keyBinds.get("ui_right")[1] != NONE) @:privateAccess controls._ui_right.addKey(ClientPrefs.keyBinds.get("ui_right")[1], PRESSED);
			if (ClientPrefs.keyBinds.get("ui_down")[0] != NONE) @:privateAccess controls._ui_down.addKey(ClientPrefs.keyBinds.get("ui_down")[0], PRESSED);
			if (ClientPrefs.keyBinds.get("ui_down")[1] != NONE) @:privateAccess controls._ui_down.addKey(ClientPrefs.keyBinds.get("ui_down")[1], PRESSED);

			if (ClientPrefs.keyBinds.get("ui_up")[0] != NONE) @:privateAccess controls._ui_upP.addKey(ClientPrefs.keyBinds.get("ui_up")[0], JUST_PRESSED);
			if (ClientPrefs.keyBinds.get("ui_up")[1] != NONE) @:privateAccess controls._ui_upP.addKey(ClientPrefs.keyBinds.get("ui_up")[1], JUST_PRESSED);
			if (ClientPrefs.keyBinds.get("ui_left")[0] != NONE) @:privateAccess controls._ui_leftP.addKey(ClientPrefs.keyBinds.get("ui_left")[0], JUST_PRESSED);
			if (ClientPrefs.keyBinds.get("ui_left")[1] != NONE) @:privateAccess controls._ui_leftP.addKey(ClientPrefs.keyBinds.get("ui_left")[1], JUST_PRESSED);
			if (ClientPrefs.keyBinds.get("ui_right")[0] != NONE) @:privateAccess controls._ui_rightP.addKey(ClientPrefs.keyBinds.get("ui_right")[0], JUST_PRESSED);
			if (ClientPrefs.keyBinds.get("ui_right")[1] != NONE) @:privateAccess controls._ui_rightP.addKey(ClientPrefs.keyBinds.get("ui_right")[1], JUST_PRESSED);
			if (ClientPrefs.keyBinds.get("ui_down")[0] != NONE) @:privateAccess controls._ui_downP.addKey(ClientPrefs.keyBinds.get("ui_down")[0], JUST_PRESSED);
			if (ClientPrefs.keyBinds.get("ui_down")[1] != NONE) @:privateAccess controls._ui_downP.addKey(ClientPrefs.keyBinds.get("ui_down")[1], JUST_PRESSED);

			if (ClientPrefs.keyBinds.get("ui_up")[0] != NONE) @:privateAccess controls._ui_upR.addKey(ClientPrefs.keyBinds.get("ui_up")[0], JUST_RELEASED);
			if (ClientPrefs.keyBinds.get("ui_up")[1] != NONE) @:privateAccess controls._ui_upR.addKey(ClientPrefs.keyBinds.get("ui_up")[1], JUST_RELEASED);
			if (ClientPrefs.keyBinds.get("ui_left")[0] != NONE) @:privateAccess controls._ui_leftR.addKey(ClientPrefs.keyBinds.get("ui_left")[0], JUST_RELEASED);
			if (ClientPrefs.keyBinds.get("ui_left")[1] != NONE) @:privateAccess controls._ui_leftR.addKey(ClientPrefs.keyBinds.get("ui_left")[1], JUST_RELEASED);
			if (ClientPrefs.keyBinds.get("ui_right")[0] != NONE) @:privateAccess controls._ui_rightR.addKey(ClientPrefs.keyBinds.get("ui_right")[0], JUST_RELEASED);
			if (ClientPrefs.keyBinds.get("ui_right")[1] != NONE) @:privateAccess controls._ui_rightR.addKey(ClientPrefs.keyBinds.get("ui_right")[1], JUST_RELEASED);
			if (ClientPrefs.keyBinds.get("ui_down")[0] != NONE) @:privateAccess controls._ui_downR.addKey(ClientPrefs.keyBinds.get("ui_down")[0], JUST_RELEASED);
			if (ClientPrefs.keyBinds.get("ui_down")[1] != NONE) @:privateAccess controls._ui_downR.addKey(ClientPrefs.keyBinds.get("ui_down")[1], JUST_RELEASED);

			if (ClientPrefs.keyBinds.get("note_up")[0] != NONE) @:privateAccess controls._note_up.addKey(ClientPrefs.keyBinds.get("note_up")[0], PRESSED);
			if (ClientPrefs.keyBinds.get("note_up")[1] != NONE) @:privateAccess controls._note_up.addKey(ClientPrefs.keyBinds.get("note_up")[1], PRESSED);
			if (ClientPrefs.keyBinds.get("note_left")[0] != NONE) @:privateAccess controls._note_left.addKey(ClientPrefs.keyBinds.get("note_left")[0], PRESSED);
			if (ClientPrefs.keyBinds.get("note_left")[1] != NONE) @:privateAccess controls._note_left.addKey(ClientPrefs.keyBinds.get("note_left")[1], PRESSED);
			if (ClientPrefs.keyBinds.get("note_right")[0] != NONE) @:privateAccess controls._note_right.addKey(ClientPrefs.keyBinds.get("note_right")[0], PRESSED);
			if (ClientPrefs.keyBinds.get("note_right")[1] != NONE) @:privateAccess controls._note_right.addKey(ClientPrefs.keyBinds.get("note_right")[1], PRESSED);
			if (ClientPrefs.keyBinds.get("note_down")[0] != NONE) @:privateAccess controls._note_down.addKey(ClientPrefs.keyBinds.get("note_down")[0], PRESSED);
			if (ClientPrefs.keyBinds.get("note_down")[1] != NONE) @:privateAccess controls._note_down.addKey(ClientPrefs.keyBinds.get("note_down")[1], PRESSED);

			if (ClientPrefs.keyBinds.get("note_up")[0] != NONE) @:privateAccess controls._note_upP.addKey(ClientPrefs.keyBinds.get("note_up")[0], JUST_PRESSED);
			if (ClientPrefs.keyBinds.get("note_up")[1] != NONE) @:privateAccess controls._note_upP.addKey(ClientPrefs.keyBinds.get("note_up")[1], JUST_PRESSED);
			if (ClientPrefs.keyBinds.get("note_left")[0] != NONE) @:privateAccess controls._note_leftP.addKey(ClientPrefs.keyBinds.get("note_left")[0], JUST_PRESSED);
			if (ClientPrefs.keyBinds.get("note_left")[1] != NONE) @:privateAccess controls._note_leftP.addKey(ClientPrefs.keyBinds.get("note_left")[1], JUST_PRESSED);
			if (ClientPrefs.keyBinds.get("note_right")[0] != NONE) @:privateAccess controls._note_rightP.addKey(ClientPrefs.keyBinds.get("note_right")[0], JUST_PRESSED);
			if (ClientPrefs.keyBinds.get("note_right")[1] != NONE) @:privateAccess controls._note_rightP.addKey(ClientPrefs.keyBinds.get("note_right")[1], JUST_PRESSED);
			if (ClientPrefs.keyBinds.get("note_down")[0] != NONE) @:privateAccess controls._note_downP.addKey(ClientPrefs.keyBinds.get("note_down")[0], JUST_PRESSED);
			if (ClientPrefs.keyBinds.get("note_down")[1] != NONE) @:privateAccess controls._note_downP.addKey(ClientPrefs.keyBinds.get("note_down")[1], JUST_PRESSED);

			if (ClientPrefs.keyBinds.get("note_up")[0] != NONE) @:privateAccess controls._note_upR.addKey(ClientPrefs.keyBinds.get("note_up")[0], JUST_RELEASED);
			if (ClientPrefs.keyBinds.get("note_up")[1] != NONE) @:privateAccess controls._note_upR.addKey(ClientPrefs.keyBinds.get("note_up")[1], JUST_RELEASED);
			if (ClientPrefs.keyBinds.get("note_left")[0] != NONE) @:privateAccess controls._note_leftR.addKey(ClientPrefs.keyBinds.get("note_left")[0], JUST_RELEASED);
			if (ClientPrefs.keyBinds.get("note_left")[1] != NONE) @:privateAccess controls._note_leftR.addKey(ClientPrefs.keyBinds.get("note_left")[1], JUST_RELEASED);
			if (ClientPrefs.keyBinds.get("note_right")[0] != NONE) @:privateAccess controls._note_rightR.addKey(ClientPrefs.keyBinds.get("note_right")[0], JUST_RELEASED);
			if (ClientPrefs.keyBinds.get("note_right")[1] != NONE) @:privateAccess controls._note_rightR.addKey(ClientPrefs.keyBinds.get("note_right")[1], JUST_RELEASED);
			if (ClientPrefs.keyBinds.get("note_down")[0] != NONE) @:privateAccess controls._note_downR.addKey(ClientPrefs.keyBinds.get("note_down")[0], JUST_RELEASED);
			if (ClientPrefs.keyBinds.get("note_down")[1] != NONE) @:privateAccess controls._note_downR.addKey(ClientPrefs.keyBinds.get("note_down")[1], JUST_RELEASED);

			if (ClientPrefs.keyBinds.get("accept")[0] != NONE) @:privateAccess controls._accept.addKey(ClientPrefs.keyBinds.get("accept")[0], JUST_PRESSED);
			if (ClientPrefs.keyBinds.get("accept")[1] != NONE) @:privateAccess controls._accept.addKey(ClientPrefs.keyBinds.get("accept")[1], JUST_PRESSED);
			if (ClientPrefs.keyBinds.get("back")[0] != NONE) @:privateAccess controls._back.addKey(ClientPrefs.keyBinds.get("back")[0], JUST_PRESSED);
			if (ClientPrefs.keyBinds.get("back")[1] != NONE) @:privateAccess controls._back.addKey(ClientPrefs.keyBinds.get("back")[1], JUST_PRESSED);
			if (ClientPrefs.keyBinds.get("pause")[0] != NONE) @:privateAccess controls._pause.addKey(ClientPrefs.keyBinds.get("pause")[0], JUST_PRESSED);
			if (ClientPrefs.keyBinds.get("pause")[1] != NONE) @:privateAccess controls._pause.addKey(ClientPrefs.keyBinds.get("pause")[1], JUST_PRESSED);
			if (ClientPrefs.keyBinds.get("reset")[0] != NONE) @:privateAccess controls._reset.addKey(ClientPrefs.keyBinds.get("reset")[0], JUST_PRESSED);
			if (ClientPrefs.keyBinds.get("reset")[1] != NONE) @:privateAccess controls._reset.addKey(ClientPrefs.keyBinds.get("reset")[1], JUST_PRESSED);

			FlxG.sound.muteKeys = TitleState.muteKeys;
			FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
			FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;
		}
	}
}
