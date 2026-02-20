/*
    SPDX-FileCopyrightText: 2023 eatsu <mkrmdk@gmail.com>
    SPDX-FileCopyrightText: 2025 Emma MB <emma@meredithblack.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support 2.0 as P5Support
import org.kde.kirigami 2.20 as Kirigami

import org.kde.kcmutils as KCM
import org.kde.config as KConfig

PlasmoidItem {
    id: root

    property bool horizontal: Plasmoid.formFactor !== PlasmaCore.Types.Vertical

    Layout.fillWidth: Plasmoid.configuration.expanding
    Layout.fillHeight: Plasmoid.configuration.expanding

    Layout.minimumWidth: Plasmoid.containment.corona?.editMode ? Kirigami.Units.gridUnit * 2 : 1
    Layout.minimumHeight: Plasmoid.containment.corona?.editMode ? Kirigami.Units.gridUnit * 2 : 1
    Layout.preferredWidth: horizontal
        ? (Plasmoid.configuration.expanding ? optimalSize : Plasmoid.configuration.length)
        : 0
    Layout.preferredHeight: horizontal
        ? 0
        : (Plasmoid.configuration.expanding ? optimalSize : Plasmoid.configuration.length)

    preferredRepresentation: fullRepresentation

    // Search the actual gridLayout of the panel
    property GridLayout panelLayout: {
        let candidate = root.parent;
        while (candidate) {
            if (candidate instanceof GridLayout) {
                return candidate;
            }
            candidate = candidate.parent;
        }
        return null;
    }

    property real optimalSize: {
        if (!panelLayout || !Plasmoid.configuration.expanding) return Plasmoid.configuration.length;
        let expandingSpacers = 0;
        let thisSpacerIndex = null;
        let sizeHints = [0];
        // Children order is guaranteed to be the same as the visual order of items in the layout
        for (const i in panelLayout.children) {
            const child = panelLayout.children[i];
            if (!child.visible) continue;

            if (child.applet && child.applet.plasmoid.pluginName === Plasmoid.pluginName && child.applet.plasmoid.configuration.expanding) {
                if (child.applet.plasmoid === Plasmoid) {
                    thisSpacerIndex = expandingSpacers
                }
                sizeHints.push(0)
                expandingSpacers += 1
            } else if (root.horizontal) {
                sizeHints[sizeHints.length - 1] += Math.min(child.Layout.maximumWidth, Math.max(child.Layout.minimumWidth, child.Layout.preferredWidth)) + panelLayout.rowSpacing;
            } else {
                sizeHints[sizeHints.length - 1] += Math.min(child.Layout.maximumHeight, Math.max(child.Layout.minimumHeight, child.Layout.preferredHeight)) + panelLayout.columnSpacing;
            }
        }
        sizeHints[0] *= 2; sizeHints[sizeHints.length - 1] *= 2
        let containment = panelLayout
        let opt = (root.horizontal ? containment.width : containment.height) / expandingSpacers - sizeHints[thisSpacerIndex] / 2 - sizeHints[thisSpacerIndex + 1] / 2
        return Math.max(opt, 0)
    }

    P5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: sourceName => disconnectSource(sourceName)

        function exec(cmd) {
            connectSource(cmd);
        }
    }

    P5Support.DataSource {
        id: desktopQuery
        engine: "executable"
        connectedSources: []
        property bool pendingForward: true

        onNewData: (sourceName, data) => {
            disconnectSource(sourceName);
            const current = parseInt(data["stdout"].trim());
            if (!isNaN(current)) {
                const next = pendingForward ? current + 1 : current - 1;
                executable.exec(`dbus-send --session --type=method_call --dest=org.kde.KWin /KWin org.kde.KWin.setCurrentDesktop int32:${next}`);
            }
        }
    }

    function runClickAction(action, command) {
        const shortcuts = [
            "Show Desktop",
            "Overview",
            "Grid View",
            "ExposeAll",
            "Expose",
            "ExposeClass",
        ];
        const shortcut = shortcuts[action - 1];

        if (shortcut) {
            executable.exec(`dbus-send --dest=org.kde.kglobalaccel --type=method_call /component/kwin org.kde.kglobalaccel.Component.invokeShortcut string:"${shortcut}"`);
        } else if (action === 7) {
            executable.exec(command);
        }
    }

    function switchDesktop(forward) {
        if (Plasmoid.configuration.wrapPage) {
            const method = forward ? "nextDesktop" : "previousDesktop";
            executable.exec(`dbus-send --session --type=method_call --dest=org.kde.KWin /KWin org.kde.KWin.${method}`);
        } else {
            desktopQuery.pendingForward = forward;
            desktopQuery.connectSource("dbus-send --session --print-reply --dest=org.kde.KWin /KWin org.kde.KWin.currentDesktop | awk '/int32/{print $2}'");
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent

        property int wheelDelta: 0

        acceptedButtons: {
            if (Plasmoid.configuration.rightClickAction > 0) {
                Qt.LeftButton | Qt.MiddleButton | Qt.RightButton;
            } else {
                // Don't disable the context menu
                Qt.LeftButton | Qt.MiddleButton;
            }
        }

        onClicked: mouse => {
            switch (mouse.button) {
            case Qt.LeftButton:
                runClickAction(
                    Plasmoid.configuration.leftClickAction,
                    Plasmoid.configuration.leftClickCommand
                );
                break;
            case Qt.MiddleButton:
                runClickAction(
                    Plasmoid.configuration.middleClickAction,
                    Plasmoid.configuration.middleClickCommand
                );
                break;
            case Qt.RightButton:
                runClickAction(
                    Plasmoid.configuration.rightClickAction,
                    Plasmoid.configuration.rightClickCommand
                );
                break;
            }
        }

        onWheel: wheel => {
            // Magic number 120 for common "one click", see:
            // https://doc.qt.io/qt-5/qml-qtquick-wheelevent.html#angleDelta-prop
            wheelDelta += wheel.angleDelta.y || wheel.angleDelta.x;

            let increment = 0;

            while (wheelDelta >= 120) {
                wheelDelta -= 120;
                increment++;
            }

            while (wheelDelta <= -120) {
                wheelDelta += 120;
                increment--;
            }

            while (increment !== 0) {
                switchDesktop(increment < 0);
                increment += (increment < 0) ? 1 : -1;
                wheelDelta = 0;
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Kirigami.Theme.highlightColor
        opacity: Plasmoid.containment.corona?.editMode ? 1 : 0
        visible: Plasmoid.containment.corona?.editMode || animator.running

        Behavior on opacity {
            NumberAnimation {
                id: animator
                duration: Kirigami.Units.longDuration
                // easing.type is updated after animation starts
                easing.type: Plasmoid.containment.corona?.editMode ? Easing.InCubic : Easing.OutCubic
            }
        }
    }

    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: i18n("Configure Virtual Desktops…")
            icon.name: "configure"
            visible: KConfig.KAuthorized.authorize("kcm_kwin_virtualdesktops")
            onTriggered: KCM.KCMLauncher.openSystemSettings("kcm_kwin_virtualdesktops")
        }
    ]
}
