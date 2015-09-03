import std.stdio;
import std.math;
import std.conv;
import lexer;
import container;

BinaryTree!token * expressionToTree(string expression) {
    bool left_associative[string];
    int priority[string];

    priority["+"] = 1;
    left_associative["+"] = true;
    priority["-"] = 1;
    left_associative["-"] = true;
    priority["*"] = 2;
    left_associative["*"] = true;
    priority["/"] = 2;
    left_associative["/"] = true;
    priority["^"] = 3;
    left_associative["^"] = false;

    Stack!token output;
    Stack!token holder;
    auto tokens = tokenRange(expression);
    while (!tokens.empty) {

        switch(tokens.front.type) {
            case tokenType.NUMBER:
            case tokenType.ID:
                output.push(tokens.front);
                break;
            case tokenType.OPEN_PAR:
                holder.push(tokens.front);
                break;
            case tokenType.CLOSE_PAR:
                while (holder.top.type != tokenType.OPEN_PAR) {
                    output.push(holder.top);
                    holder.pop();
                }
                holder.pop();
                break;
            case tokenType.OPERATOR:
                if (!holder.empty && holder.top.type == tokenType.OPERATOR) {
                    if (left_associative[tokens.front.value] &&
                            priority[tokens.front.value] <=
                            priority[holder.top.value] ||
                            !left_associative[tokens.front.value] &&
                            priority[tokens.front.value] <
                            priority[holder.top.value]) {
                        output.push(holder.top);
                        holder.pop();
                    }
                }
                holder.push(tokens.front);
                break;
            default:
                break;
        }

        tokens.popFront();
    }
    while(!holder.empty) {
        output.push(holder.top);
        holder.pop();
    }

    auto tree = new BinaryTree!token(output.top);
    output.pop();
    while(!output.empty) {
        if (tree.right == null) {
            tree.right = new BinaryTree!token(output.top, tree);
            if (output.top.type == tokenType.OPERATOR)
                tree = tree.right;
        }
        else {
            while (tree.left != null)
                tree = tree.parent;
            tree.left = new BinaryTree!token(output.top, tree);
            if (output.top.type == tokenType.OPERATOR)
                tree = tree.left;
        }
        output.pop();
    }
    while (tree.parent != null)
        tree = tree.parent;
    return tree;
}

string treeToExpression(BinaryTree!token * tree) {
    string result = "";
    if (tree != null) {
        result = treeToExpression(tree.left) ~ tree.value.value ~
            treeToExpression(tree.right);
    }
    return result;
}

void simplifyTree(BinaryTree!token * tree) {
    if (tree.left != null)
        simplifyTree(tree.left);
    if (tree.right != null)
        simplifyTree(tree.right);
    if (tree.left != null &&
        tree.right != null &&
        tree.left.value.type == tokenType.NUMBER &&
        tree.right.value.type == tokenType.NUMBER) {

        tree.value.type = tokenType.NUMBER;
        switch(tree.value.value) {
            case "+":
                tree.value.value = to!string(to!int(tree.left.value.value) +
                                             to!int(tree.right.value.value));
                break;
            case "-":
                tree.value.value = to!string(to!int(tree.left.value.value) -
                                             to!int(tree.right.value.value));
                break;
            case "*":
                tree.value.value = to!string(to!int(tree.left.value.value) *
                                             to!int(tree.right.value.value));
                break;
            case "/":
                tree.value.value = to!string(to!int(tree.left.value.value) /
                                             to!int(tree.right.value.value));
                break;
            case "^":
                tree.value.value = to!string(pow(to!int(tree.left.value.value),
                                             to!int(tree.right.value.value)));
                break;
            default: break;
        }
        tree.left = null;
        tree.right = null;
    }
}


void main() {
    writeln("Введите выражение:");
    auto expression = readln()[0 .. $-1]; // хак, чтобы не читать символ переноса строки
    auto tree = expressionToTree(expression);
    simplifyTree(tree);
    writeln(treeToExpression(tree));
}
