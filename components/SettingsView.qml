import QtQuick
import qs.Commons
import qs.Ui
import "../Model.js" as Model

Item {
  id: root

  property var hostWidget: null
  property color contentForeground: Color.foreground
  property string contentFontFamily: Style.font.family
  property string activeTab: "calendars"

  signal settingChanged(string key, var value)
  signal closeRequested()

  property var feedsList: []
  readonly property string currentSourceMode: root.hostWidget ? root.hostWidget.sourceMode : Model.SOURCE_MODE_ICS

  function loadFeedsFromHost() {
    if (!root.hostWidget) return
    var raw = root.hostWidget.setting("icsUrl", "")
    var parsed = Model.splitIcsFeeds(raw)
    var list = []
    for (var i = 0; i < parsed.length; i++) {
      list.push({
        label: parsed[i].label ? String(parsed[i].label) : "",
        url: parsed[i].url ? String(parsed[i].url) : "",
        color: parsed[i].color ? String(parsed[i].color) : Model.pickCalendarColor(parsed[i].label || parsed[i].url, i)
      })
    }
    root.feedsList = list
  }

  function serializeAndPersistFeeds() {
    var parts = []
    for (var i = 0; i < root.feedsList.length; i++) {
      var item = root.feedsList[i]
      var u = String((item && item.url) || "").trim()
      if (!u) continue
      var l = String((item && item.label) || "").trim()
      var c = String((item && item.color) || "").trim()
      if (l && c) parts.push(l + "|" + c + "|" + u)
      else if (l) parts.push(l + "|" + u)
      else if (c) parts.push(c + "|" + u)
      else parts.push(u)
    }
    root.settingChanged("icsUrl", parts.join(","))
  }

  function addFeed() {
    var copy = root.feedsList.slice()
    copy.push({ label: "", url: "", color: Model.pickCalendarColor("", copy.length) })
    root.feedsList = copy
  }

  function removeFeed(idx) {
    var copy = root.feedsList.slice()
    copy.splice(idx, 1)
    root.feedsList = copy
    serializeAndPersistFeeds()
  }

  function updateFeedLabel(idx, newLabel) {
    if (idx < 0 || idx >= root.feedsList.length) return
    var copy = root.feedsList.slice()
    copy[idx] = { label: newLabel, url: copy[idx].url, color: copy[idx].color }
    root.feedsList = copy
    serializeAndPersistFeeds()
  }

  function updateFeedUrl(idx, newUrl) {
    if (idx < 0 || idx >= root.feedsList.length) return
    var copy = root.feedsList.slice()
    copy[idx] = { label: copy[idx].label, url: newUrl, color: copy[idx].color }
    root.feedsList = copy
    serializeAndPersistFeeds()
  }

  function updateFeedColor(idx, newColor) {
    if (idx < 0 || idx >= root.feedsList.length) return
    var copy = root.feedsList.slice()
    copy[idx] = { label: copy[idx].label, url: copy[idx].url, color: newColor }
    root.feedsList = copy
    serializeAndPersistFeeds()
  }

  function feedsHaveFocus() {
    for (var i = 0; i < feedsRepeater.count; i++) {
      var item = feedsRepeater.itemAt(i)
      if (item && item.isEditing) return true
    }
    return false
  }

  onHostWidgetChanged: loadFeedsFromHost()
  onVisibleChanged: if (visible) loadFeedsFromHost()
  Component.onCompleted: loadFeedsFromHost()

  readonly property bool isEditing: daysAheadStepper.isEditing
    || refreshMinStepper.isEditing
    || maxTitleStepper.isEditing
    || maxFeedSizeStepper.isEditing
    || eventsJsonField.isEditing
    || calendarUrlField.isEditing
    || browserCmdField.isEditing
    || keyRefreshInput.isEditing
    || keySettingsInput.isEditing
    || keyJoinInput.isEditing
    || keyCalendarInput.isEditing
    || feedsHaveFocus()
    || sourceDropdown.popupOpen

  width: parent ? parent.width : 0
  height: visible ? settingsColumn.implicitHeight : 0
  implicitHeight: height

  Column {
    id: settingsColumn
    width: parent.width
    spacing: Style.space(10)

    Column {
      visible: root.activeTab === "calendars"
      width: parent.width
      spacing: Style.space(10)

      Dropdown {
        id: sourceDropdown
        width: parent.width
        label: "Source"
        value: root.currentSourceMode
        options: [
          { value: Model.SOURCE_MODE_ICS, label: "iCal" },
          { value: Model.SOURCE_MODE_JSON, label: "Google Auth" }
        ]
        foreground: root.contentForeground
        fontFamily: root.contentFontFamily
        onChanged: function(v) { root.settingChanged("sourceMode", v) }
      }

      Column {
        visible: root.currentSourceMode === Model.SOURCE_MODE_ICS
        width: parent.width
        spacing: Style.space(10)

      Text {
        visible: root.feedsList.length === 0
        width: parent.width
        textFormat: Text.PlainText
        text: "Add a private calendar URL (Google, Outlook, iCloud, Nextcloud)."
        color: Qt.darker(root.contentForeground, Tokens.dimMeta)
        font.family: root.contentFontFamily
        font.pixelSize: Style.font.caption
        wrapMode: Text.WordWrap
      }

      Column {
        width: parent.width
        spacing: Style.space(16)

        Repeater {
          id: feedsRepeater
          model: root.feedsList

          FeedCard {
            required property var modelData
            required property int index

            width: settingsColumn.width
            feedIndex: index
            feedLabel: modelData.label || ""
            feedUrl: modelData.url || ""
            feedColor: modelData.color || ""
            contentForeground: root.contentForeground
            contentFontFamily: root.contentFontFamily

            onLabelModified: function(val) { root.updateFeedLabel(index, val) }
            onUrlModified: function(val) { root.updateFeedUrl(index, val) }
            onColorModified: function(val) { root.updateFeedColor(index, val) }
            onRemoveRequested: root.removeFeed(index)
          }
        }

        Item {
          width: parent.width
          height: addFeedBtn.height

          PanelActionButton {
            id: addFeedBtn
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            iconText: "󰐕"
            fontSize: Style.font.body
            tooltipText: "Add feed"
            foreground: root.contentForeground
            fontFamily: root.contentFontFamily
            onClicked: root.addFeed()
          }
        }
      }

      SettingStepper {
        id: maxFeedSizeStepper
        width: parent.width
        label: "Max feed size"
        from: 1
        to: 100
        stepSize: 1
        value: root.hostWidget ? root.hostWidget.maxFeedSizeMiB : Model.DEFAULT_MAX_FEED_SIZE_MIB
        contentForeground: root.contentForeground
        contentFontFamily: root.contentFontFamily
        onModified: function(v) { root.settingChanged("maxFeedSizeMiB", v) }
      }
      }

      Column {
        visible: root.currentSourceMode === Model.SOURCE_MODE_JSON
        width: parent.width
        spacing: Style.space(10)

      Text {
        width: parent.width
        textFormat: Text.PlainText
        text: "For Google Workspace when private iCal URLs are blocked."
        color: Qt.darker(root.contentForeground, Tokens.dimMeta)
        font.family: root.contentFontFamily
        font.pixelSize: Style.font.caption
        wrapMode: Text.WordWrap
      }

      SetupCard {
        title: ""
        description: "Run once to sign in and sync:"
        command: Model.LABEL_SETUP_OPTION1_CMD
        contentForeground: root.contentForeground
        contentFontFamily: root.contentFontFamily
      }

      SettingField {
        id: eventsJsonField
        width: parent.width
        label: "State file"
        text: root.hostWidget ? String(root.hostWidget.setting("eventsJsonPath", root.hostWidget.eventsJsonPath || "")) : ""
        placeholderText: "~/.local/state/omarchy/calendar-events.json"
        contentForeground: root.contentForeground
        contentFontFamily: root.contentFontFamily
        onModified: function(val) { root.settingChanged("eventsJsonPath", val) }
      }
      }
    }

    Column {
      visible: root.activeTab === "options"
      width: parent.width
      spacing: Style.space(10)

      SettingStepper {
        id: daysAheadStepper
        label: "Days ahead"
        from: 1
        to: 30
        stepSize: 1
        value: root.hostWidget ? root.hostWidget.showDaysAhead : Model.DEFAULT_LOOKAHEAD_DAYS
        contentForeground: root.contentForeground
        contentFontFamily: root.contentFontFamily
        onModified: function(v) { root.settingChanged("showDaysAhead", v) }
      }

      SettingStepper {
        id: refreshMinStepper
        label: "Refresh (minutes)"
        from: 1
        to: 120
        stepSize: 1
        value: root.hostWidget ? root.hostWidget.refreshMinutes : Model.DEFAULT_REFRESH_MINUTES
        contentForeground: root.contentForeground
        contentFontFamily: root.contentFontFamily
        onModified: function(v) { root.settingChanged("refreshMinutes", v) }
      }

      SettingStepper {
        id: maxTitleStepper
        label: "Bar title length"
        from: 8
        to: 100
        stepSize: 1
        value: root.hostWidget ? root.hostWidget.maxTitleLength : Model.DEFAULT_MAX_TITLE_LENGTH
        contentForeground: root.contentForeground
        contentFontFamily: root.contentFontFamily
        onModified: function(v) { root.settingChanged("maxTitleLength", v) }
      }

      SettingToggle {
        width: parent.width
        label: "Only video meetings on the bar"
        checked: root.hostWidget ? root.hostWidget.showOnlyWithVideoLink : false
        contentForeground: root.contentForeground
        contentFontFamily: root.contentFontFamily
        onClicked: root.settingChanged("showOnlyWithVideoLink", !checked)
      }

      SettingToggle {
        width: parent.width
        label: "Show calendar names"
        checked: root.hostWidget ? root.hostWidget.showCalendarLabel : true
        contentForeground: root.contentForeground
        contentFontFamily: root.contentFontFamily
        onClicked: root.settingChanged("showCalendarLabel", !checked)
      }

      SettingToggle {
        width: parent.width
        label: "Show calendar icon"
        checked: root.hostWidget ? root.hostWidget.showCalendarIcon : true
        contentForeground: root.contentForeground
        contentFontFamily: root.contentFontFamily
        onClicked: root.settingChanged("showCalendarIcon", !checked)
      }

      SettingToggle {
        width: parent.width
        label: "Color events by calendar"
        checked: root.hostWidget ? root.hostWidget.useCalendarColors : true
        contentForeground: root.contentForeground
        contentFontFamily: root.contentFontFamily
        onClicked: root.settingChanged("useCalendarColors", !checked)
      }

      SettingToggle {
        width: parent.width
        label: "Color bar text by calendar"
        checked: root.hostWidget ? root.hostWidget.colorOnBar : false
        contentForeground: root.contentForeground
        contentFontFamily: root.contentFontFamily
        onClicked: root.settingChanged("colorOnBar", !checked)
      }

      SettingToggle {
        width: parent.width
        label: "Urgent color while in a meeting"
        checked: root.hostWidget ? root.hostWidget.urgentDuringMeeting : false
        contentForeground: root.contentForeground
        contentFontFamily: root.contentFontFamily
        onClicked: root.settingChanged("urgentDuringMeeting", !checked)
      }

      SettingToggle {
        width: parent.width
        label: "12-hour time"
        checked: root.hostWidget ? root.hostWidget.use12Hour : false
        contentForeground: root.contentForeground
        contentFontFamily: root.contentFontFamily
        onClicked: root.settingChanged("timeFormat", checked ? Model.TIME_FORMAT_24 : Model.TIME_FORMAT_12)
      }

      SettingField {
        id: calendarUrlField
        width: parent.width
        label: "Calendar URL"
        text: root.hostWidget ? String(root.hostWidget.setting("calendarUrlBase", Model.DEFAULT_CALENDAR_URL_BASE)) : Model.DEFAULT_CALENDAR_URL_BASE
        placeholderText: "https://calendar.google.com/calendar"
        contentForeground: root.contentForeground
        contentFontFamily: root.contentFontFamily
        onModified: function(val) { root.settingChanged("calendarUrlBase", val) }
      }

      SettingField {
        id: browserCmdField
        width: parent.width
        label: "Open with"
        text: root.hostWidget ? String(root.hostWidget.setting("browserCommand", "")) : ""
        placeholderText: "xdg-open"
        contentForeground: root.contentForeground
        contentFontFamily: root.contentFontFamily
        onModified: function(val) { root.settingChanged("browserCommand", val) }
      }

      SettingKeyInput {
        id: keyRefreshInput
        label: "Refresh"
        key: root.hostWidget ? root.hostWidget.keyRefresh : Model.DEFAULT_KEY_REFRESH
        defaultKey: Model.DEFAULT_KEY_REFRESH
        contentForeground: root.contentForeground
        contentFontFamily: root.contentFontFamily
        onModified: function(k) { root.settingChanged("keyRefresh", k) }
      }

      SettingKeyInput {
        id: keySettingsInput
        label: "Options tab"
        key: root.hostWidget ? root.hostWidget.keySettings : Model.DEFAULT_KEY_SETTINGS
        defaultKey: Model.DEFAULT_KEY_SETTINGS
        contentForeground: root.contentForeground
        contentFontFamily: root.contentFontFamily
        onModified: function(k) { root.settingChanged("keySettings", k) }
      }

      SettingKeyInput {
        id: keyJoinInput
        label: "Join meeting"
        key: root.hostWidget ? root.hostWidget.keyJoin : Model.DEFAULT_KEY_JOIN
        defaultKey: Model.DEFAULT_KEY_JOIN
        contentForeground: root.contentForeground
        contentFontFamily: root.contentFontFamily
        onModified: function(k) { root.settingChanged("keyJoin", k) }
      }

      SettingKeyInput {
        id: keyCalendarInput
        label: "Open calendar"
        key: root.hostWidget ? root.hostWidget.keyCalendar : Model.DEFAULT_KEY_CALENDAR
        defaultKey: Model.DEFAULT_KEY_CALENDAR
        contentForeground: root.contentForeground
        contentFontFamily: root.contentFontFamily
        onModified: function(k) { root.settingChanged("keyCalendar", k) }
      }
    }
  }
}
