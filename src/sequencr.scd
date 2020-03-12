s.boot;

// Init main vars: note layout, beat grid, player instances
(
// Ableton Push 2 8x8 grid midi note mappings
~note_grid = [
[92, 93, 94, 95, 96, 97, 98, 99],
[84, 85, 86, 87, 88, 89, 90, 91],
[76, 77, 78, 79, 80, 81, 82, 83],
[68, 69, 70, 71, 72, 73, 74, 75],
[60, 61, 62, 63, 64, 65, 66, 67],
[52, 53, 54, 55, 56, 57, 58, 59],
[44, 45, 46, 47, 48, 49, 50, 51],
[36, 37, 38, 39, 40, 41, 42, 43],
];

~channel = 0; // input channel, 0-based index so this is MIDI-channel 1

~cols = 8; // width of grid

~bars = 1; // ideally loops will be more than one bar (TODO: integrate in player/grid)

~beat_grid = [
	Array.fill(~cols, 0),
	Array.fill(~cols, 0),
	Array.fill(~cols, 0),
	Array.fill(~cols, 0),
	Array.fill(~cols, 0),
	Array.fill(~cols, 0),
	Array.fill(~cols, 0),
	Array.fill(~cols, 0),
];

~player_rows = [
	SeqPlayer.new("Row 1", 0, ~beat_grid.at(0), SeqBaseInstrument.new),
	SeqPlayer.new("Row 2", 1, ~beat_grid.at(1), SeqBaseInstrument.new),
	SeqPlayer.new("Row 3", 2, ~beat_grid.at(2), SeqBaseInstrument.new),
	SeqPlayer.new("Row 4", 3, ~beat_grid.at(3), SeqBaseInstrument.new),
	SeqPlayer.new("Row 5", 4, ~beat_grid.at(4), SeqBaseInstrument.new),
	SeqPlayer.new("Row 6", 5, ~beat_grid.at(5), SeqBaseInstrument.new),
	SeqPlayer.new("Row 7", 6, ~beat_grid.at(6), SeqBaseInstrument.new),
	SeqPlayer.new("Row 8", 7, ~beat_grid.at(7), SeqBaseInstrument.new),
];
)


//activate MIDI in and callbacks for noteOn/noteOff
(
MIDIIn.connectAll;    // lazy, refine in the future to specific channel
~noteOn = { arg src, chan, num, vel;
	if (chan != ~channel, {
		~note_grid.do { arg row, i;
			// find which column matches to the note in the beat list
			var beat_col = row.indexOf(num);
			if (beat_col != nil, { // find which row the note is in
				// update beat list to show 1 for that column
				// update player with new beat list
				~beat_grid.at(i).put(beat_col, 1);
			});
		};
	});
};

~noteOff = { arg src,chan,num,vel;
	if (chan != ~channel, {
		~note_grid.do { arg row, i;
			// find which column matches to the note in the beat list
			var beat_col = row.indexOf(num);
			if (beat_col != nil, { // find which row the note is in
				// update beat list to show 0 for that column
				// update player with new beat list
				~beat_grid.at(i).put(beat_col, 0);
			});
		};
	});
};

MIDIIn.addFuncTo(\noteOn, ~noteOn);
MIDIIn.addFuncTo(\noteOff, ~noteOff);

c = TempoClock.new(1);

~swing = 0.0; // swing amount
~times = [1 + ~swing, 1 - ~swing, 1 + ~swing, 1 - ~swing, 1 + ~swing, 1 - ~swing, 1 + ~swing, 1 - ~swing]; // add swing
{
	inf.do{
		arg i;
		var index;
		index = (i % 8).asInteger;
		~player_rows.do { arg player_row;
			player_row.play(index);
		};

		~times.at(index).wait;
	};

}.fork(c);
)

//MIDI and clock cleanup
(
c.stop;
MIDIIn.removeFuncFrom(\noteOn, ~noteOn);
MIDIIn.removeFuncFrom(\noteOff, ~noteOff);
MIDIIn.disconnectAll
)