{ config, osConfig, pkgs, ... }:

{
  home.packages = [ pkgs.bubblewrap ];
  age.secrets.codex-github-pat = {
    file = osConfig.profile.codex.githubPatSecretFile;
    path = "${config.home.homeDirectory}/.local/share/agenix/codex-github-pat";
  };
  programs.fish.functions.codex = ''
    set -lx GITHUB_PAT_TOKEN (string trim -- (cat ${config.age.secrets.codex-github-pat.path}))
    command codex $argv
  '';
  programs.codex = {
    enable = true;
    custom-instructions = ''
      Please strictly follow these principles in every task and reflect them in your plan:
          - Actively use the built-in search tool or MCP when needed to research relevant implementations.
          - When comparing implementation methods, code structure, or similar project patterns, prefer using GitHub MCP for reference.
          - Define the problem before changing the code. Prioritize fixing the root cause, respect the existing system, restore the original correct structure, and avoid masking issues with local patches, extra branches, or temporary exceptions.
          - Prioritize overall structure and long-term complexity, rather than just minimizing local edits or reducing the diff size.
          - Plan changes with foreseeable future peer features in mind. Prefer shared, extensible structures over one-off top-level designs.
          - Allow small, systematic adjustments when they improve structural consistency and future extensibility. Do not preserve duplication, special cases, or poor structure just to avoid touching more code.
          - Keep all changes consistent with the project's existing code style, conventions, and overall design.
          - Do not run formatting commands, and avoid purely stylistic or format-only changes.
          - Prefer a concise and straightforward coding style.
          - Unless the reusability is clearly justified, do not split simple logic into multiple small functions, and avoid multi-level function nesting, excessive splitting, or abstraction for its own sake.

      In every plan:
          - Briefly restate the problem first.
          - Briefly explain why the proposed approach follows these principles, especially in terms of structural consistency, long-term complexity, and support for foreseeable future extensions.
    '';
  };
}

