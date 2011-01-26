=begin overview

This is the grammar for cish in Perl 6 rules.

=end overview

grammar cish::Grammar is HLL::Grammar;

token begin_block { <?> }

token TOP {
	<.begin_block>
    <statement>*
    [ $ || <.panic: "Syntax error"> ]
}

## Lexer items

# This <ws> rule treats /* this as a comment */
token ws {
    <!ww>
    [ '/*' .*? '*/' | \s+ ]*
}

## Statements

rule statement {
	<block> | <control> | <simple> ';'
}

proto token control { <...> }
rule control:sym<while> { <sym> '(' <EXPR> ')' <statement> }
rule control:sym<if>    {
	<sym> '(' <EXPR> ')' <statement> [ 'else' : <statement> ]?
}

rule block {
	'{'
		<.begin_block>
		<statement>*
	'}'
}

rule simple {
	| <builtin>
	| <EXPR>
	| <?>
}

proto token builtin { <...> }
rule builtin:sym<say>   { <sym> [ <EXPR> ] ** ','  }
rule builtin:sym<print> { <sym> [ <EXPR> ] ** ','  }

## Terms

token term:sym<integer> { <integer> }
token term:sym<quote> { <quote> }

proto token quote { <...> }
token quote:sym<'> { <?[']> <quote_EXPR: ':q'> } #'
token quote:sym<"> { <?["]> <quote_EXPR: ':qq'> }

## Operators

INIT {
    cish::Grammar.O(':prec<v>, :assoc<unary>', '%unary');
    cish::Grammar.O(':prec<u>, :assoc<left>',  '%multiplicative');
    cish::Grammar.O(':prec<t>, :assoc<left>',  '%additive');
    cish::Grammar.O(':prec<s>, :assoc<left>',  '%comparison');
    cish::Grammar.O(':prec<r>, :assoc<left>',  '%and');
    cish::Grammar.O(':prec<q>, :assoc<left>',  '%or');
    cish::Grammar.O(':prec<p>, :assoc<right>', '%ternary');
}

token circumfix:sym<( )> { '(' <.ws> <EXPR> ')' }

token prefix:sym<-> { <sym> <O('%unary, :pirop<neg>')> }
token prefix:sym<!> { <sym> <O('%unary, :pirop<not>')> }

token infix:sym<%>  { <sym> <O('%multiplicative, :pirop<mod>')> }
token infix:sym<*>  { <sym> <O('%multiplicative, :pirop<mul>')> }
token infix:sym</>  { <sym> <O('%multiplicative, :pirop<div>')> }

token infix:sym<+>  { <sym> <O('%additive, :pirop<add>')> }
token infix:sym<->  { <sym> <O('%additive, :pirop<sub>')> }

token infix:sym('<' ) { <sym> <O('%comparison, :pirop<islt IPP>')> }
token infix:sym('<=') { <sym> <O('%comparison, :pirop<isle IPP>')> }
token infix:sym('==') { <sym> <O('%comparison, :pirop<iseq IPP>')> }
token infix:sym('!=') { <sym> <O('%comparison, :pirop<isne IPP>')> }
token infix:sym('>=') { <sym> <O('%comparison, :pirop<isge IPP>')> }
token infix:sym('>' ) { <sym> <O('%comparison, :pirop<isgt IPP>')> }

token infix:sym<&&> { <sym> <O('%and, :pirop<and PPP>')> }
token infix:sym<||> { <sym> <O('%or,  :pirop<or  PPP>')> }

token infix:sym<? :> {
	'?' <EXPR('p')> ':'
	<O('%ternary, :pasttype<if>, :reducecheck<ternary>')>
}
