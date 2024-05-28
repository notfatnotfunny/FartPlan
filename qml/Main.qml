/*
 * Copyright (C) 2024  Davide Plozner
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * fartplan is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/*
 * Copyright (C) 2024  Davide Plozner
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * fartplan is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.7
import Lomiri.Components 1.3
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0


Page {
    property var list1: []
    property var list2: []

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
                    color: "lightblue"
                }
                padding: 10
                onClicked: {
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
                                    var timeDep = response.connections[i].from.departure.slice(11, 16);
                                    var timeArr = response.connections[i].to.arrival.slice(11, 16);
                                    var Departure = Qt.createQmlObject('import QtQuick 2.0; Text { text: "' + timeDep + '"; }', timeText);
                                    var Arrival = Qt.createQmlObject('import QtQuick 2.0; Text { text: "' + timeArr + '"; }', timeText);

                                    var stationDep = response.connections[i].from.station.name;
                                    var stationArr = response.connections[i].to.station.name;
                                    var journeyDep = Qt.createQmlObject('import QtQuick 2.0; Text { text: "' + stationDep + '"; }', journeyText);
                                    var journeyArr = Qt.createQmlObject('import QtQuick 2.0; Text { text: "' + stationArr + '"; }', journeyText);

                                    var platformDep = response.connections[i].from.platform;
                                    var platformArr = response.connections[i].to.platform;
                                    var Platform = Qt.createQmlObject('import QtQuick 2.0; Text { text: "' + platformDep + '"; }', platformText);
                                    var Platform = Qt.createQmlObject('import QtQuick 2.0; Text { text: "' + platformArr + '"; }', platformText);
                                    
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

            GridLayout {
                columns: 3
                width: parent.width

                Text { text: "Time"; font.bold: true }
                Text { text: "Journey"; font.bold: true }
                Text { text: "Platform"; font.bold: true }

                Column {
                    id: timeText
                }

                Column {
                    id: journeyText
                }

                Column {
                    id: platformText
                }
            }
        }
    }
}
