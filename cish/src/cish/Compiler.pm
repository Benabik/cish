class cish::Compiler is HLL::Compiler;

INIT {
    cish::Compiler.language('cish');
    cish::Compiler.parsegrammar(cish::Grammar);
    cish::Compiler.parseactions(cish::Actions);
}
