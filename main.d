import std.stdio;
import lexer;

void main() {
    writeln("Введите выражение:");
    auto expression = readln();
    auto tokens = tokenRange(expression);
    writeln("\nТокены:");
    while (!tokens.empty) {
        writeln(tokens.front);
        tokens.popFront();
    }
}