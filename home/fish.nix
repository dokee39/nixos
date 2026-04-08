{ config, pkgs, ... }:

{
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      source ${pkgs.fish}/share/fish/prompts/nim.fish

      set -g fish_pager_color_selected_background --background=green
      set -g fish_pager_color_selected_completion brwhite
    '';

    functions = {
      fish_greeting = ''
        echo
        printf "Welcome to "
        set_color --bold blue
        printf "NixOS"
        set_color normal
        printf "!\n\n"
      '';

      mntfs = ''
      sudo mount -t ntfs3 -o uid=(id -u),gid=(id -g),fmask=0133,dmask=0022,windows_names,prealloc $argv
      '';
    };

    shellAliases = {
      # system
      rbt = "sync; sync; systemctl reboot";
      std = "sync; sync; systemctl poweroff";
      scst = "systemctl status";

      # git
      gad = "git add --all";
      gst = "git status -s";
      gci = "git commit -m";
      gbr = "git branch --all";
      glg = ''git log --pretty=format:"%C(auto)%h%Creset - %C(green)%s%Creset%n    %C(bold cyan)@%Creset%C(bold blue)%an%Creset, %C(cyan)%ah%Creset%C(auto)%d%Creset" --graph --all'';

      # shell
      ls = "eza --icons";
      la = "eza --icons --git -la";
      lt = "eza --icons --tree";
      type = "type -a";
      cr = "cd (pwd -P)";
      chmox = "chmod u+x";

      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "....." = "cd ../../../..";

      # other
      matlab = "matlab -nodesktop -nosplash";
    };

    shellAbbrs = {
      mv = "mv -v";
      rm = "rm -v";
      cp = "cp -v";
    };
  };
}
