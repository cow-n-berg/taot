/*
 *  The Advanced Online Translator
 *  Copyright (C) 2013  Oleksii Serdiuk <contacts[at]oleksii[dot]name>
 *
 *  $Id: $Format:%h %ai %an$ $
 *
 *  This file is part of The Advanced Online Translator.
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License along
 *  with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 1.1
import com.nokia.symbian 1.1
import taot 1.0

Page {
    // A hack for text item to loose focus when clicked outside of it
    MouseArea {
        id: dummyFocus
        anchors.fill: parent
        onClicked: {
            focus = true;
        }
    }

    SelectionDialog {
        id: servicesDialog
        titleText: qsTr("Select the translation service")
        model: translator.services
        delegate: ListDelegate {
            text: model.name
            privateSelectionIndicator: selectedIndex === model.index
            onClicked: {
                selectedIndex = model.index;
                translator.selectService(model.index);
                servicesDialog.accept();
            }
        }
    }

    SelectionDialog {
        id: fromDialog
        titleText: qsTr("Select the source language")
        model: translator.sourceLanguages
        delegate: ListDelegate {
            text: model.name
            privateSelectionIndicator: selectedIndex === model.index
            onClicked: {
                selectedIndex = model.index;
                translator.selectSourceLanguage(model.index);
                fromDialog.accept();
            }
        }
    }

    SelectionDialog {
        id: toDialog
        titleText: qsTr("Select the target language")
        model: translator.targetLanguages
        delegate: ListDelegate {
            text: model.name
            privateSelectionIndicator: selectedIndex === model.index
            onClicked: {
                selectedIndex = model.index;
                translator.selectTargetLanguage(model.index);
                toDialog.accept();
            }
        }
    }

    Component {
        id: header

        Column {
            id: col

            width: ListView.view.width
            height: childrenRect.height + platformStyle.paddingMedium
            spacing: platformStyle.paddingMedium

            Row {
                width: parent.width
                height: childrenRect.height

                SelectionListItem {
                    width: parent.width / 2
                    title: qsTr("From");
                    subTitle: translator.sourceLanguage.displayName

                    onClicked: {
                        fromDialog.selectedIndex = translator.sourceLanguages
                                                   .indexOf(translator.sourceLanguage);
                        fromDialog.open();
                    }
                }
                SelectionListItem {
                    width: parent.width / 2
                    title: qsTr("To")
                    subTitle: translator.targetLanguage.displayName

                    onClicked: {
                        toDialog.selectedIndex = translator.targetLanguages
                                                 .indexOf(translator.targetLanguage);
                        toDialog.open();
                    }
                }
            }

            Timer {
                id: timer
                interval: 1500

                onTriggered: {
                    if (source.text !== "")
                        translator.translate();
                }
            }

            TextArea {
                id: source

                width: parent.width
                height: Math.min(implicitHeight, listDictionary.height * 0.4)
//                text: "Welcome"
                placeholderText: qsTr("Enter the source text...")
                textFormat: TextEdit.PlainText

//                Keys.onReturnPressed: translator.translate();
//                Keys.onEnterPressed: translator.translate();

                onTextChanged: {
                    if (translator.sourceText == text)
                        return;

                    translator.sourceText = text;
                    timer.restart();
                }
            }

            Row {
                width: parent.width
                height: source.text != "" ? childrenRect.height : 0
                spacing: platformStyle.paddingMedium
                clip: true

                Button {
                    width: (parent.width - parent.spacing) / 2
                    text: qsTr("Translate")
                    enabled: !translator.busy
                    onClicked: {
                        dummyFocus.focus = true;
                        timer.stop();
                        translator.translate();
                    }
                }
                Button {
                    width: (parent.width - parent.spacing) / 2
                    text: qsTr("Clear")
                    onClicked: {
                        source.text = "";
                        source.forceActiveFocus();
                    }
                }

                Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }}
            }

            BorderImage {
                height: trans.implicitHeight + platformStyle.borderSizeMedium / 2 + 2 * platformStyle.paddingMedium
                source: privateStyle.imagePath("qtg_fr_textfield_uneditable", false)
                smooth: true
                border {
                    top: platformStyle.borderSizeMedium
                    left: platformStyle.borderSizeMedium
                    bottom: platformStyle.borderSizeMedium
                    right: platformStyle.borderSizeMedium
                }
                anchors {
                    left: parent.left
                    right: parent.right
                }

                Label {
                    id: trans

                    text: translator.translatedText
                    wrapMode: TextEdit.Wrap
                    color: platformStyle.colorNormalDark
                    anchors {
                        top: parent.top
                        topMargin: platformStyle.borderSizeMedium / 4 + platformStyle.paddingMedium
                        left: parent.left
                        leftMargin: platformStyle.borderSizeMedium / 2 + platformStyle.paddingSmall
                        right: parent.right
                        rightMargin: platformStyle.borderSizeMedium / 2 + platformStyle.paddingSmall
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        dummyFocus.focus = true;
                        if (translator.translatedText != "")
                            pageStack.push(translationPage);
                    }
                }
            }

            Row {
                id: detectedLanguage

                width: parent.width
                height: childrenRect.height
                spacing: platformStyle.paddingSmall
                state: "Empty"
                clip: true

                Label {
                    font.weight: Font.Light
                    text: qsTr("Detected language:")
                }
                Label {
                    id: dl
                    text: translator.detectedLanguageName
                }

                states: [
                    State {
                        name: "Empty"
                        when: translator.detectedLanguageName === ""

                        PropertyChanges {
                            target: detectedLanguage
                            height: 0
                            opacity: 0
                            scale: 0
                        }
                        PropertyChanges {
                            target: dl
                            text: ""
                        }
                    }
                ]

                transitions: [
                    Transition {
                        from: ""
                        to: "Empty"

                        ParallelAnimation {
                            NumberAnimation {
                                target: detectedLanguage
                                property: "height"
                                duration: 1300
                                easing.type: Easing.OutBack
                            }
                            SequentialAnimation {
                                PauseAnimation {
                                    duration: 1300
                                }
                                PropertyAction {
                                    targets: [detectedLanguage,dl]
                                    properties: "scale,opacity,text"
                                }
                            }
                        }
                    },
                    Transition {
                        from: "Empty"
                        to: ""

                        SequentialAnimation {
                            PropertyAction {
                                targets: [detectedLanguage,dl]
                                properties: "height,text"
                            }
                            NumberAnimation {
                                target: detectedLanguage
                                properties: "scale,opacity"
                                duration: 300
                                easing.type: Easing.OutBack
                            }
                        }
                    }
                ]
            }

            Component.onCompleted: {
                listDictionary.headerItem = col;
            }
        }
    }

    Rectangle {
        z: 100
        color: platformInverted ? platformStyle.colorBackgroundInverted
                                : platformStyle.colorBackground
        opacity: translator.busy ? 0.5 : 0.0
        visible: opacity != 0
        anchors.fill: parent

        BusyIndicator {
            width: platformStyle.graphicSizeLarge
            height: width
            running: parent.visible
            anchors.centerIn: parent
        }

        Behavior on opacity { NumberAnimation { duration: 200 } }
    }

    ScrollDecorator {
        flickableItem: listDictionary
    }

    Item {
        id: titleBar

        width: parent.width
        height: platformStyle.graphicSizeMedium

        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop {
                    position: 0.00
                    color: platformStyle.colorNormalLink
                }
                GradientStop {
                    position: 1.0;
                    color: Qt.darker(platformStyle.colorNormalLink)
                }
            }
        }

        Rectangle {
            color: platformStyle.colorNormalLink
            visible: mouseArea.pressed
            anchors.fill: parent
        }

        MouseArea {
            id: mouseArea
            enabled: parent.enabled
            anchors.fill: parent
            onClicked: {
                if (servicesDialog.selectedIndex < 0)
                    servicesDialog.selectedIndex = translator.selectedService.index;
                servicesDialog.open();
            }
        }

        Label {
            color: "white"
            text: translator.selectedService.name
            font.pixelSize: privateStyle.fontSizeLarge
            anchors {
                left: parent.left
                leftMargin: platformStyle.paddingLarge
                verticalCenter: parent.verticalCenter
            }
        }

        Image {
            id: icon

            source: "image://theme/qtg_graf_choice_list_indicator"
            sourceSize {
                width: platformStyle.graphicSizeSmall
                height: platformStyle.graphicSizeSmall
            }
            anchors {
                right: parent.right
                rightMargin: 10
                verticalCenter: parent.verticalCenter
            }
        }
    }

    ListView {
        id: listDictionary

        property Item headerItem

        clip: true
        model: translator.dictionary
        interactive: visibleArea.heightRatio < 1.0 || (headerItem.height > height - 2 * platformStyle.paddingMedium)
        // HACK: We need this to save the exapnded state of translation.
        // TODO: Come up with more appropriate solution.
        cacheBuffer: 65535
        anchors {
            top: titleBar.bottom
            left: parent.left
            leftMargin: platformStyle.paddingSmall
            bottom: parent.bottom
            right: parent.right
            rightMargin: platformStyle.paddingSmall
        }

        header: header
        delegate: DictionaryDelegate {
            onClicked: {
                dummyFocus.focus = true;
            }
        }

        onMovementStarted: {
            dummyFocus.focus = true;
        }
    }

    tools: ToolBarLayout {
        ToolButton {
            iconSource: Qt.resolvedUrl("icons/close.svg")
            onClicked: Qt.quit();
        }
        ToolButton {
            iconSource: "toolbar-menu"
            onClicked: mainMenu.open();
        }
    }

    Menu {
        id: mainMenu

        MenuLayout {
            MenuItem {
                text: qsTr("About")
                onClicked: aboutDialog.open();
            }
        }
    }

    QueryDialog {
        id: aboutDialog

        titleText: "<b>The Advanced Online Translator</b><br />v%1".arg(translator.version)
        acceptButtonText: qsTr("Ok")
        privateCloseIcon: true

        message: "<p>Copyright &copy; 2013 <b>Oleksii Serdiuk</b> &lt;contacts[at]oleksii[dot]name&gt;</p>
<p>&nbsp;</p>
<p>The Advanced Online Translator uses available online translation
services to provide translations. Currently it supports only Google
Translate but more services are in the plans (i.e., Bing Translate,
Yandex Translate, etc.).</p>

<p>For Google Translate alternative and reverse translations are displayed
for single words.</p>
<p>&nbsp;</p>
<p>This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.</p>

<p>This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.</p>

<p>You should have received a copy of the GNU General Public License
along with this program.  If not, see &lt;http://www.gnu.org/licenses/&gt;.</p>"
    }

    Translator {
        id: translator

//        service: "Yandex"

        onError: {
            console.debug(errorString);
            banner.text = errorString;
            banner.open();
        }
    }

    Component {
        id: translationPage
        TranslationTextAreaPage {}
    }
}