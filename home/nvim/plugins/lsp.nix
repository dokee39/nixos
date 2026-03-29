{ lib, pkgs, inputs, ... }:

let 
  navbuddy = pkgs.vimUtils.buildVimPlugin {
    name = "nvim-navbuddy";
    src = inputs.navbuddy;
    dependencies = with pkgs.vimPlugins; [
      nvim-navic
      nui-nvim
    ];
  };
  mkRaw = lib.nixvim.mkRaw;
in {
  lsp = {
    enable = true;

    servers = {
      nixd.enable = true;
      lua_ls = {
        enable = true;
        config = {
          settings = { 
            Lua = { 
              workspace.checkThirdParty = false;
              telemetry.enable = false;
              hint.enable = true;
            };
          };
        };
      };
      clangd = {
        enable = true;
        config = {
          cmd = [
            "clangd"
            "--header-insertion=never"
            "--experimental-modules-support"
          ];
        };
      };
    };

    keymaps = [
      {
        key = "<leader>d";
        mode = "n";
        action = mkRaw "vim.diagnostic.open_float";
        options.desc = "LSP: show line [d]iagnostics";
      }

      {
        key = "K";
        lspBufAction = "hover";
        options.desc = "LSP: hover documentation";
      }
      {
        key = "gD";
        lspBufAction = "declaration";
        options.desc = "LSP: [g]oto [D]eclaration";
      }
      {
        key = "+";
        mode = [ "n" "x" ];
        lspBufAction = "format";
        options.desc = "LSP: format";
      }
      {
        key = "<leader>rn";
        lspBufAction = "rename";
        options.desc = "LSP: [r]e[n]ame";
      }
      {
        key = "<leader>a";
        mode = [ "n" "x" ];
        lspBufAction = "code_action";
        options.desc = "LSP: Code [a]ction";
      }

      {
        key = "gd";
        mode = "n";
        action = mkRaw "require('telescope.builtin').lsp_definitions";
        options.desc = "LSP: Telescope [g]oto [d]efinition";
      }
      {
        key = "gt";
        mode = "n";
        action = mkRaw "require('telescope.builtin').lsp_type_definitions";
        options.desc = "LSP: [g]oto [t]ype Definition";
      }
      {
        key = "gr";
        mode = "n";
        action = mkRaw "require('telescope.builtin').lsp_references";
        options.desc = "LSP: Telescope [g]oto [r]eferences";
      }
      {
        key = "gi";
        mode = "n";
        action = mkRaw "require('telescope.builtin').lsp_implementations";
        options.desc = "LSP: Telescope [g]oto [i]mplementation";
      }
      {
        key = "gs";
        mode = "n";
        action = mkRaw "require('telescope.builtin').lsp_document_symbols";
        options.desc = "LSP: Telescope [g]oto document [s]ymbols";
      }
      {
        key = "gS";
        mode = "n";
        action = mkRaw "require('telescope.builtin').lsp_dynamic_workspace_symbols";
        options.desc = "LSP: Telescope [g]oto workspace [S]ymbols";
      }
      {
        key = "<leader>D";
        mode = "n";
        action = mkRaw "require('telescope.builtin').diagnostics";
        options.desc = "LSP: Telescope list [D]iagnostics";
      }
    ];
  };

  plugins.nvim-lightbulb = {
    enable = true;
    settings = {
      priority = 5;
      sign.text = "󰌶";
      number.enabled = true;
      autocmd = {
        enabled = true;
        events = mkRaw ''{ "CursorHold" }'';
        updatetime = 200;
      };
    };
  };

  plugins.navic.enable = true;
  plugins.navbuddy = {
    enable = true;
    package = navbuddy;
    settings = {
      window = {
        border = "rounded";
        size = { 
          height = "80%"; 
          width = "80%"; 
        };
        sections.mid.size = "32%";
      };
      lsp.auto_attach = true;
      mappings."/" = mkRaw ''
        require("nvim-navbuddy.actions").telescope({
          layout_config = {
            height = 0.80,
            width = 0.80,
            prompt_position = "top",
          },
          layout_strategy = "flex"
        }),
        '';
    };
  };

  keymaps = [
    {
      mode = "n";
      key = "<leader>n";
      action = "<CMD>Navbuddy<CR>";
      options.desc = "[n]avbuddy";
    }
  ];
}
