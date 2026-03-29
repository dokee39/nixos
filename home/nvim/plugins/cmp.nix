{ lib, ... }:
let
  mkRaw = lib.nixvim.mkRaw;
in {
  plugins = {
    friendly-snippets.enable = true;
    blink-cmp-dictionary.enable = true;
    colorful-menu.enable = true;

    blink-cmp = {
      enable = true;
      luaConfig.pre = ''
        local function dict_keyword_tail(line, col)
          local before = line:sub(1, col)
          local keyword = before:match("([%w_-]+)$") or ""
          if keyword == "" then
            return "", ""
          end

          local base = keyword:gsub("[_-]+$", "")
          if base == "" then
            return keyword, ""
          end

          local segment = base:match("([^-_]+)$") or base
          local tail =
            segment:match("([A-Z][a-z0-9]+)$") or
            segment:match("([A-Z]+)$") or
            segment

          return keyword, tail
        end
      '';

      settings = {
        completion = {
          list.selection.preselect = false;
          ghost_text.enabled = true;
          menu = {
            max_height = 25;
            border = "rounded";
            draw = {
              columns = mkRaw ''{ { "kind_icon" }, { "label", gap = 1 } }'';
              components.label = {
                text = mkRaw ''
                  function(ctx)
                    return require("colorful-menu").blink_components_text(ctx)
                  end
                '';
                highlight = mkRaw ''
                  function(ctx)
                    return require("colorful-menu").blink_components_highlight(ctx)
                  end
                '';
              };
            };
          };
          documentation = {
            auto_show = true;
            auto_show_delay_ms = 200;
            window.border = "rounded";
          };
        };

        keymap = {
          "<Tab>" = [ "select_next" "snippet_forward" "fallback" ];
          "<S-Tab>" = [ "select_prev" "snippet_backward" "fallback" ];
          "<A-Tab>" = [ "snippet_forward" "fallback" ];
          "<A-S-Tab>" = [ "snippet_backward" "fallback" ];
          "<CR>" = [ "select_and_accept" "fallback" ];
        };

        sources = {
          default = [
            "lsp"
            "snippets"
            "path_buf"
            "path_ws"
            "buffer"
            "dictionary"
          ];

          providers = {
            lsp = {
              fallbacks = [ ];
              transform_items = mkRaw ''
                function(_, items)
                  local CompletionItemKind = require("blink.cmp.types").CompletionItemKind
                  return vim.tbl_filter(function(item)
                    return item.kind ~= CompletionItemKind.Text
                  end, items)
                end
                '';
            };

            path_buf = {
              name = "PathBuf";
              module = "blink.cmp.sources.path";
              score_offset = 3;
              opts.get_cwd = mkRaw ''
                function(ctx)
                  return vim.fn.expand(("#%d:p:h"):format(ctx.bufnr))
                end
              '';
            };
            path_ws = {
              name = "PathWs";
              module = "blink.cmp.sources.path";
              score_offset = 2;
              opts.get_cwd = mkRaw ''
                function(_)
                  return vim.fn.getcwd()
                end
              '';
            };

            dictionary = {
              score_offset = -15;
              module = "blink-cmp-dictionary";
              name = "Dict";
              min_keyword_length = 3;
              max_items = 10;
              transform_items = mkRaw ''
                function(ctx, items)
                  local keyword, tail = dict_keyword_tail(ctx.line, ctx.cursor[2])
                  if keyword == "" or tail == "" then
                    return items
                  end

                  local row = ctx.cursor[1] - 1
                  local col = ctx.cursor[2]
                  local start_col = col - #tail
                  local prefix = keyword:sub(1, #keyword - #tail)

                  local right = ctx.line:sub(col + 1):match("^([%w_-]*)") or ""

                  for i, item in ipairs(items) do
                    local text = (item.textEdit and item.textEdit.newText) or item.insertText or item.label

                    local end_col = col
                    local consume_right =
                      right ~= ""
                      and #text >= #right
                      and text:sub(1, #tail) == tail
                      and text:sub(-#right) == right

                    if consume_right then
                      end_col = col + #right
                    end

                    item.filterText = prefix .. text
                    item.sortText = item.sortText or string.format("%08d", i)
                    item.textEdit = {
                      newText = text,
                      range = {
                        start = { line = row, character = start_col },
                        ["end"] = { line = row, character = end_col },
                      },
                    }
                    item.insertText = nil
                  end

                  return items
                end
              '';

              opts = {
                dictionary_files = mkRaw ''function() return { vim.env.WORDLIST } end'';
                get_prefix = mkRaw ''
                  function(ctx)
                    local _, tail = dict_keyword_tail(ctx.line, ctx.cursor[2])
                    return tail
                  end
                '';
              };
            };

            cmdline.min_keyword_length = 3;
          };
        };
      };
    };

    keymaps = [
      {
        mode = "n";
        key = "<A-Tab>";
        action = mkRaw ''
          function()
            if vim.snippet.active({ direction = 1 }) then
              vim.snippet.jump(1)
            end
          end
        '';
        options.desc = "blink.cmp: snippet forward";
      }
      {
        mode = "n";
        key = "<A-S-Tab>";
        action = mkRaw ''
          function()
            if vim.snippet.active({ direction = -1 }) then
              vim.snippet.jump(-1)
            end
          end
        '';
        options.desc = "blink.cmp: snippet forward";
      }
    ];
  };
}
