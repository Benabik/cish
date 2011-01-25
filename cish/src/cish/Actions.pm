class cish::Actions is HLL::Actions;

sub past_block($/, @statements) {
	my $past := PAST::Block.new( $past, :blocktype<immediate>, :node($/) );
	for @statements { $past.push( $_.ast ); }
	return $past;
}

method TOP($/) {
	my $past := past_block($/, $<statement>);
	$past.hll('cish');
	make $past;
}

method statement($/) {
	make $<simple>.ast;
}

method simple($/) {
	if $<builtin> {
		make $<builtin>.ast
	} elsif $<EXPR> {
		make $<EXPR>.ast
	} else {
		make PAST::Op.new( :inline<noop>, :pasttype<inline>, :node($/) );
	}
}

method builtin:sym<say>($/) {
    my $past := PAST::Op.new( :name<say>, :pasttype<call>, :node($/) );
    for $<EXPR> { $past.push( $_.ast ); }
    make $past;
}

method builtin:sym<print>($/) {
    my $past := PAST::Op.new( :name<print>, :pasttype<call>, :node($/) );
    for $<EXPR> { $past.push( $_.ast ); }
    make $past;
}

method term:sym<integer>($/) {
	make PAST::Val.new( :value($<integer>.ast) );
}

method term:sym<quote>($/) { make $<quote>.ast; }

method quote:sym<'>($/) { make $<quote_EXPR>.ast; }
method quote:sym<">($/) { make $<quote_EXPR>.ast; }

method circumfix:sym<( )>($/) { make $<EXPR>.ast; }

