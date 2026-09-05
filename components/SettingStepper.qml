import QtQuick
import qs.Commons
import qs.Ui

Item {
  id: root

  property string label: ""
  property string hint: ""
  property int value: 0
  property int from: 0
  property int to: 100
  property int stepSize: 1
  property color contentForeground: Color.foreground
  property string contentFontFamily: Style.font.family

  readonly property bool isEditing: valInput.activeFocus

  signal modified(int value)

  width: parent ? parent.width : 0
  height: Math.max(labelRow.implicitHeight, valInput.implicitHeight)
  implicitHeight: height

  Row {
    id: labelRow
    anchors.left: parent.left
    anchors.right: valInput.left
    anchors.rightMargin: Style.space(12)
    anchors.verticalCenter: parent.verticalCenter
    spacing: Style.space(6)

    Text {
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
    id: valInput
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    width: Style.space(40)
    horizontalPadding: Style.space(4)
    verticalPadding: Style.space(2)
    horizontalAlignment: Text.AlignHCenter
    text: String(root.value)
    foreground: root.contentForeground
    font.family: root.contentFontFamily
    font.pixelSize: Style.font.body
    inputMethodHints: Qt.ImhDigitsOnly

    onEditingFinished: {
      var parsed = parseInt(text, 10)
      if (isNaN(parsed)) parsed = root.value
      var clamped = Math.max(root.from, Math.min(root.to, parsed))
      text = String(clamped)
      if (clamped !== root.value) root.modified(clamped)
    }

    Keys.onPressed: function(event) {
      if (event.key === Qt.Key_Escape) {
        text = String(root.value)
        focus = false
        event.accepted = true
      } else if (event.key === Qt.Key_Up) {
        root.modified(Math.min(root.to, root.value + root.stepSize))
        event.accepted = true
      } else if (event.key === Qt.Key_Down) {
        root.modified(Math.max(root.from, root.value - root.stepSize))
        event.accepted = true
      }
    }
  }
}
