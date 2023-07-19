import QtQuick 2.1
import qb.components 1.0

Tile {
    id                          : calculatorTile

// --- Tile button


    YaLabelCalculator {
        id                      : tileButton
//        buttonText              : "Calculator"
        buttonBorderWidth       : 0
//        height                  : parent.height - 20
//        width                   : parent.width - 20
        height: isNxt ? 150 : 120
        width: isNxt ? 150 : 120
        buttonActiveColor       : dimState ? "black" : "white"
        buttonSelectedColor     : buttonActiveColor
        buttonHoverColor        : buttonActiveColor
        hoveringEnabled         : false
        selected                : true
        enabled                 : true
        textColor               : "white"
        anchors {
            verticalCenter      : parent.verticalCenter
            horizontalCenter    : parent.horizontalCenter
        }

        onClicked: {
            stage.openFullscreen(app.calculatorScreenUrl);
        }
    }

        Image {
            id: calculatorImage
            source: dimState ? "drawables/calculatorDimmed.png" : "drawables/calculator.png"
//            fillMode: Image.PreserveAspectFit
            height: isNxt ? 150 : 120
            width: isNxt ? 150 : 120

            anchors {
                verticalCenter      : parent.verticalCenter
                horizontalCenter    : parent.horizontalCenter
            }       
//        visible : ! dimState

        }
    
}
