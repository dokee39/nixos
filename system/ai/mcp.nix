{ config, lib, ... }:

{
  options.terra.ai.mcp = {
    servers = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = {};
      description = ''
        MCP server definitions, filled by other system modules (e.g. github).
        Home‑manager modules can read these via osConfig and merge them into programs.mcp.servers.
      '';
    };
    groupName = lib.mkOption {
      type = lib.types.str;
      default = "mcp";
    };
  };

  config = let
    mcpGroup = config.terra.ai.mcp.groupName;
  in {
    users.groups.${mcpGroup} = {};
    users.users.root.extraGroups = [ mcpGroup ];
    users.users.${config.terra.userName}.extraGroups = [ mcpGroup ];
  };
}
