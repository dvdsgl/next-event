import QtQuick
import qs.Commons
import qs.Ui
import "../Model.js" as Model

Item {
  id: root

  property color contentForeground: Color.foreground
  property string contentFontFamily: Style.font.family
  property bool fetching: false
  property bool cursorOnRefresh: false
  property string activeTab: "next"

  signal refreshRequested()
  signal refreshHovered(bool isHovered)
  signal tabChanged(string tab)

  property alias refreshBtn: refreshButton

  width: parent ? parent.width : 0
  height: Math.max(tabRow.height, refreshButton.height)
  implicitHeight: height

  Row {
    id: tabRow
    anchors.left: parent.left
    anchors.verticalCenter: parent.verticalCenter
    spacing: Style.space(4)

    Repeater {
      model: [
        { id: "next", label: "Next" },
        { id: "calendars", label: "Calendars" },
        { id: "options", label: "Options" }
      ]

      Item {
        required property var modelData

        width: tabLabel.implicitWidth + Style.space(12)
        height: tabLabel.implicitHeight + Style.space(10)

        Text {
          id: tabLabel
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.verticalCenter: parent.verticalCenter
          textFormat: Text.PlainText
          text: modelData.label
          color: root.contentForeground
          opacity: root.activeTab === modelData.id ? 1 : 0.55
          font.family: root.contentFontFamily
          font.pixelSize: Style.font.bodySmall
          font.bold: root.activeTab === modelData.id
        }

        Rectangle {
          visible: root.activeTab === modelData.id
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.bottom: parent.bottom
          height: Style.space(2)
          color: Color.accent
        }

        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: root.tabChanged(modelData.id)
        }
      }
    }
  }

  Item {
    id: refreshButton
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    width: Style.space(22)
    height: Style.space(22)

    Text {
      id: refreshIcon
      anchors.centerIn: parent
      width: font.pixelSize
      height: font.pixelSize
      textFormat: Text.PlainText
      text: Model.ICON_REFRESH
      color: refreshMouse.containsMouse || root.cursorOnRefresh
        ? root.contentForeground
        : Qt.darker(root.contentForeground, Tokens.dimLabel)
      font.family: root.contentFontFamily
      font.pixelSize: Style.font.icon
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
      transformOrigin: Item.Center

      RotationAnimation on rotation {
        from: 0
        to: 360
        duration: 900
        loops: Animation.Infinite
        running: root.fetching
      }
    }

    MouseArea {
      id: refreshMouse
      anchors.fill: parent
      hoverEnabled: true
      enabled: !root.fetching
      cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
      onContainsMouseChanged: root.refreshHovered(containsMouse)
      onClicked: root.refreshRequested()
    }

    PanelToolTip {
      visible: refreshMouse.containsMouse
      text: root.fetching ? Model.TOOLTIP_UPDATING : Model.TOOLTIP_REFRESH
      fontFamily: root.contentFontFamily
    }
  }

  onFetchingChanged: if (!root.fetching) refreshIcon.rotation = 0
}
