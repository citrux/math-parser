import std.stdio;
import lexer;


void main() {
    writeln("Введите выражение:");
    auto expression = readln()[0 .. $-1]; // хак, чтобы не читать символ переноса строки
    auto tokens = tokenRange(expression);
    writeln("\nТокены:");
    while (!tokens.empty) {
        writeln(tokens.front);
        tokens.popFront();
    }
}