{ ... }:

{
  colorschemes.rose-pine = {
    enable = true;
    autoLoad = true;

    settings = {
      dark_variant = "moon";

      styles = {
        transparency = true;
      };

      highlight_groups = {
        Search = { fg = "love"; bg = "foam"; bold = true; "inherit" = false; };
        CurSearch = { fg = "love"; bg = "gold"; bold = true; "inherit" = false; };

        variable = { fg = "iris"; "inherit" = false; };
        "@variable" = { link = "variable"; "inherit" = false; };
        "@property" = { link = "variable"; "inherit" = false; };
        "@variable.member" = { link = "variable"; "inherit" = false; };

        "@function" = { bold = true; };
        "@function.method" = { bold = true; };
        "@keyword" = { bold = true; };
        "@type.builtin" = { bold = false; };
        "@lsp.type.modifier.cpp" = { link = "@keyword"; "inherit" = false; };
      };
    };
  };
}
