{
  flake.modules.homeManager.packages =
    { pkgs, ... }:

    {
      home.packages = with pkgs; [
        # CLI utilities
        bat
        btop
        fd
        grc
        jq
        localsend
        nixfmt
        ripgrep
        tree
        sassc
        nodejs
        github-cli
        heroic
        mpv
        dust
        duf
        tealdeer
        ncdu
        just
        p7zip
        rsync
        socat
        psmisc
        wl-clipboard
        zenity
        yazi

        # Python
        uv
        pfetch-rs

        # Rust
        rustup

        # Flutter
        flutter
        android-tools

        # AI
        claude-code
        opencode

        # Files
        udiskie
        nautilus
        file-roller
        gnome-disk-utility
        cliphist
        ffmpegthumbnailer
        poppler-utils
        satty


        # Theming
        pywalfox-native
        nwg-look
        qgnomeplatform-qt6

        # Editors
        zed-editor
        helix

        # Desktop
        glib
        loupe
        signal-desktop
        qbittorrent
        (
          (wrapOBS.override {
            obs-studio = obs-studio.override { cudaSupport = true; };
          })
          {
            plugins = with obs-studio-plugins; [
              wlrobs
              obs-vkcapture
              obs-pipewire-audio-capture
              obs-gstreamer
              obs-backgroundremoval
            ];
          }
        )

        # (flake packages go here)
      ];
    }
;
}
