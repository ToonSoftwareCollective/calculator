import QtQuick 2.1
import qb.components 1.0
import BasicUIControls 1.0

Screen {

    id                          : calculatorInfo
    screenTitle                 : qsTr(me)

// ---------------------------------------------------------------------

    property string me          : "Toon Calculator Info"

// ---------------------------------------------------------------------

    onVisibleChanged: {
        if (visible) {
            app.log("Info")
        }
    }

// ---------------------------------------------------------------------

    YaLabelCalculator {
        id                      : calculatorBackground
        buttonText              : 
            "The last answer and memory values will show up in the right bottom field"
        + "\nUse the last answer by clicking the answer button, memory uses M buttons"
        + "\n"
        + "\nExtra characters may be added for you and sometimes input is disabled"
        + "\nExample to enter e*e press e * e OR press e e to see e*e"
        + "\nExample try to enter 123.456.123 the second . will not be accepted"
        + "\n"
        + "\nRepeat examples use memory ( works for * / + and - )"
        + "\n+ to see Mem increase by 6 :   Clear 6 M Clear MR + 6 M M M M  >> Watch the right <<"
        + "\n- to see Mem decrease by 5 :   Clear 5 M Clear MR - 5 M M M M  >> bottom field !! <<"
        + "\n"
        + "\nRemember that log is base 10 and ln is base e"
        + "\nTo calculate for other base like 7 use : ln(your input)/ln(7)"
        + "\n"
        + "\nHexadecimal and Binary calculations using Mem and Decimal mode"
        + "\nHex calculate F * D = C3 : Hex Clear F Dec M Hex Clear D Dec * MR = Hex"
        + "\nHex calculate sin(DEF) : Hex Clear D E F Dec M Clear sin MR ) = Hex"
        + "\n"
        + "\nx^y(x,y) calculates x^y and can be used to calculate any root values"
        + "\ncalculate 4V81 = 3 : Clear x^y(x,y) 81 , 1 / 4 ) creates x^y(81,1/4) now press = to see 3"

        lineHeightSize          : 0.8
        height                  : parent.height * 0.98
        width                   : parent.width  * 0.85
        buttonActiveColor       : "black"
        textColor               : "lightgrey"
        buttonBorderRadius      : 10
        anchors {
            horizontalCenter    : parent.horizontalCenter
        }
        onClicked: { hide() }
    }

// ---------------------------------------------------------------------

}
