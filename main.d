import std.stdio;
import std.math;
import std.conv;
import lexer;
import container;

BinaryTree!token * expressionToTree(string expression) {
    Stack!token output;
    Stack!token holder;
    auto tokens = tokenRange(expression);
    while (!tokens.empty) {
        auto curr = tokens.front;
        switch(curr.type) {
            case tokenType.NUMBER:
            case tokenType.ID:
                output.push(curr);
                break;
            case tokenType.OPEN_PAR:
                holder.push(curr);
                break;
            case tokenType.CLOSE_PAR:
                while (holder.top.type != tokenType.OPEN_PAR) {
                    output.push(holder.top);
                    holder.pop();
                }
                holder.pop();
                if (holder.top.type == tokenType.FUNCTION) {
                    output.push(holder.top);
                    holder.pop();
                }
                break;
            case tokenType.OPERATOR:
                if (!holder.empty && holder.top.type == tokenType.OPERATOR) {
                    if (left_associative[curr.id] &&
                            priorities[curr.id] <=
                            priorities[holder.top.id] ||
                            !left_associative[curr.id] &&
                            priorities[curr.id] <
                            priorities[holder.top.id]) {
                        output.push(holder.top);
                        holder.pop();
                    }
                }
                holder.push(curr);
                break;
            case tokenType.FUNCTION:
                holder.push(curr);
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
        if (tree.value.type == tokenType.OPERATOR && tree.right == null) {
            tree.right = new BinaryTree!token(output.top, tree);
            if (output.top.type == tokenType.OPERATOR ||
                output.top.type == tokenType.FUNCTION)
                tree = tree.right;
        }
        else {
            while (tree.left != null)
                tree = tree.parent;
            tree.left = new BinaryTree!token(output.top, tree);
            if (output.top.type == tokenType.OPERATOR ||
                output.top.type == tokenType.FUNCTION)
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
        switch(tree.value.type) {
            case tokenType.NUMBER:
                result = treeToExpression(tree.left) ~
                         to!string(tableNumbers[tree.value.id]) ~
                         treeToExpression(tree.right);
                break;
            case tokenType.ID:
                result = treeToExpression(tree.left) ~
                         tableIds[tree.value.id] ~
                         treeToExpression(tree.right);
                break;
            case tokenType.OPERATOR:
                result = treeToExpression(tree.left) ~
                         tableOperators[tree.value.id] ~
                         treeToExpression(tree.right);
                if (tree.parent != null &&
                    tree.parent.value.type == tokenType.OPERATOR &&
                    priorities[tree.parent.value.id] > priorities[tree.value.id])
                    result = "(" ~ result ~ ")";
                break;
            case tokenType.FUNCTION:
                result = tableFunctions[tree.value.id] ~
                    "(" ~ treeToExpression(tree.left) ~ ")";
                break;
            default:
                break;
        }
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
        switch(tree.value.id) {
            case 0:
                tree.value.id = addToTable(tableNumbers,
                                           tableNumbers[tree.left.value.id] +
                                           tableNumbers[tree.right.value.id]);
                break;
            case 1:
                tree.value.id = addToTable(tableNumbers,
                                           tableNumbers[tree.left.value.id] -
                                           tableNumbers[tree.right.value.id]);
                break;
            case 2:
                tree.value.id = addToTable(tableNumbers,
                                           tableNumbers[tree.left.value.id] *
                                           tableNumbers[tree.right.value.id]);
                break;
            case 3:
                tree.value.id = addToTable(tableNumbers,
                                           tableNumbers[tree.left.value.id] /
                                           tableNumbers[tree.right.value.id]);
                break;
            case 4:
                tree.value.id = addToTable(tableNumbers,
                                           pow(tableNumbers[tree.left.value.id],
                                           tableNumbers[tree.right.value.id]));
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
    auto tree1 = tree.dup;
    simplifyTree(tree);
    writeln(treeToExpression(tree));
    writeln(treeToExpression(tree1));
}
