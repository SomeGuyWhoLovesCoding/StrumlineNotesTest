package;

import flixel.util.FlxSort;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;

class PlayState extends FlxState
{
	var playerKeys:Array<Array<FlxKey>> = [[A, LEFT], [S, DOWN], [W, UP], [D, RIGHT]];
	var strumlineArrows:FlxTypedGroup<FlxSprite>;
	var despawnNotes:FlxTypedGroup<FlxSprite>;

	var songSpeed:Float = 4;
	var bpm:Float = 102;
	var isUpscroll:Bool = true;

	override public function create()
	{
		FlxG.camera.bgColor = 0xFF333333;
		strumlineArrows = new FlxTypedGroup<FlxSprite>();
		add(strumlineArrows);

		despawnNotes = new FlxTypedGroup<FlxSprite>();
		add(despawnNotes);

		makeStrumline();
		generateArrows();

		super.create();
		despawnNotes.sort(isUpscroll ? sortNotesByScroll : FlxSort.byY);
	}

	function sortNotesByScroll(Order:Int, Obj1:FlxSprite, Obj2:FlxSprite):Int
	{
		return FlxSort.byValues(FlxSort.DESCENDING, Obj1.y, Obj2.y);
	}

	override public function update(elapsed:Float)
	{
		for (i in 0...playerKeys.length) {
			keyCheck(i);
			cpu(i); // For controlling the opponent's arrows
		}

		for (note in despawnNotes) {
			note.y -= (isUpscroll ? songSpeed : -songSpeed) * 5.71;
		}

		super.update(elapsed);
	}

	var chartData:Array<Dynamic>;
	public function generateArrows()
	{
		chartData = [
			{"noteData": 0, "strumTime": 0},
			{"noteData": 3, "strumTime": 90},
			{"noteData": 1, "strumTime": 90 * 2},
			{"noteData": 3, "strumTime": 90 * 3},
			{"noteData": 2, "strumTime": 90 * 4},
			{"noteData": 0, "strumTime": 90 * 6},
			{"noteData": 1, "strumTime": 90 * 8},
			{"noteData": 2, "strumTime": 90 * 10},
			{"noteData": 3, "strumTime": 90 * 12},
			{"noteData": 2, "strumTime": 90 * 14},
			{"noteData": 6, "strumTime": 90 * 15},
			{"noteData": 5, "strumTime": 90 * 16},
			{"noteData": 4, "strumTime": 90 * 17},
			{"noteData": 5, "strumTime": 90 * 18},
			{"noteData": 4, "strumTime": 90 * 20},
			{"noteData": 6, "strumTime": 90 * 22},
			{"noteData": 5, "strumTime": 90 * 23},
			{"noteData": 5, "strumTime": 90 * 24},
			{"noteData": 4, "strumTime": 90 * 25},
			{"noteData": 4, "strumTime": 90 * 26},
			{"noteData": 6, "strumTime": 90 * 27},
			{"noteData": 7, "strumTime": 90 * 28},
			{"noteData": 6, "strumTime": 90 * 29},
			{"noteData": 5, "strumTime": 90 * 30},
			{"noteData": 4, "strumTime": 90 * 31},
			{"noteData": 5, "strumTime": 90 * 32},
			{"noteData": 7, "strumTime": 90 * 33},
			{"noteData": 6, "strumTime": 90 * 34},
			{"noteData": 4, "strumTime": 90 * 35},
			{"noteData": 4, "strumTime": 90 * 35.1},
			{"noteData": 4, "strumTime": 90 * 35.2},
			{"noteData": 4, "strumTime": 90 * 35.3},
			{"noteData": 4, "strumTime": 90 * 35.4},
			{"noteData": 4, "strumTime": 90 * 35.5},
			{"noteData": 4, "strumTime": 90 * 35.6},
			{"noteData": 4, "strumTime": 90 * 35.7},
			{"noteData": 4, "strumTime": 90 * 35.8},
			{"noteData": 4, "strumTime": 90 * 35.9},
			{"noteData": 4, "strumTime": 90 * 36}
		];
		for (chart in chartData)
		{
			var babyNote:FlxSprite; // .makeGraphic(112, 112, 0xFFFF00FF)
			if (isUpscroll)
				babyNote = new FlxSprite(strumlineArrows.members[chart.noteData].x, 50 + (chart.strumTime * (60 / bpm) * songSpeed)).loadGraphic('assets/images/arrow.png');
			else
				babyNote = new FlxSprite(strumlineArrows.members[chart.noteData].x, (FlxG.height - 150) - (chart.strumTime * (60 / bpm) * songSpeed)).loadGraphic('assets/images/arrow.png');
			despawnNotes.add(babyNote);
		}
		FlxG.sound.playMusic('assets/music/freakyMenu.ogg', 1);
	}

	public function makeStrumline()
	{
		for (i in 0...2) {
			for (j in 0...4) {
				var babyArrow:FlxSprite = new FlxSprite(50 + (120 * j) + (FlxG.width / 1.875) * i, isUpscroll ? 50 : FlxG.height - 150).makeGraphic(112, 112, 0xFF666666);
				babyArrow.alpha = 0.5;
				strumlineArrows.add(babyArrow);
			}
		}
	}

	public function keyCheck(data:Int)
	{
		if (FlxG.keys.anyPressed(playerKeys[data])) {
			strumlineArrows.members[data+4].scale.set(0.95, 0.95);
			for (note in despawnNotes) {
				if (FlxG.overlap(note, strumlineArrows.members[data+4])) {
					note.kill();
				}
			}
		} else strumlineArrows.members[data+4].scale.set(1, 1);
	}

	public function cpu(data:Int) {
		for (note in despawnNotes) {
			if (FlxG.overlap(note, strumlineArrows.members[data])) {
				if (note.y<strumlineArrows.members[data].y) note.kill();
			}
		}
	}
}