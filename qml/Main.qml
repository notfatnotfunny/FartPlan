import QtQuick 2.7
import Lomiri.Components 1.3
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0



ApplicationWindow{
    StackView{
        id: stackView
        initialItem: mainPage
        anchors.fill: parent
    }
    property var list1: []
    property var list2: []

    Page {
        id: mainPage
        ListModel {
            id: dynamicListModel
        }

        Item {
            anchors.fill: parent

            PageHeader {
                id: header
                title: i18n.tr('fartplan')
                StyleHints {
                    backgroundColor: "red"
                }
            }

            Column {
                topPadding: 40
                anchors {
                    top: header.bottom
                    left: parent.left
                    right: parent.right
                }

                spacing: 20

                TextField {
                    id: textField1
                    width: parent.width - 20
                    height: header.height
                    placeholderText: "Departure"
                    onTextChanged: {
                        for (var i = 0; i < locationButtons1.children.length; i++) {
                            locationButtons1.children[i].destroy();
                        }
                        list1 = [];

                        var xhr = new XMLHttpRequest();
                        var url = "http://transport.opendata.ch/v1/locations?query=" + textField1.text;
                        xhr.onreadystatechange = function() {
                            if (xhr.readyState === XMLHttpRequest.DONE) {
                                try {
                                    var locations = JSON.parse(xhr.responseText);
                                    for (var i = 0; i < 5; i++) {
                                        var button = Qt.createQmlObject(`
                                            import QtQuick 2.0;
                                            Rectangle {
                                                height: header.height;
                                                width: textField1.width;
                                                color: "lightblue";
                                                border {
                                                    color: "black";
                                                    width: 1;
                                                }
                                                Text {
                                                    text: "${locations.stations[i].name}";
                                                    font.pointSize: parent.height/3;
                                                    anchors.verticalCenter: parent.verticalCenter;
                                                    anchors.left: parent.left;
                                                    anchors.leftMargin: 40;
                                                }
                                                MouseArea {
                                                    anchors.fill: parent;
                                                    onClicked: {
                                                        textField1.text = "${locations.stations[i].name}";
                                                        locationButtons1.visible = false;
                                                    }
                                                }
                                            }`, locationButtons1);
                                        var station = {
                                            name: locations.stations[i].name,
                                            id: locations.stations[i].id
                                        };
                                        list1.push(station);
                                    }
                                } catch (e) {
                                    console.error("Failed to parse API response:", e);
                                }
                            }
                        }
                        xhr.open('GET', url);
                        xhr.send();
                    }
                    onAccepted: locationButtons1.visible = true;
                }

                Column {
                    id: locationButtons1
                }

                TextField {
                    id: textField2
                    width: parent.width - 20
                    height: header.height
                    placeholderText: "Arrival"
                    onTextChanged: {
                        for (var i = 0; i < locationButtons2.children.length; i++) {
                            locationButtons2.children[i].destroy();
                        }
                        list2 = [];

                        var xhr = new XMLHttpRequest();
                        var url = "http://transport.opendata.ch/v1/locations?query=" + textField2.text;
                        xhr.onreadystatechange = function() {
                            if (xhr.readyState === XMLHttpRequest.DONE) {
                                try {
                                    var locations = JSON.parse(xhr.responseText);
                                    for (var i = 0; i < 5; i++) {
                                        var button = Qt.createQmlObject(`
                                            import QtQuick 2.0;
                                            Rectangle {
                                                height: header.height;
                                                width: textField2.width;
                                                color: "lightblue";
                                                border{
                                                    color: "black";
                                                    width: 1;
                                                }
                                                Text {
                                                    text: "${locations.stations[i].name}";
                                                    font.pointSize: parent.height/3;
                                                    anchors.verticalCenter: parent.verticalCenter;
                                                    anchors.left: parent.left;
                                                    anchors.leftMargin: 40;
                                                }
                                                MouseArea {
                                                    anchors.fill: parent;
                                                    onClicked: {
                                                        textField2.text = "${locations.stations[i].name}";
                                                        locationButtons2.visible = false;
                                                    }
                                                }
                                            }`, locationButtons2);
                                        var station = {
                                            name: locations.stations[i].name,
                                            id: locations.stations[i].id
                                        };
                                        list2.push(station);
                                    }
                                } catch (e) {
                                    console.error("Failed to parse API response:", e);
                                }
                            }
                        }
                        xhr.open('GET', url);
                        xhr.send();
                    }
                    onAccepted: locationButtons2.visible = true
                }

                Column {
                    id: locationButtons2
                }

                Button {
                    id: searchButton
                    height: header.height
                    width: textField1.width/4
                    text: "Search"
                    visible: true
                    font.pointSize: parent.width/30
                    font.bold: true
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                    }
                    background: Rectangle {
                        color: "red"
                        radius: parent.width/8
                    }
                    padding: 10
                    onClicked: {
                        var from = textField1.text;
                        var to = textField2.text;

                        for(var i = 0; i<list1.length; i++){
                            if(list1[i].name == from){
                                from = list1[i].id;
                            }
                        }
                        for(var i = 0; i<list2.length; i++){
                            if(list2[i].name == to){
                                to = list2[i].id;
                            }
                        }


                        dynamicListModel.clear();
                        var url = "http://transport.opendata.ch/v1/connections?from=" + from + "&to=" + to;
                        var xhr = new XMLHttpRequest();
                        xhr.onreadystatechange = function() {
                            if (xhr.readyState === XMLHttpRequest.DONE) {
                                try {
                                    var response = JSON.parse(xhr.responseText);
                                    for(var i = 0; i < response.connections.length; i++){
                                        var connection = response.connections[i];
                                        for(var j = 0; j<connection.sections.length; j++){
                                            var section = connection.sections[j];
                                            if(j==0){
                                                dynamicListModel.append({
                                                    "category": section.journey? section.journey.category + " " + section.journey.number:"",
                                                    "timeDep": section.departure.departure.slice(11, 16),
                                                    "delayDep": section.departure.delay,
                                                    "stationDep": section.departure.station.name,
                                                    "platformDep": section.departure.platform,


                                                    "sections": connection.sections,


                                                    "timeArr": connection.to.arrival.slice(11, 16),
                                                    "delayArr": connection.to.delay,
                                                    "stationArr": connection.to.station.name,
                                                    "platformArr": connection.to.platform
                                                })
                                            }
                                        }
                                    }
                                } catch (e) {
                                    console.error("Failed to parse API response:", e);
                                }
                            }
                        }
                        xhr.open('GET', url);
                        xhr.send();
                    }
                }

                ListView {
                    id: timeText
                    width: textField1.width + 20
                    height: Math.max(dynamicListModel.count * (header.height * 2), parent.height / 2)
                    model: dynamicListModel
                    delegate: Item {
                        width: parent.width
                        height: header.height*2
                        Rectangle {
                            id: rectangle
                            width: parent.width
                            height: parent.height
                            color: "lightblue"
                            border {
                                color: "black"
                                width: 1
                            }
                            Column{
                                spacing: (rectangle.height - firstRow.height - secondRow.height - thirdRow.height -20)/3
                                Row{
                                    topPadding: 10
                                    id: firstRow
                                    spacing: (rectangle.width - departureTime.width - arrowColumn.width - arrivalTime.width -10)/2
                                    Row{
                                        id: departureTime
                                        Text{
                                            leftPadding: 20
                                            text: model.timeDep
                                            font.pointSize: header.height*3/10
                                        }
                                        Text{
                                            text: (model.delayDep!=null && model.delayDep!=0)? "+" + model.delayDep:""
                                            font.pointSize: header.height*3/10
                                            color: "red"
                                        }
                                    }
                                    Column{
                                        spacing: -arrow.height/2
                                        id: arrowColumn
                                        Text{
                                            id: category
                                            text: model.category
                                            font.pointSize: header.height*3/10
                                        }
                                        Image{
                                            id: arrow
                                            source: "arrow.png"
                                            width: rectangle.width*5/9
                                            height: rectangle.height/2
                                        }
                                    }
                                    Row{
                                        id: arrivalTime
                                        Text{
                                            rightPadding: 20
                                            text: model.timeArr
                                            font.pointSize: header.height*3/10
                                        }
                                        Text{
                                            text: (model.delayArr!=null && model.delayArr!=0)? "+" + model.delayArr:""
                                            font.pointSize: header.height*3/10
                                        }
                                    }
                                }
                                Row{
                                    id: secondRow
                                    bottomPadding: (rectangle.height - firstRow.height - arrivalStation.height)/3 + arrivalStation.height
                                    spacing: rectangle.width - departureStation.width - arrivalStation.width - 10
                                    Text{
                                        leftPadding: 20
                                        id: departureStation
                                        text: model.stationDep
                                        font.pointSize: header.height*2/10
                                    }
                                    Text{
                                        rightPadding: 20
                                        id: arrivalStation
                                        text: model.stationArr
                                        font.pointSize: header.height*2/10
                                    }
                                }
                                Row{
                                    id: thirdRow
                                    bottomPadding: 10
                                    spacing: rectangle.width - departurePlatform.width - arrivalPlatform.width - 10
                                    Text{
                                        leftPadding: 20
                                        id: departurePlatform
                                        text: model.platformDep
                                        font.pointSize: header.height*5/20
                                    }
                                    Text{
                                        rightPadding: 20
                                        id: arrivalPlatform
                                        text: model.platformArr
                                        font.pointSize: header.height*5/20
                                    }
                                }
                            }
                        }
                        MouseArea{
                            anchors.fill: parent
                            onClicked: {
                                var component = Qt.createComponent("Detailed_connection_page.qml");
                                if (component.status === Component.Ready) {
                                    var properties = {
                                        "sections": model.sections
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
        }
    }
}