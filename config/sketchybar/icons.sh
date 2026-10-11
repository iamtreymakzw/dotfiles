#!/bin/zsh

# Nerd Font glyphs. Each one was checked against JetBrainsMono Nerd Font before use.
export SEP=$''
export SEP_L=$''
export ICON_APPLE=$''
export ICON_CLOCK=$''
export ICON_CALENDAR=$''
export ICON_BOLT=$''
export ICON_WINDOW=$''

# icon_for <app name>: one glyph per app, a plain window for anything unlisted
icon_for() {
  case "$1" in
    Ghostty|Terminal|iTerm2)                     print -n $'' ;;
    Arc|"Google Chrome"|Chromium)                print -n $'' ;;
    Safari)                                      print -n $'' ;;
    Zed|"Zed Preview"|Code|"Visual Studio Code") print -n $'\U000f0a1e' ;;
    WebStorm|Xcode|"Android Studio"|OpenCode)    print -n $'' ;;
    Slack)                                       print -n $'' ;;
    Discord)                                     print -n $'\U000f066f' ;;
    WhatsApp*)                                   print -n $'\U000f05a3' ;;
    "Microsoft Teams"*)                          print -n $'\U000f02bb' ;;
    zoom.us|FaceTime)                            print -n $'' ;;
    Claude)                                      print -n $'\U000f06a9' ;;
    "Microsoft Outlook"|Mail)                    print -n $'' ;;
    "Microsoft Word")                            print -n $'\U000f022c' ;;
    "Microsoft Excel")                           print -n $'\U000f021b' ;;
    "Microsoft PowerPoint")                      print -n $'\U000f0227' ;;
    "Microsoft To Do"|Huly|Reminders)            print -n $'\U000f012c' ;;
    Figma)                                       print -n $'\U000f03d8' ;;
    "MongoDB Compass"|"Studio 3T"*)              print -n $'' ;;
    Fork|"GitHub Desktop")                       print -n $'' ;;
    yaak|Yaak)                                   print -n $'\U000f109b' ;;
    Finder)                                      print -n $'\U000f0036' ;;
    "System Settings")                           print -n $'' ;;
    *)                                           print -n "$ICON_WINDOW" ;;
  esac
}
