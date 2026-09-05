import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Ui
import "../Model.js" as Model

Item {
  id: root

  property var next: null
  property date now: new Date()
  property bool inMeeting: false
  property bool useCalendarColors: true
  property bool use12Hour: false
  property color contentForeground: Color.foreground
  property string contentFontFamily: Style.font.family
  property bool hasCursor: false
  property bool embedded: false

  signal joinRequested()
  signal hovered()

  width: parent ? parent.width : 0
  height: visible ? heroBlock.implicitHeight : 0
  implicitHeight: height

  CursorSurface {
    id: heroBlock
    width: parent.width
    hasCursor: root.hasCursor
    foreground: root.contentForeground
    accent: Color.accent
    implicitHeight: heroCol.implicitHeight + Style.space(8)

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onEntered: root.hovered()
      onClicked: root.joinRequested()
    }

    Rectangle {
      id: heroColorStripe
      visible: root.useCalendarColors && !!(root.next && root.next.calendarColor)
      anchors.left: parent.left
      anchors.top: parent.top
      anchors.bottom: parent.bottom
      anchors.margins: Style.space(2)
      width: Style.space(3.5)
      radius: Style.cornerRadius * 0.5
      color: (root.next && root.next.calendarColor) ? root.next.calendarColor : Color.accent
    }

    Column {
      id: heroCol
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      anchors.leftMargin: Style.space(12)
      anchors.rightMargin: Style.space(12)
      spacing: Style.space(5)

      RowLayout {
        width: parent.width

        Text {
          textFormat: Text.PlainText
          text: root.inMeeting ? Model.SECTION_HAPPENING_NOW : Model.SECTION_NEXT
          color: root.inMeeting ? Color.accent : Qt.darker(root.contentForeground, Tokens.dimMuted)
          font.family: root.contentFontFamily
          font.pixelSize: Style.font.caption
          font.letterSpacing: Tokens.sectionLetterSpacing
          font.bold: true
        }

        Item { Layout.fillWidth: true }

        Text {
          visible: !!root.next
          textFormat: Text.PlainText
          text: Model.heroHeaderMeta(root.next)
          color: root.inMeeting ? Color.accent : Qt.darker(root.contentForeground, Tokens.dimCaption)
          font.family: root.contentFontFamily
          font.pixelSize: Style.font.caption
          font.bold: true
        }
      }

      Text {
        width: parent.width
        textFormat: Text.PlainText
        text: root.next ? (root.next.title || "(Untitled)") : ""
        color: root.contentForeground
        font.family: root.contentFontFamily
        font.pixelSize: Style.font.bodyLarge
        font.bold: true
        wrapMode: Text.WordWrap
        maximumLineCount: 2
        elide: Text.ElideRight
      }

      Text {
        width: parent.width
        textFormat: Text.PlainText
        text: Model.heroTimeStatus(root.next, root.now, root.use12Hour)
        color: Qt.darker(root.contentForeground, Tokens.dimMeta)
        font.family: root.contentFontFamily
        font.pixelSize: Style.font.bodySmall
        wrapMode: Text.WordWrap
      }
    }
  }
}
