MIDIIn.connectAll;    // lazy, refine in the future to specific channel
s.boot;
s.meter;


// Ableton Push 2 8x8 grid midi note mappings
(
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

~beat_grid = [
	Array.fill(8, 0),
	Array.fill(8, 0),
	Array.fill(8, 0),
	Array.fill(8, 0),
	Array.fill(8, 0),
	Array.fill(8, 0),
	Array.fill(8, 0),
	Array.fill(8, 0),
];

)


//player definition and init
(
// turn into proper class
~player = {
	arg name, beat_list;
	{
		arg i;
		var amp;

		// [i, beat_list].postln;
		//
		// amp = beat_list.at(i);
		~beat_grid.do { arg beat_row; beat_row.postln;};''.postln;

		if (amp != nil, {
			if( amp>0, { ["Playing: ", name, " step ", i].postln; } );
		});
		// add synth playback here, passing in beat_list and amp value
	}
};

~player_rows = [
	~player.value("Row 1", ~beat_grid.at(0)),
	~player.value("Row 2", ~beat_grid.at(1)),
	~player.value("Row 3", ~beat_grid.at(2)),
	~player.value("Row 4", ~beat_grid.at(3)),
	~player.value("Row 5", ~beat_grid.at(4)),
	~player.value("Row 6", ~beat_grid.at(5)),
	~player.value("Row 7", ~beat_grid.at(6)),
	~player.value("Row 8", ~beat_grid.at(7)),
];
)


//activate MIDI callbacks for noteOn/noteOff
(
~noteOn = { arg src, chan, num, vel;
	if (chan != 0, {
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
	if (chan != 0, {
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

)

(
c = TempoClock.new(1);

~swing = 0.0; // swing amount
~times = [1 + ~swing, 1 - ~swing, 1 + ~swing, 1 - ~swing, 1 + ~swing, 1 - ~swing, 1 + ~swing, 1 - ~swing]; // add swing
{
	inf.do{
		arg i; // consider modulus to prevent high numbers when running indefinitely
		var index;
		index = (i % 8).asInteger;
		~player_rows.do { arg player_row;
			// value here is ugly/misleading; make a different class function
			player_row.value(index);
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