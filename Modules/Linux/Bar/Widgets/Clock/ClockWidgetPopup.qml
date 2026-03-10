import QtQuick
import QtQuick.Layouts

import qs.Common
import qs.Common.Widgets
import qs.Services

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
            return `  ${index + 1}. ${item.content}`;
        }).join('\n');

        if (unfinishedTodos.length > 5) {
            todoText += `\n  ${TranslationService.tr("... and %1 more").arg(unfinishedTodos.length - 5)}`;
        }

        return todoText;
    }

    ColumnLayout {
        id: columnLayout
        anchors.centerIn: parent
        spacing: 4

        StyledPopupHeaderRow {
            icon: "calendar_month"
            label: root.formattedDate
        }

        StyledPopupValueRow {
            icon: "timelapse"
            label: TranslationService.tr("System uptime:")
            value: root.formattedUptime
        }

        // Tasks
        Column {
            spacing: 0
            Layout.fillWidth: true

            StyledPopupValueRow {
                icon: "checklist"
                label: TranslationService.tr("To Do:")
                value: ""
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