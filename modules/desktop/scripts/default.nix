{
  flake.modules.homeManager.scripts =
    {
      pkgs,
      lib,
      ...
    }:

    let
      scriptDir = ./.;
      scriptNames = [
        "zen0x-audio-output-switch"
        "zen0x-brightness-display"
        "zen0x-capture-ocr"
        "zen0x-capture-screenrecording"
        "zen0x-capture-screenshot"
        "zen0x-clipboard"
        "zen0x-default-browser"
        "zen0x-default-editor"
        "zen0x-default-terminal"
        "zen0x-font-set"
        "zen0x-launch-audio"
        "zen0x-launch-bluetooth"
        "zen0x-launch-or-focus"
        "zen0x-launch-or-focus-tui"
        "zen0x-launch-tui"
        "zen0x-launch-wifi"
        "zen0x-osd"
        "zen0x-powermenu"
        "zen0x-qsmenu"
        "zen0x-terminal-cwd"
        "zen0x-theme-reload"
        "zen0x-toggle-bluetooth"
        "zen0x-toggle-mute"
        "zen0x-toggle-nightlight"
        "zen0x-toggle-wifi"
        "zen0x-set-wallpaper"
      ];

      makeScript =
        name:
        pkgs.writeShellScriptBin name (builtins.readFile "${scriptDir}/${name}");

      scripts = map makeScript scriptNames;
    in
    {
      xdg.configFile."xdg-terminals.list".text = ''
        kitty.desktop
      '';

      home.packages =
        scripts
        ++ (with pkgs; [
          xdg-terminal-exec
          grim
          slurp
          satty
          wf-recorder
          brightnessctl
          playerctl
          wiremix
          bluetui
          impala
          swaybg
          jq
          python3
          hyprpicker
          hyprsunset
          cliphist
          tesseract
          perl
          wl-clipboard
        ]);
    };
}
