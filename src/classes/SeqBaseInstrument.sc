SeqBaseInstrument {
	var amp = 0;

	on { | row, col, row_data |
		amp = 1;
		^["Playing", row, col, row_data].postln;
	}

	off { | row, col, row_data |
		if (amp == 1, {
			amp = 0;
			^["Stopping", row, col, row_data].postln;
		});
		^nil
	}
}