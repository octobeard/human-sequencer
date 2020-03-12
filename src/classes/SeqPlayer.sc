
//player definition and init
SeqPlayer {
	var <name, <row, <>row_data, <instrument;

	*new { | name, row, row_data, instrument |
		^super.newCopyArgs(name, row, row_data, instrument);
	}

	play { | col |
		var amp = row_data.at(col);
		if (amp != nil, {
			if( amp>0, { instrument.on(row, col, row_data); } );
			if( amp==0, { instrument.off(row, col, row_data); } );
		});
	}
}