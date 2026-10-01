#!/usr/bin/env zsh
# automator-macos.sh
#
# For each app below, creates a macOS Automator Quick Action (a Service)
# that runs `tell application "<App>" to activate`, then binds it to
# Cmd+Option+Ctrl+Shift+<key> in the Services menu.
#
# Idempotent: an app whose Quick Action already exists in ~/Library/Services
# is left untouched, and a shortcut already registered in pbs.plist is left
# untouched. Safe to re-run after adding entries to APPS below.
#
# Note: macOS caches the Services/shortcuts database (pbs). After this runs,
# new shortcuts are usually live immediately; if a Service doesn't show its
# shortcut yet, log out/in (or reopen System Settings > Keyboard > Keyboard
# Shortcuts > Services) to force a re-read.

set -euo pipefail

typeset -A APPS=(
  "RubyMine"           "m"
  "IntelliJ IDEA"      "i"
  "Visual Studio Code" "v"
  "Warp"               "w"
  "PyCharm"            "p"
  "GoLand"             "g"
  "Slack"              "s"
  "Brave Browser"      "b"
)

SERVICES_DIR="$HOME/Library/Services"
PBS_PLIST="$HOME/Library/Preferences/pbs.plist"
PLB="/usr/libexec/PlistBuddy"
PBS_BIN="/System/Library/CoreServices/pbs"

workflow_name() {
  # "IntelliJ IDEA" -> "OpenIntelliJIDEA"
  print -r -- "Open${1// /}"
}

app_exists() {
  osascript -e "id of application \"$1\"" >/dev/null 2>&1
}

create_workflow() {
  local app="$1" name="$2"
  local dir="$SERVICES_DIR/$name.workflow"
  local contents="$dir/Contents"

  if [[ -d "$dir" ]]; then
    print -r -- "  quick action already exists, skipping: $name"
    return
  fi

  mkdir -p "$contents"

  local input_uuid="$(uuidgen)"
  local output_uuid="$(uuidgen)"
  local action_uuid="$(uuidgen)"

  cat >"$contents/document.wflow" <<WFLOW
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>AMApplicationBuild</key>
	<string>534</string>
	<key>AMApplicationVersion</key>
	<string>2.10</string>
	<key>AMDocumentVersion</key>
	<string>2</string>
	<key>actions</key>
	<array>
		<dict>
			<key>action</key>
			<dict>
				<key>AMAccepts</key>
				<dict>
					<key>Container</key>
					<string>List</string>
					<key>Optional</key>
					<true/>
					<key>Types</key>
					<array>
						<string>com.apple.applescript.object</string>
					</array>
				</dict>
				<key>AMActionVersion</key>
				<string>1.0.2</string>
				<key>AMApplication</key>
				<array>
					<string>Automator</string>
				</array>
				<key>AMParameterProperties</key>
				<dict>
					<key>source</key>
					<dict/>
				</dict>
				<key>AMProvides</key>
				<dict>
					<key>Container</key>
					<string>List</string>
					<key>Types</key>
					<array>
						<string>com.apple.applescript.object</string>
					</array>
				</dict>
				<key>ActionBundlePath</key>
				<string>/System/Library/Automator/Run AppleScript.action</string>
				<key>ActionName</key>
				<string>Run AppleScript</string>
				<key>ActionParameters</key>
				<dict>
					<key>source</key>
					<string>tell application "$app" to activate</string>
				</dict>
				<key>BundleIdentifier</key>
				<string>com.apple.Automator.RunScript</string>
				<key>CFBundleVersion</key>
				<string>1.0.2</string>
				<key>CanShowSelectedItemsWhenRun</key>
				<false/>
				<key>CanShowWhenRun</key>
				<true/>
				<key>Category</key>
				<array>
					<string>AMCategoryUtilities</string>
				</array>
				<key>Class Name</key>
				<string>RunScriptAction</string>
				<key>InputUUID</key>
				<string>$input_uuid</string>
				<key>Keywords</key>
				<array>
					<string>Run</string>
				</array>
				<key>OutputUUID</key>
				<string>$output_uuid</string>
				<key>UUID</key>
				<string>$action_uuid</string>
				<key>UnlocalizedApplications</key>
				<array>
					<string>Automator</string>
				</array>
				<key>arguments</key>
				<dict>
					<key>0</key>
					<dict>
						<key>default value</key>
						<string>on run {input, parameters}

	(* Your script goes here *)

	return input
end run</string>
						<key>name</key>
						<string>source</string>
						<key>required</key>
						<string>0</string>
						<key>type</key>
						<string>0</string>
						<key>uuid</key>
						<string>0</string>
					</dict>
				</dict>
				<key>isViewVisible</key>
				<integer>1</integer>
				<key>location</key>
				<string>309.000000:368.000000</string>
				<key>nibPath</key>
				<string>/System/Library/Automator/Run AppleScript.action/Contents/Resources/Base.lproj/main.nib</string>
			</dict>
			<key>isViewVisible</key>
			<integer>1</integer>
		</dict>
	</array>
	<key>connectors</key>
	<dict/>
	<key>workflowMetaData</key>
	<dict>
		<key>applicationBundleIDsByPath</key>
		<dict/>
		<key>applicationPaths</key>
		<array/>
		<key>inputTypeIdentifier</key>
		<string>com.apple.Automator.nothing</string>
		<key>outputTypeIdentifier</key>
		<string>com.apple.Automator.nothing</string>
		<key>presentationMode</key>
		<integer>11</integer>
		<key>processesInput</key>
		<false/>
		<key>serviceInputTypeIdentifier</key>
		<string>com.apple.Automator.nothing</string>
		<key>serviceOutputTypeIdentifier</key>
		<string>com.apple.Automator.nothing</string>
		<key>serviceProcessesInput</key>
		<false/>
		<key>systemImageName</key>
		<string>NSActionTemplate</string>
		<key>useAutomaticInputType</key>
		<true/>
		<key>workflowTypeIdentifier</key>
		<string>com.apple.Automator.servicesMenu</string>
	</dict>
</dict>
</plist>
WFLOW

  cat >"$contents/Info.plist" <<INFOPLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>NSServices</key>
	<array>
		<dict>
			<key>NSBackgroundColorName</key>
			<string>background</string>
			<key>NSIconName</key>
			<string>NSActionTemplate</string>
			<key>NSMenuItem</key>
			<dict>
				<key>default</key>
				<string>$name</string>
			</dict>
			<key>NSMessage</key>
			<string>runWorkflowAsService</string>
		</dict>
	</array>
</dict>
</plist>
INFOPLIST

  print -r -- "  created quick action: $name"
}

