import QtQuick 2.7
import Lomiri.Components 1.3
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0

Page{
    id: detailedSectionPage
    property var journey: []

    header: PageHeader{
        id: detailedSectionPageHeader
        // title: "Connection Details"

        Button{
            text: qsTr("Back")
            onClicked: {
                stackView.pop()
            }
        }
    }
    ListView{
        id: detailedSectionPageList
        anchors.fill: parent
        model: journey
        delegate: Item{
            width: parent.width
            height: detailedSectionPageHeader.height*3/2
            Rectangle{
                id: journeyRectangle
                width: parent.width
                height: parent.height
                color: "lightblue"
                border{
                    color: "black"
                    width: 1
                }
                Column{
                    // Text{
                    //     text: model.arrival
                    // }
                    Text{
                        text: model.station.name
                    }
                    // Text{
                    //     text: model.departure
                    // }
                }
            }
        }
    }   

}