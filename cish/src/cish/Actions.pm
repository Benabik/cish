class cish::Actions is HLL::Actions;

our @BLOCKS; # @BLOCKS[0] = current scope, 1.. surrounding

method begin_block($/) {
	@BLOCKS.unshift( PAST::Block.new(:blocktype<immediate>, :node($/)) );
}

sub past_block($/, @statements) {
	my $past := @BLOCKS.shift();
	for @statements { $past.push( $_.ast ); }
	return $past;
}

method TOP($/) {
	my $past := past_block($/, $<statement>);
	$past.hll('cish');
	make $past;
}

method statement($/) {
	if $<block> {
		make $<block>.ast;
	} elsif $<control> {
		make $<control>.ast;
	} else {
		make $<simple>.ast;
	}
}

method block($/) {
	make past_block($/, $<statement>);
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

method control:sym<while>($/) {
	make PAST::Op.new(
		$<EXPR>.ast,
		$<statement>.ast,
		:pasttype<while>, :node($/)
	);
}

method control:sym<if>($/) {
	my $past := PAST::Op.new( $<EXPR>.ast, :pasttype<if>, :node($/) );
	for $<statement> { $past.push( $_.ast ); }
	make $past;
}

method term:sym<integer>($/) {
	make PAST::Val.new( :value($<integer>.ast) );
}

method term:sym<quote>($/) { make $<quote>.ast; }

method quote:sym<'>($/) { make $<quote_EXPR>.ast; }
method quote:sym<">($/) { make $<quote_EXPR>.ast; }

method circumfix:sym<( )>($/) { make $<EXPR>.ast; }

