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
        nodejs
        github-cli
        heroic
        mangohud
        mangojuice
        vkbasalt
        mpv
        mpvpaper
        awww
        gpu-screen-recorder
        dust
        duf
        tealdeer
        just
        p7zip
        rsync
        socat
        psmisc
        wl-clipboard
        yazi

        # Python
        uv

        # Rust
        rustup
        cargo-nextest
        cargo-watch
        cargo-audit
        cargo-deny

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
        ffmpegthumbnailer
        poppler-utils

        # Theming
        qgnomeplatform-qt6

        # Editors
        zed-editor
        helix

        # Desktop
        glib
        loupe
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
    };
}
