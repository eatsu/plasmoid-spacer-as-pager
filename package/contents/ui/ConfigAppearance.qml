/*
    SPDX-FileCopyrightText: 2023 eatsu <mkrmdk@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import org.kde.kirigami 2.19 as Kirigami

Kirigami.FormLayout {
    anchors.left: parent.left
    anchors.right: parent.right

    property alias cfg_expanding: expanding.checked
    property alias cfg_length: length.value

    ButtonGroup {
        id: expandingGroup
    }

    RadioButton {
        Kirigami.FormData.label: i18n("Length:")
        id: expanding
        text: i18n("Set flexible size")
        checked: expanding.checked
        ButtonGroup.group: expandingGroup
    }

    RadioButton {
        text: i18n("Set fixed size")
        checked: !expanding.checked
        ButtonGroup.group: expandingGroup
    }

    RowLayout {
        spacing: Kirigami.Units.smallSpacing
        enabled: !expanding.checked

        SpinBox {
            id: length
            from: 1
            to: 9999
        }

        Label {
            text: "px"
            color: enabled ? Kirigami.Theme.textColor : Kirigami.Theme.disabledTextColor
        }
    }
}
