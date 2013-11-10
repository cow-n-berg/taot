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
import com.nokia.meego 1.1
import taot 1.0
import "constants.js" as UI

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
        id: fromDialog
        titleText: qsTr("Select the source language")
        model: translator.sourceLanguages
        onSelectedIndexChanged: {
            translator.selectSourceLanguage(selectedIndex);
        }
    }

    SelectionDialog {
        id: toDialog
        titleText: qsTr("Select the target language")
        model: translator.targetLanguages
        onSelectedIndexChanged: {
            translator.selectTargetLanguage(selectedIndex);
        }
    }

    Component {
        id: header

        Column {
            id: col

            width: ListView.view.width
            height: childrenRect.height + UiConstants.ButtonSpacing
            spacing: UiConstants.ButtonSpacing

            Row {
                height: childrenRect.height
                anchors {
                    left: parent.left
                    right: parent.right
                }

                ListDelegate {
                    width: parent.width / 2
                    title: qsTr("From");
                    subTitle: translator.sourceLanguage.displayName;

                    onClicked: {
                        if (fromDialog.selectedIndex < 0) {
                            fromDialog.selectedIndex = translator.sourceLanguages
                                                       .indexOf(translator.sourceLanguage);
                        }
                        fromDialog.open();
                    }
                }
                ListDelegate {
                    width: parent.width / 2
                    title: qsTr("To")
                    subTitle: translator.targetLanguage.displayName;

                    onClicked: {
                        if (toDialog.selectedIndex < 0) {
                            toDialog.selectedIndex = translator.targetLanguages
                                                     .indexOf(translator.targetLanguage);
                        }
                        toDialog.open();
                    }
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
                }
            }

            Row {
                width: parent.width
                height: childrenRect.height
                spacing: UiConstants.ButtonSpacing
                clip: true

                Button {
                    width: (parent.width - parent.spacing) / 2
                    text: qsTr("Translate")
                    enabled: !translator.busy
                    onClicked: {
                        dummyFocus.focus = true;
                        translator.translate();
                    }
                }
                Button {
                    width: (parent.width - parent.spacing) / 2
                    text: qsTr("Clear")
                    enabled: source.text != ""
                    onClicked: {
                        source.text = "";
                        source.forceActiveFocus();
                    }
                }

                Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }}
            }

            BorderImage {
                height: trans.implicitHeight + (52 /*UI.FIELD_DEFAULT_HEIGHT*/ - trans.font.pixelSize)
                source: source.style.backgroundDisabled
                smooth: true
                border {
                    top: source.style.backgroundCornerMargin
                    left: source.style.backgroundCornerMargin
                    bottom: source.style.backgroundCornerMargin
                    right: source.style.backgroundCornerMargin
                }
                anchors {
                    left: parent.left
                    right: parent.right
                }

                Label {
                    id: trans

                    text: translator.translatedText
                    wrapMode: TextEdit.Wrap
                    color: source.style.textColor
                    font: source.style.textFont
                    anchors {
                        top: parent.top
                        topMargin: (52 /*UI.FIELD_DEFAULT_HEIGHT*/ - font.pixelSize) / 2
                        left: parent.left
                        leftMargin: source.style.paddingLeft
                        right: parent.right
                        rightMargin: source.style.paddingRight
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
                spacing: 4 /*UI.PADDING_SMALL*/
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
        color: theme.inverted ? "#000000" /*UI.COLOR_INVERTED_BACKGROUND*/
                              : "#E0E1E2" /*UI.COLOR_BACKGROUND*/
        opacity: translator.busy ? 0.5 : 0.0
        visible: opacity != 0
        anchors.fill: parent

        BusyIndicator {
            width: 48 /*UI.SIZE_ICON_LARGE*/
            height: width
            running: parent.visible
            anchors.centerIn: parent
        }

        Behavior on opacity { NumberAnimation { duration: 200 } }
    }

    ListView {
        id: listDictionary

        property Item headerItem

        clip: true
        model: translator.dictionary
        interactive: visibleArea.heightRatio < 1.0 || (headerItem.height > height - 2 * UiConstants.ButtonSpacing)
        // HACK: We need this to save the exapnded state of translation.
        // TODO: Come up with more appropriate solution.
        cacheBuffer: 65535
        anchors {
            fill: parent
            margins: 8 /*UI.PADDING_LARGE*/
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

    ScrollDecorator {
        flickableItem: listDictionary
    }

    tools: ToolBarLayout {
        ToolIcon {
            iconId: "toolbar-close"
            onClicked: Qt.quit();
        }
        ToolIcon {
            iconId: "toolbar-view-menu"
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

        onError: {
            console.debug(errorString);
            banner.text = errorString;
            banner.show();
        }
    }

    Component {
        id: translationPage
        TranslationTextAreaPage {}
    }
}
