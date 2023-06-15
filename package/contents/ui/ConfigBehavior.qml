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
    property alias cfg_leftClickAction: leftClickAction.currentIndex
    property alias cfg_leftClickCommand: leftClickCommand.text
    property alias cfg_middleClickAction: middleClickAction.currentIndex
    property alias cfg_middleClickCommand: middleClickCommand.text
    property alias cfg_rightClickAction: rightClickAction.currentIndex
    property alias cfg_rightClickCommand: rightClickCommand.text

    property var actionList: [
        i18n("Do Nothing"),
        i18n("Peek at Desktop"),
        i18n("Show Overview"),
        i18n("Show Desktop Grid"),
        i18n("Show Present Windows (All Desktops)"),
        i18n("Show Present Windows (Current Desktop)"),
        i18n("Show Present Windows (Current Application)"),
        i18n("Run Command"),
    ]
    property var commandHintText: i18n("e.g. konsole")

    CheckBox {
        Kirigami.FormData.label: i18n("Mouse wheel:")
        id: wrapPage
        text: i18n("Navigation wraps around")
    }

    Item {
        Kirigami.FormData.isSection: true
    }

    ComboBox {
        Kirigami.FormData.label: i18n("Left click:")
        id: leftClickAction
        model: actionList
    }

    TextField {
        id: leftClickCommand
        placeholderText: commandHintText
        visible: leftClickAction.currentIndex === 7
    }

    Item {
        Kirigami.FormData.isSection: true
    }

    ComboBox {
        Kirigami.FormData.label: i18n("Middle click:")
        id: middleClickAction
        model: actionList
    }

    TextField {
        id: middleClickCommand
        placeholderText: commandHintText
        visible: middleClickAction.currentIndex === 7
    }

    Item {
        Kirigami.FormData.isSection: true
    }

    ComboBox {
        Kirigami.FormData.label: i18n("Right click:")
        id: rightClickAction
        model: actionList
    }

    TextField {
        id: rightClickCommand
        placeholderText: commandHintText
        visible: rightClickAction.currentIndex === 7
    }
}
