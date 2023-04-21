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

    CheckBox {
        Kirigami.FormData.label: i18n("Mouse wheel:")
        id: wrapPage
        text: i18n("Navigation wraps around")
    }
}
