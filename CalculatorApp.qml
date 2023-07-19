import QtQuick 2.1
import qb.components 1.0
import qb.base 1.0;
import FileIO 1.0

App {

// A debug for general messages

    property bool debug                     : true
    property bool debug1                    : false
    property bool debug2                    : false

    property url                tileUrl             : "CalculatorTile.qml"
    property CalculatorTile     calculatorTile

    property url                calculatorScreenUrl : "CalculatorScreen.qml"
    property CalculatorScreen   calculatorScreen
    
    property url                calculatorInfoUrl : "CalculatorInfo.qml"
    property CalculatorInfo     calculatorInfo
    
// ---------------------------------------- Register the App in the GUI
    
    function init() {

        const args = {
            thumbCategory       : "general",
            thumbLabel          : "Calculator",
            thumbIcon           : "qrc:/tsc/plus.png",
            thumbIconVAlignment : "center",
            thumbWeight         : 30
        }
//            thumbIcon           : "/qmf/qml/apps/calculator/drawables/calculator.png",

        registry.registerWidget("tile", tileUrl, this, "calculatorTile", args);

        registry.registerWidget("screen", calculatorScreenUrl, this, "calculatorScreen");

        registry.registerWidget("screen", calculatorInfoUrl,   this, "calculatorInfo");

    }

// ------------------------------------- Actions right after APP startup

    Component.onCompleted: {

        log("onCompleted Started")

        log("onCompleted Completed")
    }
    
// -------------------- A function to log to the console with timestamps

    function log(tolog) {

        var now      = new Date();
        var dateTime = now.getFullYear() + '-' +
                ('00'+(now.getMonth() + 1)   ).slice(-2) + '-' +
                ('00'+ now.getDate()         ).slice(-2) + ' ' +
                ('00'+ now.getHours()        ).slice(-2) + ":" +
                ('00'+ now.getMinutes()      ).slice(-2) + ":" +
                ('00'+ now.getSeconds()      ).slice(-2) + "." +
                ('000'+now.getMilliseconds() ).slice(-3);
        console.log(dateTime+' Calculator : ' + tolog.toString())

    }
        
// ---------------------------------------------------------------------

}
