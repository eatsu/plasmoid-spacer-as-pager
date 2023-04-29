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

    property alias cfg_wrapPage: wrapPage.checked
    property alias cfg_command: command.text
    property int cfg_leftClickAction

    CheckBox {
        Kirigami.FormData.label: i18n("Mouse wheel:")
        id: wrapPage
        text: i18n("Navigation wraps around")
    }

    Item {
        Kirigami.FormData.isSection: true
    }

    ButtonGroup {
        id: leftClickActionGroup
    }

    RadioButton {
        Kirigami.FormData.label: i18n("Left click:")
        id: doNothingRadio
        text: i18n("Do nothing")
        checked: cfg_leftClickAction === 0
        onToggled: if (checked) cfg_leftClickAction = 0
        ButtonGroup.group: leftClickActionGroup
    }

    RadioButton {
        id: showDesktopRadio
        text: i18n("Show the desktop")
        checked: cfg_leftClickAction === 1
        onToggled: if (checked) cfg_leftClickAction = 1
        ButtonGroup.group: leftClickActionGroup
    }

    RadioButton {
        id: showOverviewRadio
        text: i18n("Show the overview")
        checked: cfg_leftClickAction === 2
        onToggled: if (checked) cfg_leftClickAction = 2
        ButtonGroup.group: leftClickActionGroup
    }

    Label {
        text: i18n("The Overview effect must be enabled to use this.")
        font: Kirigami.Theme.smallFont
    }

    RadioButton {
        id: runCommandRadio
        text: i18n("Run command")
        checked: cfg_leftClickAction === 3
        onToggled: if (checked) cfg_leftClickAction = 3
        ButtonGroup.group: leftClickActionGroup
    }

    TextField {
        id: command
        placeholderText: i18n("e.g. konsole")
        enabled: runCommandRadio.checked
    }
}
