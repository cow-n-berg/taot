/*
 *  TAO Translator
 *  Copyright (C) 2013-2018  Oleksii Serdiuk <contacts[at]oleksii[dot]name>
 *
 *  $Id: $Format:%h %ai %an$ $
 *
 *  This file is part of TAO Translator.
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

import QtQuick 1.0
import bb.cascades 1.0
import taot 1.0

Page {
    property bool darkTheme: Application.themeSupport.theme.colorTheme.style === VisualStyle.Dark

    titleBar: TitleBar {
        kind: TitleBarKind.FreeForm
        kindProperties: FreeFormTitleBarKindProperties {
            id: tbp
            Container {
                layout: StackLayout { orientation: LayoutOrientation.LeftToRight }
                leftPadding: 20
                Label {
                    text: translator.selectedService.name
                    textStyle {
                        color: osVersion < 0x0A0300 ? Color.White : undefined
                        base: SystemDefaults.TextStyles.TitleText
                    }
                    verticalAlignment: VerticalAlignment.Center
                }
            }
            expandableArea {
                content: RadioGroup {
                    id: services

                    onSelectedOptionChanged: {
                        tbp.expandableArea.expanded = false;
                        translator.selectService(selectedIndex);
                    }
                }
            }
        }
    }

    ScrollView {
        Container {
            property int padding: 15

            topPadding: padding
            leftPadding: padding
            bottomPadding: padding
            rightPadding: padding

            Container {
                layout: StackLayout { orientation: LayoutOrientation.LeftToRight }

                DropDown {
                    id: sourceLanguagesDropDown
                    title: qsTr("From") + Retranslate.onLocaleOrLanguageChanged
                    visible: !targetLanguagesDropDown.expanded

                    onSelectedIndexChanged: {
                        if (selectedIndex >= 0)
                            translator.selectSourceLanguage(selectedIndex);
                    }
                }

                Button {
                    imageSource: "asset:///icons/swap" + (darkTheme ? "_inverted" : "") + ".png"
                    visible: translator.canSwapLanguages
                             && !sourceLanguagesDropDown.expanded
                             && !targetLanguagesDropDown.expanded

                    onClicked: {
                        translator.swapLanguages();
                    }
                }

                DropDown {
                    id: targetLanguagesDropDown
                    title: qsTr("To") + Retranslate.onLocaleOrLanguageChanged
                    visible: !sourceLanguagesDropDown.expanded

                    onSelectedIndexChanged: {
                        if (selectedIndex >= 0)
                            translator.selectTargetLanguage(selectedIndex);
                    }
                }
            }

            TextArea {
                id: source
                hintText: qsTr("Enter the source text...") + Retranslate.onLocaleOrLanguageChanged
                textFormat: TextFormat.Plain

                input {
                    submitKey: translateOnEnter ? SubmitKey.Go : SubmitKey.Default

                    onSubmitted: {
                        if (translator.sourceText != "")
                            translator.translate();
                    }
                }

                onTextChanging: {
                    translator.sourceText = text;
                }
            }

            Container {
                leftPadding: 15
                bottomPadding: 15
                visible: translator.transcription.sourceText != ""

                Label {
                    text: translator.transcription.sourceText
                    topMargin: 0
                    bottomMargin: 0
                }
            }

            ExpandableLabel {
                text: translator.translit.sourceText
                leftPadding: 15
                bottomPadding: 15
                visible: translator.translit.sourceText != ""
                textStyle {
                    fontStyle: FontStyle.Italic
                }
            }

            Container {
                layout: StackLayout { orientation: LayoutOrientation.LeftToRight }

                Container {
                    layout: DockLayout {}

                    Button {
                        text: qsTr("Translate") + Retranslate.onLocaleOrLanguageChanged
                        enabled: !translator.busy && translator.sourceText != ""
                        onClicked: {
                            translator.translate();
                        }
                        horizontalAlignment: HorizontalAlignment.Fill
                        verticalAlignment: VerticalAlignment.Center
                    }
                    ActivityIndicator {
                        running: translator.busy
                        horizontalAlignment: HorizontalAlignment.Center
                        verticalAlignment: VerticalAlignment.Fill
                    }
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 5
                    }
                }
                Button {
                    id: clearButton

                    imageSource: "asset:///icons/ic_clear" + (darkTheme ? "_inverted" : "") + ".png"
                    enabled: translator.sourceText != ""
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
                    onClicked: {
                        source.text = "";
                        source.requestFocus();
                    }
                }
            }

            TextArea {
                id: translation
                text: translator.translatedText
                editable: false
                textFormat: TextFormat.Plain
                visible: translator.supportsTranslation
            }

            Container {
                leftPadding: 15
                bottomPadding: 15
                visible: translator.transcription.translatedText != ""

                Label {
                    text: translator.transcription.translatedText
                    topMargin: 0
                    bottomMargin: 0
                }
            }

            ExpandableLabel {
                text: translator.translit.translatedText
                visible: translator.translit.translatedText != ""
                leftPadding: 15
                bottomPadding: 15
                textStyle {
                    fontStyle: FontStyle.Italic
                }
            }

            Container {
                layout: StackLayout { orientation: LayoutOrientation.LeftToRight }
                bottomMargin: 15
                visible: translator.detectedLanguageName != ""

                Label {
                    text: qsTr("Detected language:") + Retranslate.onLocaleOrLanguageChanged
                }
                Label {
                    text: translator.detectedLanguageName
                    textStyle {
                        fontWeight: FontWeight.Bold
                    }
                }
            }

            Repeater {
                model: translator.dictionary
                DictionaryDelegate {}
            }
        }
    }

    actions: [
        ActionItem {
            title: qsTr("Paste") + Retranslate.onLocaleOrLanguageChanged
            imageSource: "asset:///icons/ic_paste.png"
            enabled: !clipboard.empty
            ActionBar.placement: ActionBarPlacement.OnBar

            onTriggered: {
                if (translateOnPaste) {
                    source.text = clipboard.text;
                    translator.translate();
                } else {
                    source.editor.insertPlainText(clipboard.text);
                }
            }
        },
        ActionItem {
            id: copyAction

            property bool hasSelection: translation.editor.selectedText != ""

            title: (hasSelection ? qsTr("Copy selection") : qsTr("Copy all"))
                   + Retranslate.onLocaleOrLanguageChanged
            imageSource: "asset:///icons/ic_copy.png"
            enabled: translation.text != ""
            ActionBar.placement: ActionBarPlacement.OnBar

            onTriggered: {
                clipboard.clear();
                if (clipboard.insert(hasSelection ? translation.editor.selectedText
                                                  : translation.text))
                    toast.body = qsTr("Translation was successfully copied to clipboard");
                else
                    toast.body = qsTr("Couldn't copy translation to clipboard");
                toast.show();
            }
        },
        InvokeActionItem {
            title: qsTr("Share") + Retranslate.onLanguageChanged
            enabled: translator.translatedText != ""
            query {
                mimeType: "text/plain"
                invokeActionId: "bb.action.SHARE"
            }
            onTriggered: {
                //: <source text> (<source/detected language>) -> <translated text> (<target language>)
                data = qsTr("%1 (%2) -> %3 (%4)").arg(translator.sourceText)
                                                 .arg(translator.detectedLanguageName
                                                      ? translator.detectedLanguageName
                                                      : translator.sourceLanguage.displayName)
                                                 .arg(translator.translatedText)
                                                 .arg(translator.targetLanguage.displayName);
            }
        }
    ]

    attachedObjects: [
        ComponentDefinition {
            id: option
            Option {}
        },
        Clipboard {
            id: clipboard
        },
        Connections {
            target: translation.editor
            onSelectionStartChanged: {
                selectionChanged();
            }
            onSelectionEndChanged: {
                selectionChanged();
            }
        }

    ]

    onCreationCompleted: {
        for (var k = 0; k < translator.services.count; k++) {
            var opt = option.createObject();
            opt.text = translator.services.get(k);
            services.add(opt);
        }
        services.selectedIndex = translator.selectedService.index;

        translator.sourceLanguages.modelReset.connect(updateSourceLanguages);
        translator.targetLanguages.modelReset.connect(updateTargetLanguages);
        translator.sourceLanguageChanged.connect(sourceLanguageChanged);
        translator.targetLanguageChanged.connect(targetLanguageChanged);
        updateSourceLanguages();
        updateTargetLanguages();
        sourceLanguagesDropDown.selectedIndex = translator.sourceLanguage.index;
        targetLanguagesDropDown.selectedIndex = translator.targetLanguage.index;

        translator.sourceTextChanged.connect(sourceTextChanged);
    }

    function updateSourceLanguages()
    {
        sourceLanguagesDropDown.removeAll();
        for (var k = 0; k < translator.sourceLanguages.count; k++) {
            var opt = option.createObject();
            opt.text = translator.sourceLanguages.displayNameOf(k);
            sourceLanguagesDropDown.add(opt);
        }
    }
    function updateTargetLanguages()
    {
        targetLanguagesDropDown.removeAll();
        for (var k = 0; k < translator.targetLanguages.count; k++) {
            var opt = option.createObject();
            opt.text = translator.targetLanguages.displayNameOf(k);
            targetLanguagesDropDown.add(opt);
        }
    }
    function selectionChanged()
    {
        copyAction.hasSelection = (translation.editor.selectedText != "");
    }
    function sourceLanguageChanged()
    {
        sourceLanguagesDropDown.selectedIndex = translator.sourceLanguage.index;
    }
    function targetLanguageChanged()
    {
        targetLanguagesDropDown.selectedIndex = translator.targetLanguage.index;
    }
    function sourceTextChanged()
    {
        source.text = translator.sourceText;
    }
}
