import std.stdio;
import lexer;
import ast;

void main() {
    writeln("Введите выражение:");
    auto expression = readln()[0 .. $-1]; // хак, чтобы не читать символ переноса строки
    auto varId = addToTable(tableIds, "x");
    auto tree = expressionToTree(expression);
    derivativeTree(tree, varId);
    writeln("Производная по x:");
    writeln(treeToExpression(tree));
    simplifyTree(tree);
    writeln("После упрощения:");
    writeln(treeToExpression(tree));
}
