package utils;

import flixel.util.FlxTimer;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.input.keyboard.FlxKey;
import flixel.FlxG;
import flixel.text.FlxText;

using StringTools;

class AFPInputText extends FlxSpriteGroup
{
	/**
	 * Is focus gained?
	 */
	public var focusGained(default, set):Bool = false;

	/**
	 * Callback executes on update, returns focusGained
	 */
	 public var updateCallback:Bool->Void;


	/**
	 * Object of input text
	 */
	public var textObject:FlxText;

	/**
	 * Time after which input will run when key is pressed (not just pressed)
	 */
	public var textHoldTime:Float = 0.5;

	/**
	 * String text of textObject variable (shortcut to textObject.text)
	 */
	public var text(default, set):String = "";

	/**
	 * Index of textObject variable at which the new character will be entered or removed
	 */
	public var textIndex(default, set):Int = 0;


	/**
	 * Object of rectangle thing on index of textObject
	 */
	public var rectangle:FlxSprite;

	/**
	 * Timer object, used for rectFlickerTime
	 */
	public var rectVisibleChange:FlxTimer;

	/**
	 * The time after which will change rectangle.visible variable
 	 */
	public var rectFlickerTime:Float = 0.25;


	/**
	 * Object of background thing
 	 */
	public var background:FlxSprite;


	private var keyArray:Map<Int, Array<String>> = [
		// keycode => [string in lowercase, string in uppercase]
		-2 => ['any', 'ANY'],
		-1 => ['none', 'NONE'],
		65 => ['a', 'A'],
		66 => ['b', 'B'],
		67 => ['c', 'C'],
		68 => ['d', 'D'],
		69 => ['e', 'E'],
		70 => ['f', 'F'],
		71 => ['g', 'G'],
		72 => ['h', 'H'],
		73 => ['i', 'I'],
		74 => ['j', 'J'],
		75 => ['k', 'K'],
		76 => ['l', 'L'],
		77 => ['m', 'M'],
		78 => ['n', 'N'],
		79 => ['o', 'O'],
		80 => ['p', 'P'],
		81 => ['q', 'Q'],
		82 => ['r', 'R'],
		83 => ['s', 'S'],
		84 => ['t', 'T'],
		85 => ['u', 'U'],
		86 => ['v', 'V'],
		87 => ['w', 'W'],
		88 => ['x', 'X'],
		89 => ['y', 'Y'],
		90 => ['z', 'Z'],
		48 => ['0', ')'],
		49 => ['1', '!'],
		50 => ['2', '@'],
		51 => ['3', '#'],
		52 => ['4', '$'],
		53 => ['5', '%'],
		54 => ['6', '^'],
		55 => ['7', '&'],
		56 => ['8', '*'],
		57 => ['9', '('],
		33 => ['pageup', 'PAGEUP'],
		34 => ['pagedown', 'PAGEDOWN'],
		36 => ['home', 'HOME'],
		35 => ['end', 'END'],
		45 => ['insert', 'INSERT'],
		27 => ['escape', 'ESCAPE'],
		189 => ['-', '_'],
		187 => ['=', '+'],
		46 => ['delete', 'DELETE'],
		8 => ['backspace', 'BACKSPACE'],
		219 => ['[', '{'],
		221 => [']', '}'],
		220 => ['\\', '|'],
		20 => ['capslock', 'CAPSLOCK'],
		186 => [';', ':'],
		222 => ['\'', '"'],
		13 => ['enter', 'ENTER'],
		16 => ['shift', 'SHIFT'],
		188 => [',', '<'],
		190 => ['.', '>'],
		191 => ['/', '?'],
		192 => ['`', '~'],
		17 => ['control', 'CONTROL'],
		18 => ['alt', 'ALT'],
		32 => [' ', ' '],
		38 => ['up', 'UP'],
		40 => ['down', 'DOWN'],
		37 => ['left', 'LEFT'],
		39 => ['right', 'RIGHT'],
		9 => ['tab', 'TAB'],
		301 => ['printscreen', 'PRINTSCREEN'],
		112 => ['f1', 'F1'],
		113 => ['f2', 'F2'],
		114 => ['f3', 'F3'],
		115 => ['f4', 'F4'],
		116 => ['f5', 'F5'],
		117 => ['f6', 'F6'],
		118 => ['f7', 'F7'],
		119 => ['f8', 'F8'],
		120 => ['f9', 'F9'],
		121 => ['f10', 'F10'],
		122 => ['f11', 'F11'],
		123 => ['f12', 'F12'],
		96 => ['0', '0'],
		97 => ['1', '1'],
		98 => ['2', '2'],
		99 => ['3', '3'],
		100 => ['4', '4'],
		101 => ['5', '5'],
		102 => ['6', '6'],
		103 => ['7', '7'],
		104 => ['8', '8'],
		105 => ['9', '9'],
		109 => ['-', '-'],
		107 => ['+', '+'],
		110 => ['/', '/'],
		106 => ['*', '*']
	];

