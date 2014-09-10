import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0 as ListItem

import "JSONListModel" as JSON

/*!
    \brief MainView with a Label and Button elements.
*/

MainView {
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "com.ubuntu.developer.sturmflut.storebrowser"

    /*
     This property enables the application to change orientation
     when the device is rotated. The default is false.
    */
    //automaticOrientation: true

    // Removes the old toolbar and enables new features of the new header.
    useDeprecatedToolbar: false

    width: units.gu(100)
    height: units.gu(75)

    PageStack {
        id: pageStack
        Component.onCompleted: push(appListPage)

        Page {
            id: appListPage
            title: i18n.tr("App List")

            ActivityIndicator {
                id: storeLoadIndicator
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter

                running: true
            }

                JSON.JSONListModel {
                    id: storeJSONmodel
                    source: "https://search.apps.ubuntu.com/api/v1/search?q=architecture:armhf&size=100000&page=1"

                    query: "$._embedded.clickindex:package[*]"

                    Component.onCompleted: {
                        storeJSONmodel.modelUpdated.connect(deactivateIndicator)
                    }

                    function deactivateIndicator() {
                        storeLoadIndicator.running = false
                        storeLoadIndicator.visible = false
                    }

                }

                ListView {
                    id: appList
                    model: storeJSONmodel.model
                    anchors.fill: parent

                    delegate: ListItem.Subtitled {
                        text: model.title
                        progression: true
                        subText: "Author: " + model.publisher + "  Score: " + model.ratings_average
                        iconSource: model.icon_url
                        onClicked: {
                            appDetailPage.title = model.title
                            appJSONmodel.source = model._links.self.href

                            detailLoadIndicator.running = true
                            detailLoadIndicator.visible = true

                            pageStack.push(appDetailPage)
                        }
                    }
                }

        }

        Page {
            id: appDetailPage
            visible: false

            JSON.JSONListModel {
                id: appJSONmodel

                query: "$"

                Component.onCompleted: {
                    appJSONmodel.modelUpdated.connect(updateAppDetails)
                }

                function updateAppDetails() {
                    if(appJSONmodel.model.count > 0)
                    {
                        detailLoadIndicator.running = false
                        detailLoadIndicator.visible = false

                        appName.text = "Name: " + appJSONmodel.model.get(0).name
                        appPublisher.text = "Publisher: " + appJSONmodel.model.get(0).publisher
                        appDescription.text = "Description:\n" + appJSONmodel.model.get(0).description
                        appVersion.text = "Version: " + appJSONmodel.model.get(0).version
                        appLastUpdate.text = "Last update: " + appJSONmodel.model.get(0).last_updated
                    }
                }
            }

            ActivityIndicator {
                id: detailLoadIndicator
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
            }

            Column {
                Label {
                    id:appName
                    text: "Name:"
                }

                Label {
                    id:appPublisher
                    text: "Publisher:"
                }

                Label {
                    id:appDescription
                    text: "Description:"
                }

                Label {
                    id:appVersion
                    text: "Version:"
                }

                Label {
                    id:appLastUpdate
                    text: "Last update:"
                }
            }
        }
    }
}

