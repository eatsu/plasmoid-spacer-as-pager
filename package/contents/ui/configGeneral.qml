/*
 *  SPDX-FileCopyrightText: 2023 eatsu <mkrmdk@gmail.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.5
import QtQuick.Controls 2.5 as QQC2

import org.kde.kirigami 2.5 as Kirigami
import org.kde.plasma.plasmoid 2.0

Kirigami.FormLayout {

    anchors.left: parent.left
    anchors.right: parent.right

    property alias cfg_wrapPage: wrapPage.checked
    property alias cfg_expanding: expanding.checked
    property alias cfg_length: length.value

    QQC2.CheckBox {
        Kirigami.FormData.label: i18n("Behavior:")
        id: wrapPage
        text: i18n("Navigation wraps around")
    }


    Item {
        Kirigami.FormData.isSection: true
    }


    QQC2.ButtonGroup {
        id: expandingGroup
    }

    QQC2.RadioButton {
        Kirigami.FormData.label: i18n("Length:")
        id: expanding
        text: i18n("Set flexible size")
        checked: expanding.checked
        QQC2.ButtonGroup.group: expandingGroup
    }

    QQC2.RadioButton {
        text: i18n("Set fixed size")
        checked: !expanding.checked
        QQC2.ButtonGroup.group: expandingGroup
    }

    QQC2.SpinBox {
        id: length
        from: 1
        to: 9999
        // textFromValue: function(value) { return value + "px" }
        // valueFromText: function(text) { return parseFloat(text) }
        enabled: !expanding.checked
    }
}
