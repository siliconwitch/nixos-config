{ pkgs, lib, ... }:

let
  # Chromium webapp shortcut → /run/current-system/sw/share/applications
  webapp = display: url: pkgs.makeDesktopItem {
    name        = lib.replaceStrings [ " " ] [ "-" ] display;
    desktopName = display;
    exec        = "${pkgs.chromium}/bin/chromium --app=${url}";
    terminal    = false;
    icon        = "web-browser";
  };
in
{
  environment.systemPackages = [
    (webapp "YouTube"               "https://www.youtube.com")
    (webapp "YouTube Music"         "https://music.youtube.com")
    (webapp "Fortnox"               "https://www.fortnox.se")
    (webapp "Superstack Production" "https://super.siliconwitchery.com")
    (webapp "Superstack Staging"    "https://superstaging.siliconwitchery.com")
    (webapp "Google Translate"      "https://translate.google.com")
    (webapp "Figma"                 "https://www.figma.com")
    (webapp "Draw.io"               "https://app.diagrams.net")
    (webapp "Localsend"             "https://web.localsend.org")
  ];
}