ensure_pbs_plist() {
  [[ -f "$PBS_PLIST" ]] && return
  cat >"$PBS_PLIST" <<'EMPTYPLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict/>
</plist>
EMPTYPLIST
}

set_shortcut() {
  local app="$1" name="$2" key="$3"
  local skey="(null) - ${name} - runWorkflowAsService"
  local kequiv="@~^\$${key}"

  ensure_pbs_plist

  if "$PLB" -c "Print :NSServicesStatus:\"$skey\"" "$PBS_PLIST" &>/dev/null; then
    print -r -- "  shortcut already set: $app"
    return
  fi

  "$PLB" -c "Add :NSServicesStatus dict" "$PBS_PLIST" &>/dev/null || true
  "$PLB" -c "Add :NSServicesStatus:\"$skey\" dict" "$PBS_PLIST"
  "$PLB" -c "Add :NSServicesStatus:\"$skey\":key_equivalent string \"$kequiv\"" "$PBS_PLIST"
  "$PLB" -c "Add :NSServicesStatus:\"$skey\":presentation_modes dict" "$PBS_PLIST"
  "$PLB" -c "Add :NSServicesStatus:\"$skey\":presentation_modes:ContextMenu bool true" "$PBS_PLIST"
  "$PLB" -c "Add :NSServicesStatus:\"$skey\":presentation_modes:ServicesMenu bool true" "$PBS_PLIST"
  "$PLB" -c "Add :NSServicesStatus:\"$skey\":presentation_modes:TouchBar bool true" "$PBS_PLIST"
  "$PLB" -c "Add :ServicesShortcutsPresent bool true" "$PBS_PLIST" &>/dev/null || true

  print -r -- "  shortcut set: $app -> Cmd+Opt+Ctrl+Shift+${(U)key}"
}

main() {
  for app key in "${(kv)APPS[@]}"; do
    if ! app_exists "$app"; then
      print -r -- "skipping (not installed): $app"
      continue
    fi

    print -r -- "$app"
    local name="$(workflow_name "$app")"
    create_workflow "$app" "$name"
    set_shortcut "$app" "$name" "$key"
  done

  "$PBS_BIN" -flush 2>/dev/null || true
  print -r -- "done. If a shortcut doesn't show up yet, log out/in or reopen System Settings > Keyboard > Keyboard Shortcuts > Services."
}

main "$@"
