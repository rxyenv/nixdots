{
  flake.modules.homeManager.packages =
    { pkgs, ... }:
    let
      writer = pkgs.stdenv.mkDerivation {
        pname = "writer";
        version = "0.1.0-unstable-2026-08-16";

        src = pkgs.fetchFromGitHub {
          owner = "rxyenv";
          repo = "writer";
          rev = "ecc4568";
          hash = "sha256-4L/uWobT7ZTJWqJR/RgbMOz8/L36I5J8cEya2GrqPPY=";
        };

        nativeBuildInputs = with pkgs.qt6Packages; [
          qmake
          wrapQtAppsHook
        ];

        buildInputs = with pkgs.qt6Packages; [
          qtbase
          qtdeclarative
        ];

        installPhase = ''
          install -Dm755 writer "$out/bin/writer"
          install -Dm644 "$src/LICENSE" "$out/share/licenses/writer/LICENSE"
          install -Dm644 "$src/fonts/OFL.txt" "$out/share/licenses/writer/OFL.txt"
          install -d "$out/share/fonts/truetype/iA-Writer-Mono"
          install -m644 fonts/*.ttf "$out/share/fonts/truetype/iA-Writer-Mono/"
          install -Dm644 pkgbuild/writer.svg \
            "$out/share/icons/hicolor/scalable/apps/writer.svg"
          install -Dm644 pkgbuild/writer.desktop \
            "$out/share/applications/writer.desktop"
        '';

        meta = {
          description = "Dead-simple Markdown writing app built with Qt Quick";
          homepage = "https://github.com/rxyenv/writer";
          license = pkgs.lib.licenses.mit;
          mainProgram = "writer";
          platforms = pkgs.lib.platforms.linux;
        };
      };
    in
    {
      home.packages = [ writer ] ++ (with pkgs; [
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
        nwg-look

        # Editors
        vscode

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

      ]);
    };
}
