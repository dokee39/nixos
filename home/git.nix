{ ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user.name = "dokee";
      user.email = "dokee.39@gmail.com";
      init.defaultBranch = "main";
    };
  };
}

