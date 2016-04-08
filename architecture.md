lexer:
	Queue!token tokenize(string expression)

AST:
	AST expressionToTree(string expression)

eval:
	AST eval(AST tree)
	AST simplify(AST tree)
	AST derive(AST tree)
	AST integrate(AST tree)