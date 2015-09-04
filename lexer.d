import std.regex, std.regex.internal.backtracking;
import std.conv;

enum tokenType {
    ERROR,
    NUMBER,
    OPERATOR,
    OPEN_PAR,
    CLOSE_PAR,
    ID
};

struct token {
    tokenType type;
    uint id;
};

string[] tableOperators = ["+", "-", "*", "/", "^"];
double[] tableNumbers;
string[] tableIds;

uint addToTable(T)(ref T[] table, T value) {
    foreach(uint i, T el; table)
        if (el == value)
            return i;

    table ~= [value];
    return cast(uint)table.length - 1;
}

struct tokenRange {
    auto scanner = ctRegex!(`(\s+)|(\d+\.\d+|\d+)|([-*+/^])|([A-Za-z_][A-Za-z0-9_]*)|(\()|(\))|(.)`);

    // что за фигня с этими типами?
    RegexMatch!(string, BacktrackingMatcher!(true)) matchRange;


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
            tokType = tokenType.ID;
            id = addToTable(tableIds, m[0]);
        }

        if (m[5].length)
            tokType = tokenType.OPEN_PAR;

        if (m[6].length)
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
