=begin overview

This is the grammar for cish in Perl 6 rules.

=end overview

grammar cish::Grammar is HLL::Grammar;

token TOP {
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
	<simple> ';'
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
    cish::Grammar.O(':prec<v>, :assoc<unary>',  '%unary');
    cish::Grammar.O(':prec<u>, :assoc<left>',   '%multiplicative');
    cish::Grammar.O(':prec<t>, :assoc<left>',   '%additive');
}

token circumfix:sym<( )> { '(' <.ws> <EXPR> ')' }

token prefix:sym<-> { <sym> <O('%unary, :pirop<neg>')> }

token infix:sym<%>  { <sym> <O('%multiplicative, :pirop<mod>')> }
token infix:sym<*>  { <sym> <O('%multiplicative, :pirop<mul>')> }
token infix:sym</>  { <sym> <O('%multiplicative, :pirop<div>')> }

token infix:sym<+>  { <sym> <O('%additive, :pirop<add>')> }
token infix:sym<->  { <sym> <O('%additive, :pirop<sub>')> }
