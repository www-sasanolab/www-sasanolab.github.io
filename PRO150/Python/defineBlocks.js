var list_name = [];

// Block Defines

Blockly.Blocks['getvariable'] = {
  init: function() {
    this.appendDummyInput()
        .appendField(new Blockly.FieldVariable('newVariable'), "getVar");
    this.setOutput(true, ["Variable", "Expression"]);
    this.setColour(180);
  }
};

Blockly.Blocks['string'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("\"")
        .appendField(new Blockly.FieldTextInput(""), "strText")
        .appendField("\"");
    this.setOutput(true, "String");
    this.setColour(30);
  }
};

Blockly.Blocks['number'] = {
  init: function() {
    this.appendDummyInput()
        .appendField(new Blockly.FieldNumber(0), "num");
    this.setOutput(true, ["Number", "Expression"]);
    this.setColour(90);
  }
}

Blockly.Blocks['print'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("print(");
    this.appendValueInput("printValue")
        .setCheck(["String", "Expression"]);
    this.appendDummyInput()
        .appendField(")");
    this.setInputsInline(true);
    this.setPreviousStatement(true, ['Statement']);
    this.setNextStatement(true, ['Statement']);
    this.setColour(60);
    this.setTooltip("");
    this.setHelpUrl("");
  }
};

Blockly.Blocks['print2'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("print(");
    this.appendValueInput("print2Value")
        .setCheck(["String", "Expression"]);
    this.appendDummyInput()
        .appendField(", end=' ')");
    this.setInputsInline(true);
    this.setPreviousStatement(true, ['Statement']);
    this.setNextStatement(true, ['Statement']);
    this.setColour(60);
    this.setTooltip("");
    this.setHelpUrl("");
  }
};

Blockly.Blocks['assinput'] = {
  init: function() {
    this.appendValueInput("inputValue")
        .setCheck("Variable");
    this.appendDummyInput()
        .appendField("= str(input())");
    this.setInputsInline(true);
    this.setPreviousStatement(true, ['Statement']);
    this.setNextStatement(true, ['Statement']);
    this.setColour(60);
    this.setTooltip("");
    this.setHelpUrl("");
  }
};

Blockly.Blocks['assinputnum'] = {
  init: function() {
    this.appendValueInput("inputValue")
        .setCheck("Variable");
    this.appendDummyInput()
        .appendField("= float(input())");
    this.setInputsInline(true);
    this.setPreviousStatement(true, ['Statement']);
    this.setNextStatement(true, ['Statement']);
    this.setColour(60);
    this.setTooltip("");
    this.setHelpUrl("");
  }
};

Blockly.Blocks['assignment']  = {
  init: function() {
    this.appendValueInput("assValue1")
        .setCheck("Variable");
    this.appendDummyInput()
        .appendField("=");
    this.appendValueInput("assValue2")
        .setCheck(["String", "Expression"]);
    this.setInputsInline(true);
    this.setPreviousStatement(true, null);
    this.setNextStatement(true, null);
    this.setColour("#A9A9A9");
    this.setTooltip("");
    this.setHelpUrl("");
  }
};

Blockly.Blocks['arithmetic'] = {
  init: function() {
    this.appendValueInput("arithValue1")
        .setCheck(["String", "Expression"]);
    this.appendDummyInput()
        .appendField(new Blockly.FieldDropdown([
            ['+', '+'],
            ['-', '-'],
            ['*', '*'],
            ['/', '/'],
            ['//', '//'],
            ['%', '%'],
            ['**', '**']
        ]), 'arithOperator');
    this.appendValueInput("arithValue2")
        .setCheck(["String", "Expression"]);
    this.setInputsInline(true);
    this.setOutput(true, "Expression");
    this.setColour("#A9A9A9");
  }
}

Blockly.Blocks['compare'] = {
  init: function() {
    this.appendValueInput("compValue1")
        .setCheck(["Compare", "String", "Expression"]);
    this.appendDummyInput()
        .appendField(new Blockly.FieldDropdown([
            ['==', '=='],
            ['!=', '!='],
            ['<', '<'],
            ['<=', '<='],
            ['>', '>'],
            ['>=', '>=']
        ]), 'compOperator');
    this.appendValueInput("compValue2")
        .setCheck(["Compare", "String", "Expression"]);
    this.setInputsInline(true);
    this.setOutput(true, "Compare");
    this.setColour("#A9A9A9");
  }
}

