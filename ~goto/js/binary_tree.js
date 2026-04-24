function node(value, left, right) {
    return {
        value: value,
        left: left,
        right: right
    };
}

function node2string(node) {
    if (node.left)
        return "(" + node.value + " " + node2string(node.left) + (node.right ? (", " + node2string(node.right)) : "") + ")";
    else return node.value;
}


function treeDepth(n) {
    var l, r;
    if (n.left) {
        l = treeDepth(n.left);
        if (n.right) {

            r = treeDepth(n.right);
            return (l < r ? r : l) + 1;
        }
        return l + 1;
    } else return 1;
}

function treeWidth(t) {
    var l, r;
    if (t.left) {
        l = treeDepth(t.left);
        if (t.right) {

            r = treeDepth(t.right);
            return l + r;
        }
        return l;
    } else return 1;
}

function maxX(tree) {
    var l, r;
    if (tree.left) {
        l = maxX(tree.left);
        if (tree.right) {
            r = maxX(tree.right);
            return l < r ? r : l;
        } else return l;
    }
    return tree.x;
}

function minY(tree) {
    if (tree.right)
        return tree.left.y < tree.right.y ? tree.left.y : tree.right.y;
    else return tree.left.y;
}

function drawTree(p, tree, x, y) {
    var leftChildPos = null;
    var rightChildPos = null;

    //size of box.
    var box_w = 70;
    var box_h = 20;

    if (tree.left != null) {
        //draw left child
        drawTree(p, tree.left, x, y);

        //draw right child if it exist
        tree.right && drawTree(p, tree.right, maxX(tree.left) + 80, y);

        var mx = tree.right ? (tree.left.x + (tree.right.x - tree.left.x) / 2) : tree.left.x;
        var my = minY(tree) - 35;
        tree.x = mx;
        tree.y = my;

        //draw lines and boxes
        p.fill(255);
        p.line(mx + box_w / 2, my + box_h, tree.left.x + box_w / 2, tree.left.y);
        tree.right && p.line(mx + box_w / 2, my + box_h, tree.right.x + box_w / 2, tree.right.y);

        p.rect(mx, my, box_w, box_h);
        p.fill(0);
        p.text(tree.value, mx + 5, my + 15);
    }


    //if tree represents terminal symbol then come here
    if ((tree.left == null) && (tree.right == null)) {

        //remember position in this tree
        tree.x = x;
        tree.y = y;

        //draw 
        p.fill(220);
        p.rect(x, y, 60, 20);
        p.fill(192, 64, 64);
        p.text(tree.value, x + 5, y + 15);
    }
}

function visualizeTree(tree) {
    var canvas = document.createElement("canvas");

    var p = Processing(canvas);
    var width = treeDepth(tree);
    var height = treeWidth(tree);

    p.setup = function () {
        //precomputation to calculate the size of parse tree
        drawTree(p, tree, 5, height * 30);

        this.size(maxX(tree) + 100, 35 * height);

        //redraw
        this.background(192, 192, 160);
        drawTree(p, tree, 5, height * 30);
    };

    //start drawing
    p.init();
    return canvas;
}

