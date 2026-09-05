import QtQuick
import qs.Commons
import qs.Ui

Item {
  id: root

  property string text: ""
  property color contentForeground: Color.foreground
  property string contentFontFamily: Style.font.family

  visible: root.text !== ""
  implicitWidth: hintLabel.implicitWidth + Style.space(4)
  implicitHeight: Math.max(hintLabel.implicitHeight, Style.space(16))
  width: implicitWidth
  height: implicitHeight

  Text {
    id: hintLabel
    anchors.centerIn: parent
    textFormat: Text.PlainText
    text: "?"
    color: Qt.darker(root.contentForeground, Tokens.dimMuted)
    font.family: root.contentFontFamily
    font.pixelSize: Style.font.caption
    font.bold: true
  }

  MouseArea {
    id: mouse
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.WhatsThisCursor
    onClicked: function(event) { event.accepted = true }
  }

  PanelToolTip {
    visible: mouse.containsMouse && root.text !== ""
    text: root.text
    fontFamily: root.contentFontFamily
  }
}