	private function set_textIndex(value:Int)
	{
		if (value < 0)
			value = 0;
		if (value > text.length)
			value = text.length;

		rectangle.x = (textObject.textField.textWidth / text.length) * value;
		rectangle.setGraphicSize(Std.int(rectangle.width), Std.int(textObject.textField.textHeight * 1.2));
		rectangle.updateHitbox();
		textIndex = value;
		return value;
	}

	private function set_text(value:String)
	{
		if (textIndex < 0)
			textIndex = 0;
		if (textIndex > value.length)
			textIndex = value.length;

		textObject.text = value;
		while (textObject.textField.textWidth > textObject.fieldWidth)
		{
			textObject.text = textObject.text.substring(1, textObject.text.length);
			if (textIndex < 0)
				textIndex = 0;
			if (textIndex > value.length)
				textIndex = value.length;
		}
		text = value;
		return value;
	}

	private function set_focusGained(value:Bool)
	{
		if (value)
		{
			rectVisibleChange.start(rectFlickerTime, function (tmr:FlxTimer) {
				rectangle.visible = rectangle.visible ? false : true;
				tmr.reset();
			});
		}
		else
		{
			if (!rectVisibleChange.finished) rectVisibleChange.cancel();
			rectangle.visible = false;
		}
		return focusGained = value;
	}

	/**
	 * Creates a new `AFPInputText` object at the specified position. (like the address bar in your browser)
	 *
	 * @param   x                The x position of the text.
	 * @param   y                The y position of the text.
	 * @param   fieldWidth       The `width` of the text object. Enables `autoSize` if `<= 0`. (`height` is determined automatically).
	 * @param   textString       The actual text you would like to display initially.
	 * @param   size             The font size for this text object.
	 * @param   textColor        The color of the text object.
	 * @param   backgroundColor  The color of the background object.
	 * @param   font             The font of the text object.
	 */
	public function new(x:Float, y:Float, fieldWidth:Float = 0, textString:String = "", size:Int = 8, textColor:FlxColor = null, backgroundColor:FlxColor = null, font:String = "Nokia Cellphone FC Small")
	{
		super(0, 0);
		rectVisibleChange = new FlxTimer();

		background = new FlxSprite(x, y).makeGraphic(100, 100, (backgroundColor == null ? FlxColor.BLACK : backgroundColor));
		textObject = new FlxText(x, y, fieldWidth, textString, size, true);
		rectangle = new FlxSprite(x, y).makeGraphic(2, 10, (textColor == null ? FlxColor.BLACK : textColor));

		add(background);
		background.setGraphicSize(Std.int(textObject.width), Std.int(textObject.height * 0.8));
		background.updateHitbox();

		add(textObject);
		textObject.wordWrap = false;
		textObject.font = font;
		textObject.color = (textColor == null ? FlxColor.BLACK : textColor);

		add(rectangle);

		// update values
		focusGained = false;
		text = textString;
		textIndex = text.length;
	}

	private var holdTime:Float = 0;
	public override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (FlxG.mouse.justPressed)
			focusGained = mouseOverlaps(textObject);

		if (FlxG.keys.justPressed.ESCAPE && focusGained)
			focusGained = false;

		if (focusGained)
		{
			var keyJustPressed = FlxG.keys.firstJustPressed();

			if (keyJustPressed > -1)
				inputThings(keyJustPressed);

			// need rework
			/*var keyPressed = FlxG.keys.firstPressed();

			if (keyPressed > -1)
			{
				holdTime += elapsed;
				if (holdTime >= textHoldTime)
				{
					inputThings(keyPressed);
				}
			}
			else
				holdTime = 0;*/
		}

		if (updateCallback != null)
			updateCallback(focusGained);
	}

	private function inputThings(keyPressed:Int)
	{
		if (keyArray.get(keyPressed)[0].length == 1)
		{
			var addText:String = keyArray.get(keyPressed)[0];
			if (FlxG.keys.pressed.SHIFT /*|| FlxG.keys.pressed.CAPSLOCK*/) // idk capslock not working properly
				addText = keyArray.get(keyPressed)[1];
			text = text.substring(0, textIndex) + addText + text.substring(textIndex, text.length);
			textIndex++;
		}
		else if (keyPressed == 8)
		{
			textIndex--;
			text = text.substring(0, textIndex) + text.substring(textIndex + 1, text.length);
		}
		else if (keyPressed == 46)
		{
			text = text.substring(0, textIndex) + text.substring(textIndex + 1, text.length);
		}
		else if (keyPressed == 37)
			textIndex--;
		else if (keyPressed == 39)
			textIndex++;
	}

	private function mouseOverlaps(object:FlxText)
	{
		return object.overlapsPoint(new FlxPoint(FlxG.mouse.getScreenPosition(FlxG.cameras.list[FlxG.cameras.list.length - 1]).x, FlxG.mouse.getScreenPosition(FlxG.cameras.list[FlxG.cameras.list.length - 1]).y), true, FlxG.cameras.list[FlxG.cameras.list.length - 1]);
	}
}