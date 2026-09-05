import QtQuick
import qs.Commons
import qs.Ui

Item {
  id: root

  property string label: ""
  property string hint: ""
  property bool checked: false
  property bool hasCursor: false
  property color contentForeground: Color.foreground
  property color accent: Color.accent
  property string contentFontFamily: Style.font.family

  signal clicked()
  signal hovered(bool isHovered)

  width: parent ? parent.width : 0
  height: Math.max(labelRow.implicitHeight, track.implicitHeight)
  implicitHeight: height

  Row {
    id: labelRow
    anchors.left: parent.left
    anchors.right: track.left
    anchors.rightMargin: Style.space(12)
    anchors.verticalCenter: parent.verticalCenter
    spacing: Style.space(6)

    Text {
      id: titleText
      width: Math.min(implicitWidth, parent.width - (hintSlot.visible ? hintSlot.width + parent.spacing : 0))
      textFormat: Text.PlainText
      text: root.label
      color: root.contentForeground
      font.family: root.contentFontFamily
      font.pixelSize: Style.font.bodySmall
      font.bold: true
      elide: Text.ElideRight
      anchors.verticalCenter: parent.verticalCenter
    }

    Item {
      id: hintSlot
      visible: root.hint !== ""
      width: hintIcon.implicitWidth
      height: hintIcon.implicitHeight
      anchors.verticalCenter: parent.verticalCenter
    }
  }

  ToggleSwitch {
    id: track
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    checked: root.checked
    foreground: root.contentForeground
    accent: root.accent
    interactive: false
    cursorRing: false
    hasCursor: root.hasCursor || mouse.containsMouse
  }

  MouseArea {
    id: mouse
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: root.clicked()
    onContainsMouseChanged: root.hovered(containsMouse)
  }

  SettingHint {
    id: hintIcon
    z: 1
    x: labelRow.x + hintSlot.x
    y: labelRow.y + hintSlot.y
    text: root.hint
    contentForeground: root.contentForeground
    contentFontFamily: root.contentFontFamily
  }
}
