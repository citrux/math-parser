/++
    Lexer
+/
module lexer;

import std.regex;
import std.conv;

struct func {
    string name;

    //double eval(double arg) {
    //    mixin("return " ~ name ~ to!string(arg) ~ ";");
    //};
}

struct oper {
    string name;
    uint priority;
    bool left_associative;

    //double eval(double left, double right) {
    //    mixin("return " ~ to!string(left) ~ name ~ to!string(right) ~ ";");
    //};
}

enum tokenType {
    ERROR,
    NUMBER,
    OPERATOR,
    FUNCTION,
    OPEN_PAR,
    CLOSE_PAR,
    ID
};

union tokenData {
    func f;
    oper o;
    double d;
    int i;
};

struct token {
    tokenType type;
    uint id;

    void toString(scope void delegate(const(char)[]) sink) const {
        switch(type) {
            case tokenType.ERROR:
                sink("[ERROR]");
                break;
            case tokenType.NUMBER:
                sink(to!string(tableNumbers[id]));
                break;
            case tokenType.OPERATOR:
                sink(tableOperators[id]);
                break;
            case tokenType.FUNCTION:
                sink(tableFunctions[id]);
                break;
            case tokenType.OPEN_PAR:
                sink("(");
                break;
            case tokenType.CLOSE_PAR:
                sink(")");
                break;
            case tokenType.ID:
                sink(tableIds[id]);
                break;
            default: break;
        }
    }
};



string[] tableOperators = ["+", "-", "*", "/", "^"];
string[] tableFunctions = ["sin", "cos", "exp", "ln"];
double[] tableNumbers;
string[] tableIds;

uint[] priorities = [1, 1, 2, 2, 3];
bool[] left_associative = [1, 1, 1, 1, 0];


uint addToTable(T)(ref T[] table, T value) {
    foreach(uint i, T el; table)
        if (el == value)
            return i;

    table ~= [value];
    return cast(uint)table.length - 1;
}



Queue!token tokenize(string expression) {
    uint id;
    auto result;
    auto scanner = ctRegex!(`(\s+)|(\d+\.\d+|\d+)|([-*+/^])|(sin|cos|exp|ln)|([A-Za-z_][A-Za-z0-9_]*)|(\()|(\))|(.)`);
    foreach(m; matchAll(expression, scanner)) {
        auto tokType = tokenType.ERROR;
        // всё ещё говнокод)
        if (m[2].length) {
            tokType = tokenType.NUMBER;
            id = addToTable(tableNumbers, to!double(m[0]));
        }
        if (m[3].length) {
            tokType = tokenType.OPERATOR;
            id = addToTable(tableOperators, m[0]);
        }
        if (m[4].length) {
            tokType = tokenType.FUNCTION;
            id = addToTable(tableFunctions, m[0]);
        }
        if (m[5].length) {
            tokType = tokenType.ID;
            id = addToTable(tableIds, m[0]);
        }
        if (m[6].length) {
            tokType = tokenType.OPEN_PAR;
        }
        if (m[7].length) {
            tokType = tokenType.CLOSE_PAR;
        }
        result.push(token(tokType, id));
    }
    return result;
}
