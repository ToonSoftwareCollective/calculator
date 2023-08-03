import QtQuick 2.1
import qb.components 1.0
import BasicUIControls 1.0

Screen {

    id                          : calculatorScreen
    screenTitle                 : qsTr(me)

// ---------------------------------------------------------------------

    property string me          : correctionNeeded ? '<font color="red">Correct error : click Error or Clear or Del</font>' : "Toon Calculator"

    property string infoButtonbuttonText : "Toon Calculator"

    property int gridRows   : 9
    property int gridColumns: 5

    property var evalString : ""
    property string answer  : ""
    property string memory  : ""

    property bool isRadians: true

    property bool inputEnabled    : true    // anti dender. value is false as soon as a key is clicked. Triggers timer enableInput to reset.

    property bool correctionNeeded: false   // some error

    property int decimalMode    : 0
    property int binaryMode     : 1
    property int hexadecimalMode: 2
    property int conversionMode: decimalMode

    property int openParenthesesLeft : 0    // used to avoid too many close parentheses and wrong order of parentheses

// ---------------------------------------------------------------------
/*
    onOpenParenthesesLeftChanged: {
        app.log("openParenthesesLeft : "+openParenthesesLeft)
    }
*/
// ---------------------------------------------------------------------

    Timer {
        id: enableInput
        interval: 175
        running: ( ! inputEnabled )
        repeat: true
        onTriggered: { inputEnabled  = ! correctionNeeded }
    }

// ---------------------------------------------------------------------

    onVisibleChanged: {
        if (visible) {
            updateFields()
        }
    }

// ---------------------------------------------------------------------

    function deleteLastChar() {
        evalString = evalString.slice(0, evalString.length - 1)
        openParenthesesLeft = countParenthesesLeft()
        correctionNeeded=false
        updateFields()
    }

// ---------------------------------------------------------------------

    function clearAll() {
        evalString = ""
        evaluation.buttonText = ""
        correctionNeeded=false

    }

// ---------------------------------------------------------------------

    function updateFields() {
        second.selected = false         // unhighlight '2nd' button
        if (evalString.length > 64 )    // sometimes a binary string is very long and I show it in 2 parts split by the .
             {evaluation.buttonText = evalString.substring(0,evalString.indexOf(".")+1) + "\n" + evalString.substring(evalString.indexOf(".")+1 ) }
        else {evaluation.buttonText = evalString }
// in decimal mode we show some infor on the wigth bottom button
        if ( conversionMode == decimalMode) {
            if      ( (answer == "" ) && (memory == "" ) )  { infoButtonbuttonText = "Calculator Info" }
            else if ( (answer == "" ) && (memory != "" ) )  { infoButtonbuttonText = "Answ: ----" + "\nMem: " + memory.substring(0,10) }
            else if ( (answer != "" ) && (memory == "" ) )  { infoButtonbuttonText = "Answ: " + answer.substring(0,10) + "\nMem: ----" }
            else                                            { infoButtonbuttonText = "Answ: " + answer.substring(0,10) + "\nMem: " + memory.substring(0,10) }
        }
    }

// ---------------------------------------------------------------------

    function saveEvaluation(text) {
        if (text) {
            if (conversionMode == decimalMode)
                { evalString = text.trim() }
            else if (text.trim().split(".").length < 3) {
                if (conversionMode == hexadecimalMode) {
                    var regex = /[0-9A-Fa-f]/g;
                    var check=text.trim().replace(".","")
                    if ( check.match(regex) ) { evalString = text.trim().toUpperCase() }
                } else {
                    var regex = /[0-1]/g;
                    var check=text.trim().replace(".","")
                    if ( check.match(regex) ) { evalString = text.trim() }
                }
            }
            openParenthesesLeft = countParenthesesLeft()
            correctionNeeded=false
            updateFields()
        }
    }

// ---------------------------------------------------------------------

    function appendToExpression(value) {

// the next isables all buttons and starts a timer which enables all buttons again after some time to avoid dender

        inputEnabled=false

        if (! correctionNeeded) {
// decimal mode input
            if (conversionMode == decimalMode) {
                var checks = "(*/+-,"
// if the value to add is any of the following
                if (
                       (value == "(")  || (value == "pi")
                    || (value == "sin(") || (value == "cos(") || (value == "tan(")
                    || (value == "asin(") || (value == "acos(") || (value == "atan(")
                    || (value == "pi") || (value == "sin(") || (value == "cos(") || (value == "tan(")
                    || (value == "e")  || (value == "ln(")  || (value == "log(")
                    || (value == "V(") || (value == "x^y(") || ( value == "(answer)" ) || ( value == "(memory)" )
                    ) {
// do not add empty answer or empty memory
                    if ( ! ( ( ( value == "answer" ) && ( answer == "" ) ) || ( ( value == "memory" ) && ( memory == "" ) ) ) ) {
                        if (evalString == "") {
                            evalString += value
                        } else {
                            if ( checks.indexOf(evalString.slice(-1))   > -1 )  {
                                evalString += value
                            } else {
                                evalString = evalString + "*"
                                evalString += value
                            }
                        }
                    }
                } else {
// if it is a number or a . or a )
                    if (
                           (value == "1")  || (value == "2") || (value == "3") || (value == "4") || (value == "5")
                        || (value == "6")  || (value == "7") || (value == "8") || (value == "9") || (value == "0")
                        || (value == ".")
                        ) {
                            if (   (evalString.slice(-1) == ")" )                                       // closing )
                                || (evalString.slice(-1) == "y" ) || (evalString.slice(-1) == "r" )     // memory || answer
                                || (evalString.slice(-1) == "i" ) || (evalString.slice(-1) == "e" )     // pi || e
                             ) {
                                if ( value == "." ) { value = "0."}
                                evalString = evalString + "*"
                                evalString += value
                            } else {
                                if ( ( value == "." ) && ( (evalString.substring(0,1) == "(" ) || (evalString == "" ) ) )
                                    { value = "0."}
                                evalString += value
                            }
                    } else {
// it is ) * / + - e+ or e- and we need to check if the previous is not one of the checks characters
// exception : allow a - after all of them except after a previous -
                        if ( ( checks.indexOf(evalString.slice(-1))  == -1 ) ||
                        ( ( value == "-" ) && ( evalString.slice(-1) != "-" ) ) ) {
                            evalString += value
                        } else {
                            app.log("can not add >"+value+"< to >"+evalString+"< because last character >"+evalString.slice(-1)+"< is in >"+checks+"<")
                        }
                    }
                }
                openParenthesesLeft = countParenthesesLeft()
            } else {
// binary and hexadecimal screens have no way to enter invalid data so just add the value
                if (evalString.indexOf("Error") == -1 ) {evalString += value}
            }
        }
        updateFields()
    }

// ---------------------------------------------------------------------
    
    function countParenthesesLeft() {
        var i = 0
        var openParenthesesLeft = 0
        while ( i < evalString.length ) {
            if      (evalString.charAt(i) == "(" ) { openParenthesesLeft++ }
            else if (evalString.charAt(i) == ")" ) { openParenthesesLeft-- }
            i++
        }
        return openParenthesesLeft
    }

// ---------------------------------------------------------------------

    function evaluateExpression() {
        inputEnabled=false
// if evalString is not empty, in Error and counts of ( and ) are equal
        if   ( ( evalString != "" )
            && ( ! correctionNeeded )
            && ( openParenthesesLeft == 0) ) {
            try {

// try to build and execute a valid javascript formula from evalString

//                var evalStringOrg=evalString
                var javaString=evalString
// fill in previous answer and memory values

                javaString=javaString.split("answer").join(answer)
                javaString=javaString.split("memory").join(memory)

// replace e calculations ( clumsy way because we need to avoid e+ end e- which can be used for scientific notations )

                if (javaString.substring(0,1) == "e" ) { javaString = "Math.E"+javaString.substring(1) }
                javaString=javaString.split("(e").join("(Math.E")
                javaString=javaString.split("*e").join("*Math.E")
                javaString=javaString.split("/e").join("/Math.E")
                javaString=javaString.split("+e").join("+Math.E")
                javaString=javaString.split("-e").join("-Math.E")

// replace some other things

                javaString=javaString.split("pi").join("Math.PI")
                javaString=javaString.split("V(").join("Math.sqrt(")
                javaString=javaString.split("x^y(").join("Math.pow(")
// swap the next 2 lines and you better prepare for strange results due to replacement of the string 'log' 8-)
                javaString=javaString.split("log(").join("1/Math.log(10)*Math.log(")
                javaString=javaString.split("ln(").join("Math.log(")

                if (isRadians) {
                    javaString=javaString.split("asin(").join("Math.ASIN(")
                    javaString=javaString.split("acos(").join("Math.ACOS(")
                    javaString=javaString.split("atan(").join("Math.ATAN(")
                    javaString=javaString.split("sin(").join("Math.sin(")
                    javaString=javaString.split("cos(").join("Math.cos(")
                    javaString=javaString.split("tan(").join("Math.tan(")
                    javaString=javaString.split("ASIN(").join("asin(")
                    javaString=javaString.split("ACOS(").join("acos(")
                    javaString=javaString.split("ATAN(").join("atan(")
                } else {
                    javaString=javaString.split("asin(").join("ASIN(")
                    javaString=javaString.split("acos(").join("ACOS(")
                    javaString=javaString.split("atan(").join("ATAN(")
                    javaString=javaString.split("sin(").join("Math.sin(Math.PI / 180 * ")
                    javaString=javaString.split("cos(").join("Math.cos(Math.PI / 180 * ")
                    javaString=javaString.split("tan(").join("Math.tan(Math.PI / 180 * ")
                    javaString=javaString.split("ASIN(").join("180 / Math.PI * Math.asin(")
                    javaString=javaString.split("ACOS(").join("180 / Math.PI * Math.acos(")
                    javaString=javaString.split("ATAN(").join("180 / Math.PI * Math.atan(")
                }
// now we replaced everything to build a valid javascript formula so lets try to execute it :-o
                var result = eval(javaString)
                if ( (result.toString() == "NaN" ) || (result.toString() == "NAN" ) ) {
// ouch, this went wrong
                    app.log("evaluateExpression Error your entry : "+evalString)
                    app.log("evaluateExpression Error translated : "+javaString)
//                    evalString = evalStringOrg+" Error"
                    correctionNeeded=true
                } else {
// the calculatin went just fine so let's remember the answer in case we want to do something with it
                    evalString = result.toString()
                    answer=evalString
                }
            } catch (error) {
// ouch, this went wrong
//                app.log("evaluateExpression Error : " +error)
                app.log("evaluateExpression Error your entry : "+evalString)
                app.log("evaluateExpression Error translated : "+javaString)
//                evalString = evalStringOrg+" Error"
                correctionNeeded=true
            }
        } else { if ( evalString != "" ) { correctionNeeded = true }  }
        updateFields()
    }

// ---------------------------------------------------------------------

    function convertToDecimal() {
        if (evalString != "") {
            var negativeConversionValue = ( evalString.substring(0,1) == "-" )
            if (negativeConversionValue) { evalString = evalString.substring(1) }

            if (conversionMode == hexadecimalMode) (evalString=hexToDec(evalString).toString())
            if (conversionMode == binaryMode) (evalString=binToDec(evalString).toString())

            if (negativeConversionValue) {evalString="-"+evalString}
            conversionMode = decimalMode
            updateFields()
        }
        if (evalString == "") {
            conversionMode = decimalMode
            updateFields()
        }
    }

// ---------------------------------------------------------------------

    function convertToHexadecimal() {
//check for valid input [+-] (decimalnumber [.decimalnumber] | .decimalnumber)
        if (evalString.replace(/[+-]?([0-9]+([.][0-9]*)?|[.][0-9]+)/mg, "oke") == "oke" ) {
            var negativeConversionValue = ( evalString.substring(0,1) == "-" )
            if (negativeConversionValue) { evalString = evalString.substring(1) }

            if (conversionMode == decimalMode) (evalString=decToHex(evalString).toString())
            if (conversionMode == binaryMode) (evalString=binToHex(evalString).toString())

            if (negativeConversionValue) {evalString="-"+evalString}
            conversionMode = hexadecimalMode
            updateFields()
        }
        if (evalString == "") {
            conversionMode = hexadecimalMode
            updateFields()
        }
    }

// ---------------------------------------------------------------------

    function convertToBinary() {
//check for valid input [+-] ((hexa-)decimalnumber [.(hexa-)decimalnumber] | .(hexa-)decimalnumber)
        if (evalString.replace(/[+-]?([0-9A-F]+([.][0-9A-F]*)?|[.][0-9A-F]+)/mg, "oke") == "oke" ) {
            var negativeConversionValue = ( evalString.substring(0,1) == "-" )
            if (negativeConversionValue) { evalString = evalString.substring(1) }

            if (conversionMode == decimalMode) (evalString=decToBin(evalString).toString())
            if (conversionMode == hexadecimalMode) (evalString=hexToBin(evalString).toString())

            if (negativeConversionValue) {evalString="-"+evalString}
            conversionMode = binaryMode
            updateFields()
        }
        if (evalString == "") {
            conversionMode = binaryMode
            updateFields()
        }
    }

// ---------------------------------------------------------------------

    Rectangle {
        id                      : calculatorBackground
        height                  : parent.height * 0.98
        width                   : parent.width  * 0.85
        color                   : "black"
        radius                  : 10
        anchors {
            horizontalCenter    : parent.horizontalCenter
        }
    }

    YaLabelCalculator {
        id                      : evaluation
//        enabled                 : inputEnabled
        buttonText              : evalString
        width                   : parent.width * 0.8
        height                  : parent.height / ( gridRows + 1 )
        anchors.horizontalCenter: parent.horizontalCenter
        buttonActiveColor       : ( correctionNeeded ) ? "lightgrey" : "grey"
        textColor               : ( correctionNeeded ) ? "red" : "black"
        lineHeightSize          : 0.6
        anchors {
            top                 : calculatorBackground.top
            topMargin           : isNxt ? 20 : 16
        }
        onClicked: {
            if (conversionMode == decimalMode)
                {qkeyboard.open("Enter a valid calculation", evaluation.buttonText, saveEvaluation)}
            else if (conversionMode == hexadecimalMode)
                {qkeyboard.open("Enter a valid Hexadecimal value", evaluation.buttonText, saveEvaluation)}
            else
                {qkeyboard.open("Enter a valid Binary value", evaluation.buttonText, saveEvaluation)}
        }
    }

    Rectangle {

        height                  : parent.height * 0.8
        width                   : parent.width * 0.8
        color                   : "black"
        anchors {
            top                 : evaluation.bottom
            horizontalCenter    : parent.horizontalCenter
        }

        Grid {
            id: layout
            rows                : gridRows
            columns             : gridColumns
            anchors.fill        : parent

            YaLabelCalculator {
//                enabled         : inputEnabled
                buttonText      : "Clear"
                width           : parent.width / gridColumns
                height          : parent.height / gridRows
                buttonActiveColor : ( correctionNeeded ) ? "lightgrey" : "grey"
                onClicked       : clearAll()
            }

            YaLabelCalculator {
//                enabled         : inputEnabled
                buttonText      : "Del"
                width           : parent.width / gridColumns
                height          : parent.height / gridRows
                buttonActiveColor : ( correctionNeeded ) ? "lightgrey" : "grey"
                onClicked       : deleteLastChar()
            }

            YaLabelCalculator {
                buttonText      : "Dec"
                width           : parent.width / gridColumns
                height          : parent.height / gridRows
                selected        : ( ( conversionMode == decimalMode ) && (! correctionNeeded) )
                onClicked       : { if (! correctionNeeded ) { convertToDecimal() } }
            }

            YaLabelCalculator {
                buttonText      : "Hex"
                width           : parent.width / gridColumns
                height          : parent.height / gridRows
                selected        : ( conversionMode == hexadecimalMode )
                onClicked       : { if (! correctionNeeded ) { convertToHexadecimal() } }
            }

            YaLabelCalculator {
                buttonText      : "Bin"
                width           : parent.width / gridColumns
                height          : parent.height / gridRows
                selected        : ( conversionMode == binaryMode )
                onClicked       : { if (! correctionNeeded ) { convertToBinary() } }
            }

            YaLabelCalculator {
                enabled         : inputEnabled
                buttonText      : (conversionMode == decimalMode) ? "M" : ""
                width           : parent.width / gridColumns
                height          : parent.height / gridRows
                onClicked       : {
                    if (conversionMode == decimalMode) {
                        var evalStringOld=evalString
                        var answerOld=answer
                        evaluateExpression()
                        if (! correctionNeeded ) {
                            memory=evalString
                        }
                        evalString=evalStringOld
                        answer=answerOld
                        updateFields()
                    }
                }
            }

            YaLabelCalculator {
                enabled         : inputEnabled
                buttonText      : (conversionMode == decimalMode) ? "M+" : ""
                width           : parent.width / gridColumns
                height          : parent.height / gridRows
                onClicked       : {
                    if (( conversionMode == decimalMode) && (evalString != "")){
                        var evalStringOld=evalString
                        var answerOld=answer
                        if (memory == "" ) {memory=0}
                        evalString="memory+("+evalString+")"
                        evaluateExpression()
                        if (! correctionNeeded ) {
                            memory=answer
                        }
                        evalString=evalStringOld
                        answer=answerOld
                        updateFields()
                    }
                }
            }

            YaLabelCalculator {
                enabled         : inputEnabled
                buttonText      : (conversionMode == decimalMode) ? "M-" : ""
                width           : parent.width / gridColumns
                height          : parent.height / gridRows
                onClicked       : {
                    if (( conversionMode == decimalMode) && (evalString != "")){
                        var evalStringOld=evalString
                        var answerOld=answer
                        if (memory == "" ) {memory=0}
                        evalString="memory-("+evalString+")"
                        evaluateExpression()
                        if (! correctionNeeded ) {
                            memory=answer
                        }
                        evalString=evalStringOld
                        answer=answerOld
                        updateFields()
                    }
                }
            }

            YaLabelCalculator {
                enabled         : inputEnabled
                buttonText      : (conversionMode == decimalMode) ? "MR" : ""
                width           : parent.width / gridColumns
                height          : parent.height / gridRows
                onClicked       : if (conversionMode == decimalMode) { appendToExpression("(memory)"); updateFields() }
            }

            YaLabelCalculator {
                enabled         : inputEnabled
                buttonText      : (conversionMode == decimalMode) ? "MC" : ""
                width           : parent.width / gridColumns
                height          : parent.height / gridRows
                onClicked       : {
                    if (conversionMode == decimalMode) {
                        memory=""
                        updateFields()
                    }
                }
            }

            YaLabelCalculator {
                enabled         : inputEnabled
                buttonText      : (conversionMode == decimalMode) ? "sin\nasin\n" : (conversionMode == hexadecimalMode) ? "A" : ""
                width           : parent.width / gridColumns
                height          : parent.height / gridRows
                lineHeightSize  : 0.6
                onClicked       : {
                    if (conversionMode == decimalMode) {
                        if (second.selected) { appendToExpression(buttonText.split("\n")[1]+"(") }
                        else                 { appendToExpression(buttonText.split("\n")[0]+"(") }
                    } else {
                        appendToExpression(buttonText)
                    }
                }
            }

            YaLabelCalculator {
                enabled         : inputEnabled
                buttonText      : (conversionMode == decimalMode) ? "cos\nacos\n" : (conversionMode == hexadecimalMode) ? "B" : ""
                width           : parent.width / gridColumns
                height          : parent.height / gridRows
                lineHeightSize  : 0.6
                onClicked       : {
                    if (conversionMode == decimalMode) {
                        if (second.selected) { appendToExpression(buttonText.split("\n")[1]+"(") }
                        else                 { appendToExpression(buttonText.split("\n")[0]+"(") }
                    } else {
                        appendToExpression(buttonText)
                    }
                }
            }

            YaLabelCalculator {
                enabled         : inputEnabled
                buttonText      : (conversionMode == decimalMode) ? "tan\natan\n" : (conversionMode == hexadecimalMode) ? "C" : ""
                width           : parent.width / gridColumns
                height          : parent.height / gridRows
                lineHeightSize  : 0.6
                onClicked       : {
                    if (conversionMode == decimalMode) {
                        if (second.selected) { appendToExpression(buttonText.split("\n")[1]+"(") }
                        else                 { appendToExpression(buttonText.split("\n")[0]+"(") }
                    } else {
                        appendToExpression(buttonText)
                    }
                }
            }

            YaLabelCalculator {
                enabled         : inputEnabled
                buttonText      : (conversionMode == decimalMode) ? (isRadians ? "Rad" : "Deg") : ""
                width           : parent.width / gridColumns
                height          : parent.height / gridRows
//                onClicked       : { if (conversionMode == decimalMode) { isRadians = ! isRadians ; updateFields() } }
                onClicked       : { if (conversionMode == decimalMode) { isRadians = ! isRadians } }
            }

            YaLabelCalculator {
                enabled         : inputEnabled
                id              : second
                buttonText      : (conversionMode == decimalMode) ? "2nd" : ""
                width           : parent.width / gridColumns
                height          : parent.height / gridRows
                onClicked       : { if (conversionMode == decimalMode)  { selected = ! selected } }
            }

            YaLabelCalculator {
                enabled         : inputEnabled
                buttonText      : (conversionMode == decimalMode) ? "log" : (conversionMode == hexadecimalMode) ? "D" : ""
                width           : parent.width / gridColumns
                height          : parent.height / gridRows
                onClicked       : {
                    if (conversionMode == decimalMode) {
                        appendToExpression(buttonText+"(")
                    } else {
                        appendToExpression(buttonText)
                    }
                }
            }

            YaLabelCalculator {
                enabled         : inputEnabled
                buttonText      : (conversionMode == decimalMode) ? "ln" : (conversionMode == hexadecimalMode) ? "E" : ""
                width           : parent.width / gridColumns
                height          : parent.height / gridRows
                onClicked       : {
                    if (conversionMode == decimalMode) {
                        appendToExpression(buttonText+"(")
                    } else {
                        appendToExpression(buttonText)
                    }
                }
            }

            YaLabelCalculator {
                enabled         : inputEnabled
                buttonText      : (conversionMode == decimalMode) ? "e" : (conversionMode == hexadecimalMode) ? "F" : ""
                width           : parent.width / gridColumns
                height          : parent.height / gridRows
                onClicked       : {
                    if (conversionMode == decimalMode)  {
                        appendToExpression("e")
                    } else {
                        appendToExpression(buttonText)
                    }
                }
            }

            YaLabelCalculator {
                enabled         : inputEnabled
                buttonText      : (conversionMode == decimalMode) ? "π" : ""
                width           : parent.width / gridColumns
                height          : parent.height / gridRows
                onClicked       : if (conversionMode == decimalMode) {  appendToExpression("pi") }
            }

            YaLabelCalculator {
                enabled         : inputEnabled
                buttonText      : (conversionMode == decimalMode) ? "1/x" : ""
                width           : parent.width / gridColumns
                height          : parent.height / gridRows
                onClicked       : {
                    if ( (conversionMode == decimalMode) && (evalString != "") ) {
                        evalString="1/("+evalString+")"
                        evaluateExpression()
                    }
                }
            }

            YaLabelCalculator {
                enabled         : inputEnabled
                buttonText      : (conversionMode != binaryMode) ? "7" : ""
                width           : parent.width / gridColumns
                height          : parent.height / gridRows
                onClicked       : if (conversionMode != binaryMode) { appendToExpression("7") }
            }

            YaLabelCalculator {
                enabled         : inputEnabled
                buttonText      : (conversionMode != binaryMode) ? "8" : ""
                width           : parent.width / gridColumns
                height          : parent.height / gridRows
                onClicked       : if (conversionMode != binaryMode) { appendToExpression("8") }
            }

            YaLabelCalculator {
                enabled         : inputEnabled
                buttonText      : (conversionMode != binaryMode) ? "9" : ""
                width           : parent.width / gridColumns
                height          : parent.height / gridRows
                onClicked       : if (conversionMode != binaryMode) { appendToExpression("9") }
            }

            YaLabelCalculator {
                enabled         : inputEnabled
                buttonText      : (conversionMode == decimalMode) ? "(" : ""
                width           : parent.width / gridColumns
                height          : parent.height / gridRows
                onClicked       : if (conversionMode == decimalMode) { appendToExpression("(") }
            }

            YaLabelCalculator {
                enabled         : inputEnabled
                buttonText      : (conversionMode == decimalMode) ? ")" : ""
                width           : parent.width / gridColumns
                height          : parent.height / gridRows
                onClicked       : {
                    if ( (conversionMode == decimalMode) && (evalString != "") && (openParenthesesLeft > 0 ) ) { appendToExpression(")") }
                }
            }

            YaLabelCalculator {
                enabled         : inputEnabled
                buttonText      : (conversionMode != binaryMode) ? "4" : ""
                width           : parent.width / gridColumns
                height          : parent.height / gridRows
                onClicked       : if (conversionMode != binaryMode) { appendToExpression("4") }
            }
            YaLabelCalculator {
                enabled         : inputEnabled
                buttonText      : (conversionMode != binaryMode) ? "5" : ""
                width           : parent.width / gridColumns
                height          : parent.height / gridRows
                onClicked       : if (conversionMode != binaryMode) { appendToExpression("5") }
            }

            YaLabelCalculator {
                enabled         : inputEnabled
                buttonText      : (conversionMode != binaryMode) ? "6" : ""
                width           : parent.width / gridColumns
                height          : parent.height / gridRows
                onClicked       : if (conversionMode != binaryMode) { appendToExpression("6") }
            }

            YaLabelCalculator {
                enabled         : inputEnabled
                buttonText      : (conversionMode == decimalMode) ? "*" : ""
                width           : parent.width / gridColumns
                height          : parent.height / gridRows
                onClicked       : if ( (conversionMode == decimalMode) && (evalString != "") ) { appendToExpression("*") }
            }

            YaLabelCalculator {
                enabled         : inputEnabled
                buttonText      : (conversionMode == decimalMode) ? "/" : ""
                width           : parent.width / gridColumns
                height          : parent.height / gridRows
                onClicked       : if ( (conversionMode == decimalMode) && (evalString != "") ) { appendToExpression("/") }
            }

            YaLabelCalculator {
                enabled         : inputEnabled
                buttonText      : "1"
                width           : parent.width / gridColumns
                height          : parent.height / gridRows
                onClicked       : appendToExpression("1")
            }

            YaLabelCalculator {
                enabled         : inputEnabled
                buttonText      : (conversionMode != binaryMode) ? "2" : ""
                width           : parent.width / gridColumns
                height          : parent.height / gridRows
                onClicked       : if (conversionMode != binaryMode) { appendToExpression("2") }
            }

            YaLabelCalculator {
                enabled         : inputEnabled
                buttonText      : (conversionMode != binaryMode) ? "3" : ""
                width           : parent.width / gridColumns
                height          : parent.height / gridRows
                onClicked       : if (conversionMode != binaryMode) { appendToExpression("3") }
            }

            YaLabelCalculator {
                enabled         : inputEnabled
                buttonText      : (conversionMode == decimalMode) ? "+" : ""
                width           : parent.width / gridColumns
                height          : parent.height / gridRows
                onClicked       : if (conversionMode == decimalMode) { appendToExpression("+") }
            }

            YaLabelCalculator {
                enabled         : inputEnabled
                buttonText      : (conversionMode == decimalMode) ? "-" : ""
                width           : parent.width / gridColumns
                height          : parent.height / gridRows
                onClicked       : if (conversionMode == decimalMode) { appendToExpression("-") }
            }

            YaLabelCalculator {
                enabled         : inputEnabled
                buttonText      : "0"
                width           : parent.width / gridColumns
                height          : parent.height / gridRows
                onClicked       : {
                    if (conversionMode == decimalMode) {
                        if (! (/[0-9]e[+-]$/.test(evalString)) ) {  // do not allow a 0 after e+ or e- of scientific notation
                            if ( (evalString == "") || (evalString == "0") )    { evalString = "0." }
                            else if ( /[(*/+\-,]$/.test(evalString) )            { evalString+= "0." }
                            else if ( /[)ei]$/.test(evalString) )               { evalString+= "*0."}
                            else                                                { evalString+= "0"  }
                            updateFields()
                        }
                        else {app.log("skip "+evalString.slice(-3)) }
                    } else { appendToExpression("0") }
                }
            }

            YaLabelCalculator {
                enabled         : inputEnabled
                buttonText      : "."
                width           : parent.width / gridColumns
                height          : parent.height / gridRows
                pixelsizeoverride     : true
                pixelsizeoverridesize : isNxt ? 40 : 32
                onClicked       : {
                // if evalString does not already end with a number conating a .
                    if (! /[0-9]*\.[0-9]*$/.test(evalString) ) { appendToExpression(".") }
                }
            }

            YaLabelCalculator {
                enabled         : inputEnabled
                buttonText      : (conversionMode == decimalMode) ? "=" : ""
                width           : parent.width / gridColumns
                height          : parent.height / gridRows
                onClicked       : {
                    if (conversionMode == decimalMode) {
                        evaluateExpression()
                        updateFields()
                    }
                }
            }

            YaLabelCalculator {
                enabled         : inputEnabled
                buttonText      : (conversionMode == decimalMode) ? "e+" : ""
                width           : parent.width / gridColumns
                height          : parent.height / gridRows
                onClicked       : {
                    if ( (conversionMode == decimalMode) && ( /[0-9]$/.test(evalString) ) ) { appendToExpression("e+") }
                }
            }

            YaLabelCalculator {
                enabled         : inputEnabled
                buttonText      : (conversionMode == decimalMode) ? "e-" : ""
                width           : parent.width / gridColumns
                height          : parent.height / gridRows
                onClicked       : {
                    if ( (conversionMode == decimalMode) && ( /[0-9]$/.test(evalString) ) ) { appendToExpression("e-") }
                }
            }

            YaLabelCalculator {
                enabled         : inputEnabled
                buttonText      : (conversionMode == decimalMode) ? "answer" : ""
                width           : parent.width / gridColumns
                height          : parent.height / gridRows
                onClicked       : if (conversionMode == decimalMode) { appendToExpression("(answer)") }
            }

            YaLabelCalculator {
                enabled         : inputEnabled
                buttonText      : (conversionMode == decimalMode) ? "√\n√=" : ""
                width           : parent.width / gridColumns
                height          : parent.height / gridRows
                lineHeightSize  : 0.6
                onClicked       : {
                    if (second.selected) {
                        if ( (conversionMode == decimalMode) && (evalString != "") ) {
                            evalString="V("+evalString+")"
                            evaluateExpression()
                        }
                    } else { appendToExpression("V(")  }
                }
            }


            YaLabelCalculator {
                enabled         : inputEnabled
                buttonText      : (conversionMode == decimalMode) ? "x^y(x,y)  , ->" : ""
                width           : parent.width / gridColumns
                height          : parent.height / gridRows
                onClicked       : if (conversionMode == decimalMode)
                        { powerComma.selected=true ; powerComma.enabled=true ; appendToExpression("x^y(") }
            }

            YaLabelCalculator {
                id              : powerComma
                enabled         : false
                buttonText      : (conversionMode == decimalMode) ? "," : ""
                width           : parent.width / gridColumns
                height          : parent.height / gridRows
                pixelsizeoverridesize : isNxt ? 40 : 32
                pixelsizeoverride     : true
                onClicked       : if (conversionMode == decimalMode) { selected=false ; enabled=false ; appendToExpression(",") }
            }

            YaLabelCalculator {
                id              : infoButton
                enabled         : inputEnabled
                buttonText      : (conversionMode == decimalMode) ? infoButtonbuttonText : (conversionMode == hexadecimalMode) ? "Hexadecimal" : "Binary"
                textColor       : ( buttonText == "Calculator Info" ) ? "yellow" : "black"
                width           : parent.width / gridColumns
                height          : parent.height / gridRows
                pixelsizeoverridesize : isNxt ? 15 : 12
                pixelsizeoverride     : true
                onClicked: {
                    stage.openFullscreen(app.calculatorInfoUrl);
                }
            }

        }

    }

// ---------------------------------------------------------------------

	function decToBin(dec)
	{
// max 64 bits after the .

        var precision = 64
		var bin = ""

		var integral = parseInt(dec, 10)

		var fractional = dec - integral

		// Conversion of integral

		while (integral > 0)
		{
			var rem = integral % 2

			// Prepend 0 / 1 in bin

            if (rem == 0) {bin = "0" + bin } else {bin = "1" + bin}

			integral = parseInt(integral / 2, 10);
		}

        if (fractional > 0 ) {

            bin += (".");

            while ( ( fractional > 0 ) && (precision-- > 0) )
            {
                // Find next bit in fraction
                fractional *= 2;
                var fract_bit = parseInt(fractional, 10);

                if (fract_bit == 1)
                {
                    fractional -= fract_bit;
                    bin += "1"
                }
                else
                {
                    bin += "0"
                }
            }

        }

// make sure we get at leat a 0 ( before the . )

        if ( (bin == "" ) || (bin.slice(0,1) == "." ) ) { bin = "0"+bin }

		return bin;
	}

// ---------------------------------------------------------------------

	function binToDec(bin) {

        var left = bin.split(".")[0]

		var dec = 0

        var toadd = 1

        for ( var i = left.length - 1 ; i >= 0; i-- ) {
            dec = dec + toadd*left.substring(i,i+1)
            toadd = toadd * 2
        }

        if (bin.indexOf(".") > -1)  {
            toadd = 0.5
            var right = bin.split(".")[1]
            for (var i = 0 ; i < right.length ; i++) {
                dec = dec + toadd*right.substring(i,i+1)
                toadd = toadd * 0.5
            }
        }

		return dec;

	}

// ---------------------------------------------------------------------

    function hexToBin(hex){
        var bin = "";
        for (var i = 0; i < hex.length; ++i) {
            switch(hex.charAt(i)) {
                case '0': bin += "0000"; break;
                case '1': bin += "0001"; break;
                case '2': bin += "0010"; break;
                case '3': bin += "0011"; break;
                case '4': bin += "0100"; break;
                case '5': bin += "0101"; break;
                case '6': bin += "0110"; break;
                case '7': bin += "0111"; break;
                case '8': bin += "1000"; break;
                case '9': bin += "1001"; break;
                case 'A': bin += "1010"; break;
                case 'B': bin += "1011"; break;
                case 'C': bin += "1100"; break;
                case 'D': bin += "1101"; break;
                case 'E': bin += "1110"; break;
                case 'F': bin += "1111"; break;
                case '.': bin += "."; break;
                default: return "";
            }
        }

// remove leading 0's from bin string

        bin=bin.replace(/^0+/, '')

// remove trailing 0's of fraction

        if (bin.indexOf(".") > -1) { bin=bin.replace(/0+$/, '') }

        if (bin.indexOf(".") + 1 == bin.length ) { bin=bin.slice(0,-1) }

// make sure we get at leat a 0 ( before the . )

        if ( (bin == "" ) || (bin.slice(0,1) == "." ) ) { bin = "0"+bin }

        return bin;
    }

// ---------------------------------------------------------------------

    function binToHex(bin){

        var left = bin.split(".")[0]

        if (left.length % 4 != 0) { left = "0000".substring(0,4 - left.length % 4)+left }

        var hex=""

        while (left.length > 0) { hex+=nibbleToHex(left.substring(0,4)) ; left=left.substring(4) }

        if (bin.indexOf(".") > -1)  {
            hex+="."
            var right = bin.split(".")[1]

            if (right.length % 4 != 0) { right=right + "0000".substring(0, 4 - right.length % 4)}

            while (right.length > 0) { hex+=nibbleToHex(right.substring(0,4)) ; right=right.substring(4) }
        }

// remove leading 0's from hex string

        hex=hex.replace(/^0+/, '')

// remove trailing 0's of fraction

        if (hex.indexOf(".") > -1) { hex=hex.replace(/0+$/, '') }

        if (hex.indexOf(".") + 1 == hex.length ) { hex=hex.slice(0,-1) }

// make sure we get at leat a 0 ( before the . )

        if ( (hex == "" ) || (hex.slice(0,1) == "." ) ) { hex = "0"+hex }

        return hex
    }

//---- help function for function above

    function nibbleToHex(nibble){
        var out = "";
        switch(nibble) {
            case "0000": out="0"; break;
            case "0001": out="1"; break;
            case "0010": out="2"; break;
            case "0011": out="3"; break;
            case "0100": out="4"; break;
            case "0101": out="5"; break;
            case "0110": out="6"; break;
            case "0111": out="7"; break;
            case "1000": out="8"; break;
            case "1001": out="9"; break;
            case "1010": out="A"; break;
            case "1011": out="B"; break;
            case "1100": out="C"; break;
            case "1101": out="D"; break;
            case "1110": out="E"; break;
            case "1111": out="F"; break;
        }
        return out;
    }

// ---------------------------------------------------------------------


// dec <--> hexadecimal conversion via ......ToBin

    function decToHex(dec) {
        return binToHex(decToBin(dec))
    }

    function hexToDec(hex) {
        return binToDec(hexToBin(hex))
    }
}

