import QtQuick 2.7
import Lomiri.Components 1.3
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0

Page{
    id: detailedConnectionPage
    property var sections: []

    header: PageHeader{
        id: detailedConnectionPageHeader
        // title: "Connection Details"

        Button{
            text: qsTr("Back")
            onClicked: {
                stackView.pop()
            }
        }
    }
    ListView{
        id: detailedConnectionPageList
        anchors.fill: parent
        model: sections
        delegate: Item{
            width: parent.width
            height: detailedConnectionPageHeader.height*2
            Rectangle{
                id: sectionRectangle
                width: parent.width
                height: parent.height
                color: "lightblue"
                border{
                    color: "black"
                    width: 1
                }
                Column{
                    spacing: (sectionRectangle.height - firstSectionRow.height - secondSectionRow.height - thirdSectionRow.height -20)/3
                    Row{
                        id: firstSectionRow
                        topPadding: 10
                        spacing: (sectionRectangle.width - departureTime.width - arrow.width - arrivalTime.width -10)/2
                        Row{
                            id: departureTime
                            Text{
                                leftPadding: 20
                                text: model.departure.departure.slice(11,16)
                                font.pointSize: detailedConnectionPageHeader.height*3/10
                            }
                            Text{
                                text: (model.departure.delay!=null && model.departure.delay!=0)? "+" + model.departure.delay:""
                                font.pointSize: detailedConnectionPageHeader.height*3/10
                                color: "red"
                            }
                        }
                        Column{
                            spacing: -arrow.height/2
                            Text{
                                text: model.journey.category + " " + model.journey.number
                                font.pointSize: detailedConnectionPageHeader.height*3/10
                            }
                            Image{
                                id: arrow
                                source: "arrow.png"
                                width: sectionRectangle.width*5/9
                                height: sectionRectangle.height/2
                            }
                        }
                        Row{
                            id: arrivalTime
                            Text{
                                rightPadding: 20
                                text: model.arrival.arrival.slice(11,16)
                                font.pointSize: detailedConnectionPageHeader.height*3/10
                            }
                            Text{
                                text: (model.arrival.delay!=null && model.arrival.delay!=0)? "+" + model.arrival.delay:""
                                font.pointSize: detailedConnectionPageHeader.height*3/10
                                color: "red"
                            }
                        }
                    }
                    Row{
                        id: secondSectionRow
                        bottomPadding: (sectionRectangle.height - firstSectionRow.height - arrivalStation.height)/3 + arrivalStation.height
                        spacing: sectionRectangle.width - departureStation.width - arrivalStation.width -10
                        Text{
                            leftPadding: 20
                            id: departureStation
                            text: model.departure.station.name
                            font.pointSize: detailedConnectionPageHeader.height*2/10
                        }
                        Text{
                            rightPadding: 20
                            id: arrivalStation
                            text: model.arrival.station.name
                            font.pointSize: detailedConnectionPageHeader.height*2/10
                        }
                    }
                    Row{
                        id: thirdSectionRow
                        bottomPadding: 10
                        spacing: sectionRectangle.width - departurePlatform.width - arrivalPlatform.width -10
                        Text{
                            leftPadding: 20
                            id: departurePlatform
                            text: model.departure.platform
                            font.pointSize: detailedConnectionPageHeader.height*5/20
                        }
                        Text{
                            rightPadding: 20
                            id: arrivalPlatform
                            text: model.arrival.platform
                            font.pointSize: detailedConnectionPageHeader.height*5/20
                        }
                    }
                }
            }
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    console.log("Clicked on connection")
                    var component = Qt.createComponent("Detailed_section_page.qml");
                    if (component.status === Component.Ready) {
                        var properties = {
                            "journey": model.journey
                        }
                        stackView.push(component, properties);
                    } else if (component.status === Component.Error) {
                        console.log("Error: ", component.errorString());
                    }
                }
            }
        }
    }
}