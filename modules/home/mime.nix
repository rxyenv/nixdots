{
  flake.modules.homeManager.mime =
    {
      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "image/png" = "org.gnome.Loupe.desktop";
          "image/jpeg" = "org.gnome.Loupe.desktop";
          "image/gif" = "org.gnome.Loupe.desktop";
          "image/webp" = "org.gnome.Loupe.desktop";
          "image/bmp" = "org.gnome.Loupe.desktop";
          "image/tiff" = "org.gnome.Loupe.desktop";
          "image/svg+xml" = "org.gnome.Loupe.desktop";

          "application/pdf" = "org.pwmt.zathura.desktop";

          "application/zip" = "org.gnome.FileRoller.desktop";
          "application/x-7z-compressed" = "org.gnome.FileRoller.desktop";
          "application/x-tar" = "org.gnome.FileRoller.desktop";
          "application/x-compressed-tar" = "org.gnome.FileRoller.desktop";
          "application/gzip" = "org.gnome.FileRoller.desktop";
          "application/x-bzip2" = "org.gnome.FileRoller.desktop";
          "application/x-rar" = "org.gnome.FileRoller.desktop";

          "video/mp4" = "mpv.desktop";
          "video/mkv" = "mpv.desktop";
          "video/x-matroska" = "mpv.desktop";
          "video/webm" = "mpv.desktop";
          "video/avi" = "mpv.desktop";
          "video/x-msvideo" = "mpv.desktop";
          "video/quicktime" = "mpv.desktop";
          "video/x-flv" = "mpv.desktop";
          "video/ogg" = "mpv.desktop";
          "audio/mpeg" = "mpv.desktop";
          "audio/ogg" = "mpv.desktop";
          "audio/flac" = "mpv.desktop";
          "audio/x-wav" = "mpv.desktop";
          "audio/mp4" = "mpv.desktop";
          "audio/opus" = "mpv.desktop";

          "text/plain" = "code.desktop";

          "x-scheme-handler/http" = "helium.desktop";
          "x-scheme-handler/https" = "helium.desktop";
          "text/html" = "helium.desktop";
          "application/xhtml+xml" = "helium.desktop";
          "x-scheme-handler/mailto" = "helium.desktop";

          "application/x-bittorrent" = "org.qbittorrent.qBittorrent.desktop";
          "x-scheme-handler/magnet" = "org.qbittorrent.qBittorrent.desktop";

          "inode/directory" = "org.gnome.Nautilus.desktop";
        };
      };
    }
;
}
