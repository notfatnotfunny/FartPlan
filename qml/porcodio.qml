import QtQuick 2.7
import Lomiri.Components 1.3
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0


Page {
    property var list1: []
    property var list2: []
    property var connectionsList: []

    Item {
        anchors.fill: parent

        PageHeader {
            id: header
            title: i18n.tr('fartplan')
        }

        Column {
            anchors {
                top: header.bottom
                left: parent.left
                right: parent.right
            }

            spacing: 10

            TextField {
                id: textField1
                width: parent.width - 20
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
                                for (var i = 0; i < 2; i++) {
                                    var button = Qt.createQmlObject('import QtQuick 2.0; Text { text: "' + locations.stations[i].name + '"; color: "blue"; MouseArea { anchors.fill: parent; onClicked: { textField1.text = "' + locations.stations[i].name + '";} } }', locationButtons1);
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
                onAccepted: locationButtons1.visible = true
            }

            Column {
                id: locationButtons1
            }

            TextField {
                id: textField2
                width: parent.width - 20
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
                                for (var i = 0; i < 2; i++) {
                                    var button = Qt.createQmlObject('import QtQuick 2.0; Text { text: "' + locations.stations[i].name + '"; color: "blue"; MouseArea { anchors.fill: parent; onClicked: { textField2.text = "' + locations.stations[i].name + '"; } } }', locationButtons2);
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
                text: "search"
                visible: true
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
                background: Rectangle {
                    color: "red"
                }
                padding: 10
                onClicked: {
                    connectionsList = [];
                    var from = textField1.text;
                    var to = textField2.text;
                    
                    for(var i = 0; i < list1.length; i++) {
                        if (list1[i].name === from) {
                            from = list1[i].id;
                        }
                    }
                    for(var i = 0; i < list2.length; i++) {
                        if (list2[i].name === to) {
                            to = list2[i].id;
                        }
                    }

                    var xhr = new XMLHttpRequest();
                    var url = "http://transport.opendata.ch/v1/connections?from=" + from + "&to=" + to;
                    xhr.onreadystatechange = function() {
                        if (xhr.readyState === XMLHttpRequest.DONE) {
                            try {
                                var response = JSON.parse(xhr.responseText);
                                for(var i = 0; i < response.connections.length; i++) {
                                    var connection = {
                                        timeDep: response.connections[i].from.departure.slice(11, 16),
                                        timeArr: response.connections[i].to.arrival.slice(11, 16),
                                        stationDep: response.connections[i].from.station.name,
                                        stationArr: response.connections[i].to.station.name,
                                        platformDep: response.connections[i].from.platform,
                                        platformArr: response.connections[i].to.platform
                                    };
                                    connectionsList.push(connection);
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
                id: connectionsListView
                width: parent.width
                height: 200
                model: connectionsList
                delegate: Item {
                    width: parent.width
                    height: 50
                    Column {
                        Text { text: "Departure: " + model.timeDep + " (" + model.stationDep + ")" }
                        Text { text: "Arrival: " + model.timeArr + " (" + model.stationArr + ")" }
                        Text { text: "Platform: " + model.platformDep + " - " + model.platformArr }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                console.log("Clicked: " + model.timeDep + " - " + model.timeArr);
                            }
                        }
                    }
                }
            }
        }
    }
}
