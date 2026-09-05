import QtQuick
import qs.Commons
import qs.Ui
import "../Model.js" as Model

Item {
  id: root

  property string currentMode: Model.SOURCE_MODE_ICS
  property color contentForeground: Color.foreground
  property string contentFontFamily: Style.font.family

  signal modeChanged(string mode)

  width: parent ? parent.width : 0
  height: tabRow.height + Style.space(6)
  implicitHeight: height

  Row {
    id: tabRow
    width: parent.width
    spacing: 0

    Item {
      width: parent.width / 2
      height: icalLabel.implicitHeight + Style.space(8)

      Text {
        id: icalLabel
        anchors.centerIn: parent
        textFormat: Text.PlainText
        text: "iCal"
        color: root.contentForeground
        opacity: root.currentMode === Model.SOURCE_MODE_ICS ? 1 : 0.55
        font.family: root.contentFontFamily
        font.pixelSize: Style.font.bodySmall
        font.bold: root.currentMode === Model.SOURCE_MODE_ICS
      }

      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.modeChanged(Model.SOURCE_MODE_ICS)
      }
    }

    Item {
      width: parent.width / 2
      height: oauthLabel.implicitHeight + Style.space(8)

      Text {
        id: oauthLabel
        anchors.centerIn: parent
        textFormat: Text.PlainText
        text: "Google Auth"
        color: root.contentForeground
        opacity: root.currentMode === Model.SOURCE_MODE_JSON ? 1 : 0.55
        font.family: root.contentFontFamily
        font.pixelSize: Style.font.bodySmall
        font.bold: root.currentMode === Model.SOURCE_MODE_JSON
      }

      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.modeChanged(Model.SOURCE_MODE_JSON)
      }
    }
  }

  Rectangle {
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    height: 1
    color: Qt.rgba(root.contentForeground.r, root.contentForeground.g, root.contentForeground.b, Tokens.separatorGroup)
  }

  Rectangle {
    id: activeUnderline
    width: tabRow.width / 2
    height: Style.space(2)
    anchors.bottom: parent.bottom
    x: root.currentMode === Model.SOURCE_MODE_JSON ? tabRow.width / 2 : 0
    color: Color.accent

    Behavior on x { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
  }
}
