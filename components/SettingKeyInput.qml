import QtQuick
import qs.Commons
import qs.Ui
import "../Model.js" as Model

Item {
  id: root

  property string label: ""
  property string key: ""
  property string defaultKey: ""
  property color contentForeground: Color.foreground
  property string contentFontFamily: Style.font.family

  signal modified(string key)

  readonly property bool isEditing: inputField.activeFocus
  property alias field: inputField

  width: parent ? parent.width : 0
  height: Math.max(labelText.implicitHeight, inputField.implicitHeight)
  implicitHeight: height

  Text {
    id: labelText
    anchors.left: parent.left
    anchors.right: inputField.left
    anchors.rightMargin: Style.space(12)
    anchors.verticalCenter: parent.verticalCenter
    textFormat: Text.PlainText
    text: root.label
    color: root.contentForeground
    font.family: root.contentFontFamily
    font.pixelSize: Style.font.bodySmall
    font.bold: true
    elide: Text.ElideRight
  }

  TextField {
    id: inputField
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    width: Style.space(40)
    horizontalPadding: Style.space(4)
    verticalPadding: Style.space(2)
    maximumLength: 1
    text: root.key || root.defaultKey
    placeholderText: root.defaultKey
    foreground: root.contentForeground
    font.family: root.contentFontFamily
    horizontalAlignment: Text.AlignHCenter
    onEditingFinished: root.modified(Model.normalizeKey(text, root.defaultKey))
    Keys.onPressed: function(event) {
      if (event.key === Qt.Key_Escape) {
        focus = false
        event.accepted = true
      }
    }
  }
}