Blockly.Blocks['logical'] = {
  init: function() {
    this.appendValueInput("logValue1")
        .setCheck(null);
    this.appendDummyInput()
        .appendField(new Blockly.FieldDropdown([
            ['and', 'and'],
            ['or', 'or']
        ]), 'logOperator');
    this.appendValueInput("logValue2")
        .setCheck(null);
    this.setInputsInline(true);
    this.setOutput(true, "Logic");
    this.setColour(210);
  }
}

Blockly.Blocks['not'] = {
  init: function() {
    this.appendDummyInput()
        .appendField('not');
    this.appendValueInput("notValue")
        .setCheck(null);
    this.setInputsInline(true);
    this.setOutput(true, "Logic");
    this.setColour(210);
  }
}

Blockly.Blocks['if'] = {
  init: function() {
    this.appendDummyInput()
        .appendField('if');
    this.appendValueInput("ifCond")
        .setCheck(["Compare", "Logic"]);
    this.appendDummyInput()
        .appendField(':');    
    this.appendStatementInput("ifStat")
        .setCheck(null);
    this.setInputsInline(true);
    this.setPreviousStatement(true, ['Statement']);
    this.setNextStatement(true, ['Statement', 'StatementIf']);
    this.setColour(330);
  }
}

Blockly.Blocks['elif'] = {
  init: function() {
    this.appendDummyInput()
        .appendField('elif');
    this.appendValueInput("elifCond")
        .setCheck(["Compare", "Logic"]);
    this.appendDummyInput()
        .appendField(':');    
    this.appendStatementInput("elifStat")
        .setCheck(null);
    this.setInputsInline(true);
    this.setPreviousStatement(true, ['StatementIf']);
    this.setNextStatement(true, ['Statement', 'StatementIf']);
    this.setColour(330);
  }
}

Blockly.Blocks['else'] = {
  init: function() {
    this.appendDummyInput()
        .appendField('else:');  
    this.appendStatementInput("elseStat")
        .setCheck(null);
    this.setInputsInline(true);
    this.setPreviousStatement(true, ['StatementIf']);
    this.setNextStatement(true, ['Statement']);
    this.setColour(330);
  }
}

Blockly.Blocks['for'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("for")
        .appendField(new Blockly.FieldVariable("newVariable"), "forVar")
        .appendField("in range(");
    this.appendValueInput("forValue1")
        .setCheck("Expression");
    this.appendDummyInput()
        .appendField(',');
    this.appendValueInput("forValue2")
        .setCheck("Expression");
    this.appendDummyInput()
        .appendField(',');
    this.appendValueInput("forValue3")
        .setCheck("Expression");
    this.appendDummyInput()
        .appendField('):');
    this.appendStatementInput("forStat")
        .setCheck(null);
    this.setInputsInline(true);
    this.setPreviousStatement(true, ['Statement']);
    this.setNextStatement(true, ['Statement']);
    this.setColour(330);
  }
}

Blockly.Blocks['while'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("while");
    this.appendValueInput("whileCond")
        .setCheck(["Compare", "Logic"]);
    this.appendDummyInput()
        .appendField(':');    
    this.appendStatementInput("whileStat")
        .setCheck(null);
    this.setInputsInline(true);
    this.setPreviousStatement(true, ['Statement']);
    this.setNextStatement(true, ['Statement']);
    this.setColour(330);
  }
}


// Generator Stubs

Blockly.Python['getvariable'] = function(block) {
  var code = block.getFieldValue('getVar')
  return code;
};

Blockly.Python['string'] = function(block) {
  var text_string = block.getFieldValue('strText');
  return "\"" + text_string + "\"";
};

Blockly.Python['number'] = function(block) {
  var num_string = block.getFieldValue('num');
  return num_string;
};

Blockly.Python['print'] = function(block) {
  var value_printvalue = Blockly.Python.statementToCode(block, 'printValue');
  return 'print(' + value_printvalue.trim() + ')\n';
};

