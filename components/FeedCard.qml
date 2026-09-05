import QtQuick
import qs.Commons
import qs.Ui
import "../Model.js" as Model

Item {
  id: root

  property int feedIndex: 0
  property string feedLabel: ""
  property string feedUrl: ""
  property string feedColor: ""
  property color contentForeground: Color.foreground
  property string contentFontFamily: Style.font.family
  property bool pickingColor: false

  signal labelModified(string newLabel)
  signal urlModified(string newUrl)
  signal colorModified(string newColor)
  signal removeRequested()

  readonly property bool isEditing: labelInput.activeFocus || urlInput.activeFocus || colorPicker.isEditing

  width: parent ? parent.width : 0
  height: feedCardCol.implicitHeight
  implicitHeight: height

  Column {
    id: feedCardCol
    width: parent.width
    spacing: Style.space(6)

    Item {
      width: parent.width
      height: Math.max(colorChip.height, labelInput.implicitHeight, deleteFeedBtn.height)

      Rectangle {
        id: colorChip
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: Style.space(28)
        height: Style.space(28)
        radius: Style.cornerRadius
        color: root.feedColor || Color.accent
        border.width: root.pickingColor ? Style.space(2) : Style.space(1)
        border.color: root.contentForeground

        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: root.pickingColor = !root.pickingColor
        }
      }

      TextField {
        id: labelInput
        anchors.left: colorChip.right
        anchors.leftMargin: Style.space(8)
        anchors.right: deleteFeedBtn.left
        anchors.rightMargin: Style.space(8)
        anchors.verticalCenter: parent.verticalCenter
        text: root.feedLabel
        placeholderText: "Label"
        foreground: root.contentForeground
        font.family: root.contentFontFamily
        font.pixelSize: Style.font.bodySmall
        onEditingFinished: root.labelModified(text.trim())
        Keys.onPressed: function(e) { if (e.key === Qt.Key_Escape) { focus = false; e.accepted = true } }
      }

      PanelActionButton {
        id: deleteFeedBtn
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        iconText: "󰅖"
        fontSize: Style.font.body
        hoverColor: Color.urgent
        tooltipText: "Remove feed"
        foreground: root.contentForeground
        fontFamily: root.contentFontFamily
        onClicked: root.removeRequested()
      }
    }

    Item {
      visible: !root.pickingColor
      width: parent.width
      height: urlInput.implicitHeight

      TextField {
        id: urlInput
        anchors.left: parent.left
        anchors.leftMargin: colorChip.width + Style.space(8)
        anchors.right: parent.right
        anchors.rightMargin: deleteFeedBtn.width + Style.space(8)
        text: root.feedUrl
        placeholderText: "Feed URL"
        foreground: root.contentForeground
        font.family: root.contentFontFamily
        font.pixelSize: Style.font.bodySmall
        onEditingFinished: root.urlModified(text.trim())
        Keys.onPressed: function(e) { if (e.key === Qt.Key_Escape) { focus = false; e.accepted = true } }
      }
    }

    ColorSpectrumPicker {
      id: colorPicker
      visible: root.pickingColor
      width: parent.width
      selectedColor: root.feedColor || "#4285f4"
      contentForeground: root.contentForeground
      contentFontFamily: root.contentFontFamily
      onColorSelected: function(hex) {
        root.colorModified(hex)
      }
    }
  }
}
