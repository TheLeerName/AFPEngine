package;

import utils.AFPInputText;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import flixel.addons.ui.FlxInputText;
import flixel.text.FlxText;

import FunkinLua;
import hscript.Parser;
import hscript.Interp;
import hscript.Expr;

using StringTools;

@:build(macros.SetCallbacksBuilding.build())
class ConsoleSubState extends FlxSpriteGroup
{
	public var consoleAlpha(default, set):Float = 0.8;
	public var bg:FlxSprite;
	public var inputText:AFPInputText;
	public var opened(default, set):Bool = false;
	public var openedCallback:Bool->Void;
	public var inputText_log:Array<FlxText> = [];
	public var hscript:HScript;

	private var saveMouseVisible:Bool = false;
	private function set_opened(value:Bool):Bool
	{
		bg.alpha = inputText.alpha = value ? consoleAlpha : 0;
		opened = value;
		FlxG.mouse.visible = value ? value : saveMouseVisible;
		if (openedCallback != null) openedCallback(value);
		return value;
	}

	private function set_consoleAlpha(value:Float):Float
	{
		for (th in inputText_log)
			th.alpha = value;
		bg.alpha = inputText.background.alpha = value;
		return value;
	}

	public function new(x:Float = 0, y:Float = 0, controls:Controls)
	{
		super(x, y);

		hscript = new HScript();

		bg = new FlxSprite(x, y).makeGraphic(Std.int(FlxG.width * 0.4), Std.int(FlxG.width * 0.2));
		add(bg);

		inputText = new AFPInputText(0, FlxG.width * 0.2, Std.int(FlxG.width * 0.4), "", 16, FlxColor.WHITE, FlxColor.BLACK, Paths.font("vcr.ttf"));
		inputText.updateCallback = function (focusGained:Bool) {
			if (focusGained && FlxG.keys.justPressed.ENTER)
			{
				if (inputText.text.length > 0)
					executeCommand(inputText.text);
				inputText.text = "";
			}
		};
		add(inputText);

		// update values
		saveMouseVisible = FlxG.mouse.visible;
		opened = opened;

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	public function executeCommand(command:String)
	{
		var cmdName:String = command.substring(0, command.indexOf(" "));
		var cmd:String = command.substring(command.indexOf(" ") + 1, command.length);
		switch(cmdName)
		{
			case "switchState":
				try {
					hscript.variables.set('MusicBeatState', MusicBeatState);
					hscript.variables.set(cmd.substring(cmd.indexOf(".") + 1, cmd.length), Type.resolveClass(cmd));
					hscript.execute("MusicBeatState.switchState(new " + cmd + "());");
					//opened = false;
				}
				catch (e) {
					addLog(e.message.substring(e.message.indexOf(": ") + 2, e.message.length), FlxColor.RED);
				}
			case "echo":
				addLog(cmd);
			default:
				try {
					//opened = false;
					hscript.execute(cmd + ";");
				}
				catch (e) {
					addLog(e.message.substring(e.message.indexOf(": ") + 2, e.message.length), FlxColor.RED);
				}
		}
	}

	public function addLog(logStr:String, color:FlxColor = FlxColor.BLACK)
	{
		var d:FlxText = new FlxText(bg.x, bg.y, inputText.textObject.fieldWidth, logStr, inputText.textObject.size);
		d.color = color;
		d.font = inputText.textObject.font;
		d.y += inputText_log.length * d.height;
		inputText_log.push(d);
		add(d);

		if (inputText_log[inputText_log.length - 1].y + inputText_log[inputText_log.length - 1].height > (bg.y + bg.height))
		{
			inputText_log[0].kill();
			inputText_log[0].destroy();
			inputText_log.splice(0, 1);
			for (i in 0...inputText_log.length)
				inputText_log[i].y = bg.y + (i * inputText_log[i].height);
		}
	}

	public override function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	public override function destroy()
	{
		super.destroy();
		opened = false;
		FlxG.mouse.visible = saveMouseVisible;
	}
}