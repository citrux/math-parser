/++
    Lexer
+/
module lexer;

import std.regex;
import std.conv;

enum tokenType {
    ERROR,
    NUMBER,
    OPERATOR,
    FUNCTION,
    OPEN_PAR,
    CLOSE_PAR,
    ID
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

struct tokenRange {
    auto scanner = ctRegex!(`(\s+)|(\d+\.\d+|\d+)|([-*+/^])|(sin|cos|exp|ln)|([A-Za-z_][A-Za-z0-9_]*)|(\()|(\))|(.)`);

    // что за фигня с этими типами?
    typeof(matchAll("", scanner)) matchRange;


    this(string expression) {
        matchRange = matchAll(expression, scanner);
    }

    @property token front() {
        auto m = matchRange.front();
        auto tokType = tokenType.ERROR;
        uint id;

        // говнокооооооддддд))))
        if (m[1].length) {
            matchRange.popFront();
            m = matchRange.front();
        }

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

        if (m[6].length)
            tokType = tokenType.OPEN_PAR;

        if (m[7].length)
            tokType = tokenType.CLOSE_PAR;

        return token(tokType, id);
    }

    void popFront () {
        matchRange.popFront();
    }

    @property bool empty() {
        return matchRange.empty;
    }
}
