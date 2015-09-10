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
                if (!holder.empty && holder.top.type == tokenType.FUNCTION) {
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

void derivativeTree(BinaryTree!token * tree, uint varId) {
    switch(tree.value.type) {
        case tokenType.NUMBER:
            tree.value.id = addToTable(tableNumbers, 0);
            break;
        case tokenType.ID:
            tree.value.type = tokenType.NUMBER;
            if (tree.value.id == varId)
                tree.value.id = addToTable(tableNumbers, 1);
            else
                tree.value.id = addToTable(tableNumbers, 0);
            break;
        case tokenType.OPERATOR:
            switch(tree.value.id) {
                case 0:
                case 1:
                    derivativeTree(tree.left, varId);
                    derivativeTree(tree.right, varId);
                    break;
                case 2:
                    auto ldup = tree.dup(tree);
                    auto rdup = tree.dup(tree);
                    tree.value.id = 0;
                    derivativeTree(ldup.left, varId);
                    derivativeTree(rdup.right, varId);
                    tree.left = ldup;
                    tree.right = rdup;
                    break;
                case 3:
                    auto ldup = tree.dup;
                    auto rdup = tree.dup;
                    ldup.value.id = 2;
                    rdup.value.id = 2;
                    derivativeTree(ldup.left, varId);
                    derivativeTree(rdup.right, varId);
                    tree.right = new BinaryTree!token(
                            token(tokenType.OPERATOR, 4), tree, tree.right);
                    tree.right.right = new BinaryTree!token(
                        token(tokenType.NUMBER, addToTable(tableNumbers, 2)),
                        tree.right);
                    tree.left = new BinaryTree!token(
                            token(tokenType.OPERATOR, 1), tree, ldup, rdup);
                    ldup.parent = tree.left;
                    rdup.parent = tree.left;
                    break;
                case 4:
                    auto l1 = tree.left.dup;
                    auto l2 = tree.left.dup;
                    auto l3 = tree.left.dup;
                    auto l4 = tree.left.dup;
                    auto r1 = tree.right.dup;
                    auto r2 = tree.right.dup;
                    auto r3 = tree.right.dup;
                    auto r4 = tree.right.dup;
                    tree.value.id = 0;
                    tree.left = new BinaryTree!token(
                            token(tokenType.OPERATOR, 2), tree);

                    tree.left.left = new BinaryTree!token(
                            token(tokenType.OPERATOR, 4), tree.left);

                    tree.left.left.left = l1;
                    l1.parent = tree.left.left;

                    tree.left.left.right = new BinaryTree!token(
                            token(tokenType.OPERATOR, 1), tree.left.left);

                    tree.left.left.right.left = r1;
                    r1.parent = tree.left.left.right;

                    tree.left.left.right.right = new BinaryTree!token(
                            token(tokenType.NUMBER, addToTable(tableNumbers,
                                    1)), tree.left.left.right);

                    derivativeTree(l2, varId);
                    tree.left.right = new BinaryTree!token(
                            token(tokenType.OPERATOR, 2), tree.left, l2, r2);
                    l2.parent = tree.left.right;
                    r2.parent = tree.left.right;


                    tree.right = new BinaryTree!token(
                            token(tokenType.OPERATOR, 2), tree);

                    tree.right.left = new BinaryTree!token(
                            token(tokenType.OPERATOR, 4), tree.right, l3, r3);
                    l3.parent = tree.right.left;
                    r3.parent = tree.right.left;

                    tree.right.right = new BinaryTree!token(
                            token(tokenType.OPERATOR, 2), tree.right);
                    tree.right.right.left = new BinaryTree!token(
                            token(tokenType.FUNCTION, 3), tree.right.right, l4);
                    l4.parent = tree.right.right.left;

                    derivativeTree(r4, varId);
                    tree.right.right.right = r4;
                    r4.parent = tree.right.right;
                    break;
                default: break;
            }
            break;
        case tokenType.FUNCTION:
            auto copy = tree.dup(tree);
            tree.value.type = tokenType.OPERATOR;
            switch(tree.value.id) {
                case 0:
                case 1:
                case 2:
                    tree.value.id = 2;
                    tree.right = tree.left;
                    derivativeTree(tree.right, varId);
                    tree.left = copy;
                    if (tree.left.value.id == 0) {tree.left.value.id = 1;}
                    else if (tree.left.value.id == 1) {
                        tree.left.value.id = 0;
                        auto newcopy = tree.dup;
                        auto minusOne = new
                            BinaryTree!token(token(tokenType.NUMBER,
                                        addToTable(tableNumbers, -1)));
                        tree.value = token(tokenType.OPERATOR, 2);
                        tree.left = minusOne;
                        tree.right = newcopy;
                        tree.left.parent = tree;
                        tree.right.parent = tree;
                    }
                    break;
                case 3:
                    tree.value.id = 3;
                    tree.right = copy.left;
                    derivativeTree(tree.left, varId);
                    break;
                default: break;
            }
            break;
        default: break;
    }
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

    auto zero = token(tokenType.NUMBER, addToTable(tableNumbers, 0));
    auto one = token(tokenType.NUMBER, addToTable(tableNumbers, 1));

    if (tree.value.type == tokenType.OPERATOR)
        switch (tree.value.id) {
            case 0:
                if (tree.left.value == zero || tree.right.value == zero) {
                    auto src = (tree.left.value == zero) ?
                        tree.right: tree.left;
                    tree.value = src.value;
                    tree.left = src.left;
                    tree.right = src.right;
                }
                break;
            case 1:
                if (tree.right.value == zero) {
                    tree.value = tree.left.value;
                    tree.right = tree.left.right;
                    tree.left = tree.left.left;
                }
                break;
            case 2:
                if (tree.left.value == zero || tree.right.value == zero) {
                    tree.value = zero;
                    tree.left = null;
                    tree.right = null;
                }
                else if (tree.left.value == one || tree.right.value == one) {
                    auto src = (tree.left.value == one) ?
                        tree.right: tree.left;
                    tree.value = src.value;
                    tree.left = src.left;
                    tree.right = src.right;
                }
                break;
            case 3:
                if (tree.right.value == one) {
                    tree.value = tree.left.value;
                    tree.right = tree.left.right;
                    tree.left = tree.left.left;
                }
                break;
            case 4:
                if (tree.right.value == one ||
                    tree.left.value == one ||
                    tree.left.value == zero) {
                    tree.value = tree.left.value;
                    tree.right = tree.left.right;
                    tree.left = tree.left.left;
                }
                break;

            default: break;
        }
}

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
