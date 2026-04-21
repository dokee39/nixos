{ pkgs, ... }:

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
        if set -q IN_NIX_SHELL
          printf 'Nix Shell'
        else if test "$SHLVL" -gt 1; and string match -qr '^/nix/store/' -- $PATH[1]
          printf 'Nix Shell'
        else
          printf "NixOS"
        end
        set_color normal
        printf "!\n\n"
      '';

      fish_right_prompt = ''
        if set -q IN_NIX_SHELL
          set_color --bold blue
          printf '[nix shell]'
          set_color normal
        else if test "$SHLVL" -gt 1; and string match -qr '^/nix/store/' -- $PATH[1]
          set_color --bold blue
          printf '[nix shell]'
          set_color normal
        end

        if set -q SSH_CONNECTION; or set -q SSH_TTY
          printf " "
          set_color --bold green
          printf "[ssh]"
          set_color normal
        end
      '';

      mntfs = ''
      sudo mount -t ntfs3 -o uid=(id -u),gid=(id -g),fmask=0133,dmask=0022,windows_names,prealloc,force $argv
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
      ls = "eza --icons --group-directories-first";
      la = "eza --icons --group-directories-first --git -la";
      lt = "eza --icons --group-directories-first --tree";
      type = "type -a";
      cr = "cd (pwd -P)";
      chmox = "chmod u+x";
    };

    shellAbbrs = {
      mv = "mv -v";
      rm = "rm -v";
      cp = "cp -v";
    };
  };
}
