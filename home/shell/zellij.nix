{ inputs, ... }:

{
  programs.zellij = {
    enable = true;
    enableBashIntegration = false;
    enableZshIntegration = false;
    enableFishIntegration = false;

    themes = {
      rose-pine = builtins.readFile "${inputs.rose-pine-zellij}/dist/rose-pine.kdl";
      rose-pine-moon = builtins.readFile "${inputs.rose-pine-zellij}/dist/rose-pine-moon.kdl";
      rose-pine-dawn = builtins.readFile "${inputs.rose-pine-zellij}/dist/rose-pine-dawn.kdl";
    };

    settings = {
      theme = "rose-pine-moon";
      default_layout = "compact";
      simplified_ui = true;
      show_startup_tips = false;

      ui.pane_frames = {
        rounded_corners = true;
      };
    };

    extraConfig = ''
      plugins {
        compact-bar location="zellij:compact-bar" {
          tooltip "F1"
        }
      }
    '';
  };
}
