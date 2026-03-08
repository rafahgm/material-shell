import QtQuick
import QtQuick.Layouts

import qs.Modules.Common
import qs.Modules.Common.Widgets
import qs.Services
import qs.Modules.Linux.Bar.Widgets

StyledPopup {
    id: root
    property string formattedDate: Qt.locale().toString(DateTimeService.clock.date, "dddd, MMMM dd, yyyy")
    property string formattedTime: DateTimeService.time
    property string formattedUptime: DateTimeService.uptime
    property string todosSection: getUpcomingTodos()

    function getUpcomingTodos() {
        const unfinishedTodos = TodoService.list.filter(function (item) {
            return !item.done;
        });
        if (unfinishedTodos.length === 0) {
            return TranslationService.tr("No pending tasks");
        }

        // Limit to first 5 todos to keep popup manageable
        const limitedTodos = unfinishedTodos.slice(0, 5);
        let todoText = limitedTodos.map(function (item, index) {
            return `${index + 1}. ${item.content}`;
        }).join('\n');

        if (unfinishedTodos.length > 5) {
            todoText += `\n${TranslationService.tr("... and %1 more").arg(unfinishedTodos.length - 5)}`;
        }

        return todoText;
    }

    ColumnLayout {
        id: columnLayout
        anchors.centerIn: parent
        spacing: 4

        // Date + Time row
        Row {
            spacing: 5

            MaterialSymbol {
                anchors.verticalCenter: parent.verticalCenter
                fill: 0
                font.weight: Font.Medium
                text: "calendar_month"
                iconSize: Appearance.font.pixelSize.large
                color: Appearance.colors.colOnSurfaceVariant
            }
            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignLeft
                color: Appearance.colors.colOnSurfaceVariant
                text: `${root.formattedDate}`
                font.weight: Font.Medium
            }
        }

        // Uptime row
        RowLayout {
            spacing: 5
            Layout.fillWidth: true
            MaterialSymbol {
                text: "timelapse"
                color: Appearance.colors.colOnSurfaceVariant
                font.pixelSize: Appearance.font.pixelSize.large
            }
            StyledText {
                text: TranslationService.tr("System uptime:")
                color: Appearance.colors.colOnSurfaceVariant
            }
            StyledText {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
                color: Appearance.colors.colOnSurfaceVariant
                text: root.formattedUptime
            }
        }

        // Tasks
        Column {
            spacing: 0
            Layout.fillWidth: true

            Row {
                spacing: 4
                MaterialSymbol {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "checklist"
                    color: Appearance.colors.colOnSurfaceVariant
                    font.pixelSize: Appearance.font.pixelSize.large
                }
                StyledText {
                    anchors.verticalCenter: parent.verticalCenter
                    text: TranslationService.tr("To Do:")
                    color: Appearance.colors.colOnSurfaceVariant
                }
            }

            StyledText {
                horizontalAlignment: Text.AlignLeft
                wrapMode: Text.Wrap
                color: Appearance.colors.colOnSurfaceVariant
                text: root.todosSection
            }
        }
    }
}