import QtQuick
import qs.Commons
import qs.Ui

Column {
  id: root

  property string label: ""
  property string hint: ""
  property string text: ""
  property string placeholderText: ""
  property color contentForeground: Color.foreground
  property string contentFontFamily: Style.font.family

  signal modified(string value)

  readonly property bool isEditing: inputField.activeFocus
  property alias field: inputField

  width: parent ? parent.width : 0
  spacing: Style.space(3)

  Row {
    width: parent.width
    spacing: Style.space(6)
    visible: root.label !== "" || root.hint !== ""

    Text {
      visible: root.label !== ""
      width: Math.min(implicitWidth, parent.width - (hintIcon.visible ? hintIcon.width + parent.spacing : 0))
      textFormat: Text.PlainText
      text: root.label
      color: root.contentForeground
      font.family: root.contentFontFamily
      font.pixelSize: Style.font.bodySmall
      font.bold: true
      elide: Text.ElideRight
      anchors.verticalCenter: parent.verticalCenter
    }

    SettingHint {
      id: hintIcon
      text: root.hint
      contentForeground: root.contentForeground
      contentFontFamily: root.contentFontFamily
      anchors.verticalCenter: parent.verticalCenter
    }
  }

  TextField {
    id: inputField
    width: parent.width
    text: root.text
    placeholderText: root.placeholderText
    foreground: root.contentForeground
    font.family: root.contentFontFamily
    onEditingFinished: root.modified(text.trim())
    Keys.onPressed: function(event) {
      if (event.key === Qt.Key_Escape) {
        focus = false
        event.accepted = true
      }
    }
  }
}
