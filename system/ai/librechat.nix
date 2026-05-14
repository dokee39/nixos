{ config, lib, ... }:

let
  cfg = config.terra.ai.librechat;
  aiCfg = config.terra.ai;
in {
  options.terra.ai.librechat = {
    enable = lib.mkEnableOption "LibreChat service";
    port = lib.mkOption {
      type = lib.types.port;
      default = 3080;
    };
    credentials_secretFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Path to a secret file containing the credentials.
        ```
          CREDS_KEY=xxx
          CREDS_IV=xxx
          JWT_SECRET=xxx
          JWT_REFRESH_SECRET=xxx
          MEILI_MASTER_KEY=xxx
          SEARXNG_INSTANCE_URL=https://api.example.com
          SEARXNG_API_KEY=xxx
          FIRECRAWL_API_URL=https://api.example.com
          FIRECRAWL_VERSION=v1
          FIRECRAWL_API_KEY=xxx
          JINA_API_URL=http://api.example.com/v1/rerank
          JINA_API_KEY=xxx
          DEEPSEEK_API_KEY=xxx
          MOONSHOT_API_KEY=xxx
          OPENROUTER_KEY=xxx
        ```
      '';
    };
  };

  config = {
    age.secrets.librechat-credentials.file = cfg.credentials_secretFile;

    users.users.librechat.extraGroups = [ aiCfg.mcp.groupName ];

    services.librechat = {
      enable = true;

      env = {
        PORT = cfg.port;
        SEARCH = true;
        ALLOW_REGISTRATION = false;
        MONGO_URI = "mongodb://localhost:${toString aiCfg.mongodb.port}/LibreChat";
        MEILI_HOST = "http://localhost:${toString aiCfg.meilisearch.port}";
      };
      credentialsFile = config.age.secrets.librechat-credentials.path;

      settings = {
        version = "1.3.9";
        cache = true;

        interface = {
          defaultEndpoint = "DeepSeek";
          defaultModel = "deepseek-v4-flash";
          marketplace.use = false;
          modelSelect = false;
          prompts = false;
          parameters = true;
          memories = false;
          presets = true;
          multiConvo = true;
        };

        memory.disabled = true;

        webSearch = {
          searchProvider = "searxng";
          scraperProvider = "firecrawl";
          rerankerType = "jina";
        };

        mcpSettings.allowedDomains = lib.lists.unique (
          lib.mapAttrsToList (name: server:
            let
              url = server.url or "";
              m = builtins.match "([^/]+://[^/]+).*" url;
            in
              if m == null then url else builtins.head m
          ) config.services.librechat.settings.mcpServers
        );
        mcpServers = lib.mkMerge (
          [ aiCfg.mcp.servers ]
          ++ map (name: { ${name}.serverInstructions = true; })
            (builtins.attrNames aiCfg.mcp.servers)
        );

        summarization = {
          provider = "DeepSeek";
          model = "deepseek-v4-flash";
          parameters = {
            max_tokens = 16384;
            maxContextTokens = 1048576;
            reasoning_effort = "high";
          };
          trigger = {
            type = "token_ratio";
            value = 0.8;
          };
          maxSummaryTokens = 16384;
          reserveRatio = 0.1;
          contextPruning = {
            enabled = true;
            keepLastAssistants = 3;
            softTrimRatio = 0.4;
            hardClearRatio = 0.6;
            minPrunableToolChars = 50000;
          };
        };

        modelSpecs = let
          systemPrompt = ''
            You are a helpful assistant.

            Current Date & Time: {{current_datetime}}

            回答风格:
              - 禁用引号，直接引语除外。
              - 禁止形象化替换。降低理解门槛：从已知事实开始，每次只引入一个概念。用更精确的词替换生僻词或语义虚泛的词。
              - 禁止"不是……而是……"等对照、纠偏式句型。直接陈述最终观点，不使用否定铺垫或修辞转折。
              - 不推断缺失事实或预期行为。优先使用可用工具核实信息。
              - 无明确事实错误时，不质疑用户说明，不自行推断可能性。直接按用户要求处理。确有必要补充时，仅在末尾用一句话提示。
              - 用户未明确要求时不展开细节，不强行总结。
              - 用户未明确要求多方案时，给出一个最合适的方案。仅当确有必要时，才简要提及其他可能。
              - 使用简明直接的回答风格。用短句。省略铺垫、重复、总结、客套和过渡语。除非用户明确要求，否则不做任何解释性说明。
              - 调研实现方式时，个人小项目可作为参考。推荐用于长期部署的方案时，仅选择社区广泛认可的开源项目。

            Coding Principles:
              Research & Verification:
                - Use built-in search or MCP to research relevant implementations when needed.
                - Use GitHub MCP as reference when comparing implementations, code structure, or project patterns.
                - Do not infer missing facts or intended behavior. Verify with available tools.

              Structural Principles:
                - Define the problem before changing the code. Fix the root cause, not the symptom.
                - Prioritize correct structure over minimal diffs. Do not preserve bad patterns to avoid touching code.
                - Design with foreseeable extensions in mind. Prefer extensible structures over one-off designs.
                - Allow small adjustments that improve structural consistency. Do not preserve duplication or special cases just to avoid touching more code.

              Coding Style:
                - Keep changes consistent with the project's existing style and conventions.
                - Use a concise, straightforward style. Do not abstract or split simple logic without clear justification.
                - Write comments in English. Do not add comments unless necessary or explicitly requested.
          '';
          deepseekPreset = {
            endpoint = "DeepSeek";
            promptPrefix = systemPrompt;
            reasoning_effort = "xhigh";
            max_tokens = 48000;
            maxContextTokens = 1048576;
          };
        in {
          list = [
            {
              name = "DeepSeek V4 Flash";
              label = "DeepSeek V4 Flash";
              default = true;
              preset = lib.mkMerge [
                deepseekPreset
                { model = "deepseek-v4-flash"; }
              ];
            }
            {
              name = "DeepSeek V4 Pro";
              label = "DeepSeek V4 Pro";
              preset = lib.mkMerge [
                deepseekPreset
                { model = "deepseek-v4-pro"; }
              ];
            }
          ];
        };

        endpoints = {
          all = {
            titleConvo = true;
            titleEndpoint = "DeepSeek";
            titleModel = "deepseek-v4-flash";
          };

          agents = {
            recursionLimit = 80;
            maxRecursionLimit = 200;
            maxCitations = 10;
            maxCitationsPerFile = 5;
            minRelevanceScore = 0.6;
          };

          custom = [
            {
              name = "DeepSeek";
              apiKey = "\${DEEPSEEK_API_KEY}";
              baseURL = "https://api.deepseek.com/v1";
              models = {
                default = [ "deepseek-v4-pro" "deepseek-v4-flash" ];
                fetch = true;
              };
              modelDisplayLabel = "DeepSeek";
              customParams = {
                defaultParamsEndpoint = "custom";
                paramDefinitions = [
                  {
                    key = "max_tokens";
                    type = "number";
                    component = "slider";
                    default = 48000;
                    range = {
                      min = 3000;
                      max = 384000;
                      step = 3000;
                    };
                  }
                  {
                    key = "maxContextTokens";
                    type = "number";
                    component = "slider";
                    default = 1048576;
                    range = {
                      min = 1024;
                      max = 1048576;
                      step = 1024;
                    };
                  }
                ];
              };
            }
            {
              name = "Moonshot";
              apiKey = "\${MOONSHOT_API_KEY}";
              baseURL = "https://api.moonshot.cn/v1";
              models = {
                default = [ "kimi-k2.6" ];
                fetch = true;
              };
              modelDisplayLabel = "Moonshot";
            }
            {
              name = "OpenRouter";
              apiKey = "\${OPENROUTER_KEY}";
              baseURL = "https://openrouter.ai/api/v1";
              models = {
                default = [ "deepseek/deepseek-v4-pro" "deepseek/deepseek-v4-flash" ];
                fetch = false;
              };
              dropParams = [ "stop" ];
              modelDisplayLabel = "OpenRouter";
            }
          ];
        };
      };
    };
  };
}
