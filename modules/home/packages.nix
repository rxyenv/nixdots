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
        nil
        nixd
        nixfmt
        ripgrep
        tree
        sassc
        nodejs
        github-cli
        heroic
        mangohud
        mangojuice
        vkbasalt
        mpv
        mpvpaper
        gpu-screen-recorder
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

        # Rust
        rustup

        # Flutter
        flutter
        android-tools

        # AI
        opencode

        # Security
        proton-pass-cli
        tor-browser

        # Files
        udiskie
        nautilus
        file-roller
        gnome-disk-utility
        ffmpegthumbnailer
        poppler-utils

        # Theming
        nwg-look
        qgnomeplatform-qt6

        # Editors
        zed-editor
        helix

        # Desktop
        glib
        loupe
        signal-desktop
        vesktop
        anydesk
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
