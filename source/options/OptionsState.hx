package options;

import flixel.system.FlxSound;
import utils.AFPAlphabet;
#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;

using StringTools;

class OptionsState extends MusicBeatState
{
	var options:Array<String> = ['Note Colors', 'Controls', 'Adjust Delay and Combo', 'Graphics', 'Visuals and UI', 'Gameplay'];
	private var grpOptions:FlxTypedGroup<AFPAlphabet>;
	private var curSelected(default, set):Int = 0;
	public static var menuBG:FlxSprite;
	var selectorLeft:Alphabet;
	var selectorRight:Alphabet;
	var confirmSound:FlxSound;

	private function set_curSelected(value:Int):Int
	{
		if (value < 0)
			value = options.length - 1;
		if (value >= options.length)
			value = 0;

		var bullShit:Int = 0;

		for (item in grpOptions.members) {
			item.targetY = bullShit - value;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0) {
				item.alpha = 1;
				selectorLeft.x = item.x - 63;
				selectorLeft.y = item.y;
				selectorRight.x = item.x + item.width + 15;
				selectorRight.y = item.y;
			}
		}

		curSelected = value;
		return value;
	}

	override function create() {
		#if desktop
		DiscordClient.changePresence("Options Menu", null);
		#end

		confirmSound = new FlxSound().loadEmbedded(Paths.sound('scrollMenu'), false, false);

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = 0xFFea71fd;
		bg.updateHitbox();

		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		grpOptions = new FlxTypedGroup<AFPAlphabet>();
		add(grpOptions);

		for (i in 0...options.length)
		{
			var optionText:AFPAlphabet = new AFPAlphabet(0, 0, options[i], true, i);
			optionText.onClick = function (id:Int) {
				openSelectedSubstate(options[id]);
			};
			optionText.y += (100 * (i - (options.length / 2))) + 50;
			grpOptions.add(optionText);
		}

		selectorLeft = new Alphabet(0, 0, '>', true);
		add(selectorLeft);
		selectorRight = new Alphabet(0, 0, '<', true);
		add(selectorRight);

		curSelected = 0;
		if (FlxG.save.data.curSelected_OptionsState == null)
		{
			FlxG.save.data.curSelected_OptionsState = 0;
			FlxG.save.flush();
		}
		else if (curSelected < options.length)
			curSelected = FlxG.save.data.curSelected_OptionsState;

		ClientPrefs.saveSettings();

		super.create();
	}

	override function closeSubState() {
		super.closeSubState();
		ClientPrefs.saveSettings();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (controls.UI_UP_P || FlxG.mouse.wheel > 0) {
			confirmSound.volume = FlxG.mouse.wheel > 0 ? 0.75 : 1;
			confirmSound.play(true);
			curSelected -= 1;
		}
		if (controls.UI_DOWN_P || FlxG.mouse.wheel < 0) {
			confirmSound.volume = FlxG.mouse.wheel < 0 ? 0.75 : 1;
			confirmSound.play(true);
			curSelected += 1;
		}

		if (controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

		if (controls.ACCEPT) {
			openSelectedSubstate(options[curSelected]);
		}

		grpOptions.forEach(function(spr:AFPAlphabet) {
			if (spr.focusGained && curSelected != spr.ID)
			{
				confirmSound.volume = 0.75;
				confirmSound.play(true);
				curSelected = spr.ID;
			}
		});
	}

	function openSelectedSubstate(label:String) {
		switch(label) {
			case 'Note Colors':
				openSubState(new options.NotesSubState());
			case 'Controls':
				openSubState(new options.ControlsSubState());
			case 'Graphics':
				openSubState(new options.GraphicsSettingsSubState());
			case 'Visuals and UI':
				openSubState(new options.VisualsUISubState());
			case 'Gameplay':
				openSubState(new options.GameplaySettingsSubState());
			case 'Adjust Delay and Combo':
				LoadingState.loadAndSwitchState(new options.NoteOffsetState());
		}
	}
}