Blockly.Python['print2'] = function(block) {
  var value_print2value = Blockly.Python.statementToCode(block, 'print2Value');
  return 'print(' + value_print2value.trim() + ', end=" ")\n';
};

Blockly.Python['assinput'] = function(block) {
  var value_inputvalue = Blockly.Python.statementToCode(block, 'inputValue');
  return value_inputvalue.trim() + ' = input()\n';
};

Blockly.Python['assinputnum'] = function(block) {
  var value_inputvalue = Blockly.Python.statementToCode(block, 'inputValue');
  return value_inputvalue.trim() + ' = float(input())\n';
};

Blockly.Python['assignment'] = function(block) {
  var value_assvalue1 = Blockly.Python.statementToCode(block, 'assValue1');
  var value_assvalue2 = Blockly.Python.statementToCode(block, 'assValue2');
  return value_assvalue1.trim() + ' = ' + value_assvalue2.trim() + '\n';
};

Blockly.Python['arithmetic'] = function(block) {
  var value_arithvalue1 = Blockly.Python.statementToCode(block, 'arithValue1');
  var text_arithOperator = block.getFieldValue('arithOperator');
  var value_arithvalue2 = Blockly.Python.statementToCode(block, 'arithValue2');
  return value_arithvalue1.trim() + ' ' + text_arithOperator + ' ' + value_arithvalue2.trim();
};

Blockly.Python['compare'] = function(block) {
  var value_compvalue1 = Blockly.Python.statementToCode(block, 'compValue1');
  var text_compOperator = block.getFieldValue('compOperator');
  var value_compvalue2 = Blockly.Python.statementToCode(block, 'compValue2');
  return value_compvalue1.trim() + ' ' + text_compOperator + ' ' + value_compvalue2.trim();
};

Blockly.Python['logical'] = function(block) {
  var value_logvalue1 = Blockly.Python.statementToCode(block, 'logValue1');
  var text_logOperator = block.getFieldValue('logOperator');
  var value_logvalue2 = Blockly.Python.statementToCode(block, 'logValue2');
  return value_logvalue1.trim() + ' ' + text_logOperator + ' ' + value_logvalue2.trim();
};

Blockly.Python['not'] = function(block) {
  var value_notvalue = Blockly.Python.statementToCode(block, 'notValue');
  return 'not ' + value_notvalue.trim();
};

Blockly.Python['if'] = function(block) {
  var value_if = Blockly.Python.statementToCode(block, 'ifCond');
  var statements_if = Blockly.Python.statementToCode(block, 'ifStat');
  return 'if ' + value_if.trim() + ":\n" + statements_if;
};

Blockly.Python['elif'] = function(block) {
  var value_elif = Blockly.Python.statementToCode(block, 'elifCond');
  var statements_elif = Blockly.Python.statementToCode(block, 'elifStat');
  return 'elif ' + value_elif.trim() + ":\n" + statements_elif;
};

Blockly.Python['else'] = function(block) {
  var statements_else = Blockly.Python.statementToCode(block, 'elseStat');
  return 'else:\n' + statements_else;
};

Blockly.Python['for'] = function(block) {
  var variable_forvar = block.getFieldValue('forVar');
  var value_forvalue1 = Blockly.Python.statementToCode(block, 'forValue1');
  var value_forvalue2 = Blockly.Python.statementToCode(block, 'forValue2');
  var value_forvalue3 = Blockly.Python.statementToCode(block, 'forValue3');
  var statements_for = Blockly.Python.statementToCode(block, 'forStat');
  var code = 'for ' + variable_forvar + ' in range(int(' + value_forvalue1.trim() + '), int(' + value_forvalue2.trim() + '), int(' + value_forvalue3.trim() + ')):\n' + statements_for;
  return code;
};

Blockly.Python['while'] = function(block) {
  var value_while = Blockly.Python.statementToCode(block, 'whileCond');
  var statements_while = Blockly.Python.statementToCode(block, 'whileStat');
  return 'while ' + value_while.trim() + ":\n" + statements_while;
};

function RunCode() {
  document.getElementById('result').innerHTML = '<py-script output="result">' + document.getElementById('code').innerText + "</py-script>";
}