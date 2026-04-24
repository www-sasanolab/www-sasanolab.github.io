String.prototype.trim = function () {
    return this.replace(/^\s*/, "").replace(/\s*$/, "");
};

//class
function ParserTable() {
    this.tokens = [];
    this.states = [];
    this.rules = [];
    this.popCount = [];
}

ParserTable.prototype.toHTML = function(){
	var string = "";
	var puts = function (s) { string += s; };
	var putsln = function (s) { puts(s + "\n"); };
	
	var stat = this.states;
	var tokens = this.tokens;


	for (var s = 0; s < stat.length; s++) {
            putsln("<font size=7 color=red>State: " + s + "</font></h5><br>");
            var actions = [];
            //initialize by default action
            for (var t = 0; t < tokens.length; t++)
		actions[t] = "("+ stat[s]["."].action + " . " + stat[s]["."].number + ")";
            
            for (var o in stat[s]) 
		actions[this.tokenToIndex(o)] = "("+ stat[s][o].action + " . " + stat[s][o].number + ")";

            putsln("[" + actions.join("]<br>[") + "]<br>");
	}
	return string;
};

ParserTable.prototype.makeActionFunction = function(){
    var s = "(defun do-action (rule-number args)\n";
    s += "  (cond \n";
    for(var i=0;i<this.rules.length;i++){
	s += "    ((eq rule-number " + i + ")\n";
	s += "     ;;"+this.rules[i].lhs+" := "+ this.rules[i].rhs.join(" ")+"\n";
	s += "     (message \"action: "+this.rules[i].lhs+" := "+ this.rules[i].rhs.join(" ")+ "\")\n";
	s += "    )\n";
    };
    return s + "))\n";
};

ParserTable.prototype.makeTokenMap = function(){
	var code = "(setq token-to-index '(";
	for (var i = 0; i < this.tokens.length; i++) {
            code += "(" + this.tokens[i].split("'").join("") + " . " + i + ")\n";
	}
	return code+"))";
    };

ParserTable.prototype.rulesToString = function(){
    var s = "";
    for(var i=0;i<this.rules.length;i++)
	s+= "["+i+"] " + this.rules[i].lhs +" := " + this.rules[i].rhs.join(" ") + "\n";
    return s;
};
ParserTable.prototype.rulesToHTML = function(){
    var s = "<table>";
    for(var i=0;i<this.rules.length;i++)
	s+= "<tr><td>["+i+"]</td><td> " + this.rules[i].lhs +"</td> := <td>" + this.rules[i].rhs.join(" ") + "</td></tr>\n";
    return s+"</table>";
};

ParserTable.prototype.make = function(){
    var s = [];
    s.push(this.makePopCount());
    s.push(this.makeTokenMap());
    s.push(this.makeRulesToNonterminalMap());
    s.push(this.makeActionFunction());
    s.push(this.makeParserTable());

    return s.join("\n\n");
};

ParserTable.prototype.makeRulesToNonterminalMap = function(){
    var s = "(setq rule-to-nonterminal [";
    for(var i = 0;i<this.rules.length;i++)
	s += this.rules[i].lhs + " ";
    return s +"])";    
};

ParserTable.prototype.makePopCount = function(){
    var string = "(setq pop-count [";
    for(var i=0;i<this.rules.length;i++)
	string += this.rules[i].rhs.length + " ";
    return string + "])";
};

ParserTable.prototype.makeParserTable = function(){
	var string = "(setq parser-table ";
	var puts = function (s) { string += s; };
	var putsln = function (s) { puts(s + "\n"); };

	var stat = this.states;
	var tokens = this.tokens;

	putsln("[");
	for (var s = 0; s < stat.length; s++) {
            putsln("[");
            var actions = [];
            //initialize by default action
	    if(stat[s]["."]) 
		for (var t = 0; t < tokens.length; t++)
		    actions[t] = "("+ stat[s]["."].action + " . " + stat[s]["."].number + ")";
            
            for (var o in stat[s]) 
		actions[this.tokenToIndex(o)] = "("+ stat[s][o].action + " . " + stat[s][o].number + ")";

            putsln(actions.join("\n") + "\n]");
	}
	putsln("])");
	return string;
};


ParserTable.prototype.hasToken = function (token) {
    for (var j = 0; j < this.tokens.length; j++) if (this.tokens[j] == token) return false;
    return true;
};

ParserTable.prototype.tokenToIndex = function (token) {
    for (var i = 0; i < this.tokens.length; i++) if (this.tokens[i] == token) return i;
    return -1;
};

ParserTable.prototype.collectTokens = function () {
    for (var i = 0; i < this.states.length; i++) {
        for (var token in this.states[i]) {
            if (token == ".") continue;
            this.hasToken(token) && this.tokens.push(token);
        }
    }
};


function trimLines(text) {
    var lines = [];
    text = text.split("\n");

    for (var i = 0; i < text.length; i++) {
        var line = text[i].trim();
        if (line != "") lines.push(line);
    }
    return lines;
}

ParserTable.readFromText = function(text) {
    var parserTable = new ParserTable();
    var productionRules = [];
    var lines = trimLines(text);
    var index = 0;
    var actions, test, state, prod;
    while (index < lines.length) {
        //state NN  :: one time
        actions = {};
        test = lines[index].match(/state ([0-9]+)/);
        if (test) {
            state = RegExp.$1;
            index++;
        } else break;
        //(NN) LHS : RHS :: n times
        for (; index < lines.length; ) {
            test = lines[index].match(/\(([0-9]+)\) (.*)/);
            if (test){
		prod = RegExp.$2.replace(".","").split(":");
		index++;
		if(!productionRules[RegExp.$1])
		    productionRules[RegExp.$1] = {
			'lhs' : prod[0].trim(),
			'rhs' : (function(rhs){
				   var r = [];
				     for(var i=0;i<rhs.length;i++)
					 if(rhs[i].trim()) r.push(rhs[i].trim());
				     return r;
				 })(prod[1].split(" "))
		    };
	    }else break;
        }
        //SYMBOL action N :: n times
        for (; index < lines.length; ) {
            test = lines[index].match(/(.+)\t\t([a-z]+).*/);
            var symbol = RegExp.$1;
	    var act = { action: RegExp.$2, number: -1};

            if (act.action != "error") {
                lines[index].match(/([0-9]+)/);
                act.number = RegExp.$1;
            }
            if (test) {
                index++;
                actions[symbol] = act;
            } else break;
            parserTable.states[state] = actions;
        }
	if(lines[index]&&lines[index].match(/Statistics for/)) break;
    }
    parserTable.rules = productionRules;
    return parserTable;
};
