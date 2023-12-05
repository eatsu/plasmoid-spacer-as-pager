/*
    SPDX-FileCopyrightText: 2023 eatsu <mkrmdk@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support 2.0 as P5Support
import org.kde.plasma.private.pager 2.0
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

    function runClickAction(action, command) {
        if (action === 1) {
            executable.exec("/usr/lib/qt6/bin/qdbus org.kde.kglobalaccel /component/kwin invokeShortcut 'Show Desktop'");
        } else if (action === 2) {
            executable.exec("/usr/lib/qt6/bin/qdbus org.kde.kglobalaccel /component/kwin invokeShortcut Overview");
        } else if (action === 3) {
            executable.exec("/usr/lib/qt6/bin/qdbus org.kde.kglobalaccel /component/kwin invokeShortcut ShowDesktopGrid");
        } else if (action === 4) {
            executable.exec("/usr/lib/qt6/bin/qdbus org.kde.kglobalaccel /component/kwin invokeShortcut ExposeAll");
        } else if (action === 5) {
            executable.exec("/usr/lib/qt6/bin/qdbus org.kde.kglobalaccel /component/kwin invokeShortcut Expose");
        } else if (action === 6) {
            executable.exec("/usr/lib/qt6/bin/qdbus org.kde.kglobalaccel /component/kwin invokeShortcut ExposeClass");
        } else if (action === 7) {
            executable.exec(command);
        }
    }

    PagerModel {
        id: pagerModel
        enabled: root.visible
        screenGeometry: Plasmoid.containment.screenGeometry
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
                if (increment < 0) {
                    const nextPage = Plasmoid.configuration.wrapPage?
                        (pagerModel.currentPage + 1) % pagerModel.count :
                        Math.min(pagerModel.currentPage + 1, pagerModel.count - 1);
                    pagerModel.changePage(nextPage);
                } else {
                    const previousPage = Plasmoid.configuration.wrapPage ?
                        (pagerModel.count + pagerModel.currentPage - 1) % pagerModel.count :
                        Math.max(pagerModel.currentPage - 1, 0);
                    pagerModel.changePage(previousPage);
                }

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
