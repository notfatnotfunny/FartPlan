import QtQuick 2.7
import Lomiri.Components 1.3
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0

Page{
    id: detailedSectionPage
    property var journey: []

    ListModel{
        id: journeyModel
    }
    Component.onCompleted: {
        for (var i = 0; i < journey.passList.length; i++) {
            journeyModel.append({
                "arrival": journey.passList[i].arrival,
                "departure": journey.passList[i].departure,
                "station": journey.passList[i].station.name
            });
        }
    }

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
        model: journeyModel
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
                    spacing: (journeyRectangle.height - firstJourneyRow.height - secondJourneyRow.height - thirdJourneyRow.height -20)/3
                    Row{
                        id: firstJourneyRow
                        Text{
                            id: arrivalText
                            topPadding: 5
                            leftPadding: 20
                            text: model.arrival? model.arrival.slice(11,16) : "start"
                            font.pointSize: detailedSectionPageHeader.height*5/20
                        }
                    }
                    Row{
                        id: secondJourneyRow
                        Text{
                            id: stationText
                            leftPadding: journeyRectangle.width/2 - stationText.width/4
                            text: model.station
                            font.pointSize: detailedSectionPageHeader.height*3/10
                            font.bold: true
                        }
                    }
                    Row{
                        spacing: journeyRectangle.width-2*marginText.width - departureText.width-20
                        id: thirdJourneyRow
                        Text{
                            id: marginText
                            leftPadding: 20
                            text: " "
                        }
                        Text{
                            id: departureText
                            bottomPadding: 5
                            text: model.departure? model.departure.slice(11,16) : "end"
                            font.pointSize: detailedSectionPageHeader.height*5/20
                        }
                    }
                }
            }
        }
    }   

}
