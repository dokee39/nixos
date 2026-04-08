{ pkgs, ... }:

{
  programs.yazi = {
    enable = true;

    package = pkgs.yazi.override {
      _7zz = pkgs._7zz-rar;
    };

    enableFishIntegration = true;
    shellWrapperName = "y";

    plugins = {
      git = pkgs.yaziPlugins.git;
      piper = pkgs.yaziPlugins.piper;
      lsar = pkgs.yaziPlugins.lsar;
      "mime-ext" = pkgs.yaziPlugins."mime-ext";
    };

    initLua = ''
      require("git"):setup()
    '';

    keymap = {
      mgr.prepend_keymap = [
        {
          on = "S";
          run = "shell --block -- ${pkgs.fish}/bin/fish";
          desc = "Open fish in current directory";
        }
      ];
    };

    theme = {
      mgr.border_symbol = " ";
    };

    settings = {
      mgr.ratio = [ 1 3 4 ];
      plugin = {
        prepend_fetchers = [
          {
            id = "git";
            url = "*";
            run = "git";
          }
          {
            id = "git";
            url = "*/";
            run = "git";
          }
          {
            id = "mime";
            url = "remote://*";
            run = "mime-ext.remote";
            prio = "high";
          }
        ];

        prepend_previewers = [
          {
            mime = "application/{,g}zip";
            run = "lsar";
          }
          {
            mime = "application/{tar,bzip*,7z*,xz,rar}";
            run = "lsar";
          }
          {
            url = "*.csv";
            run = ''piper -- bat -p --color=always "$1"'';
          }
          {
            url = "*.md";
            run = ''piper -- CLICOLOR_FORCE=1 glow -w=$w -s=dark "$1"'';
          }
        ];
        append_previewers = [
          {
            url = "*";
            run = ''piper -- hexyl --border=none --terminal-width=$w "$1"'';
          }
        ];
      };
    };
  };
}
