{
  flake.modules.homeManager.webapps = {
    xdg.desktopEntries = {
      youtube = {
        name = "YouTube";
        comment = "Watch videos on YouTube";
        icon = "youtube";
        exec = "uwsm-app -- helium --class=zen0x-webapp --app=https://www.youtube.com/";
        terminal = false;
        categories = [
          "AudioVideo"
          "Network"
        ];
      };

      netflix = {
        name = "Netflix";
        comment = "Watch Netflix";
        icon = "netflix";
        exec = "uwsm-app -- helium --class=zen0x-webapp --app=https://www.netflix.com/";
        terminal = false;
        categories = [
          "AudioVideo"
          "Network"
        ];
      };

      reddit = {
        name = "Reddit";
        comment = "Browse Reddit";
        icon = "reddit";
        exec = "uwsm-app -- helium --class=zen0x-webapp --app=https://www.reddit.com/";
        terminal = false;
        categories = [ "Network" ];
      };

      whatsapp = {
        name = "WhatsApp";
        comment = "Chat on WhatsApp";
        icon = "whatsapp";
        exec = "uwsm-app -- helium --class=zen0x-webapp --app=https://web.whatsapp.com/";
        terminal = false;
        categories = [ "Network" ];
      };
    };

    xdg.dataFile = {
      "icons/hicolor/scalable/apps/youtube.svg".source = ./webapp-icons/youtube.svg;
      "icons/hicolor/scalable/apps/netflix.svg".source = ./webapp-icons/netflix.svg;
      "icons/hicolor/scalable/apps/reddit.svg".source = ./webapp-icons/reddit.svg;
      "icons/hicolor/scalable/apps/whatsapp.svg".source = ./webapp-icons/whatsapp.svg;
    };
  };
}
