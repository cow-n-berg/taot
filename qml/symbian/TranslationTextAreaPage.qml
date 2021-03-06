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

import QtQuick 1.1
import com.nokia.symbian 1.1

Page {
    id: root

    property bool platformInverted: false

    TextArea {
        id: translation

        text: translator.translatedText
        readOnly: true
        anchors.fill: parent
        platformInverted: root.platformInverted
    }

    tools: ToolBarLayout {
        ToolButton {
            iconSource: "toolbar-back"
            platformInverted: root.platformInverted
            onClicked: {
                pageStack.pop();
            }
        }
        ToolButton {
            property bool hasSelection: translation.selectionStart
                                        != translation.selectionEnd
            text: hasSelection ? qsTr("Copy selection") : qsTr("Copy all")
            enabled: translation.text != ""
            platformInverted: root.platformInverted
            onClicked: {
                if (hasSelection)
                    clipboard.insert(translation.selectedText);
                else
                    clipboard.insert(translation.text);
            }
        }
    }
}
