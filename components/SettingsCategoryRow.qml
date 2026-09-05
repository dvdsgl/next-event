import QtQuick
import qs.Commons
import qs.Ui

BorderSurface {
  id: root

  property string title: ""
  property string summary: ""
  property bool hasCursor: false
  property color contentForeground: Color.foreground
  property color accent: Color.accent
  property string contentFontFamily: Style.font.family

  signal clicked()
  signal hovered(bool isHovered)

  implicitHeight: Math.max(Style.space(54), content.implicitHeight + Style.space(16))
  implicitWidth: parent ? parent.width : Style.space(240)
  width: parent ? parent.width : implicitWidth
  radius: Style.cornerRadius

  readonly property bool _hot: hasCursor || mouse.containsMouse
  readonly property var _borderSpec: Border.controlSpec(activeFocus ? "focus" : (_hot ? "hover-cursor" : "normal"), contentForeground, accent)

  color: Style.controlFill(activeFocus, _hot, contentForeground, accent)
  borderSpec: _borderSpec

  Behavior on color { ColorAnimation { duration: 100 } }

  MouseArea {
    id: mouse
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: root.clicked()
  }

  HoverHandler {
    onHoveredChanged: root.hovered(hovered)
  }

  Row {
    id: content
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    anchors.leftMargin: root.borderLeft + Style.space(10)
    anchors.rightMargin: root.borderRight + Style.space(10)
    spacing: Style.space(10)

    Column {
      width: parent.width - chevron.implicitWidth - parent.spacing
      spacing: Style.space(2)
      anchors.verticalCenter: parent.verticalCenter

      Text {
        width: parent.width
        textFormat: Text.PlainText
        text: root.title
        color: root.contentForeground
        font.family: root.contentFontFamily
        font.pixelSize: Style.font.subtitle
        font.bold: true
        elide: Text.ElideRight
      }

      Text {
        width: parent.width
        visible: root.summary !== ""
        textFormat: Text.PlainText
        text: root.summary
        color: Qt.darker(root.contentForeground, Tokens.dimMeta)
        font.family: root.contentFontFamily
        font.pixelSize: Style.font.caption
        elide: Text.ElideRight
      }
    }

    Text {
      id: chevron
      textFormat: Text.PlainText
      text: "›"
      color: root.contentForeground
      opacity: 0.36
      font.family: root.contentFontFamily
      font.pixelSize: Style.font.heading
      anchors.verticalCenter: parent.verticalCenter
    }
  }
}
