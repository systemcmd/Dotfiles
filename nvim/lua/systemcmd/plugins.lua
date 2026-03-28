-- lazy.nvim bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local out = vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
  if vim.v.shell_error ~= 0 then
    error("lazy.nvim klonlanamadı:\n" .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

local is_win = vim.fn.has("win32") == 1

require("lazy").setup({

  -- ── Bağımlılıklar ───────────────────────────────────────────────────
  "nvim-lua/plenary.nvim",
  "nvim-tree/nvim-web-devicons",
  "MunifTanjim/nui.nvim",

  -- ── Treesitter ──────────────────────────────────────────────────────
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua", "vim", "vimdoc", "query",
          "javascript", "typescript", "tsx",
          "python", "go", "c", "cpp", "rust",
          "html", "css", "json", "jsonc",
          "yaml", "toml", "markdown", "markdown_inline",
          "bash", "regex", "git_config", "gitcommit", "diff",
        },
        highlight = { enable = true, additional_vim_regex_highlighting = false },
        indent    = { enable = true },
        incremental_selection = {
          enable  = true,
          keymaps = {
            init_selection    = "<C-space>",
            node_incremental  = "<C-space>",
            scope_incremental = false,
            node_decremental  = "<BS>",
          },
        },
      })
    end,
  },

  -- ── Telescope ───────────────────────────────────────────────────────
  {
    "nvim-telescope/telescope.nvim",
    cmd        = "Telescope",
    branch     = "0.1.x",
    dependencies = {
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = is_win
          and "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build"
          or  "make",
        cond = is_win
          and function() return vim.fn.executable("cmake") == 1 end
          or  function() return vim.fn.executable("make")  == 1 end,
      },
    },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>",                desc = "Dosya bul" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>",                 desc = "İçerikte ara" },
      { "<leader>fb", "<cmd>Telescope buffers sort_mru=true<cr>",     desc = "Bufferlar" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>",                  desc = "Son dosyalar" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>",                 desc = "Yardım" },
      { "<leader>fk", "<cmd>Telescope keymaps<cr>",                   desc = "Tuş haritaları" },
      { "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>",      desc = "Semboller" },
      { "<leader>fd", "<cmd>Telescope diagnostics bufnr=0<cr>",       desc = "Tanılar" },
      { "<leader>fc", "<cmd>Telescope commands<cr>",                  desc = "Komutlar" },
      { "<leader>/",  "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Buffer'da ara" },
      { "<leader>gs", "<cmd>Telescope git_status<cr>",                desc = "Git durumu" },
      { "<leader>gc", "<cmd>Telescope git_commits<cr>",               desc = "Git commit'ler" },
    },
    config = function()
      local telescope = require("telescope")
      local actions   = require("telescope.actions")
      telescope.setup({
        defaults = {
          prompt_prefix    = "  Ara: ",
          selection_caret  = " ❯ ",
          entry_prefix     = "   ",
          sorting_strategy = "ascending",
          layout_strategy  = "horizontal",
          layout_config    = {
            horizontal = { prompt_position = "top", preview_width = 0.55 },
            width       = 0.87,
            height      = 0.80,
          },
          borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
          file_ignore_patterns = {
            "node_modules", "%.git/", "dist/", "build/", "__pycache__/",
            "%.lock$", "%.min%.", "%.map$",
          },
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
              ["<Esc>"] = actions.close,
              ["<C-u>"] = false,
            },
          },
        },
        pickers = {
          find_files     = { prompt_title = "Dosya Bul",        results_title = "Dosyalar",       preview_title = "Önizleme" },
          live_grep      = { prompt_title = "İçerik Ara",       results_title = "Eşleşmeler",     preview_title = "Önizleme" },
          buffers        = { prompt_title = "Açık Dosyalar",    results_title = "Bufferlar",      preview_title = "Önizleme" },
          oldfiles       = { prompt_title = "Son Açılan",       results_title = "Dosyalar",       preview_title = "Önizleme" },
          help_tags      = { prompt_title = "Yardım Ara",       results_title = "Konular",        preview_title = "İçerik" },
          keymaps        = { prompt_title = "Tuş Haritaları",   results_title = "Haritalar" },
          commands       = { prompt_title = "Komut Ara",        results_title = "Komutlar" },
          git_status     = { prompt_title = "Git Durumu",       results_title = "Değişiklikler",  preview_title = "Fark" },
          git_commits    = { prompt_title = "Commit Geçmişi",   results_title = "Commit'ler",     preview_title = "Fark" },
          diagnostics    = { prompt_title = "Tanı Ara",         results_title = "Sorunlar",       preview_title = "Bağlam" },
          lsp_document_symbols    = { prompt_title = "Sembol Ara",   results_title = "Semboller",  preview_title = "Önizleme" },
          current_buffer_fuzzy_find = { prompt_title = "Dosyada Ara", results_title = "Sonuçlar", preview_title = "Bağlam" },
        },
      })
      pcall(telescope.load_extension, "fzf")
    end,
  },

  -- ── Neo-tree ────────────────────────────────────────────────────────
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd    = "Neotree",
    keys   = {
      { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Dosya gezgini" },
      { "<leader>E", "<cmd>Neotree reveal<cr>", desc = "Mevcut dosyayı göster" },
    },
    config = function()
      require("neo-tree").setup({
        close_if_last_window = true,
        popup_border_style   = "rounded",
        enable_git_status    = true,
        window = {
          width    = 30,
          mappings = {
            ["<space>"] = "toggle_node",
            ["<cr>"]    = "open",
            ["o"]       = "open",
            ["v"]       = "open_vsplit",
            ["s"]       = "open_split",
            ["t"]       = "open_tabnew",
            ["a"]       = { "add", config = { show_path = "none" } },
            ["A"]       = "add_directory",
            ["d"]       = "delete",
            ["r"]       = "rename",
            ["y"]       = "copy_to_clipboard",
            ["x"]       = "cut_to_clipboard",
            ["p"]       = "paste_from_clipboard",
            ["c"]       = "copy",
            ["m"]       = "move",
            ["q"]       = "close_window",
            ["R"]       = "refresh",
            ["?"]       = "show_help",
          },
        },
        default_component_configs = {
          indent = {
            indent_size        = 2,
            last_indent_marker = "└",
            indent_marker      = "│",
          },
          icon = {
            folder_closed = "",
            folder_open   = "",
            folder_empty  = "󰜌",
          },
          git_status = {
            symbols = {
              added     = " ", -- Eklendi
              modified  = " ", -- Değişti
              deleted   = "✖", -- Silindi
              renamed   = "󰁕", -- Yeniden adlandırıldı
              untracked = "", -- İzlenmiyor
              ignored   = "", -- Yoksayıldı
              staged    = "", -- Staged
              conflict  = "", -- Çakışma
            },
          },
        },
        filesystem = {
          filtered_items = { hide_dotfiles = false, hide_gitignored = true },
          follow_current_file = { enabled = true },
        },
      })
    end,
  },

  -- ── Lualine ─────────────────────────────────────────────────────────
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    config = function()
      local theme = require("systemcmd.theme").lualine_theme()
      require("lualine").setup({
        options = {
          theme                = theme,
          globalstatus         = true,
          component_separators = { left = "", right = "" },
          section_separators   = { left = "", right = "" },
          disabled_filetypes   = { statusline = { "neo-tree", "lazy", "mason" } },
        },
        sections = {
          lualine_a = {
            {
              "mode",
              icon = "",
              fmt = function(str)
                return ({
                  NORMAL       = "NORMAL",
                  INSERT       = "EKLE",
                  VISUAL       = "GÖRSEL",
                  ["V-LINE"]   = "G·SATIR",
                  ["V-BLOCK"]  = "G·BLOK",
                  SELECT       = "SEÇ",
                  ["S-LINE"]   = "S·SATIR",
                  ["S-BLOCK"]  = "S·BLOK",
                  REPLACE      = "DEĞİŞTİR",
                  ["V-REPLACE"]= "G·DEĞİŞ",
                  COMMAND      = "KOMUT",
                  EX           = "EX",
                  TERMINAL     = "TERMİNAL",
                  SHELL        = "KABUK",
                  MORE         = "DEVAM",
                  CONFIRM      = "ONAYLA",
                  ["O-PENDING"]= "BEKLE",
                })[str] or str
              end,
            },
          },
          lualine_b = {
            { "branch", icon = "" },
            { "diff", symbols = { added = " ", modified = " ", removed = " " } },
          },
          lualine_c = {
            { "filename", path = 1, symbols = { modified = " ●", readonly = " ", unnamed = "[Yeni]" } },
          },
          lualine_x = {
            { "diagnostics", symbols = { error = " Hata:", warn = " Uyarı:", info = " Bilgi:", hint = " İpucu:" } },
            { "encoding",    cond = function() return vim.bo.fileencoding ~= "utf-8" end },
            { "filetype", colored = true },
          },
          lualine_y = {
            { "progress", fmt = function(str)
                return str:gsub("Top", "Üst"):gsub("Bot", "Alt")
            end },
          },
          lualine_z = { "location" },
        },
        inactive_sections = {
          lualine_c = { "filename" },
          lualine_x = { "location" },
        },
        extensions = { "neo-tree", "trouble", "lazy", "mason", "quickfix" },
      })
    end,
  },

  -- ── Bufferline ──────────────────────────────────────────────────────
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    keys  = {
      { "<leader>bp", "<cmd>BufferLineTogglePin<cr>",   desc = "Buffer sabitle" },
      { "<leader>bx", "<cmd>BufferLineCloseOthers<cr>", desc = "Diğerlerini kapat" },
      { "<leader>bl", "<cmd>BufferLineCloseLeft<cr>",   desc = "Soldakileri kapat" },
      { "<leader>br", "<cmd>BufferLineCloseRight<cr>",  desc = "Sağdakileri kapat" },
    },
    config = function()
      require("bufferline").setup({
        options = {
          mode            = "buffers",
          separator_style = "slant",
          color_icons     = true,
          diagnostics     = "nvim_lsp",
          diagnostics_indicator = function(count, level)
            local icon = level:match("error") and " " or " "
            return icon .. count
          end,
          name_formatter = function(buf)
            return buf.name
          end,
          tab_size      = 20,
          max_name_length = 18,
          offsets = {{
            filetype  = "neo-tree",
            text      = "  Dosya Gezgini",
            highlight = "Directory",
            separator = true,
          }},
        },
      })
    end,
  },

  -- ── Gitsigns ────────────────────────────────────────────────────────
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("gitsigns").setup({
        signs = {
          add          = { text = "▎" },
          change       = { text = "▎" },
          delete       = { text = "" },
          topdelete    = { text = "" },
          changedelete = { text = "▎" },
          untracked    = { text = "▎" },
        },
        on_attach = function(buf)
          local gs  = package.loaded.gitsigns
          local map = function(m, l, r, desc)
            vim.keymap.set(m, l, r, { buffer = buf, desc = desc })
          end
          map("n", "]h", function() gs.nav_hunk("next") end, "Sonraki hunk")
          map("n", "[h", function() gs.nav_hunk("prev") end, "Önceki hunk")
          map({ "n", "v" }, "<leader>hs", gs.stage_hunk,                               "Hunk'ı staged'e al")
          map({ "n", "v" }, "<leader>hr", gs.reset_hunk,                               "Hunk'ı sıfırla")
          map("n",          "<leader>hS", gs.stage_buffer,                             "Buffer'ı staged'e al")
          map("n",          "<leader>hR", gs.reset_buffer,                             "Buffer'ı sıfırla")
          map("n",          "<leader>hu", gs.undo_stage_hunk,                          "Stage'i geri al")
          map("n",          "<leader>hp", gs.preview_hunk,                             "Hunk önizle")
          map("n",          "<leader>hb", function() gs.blame_line({ full = true }) end, "Satır blame")
          map("n",          "<leader>hd", gs.diffthis,                                 "Diff göster")
          map("n",          "<leader>hB", gs.toggle_current_line_blame,                "Blame aç/kapat")
          map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<cr>",                   "Hunk nesnesi")
        end,
      })
    end,
  },

  -- ── Indent blankline ────────────────────────────────────────────────
  {
    "lukas-reineke/indent-blankline.nvim",
    main  = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("ibl").setup({
        indent  = { char = "│", tab_char = "│" },
        scope   = { show_start = false, show_end = false },
        exclude = {
          filetypes = { "help", "neo-tree", "lazy", "mason", "notify", "dashboard" },
        },
      })
    end,
  },

  -- ── Which-key ───────────────────────────────────────────────────────
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      local wk = require("which-key")
      wk.setup({
        preset = "modern",
        delay  = 400,
        icons  = { separator = "→" },
        win    = { border = "rounded" },
      })
      wk.add({
        { "<leader>f",  group = "Bul / Telescope" },
        { "<leader>g",  group = "Git" },
        { "<leader>h",  group = "Git hunk" },
        { "<leader>b",  group = "Buffer" },
        { "<leader>c",  group = "Kod / LSP" },
        { "<leader>x",  group = "Sorun listesi" },
        { "<leader>?",  desc  = "Türkçe yardım" },
        { "<F1>",       desc  = "Türkçe yardım" },
      })
    end,
  },

  -- ── Flash (hızlı gezinti) ────────────────────────────────────────────
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    keys  = {
      { "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash git" },
      { "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
      { "r",     mode = "o",               function() require("flash").remote() end,             desc = "Remote Flash" },
      { "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter ara" },
    },
  },

  -- ── Autopairs ───────────────────────────────────────────────────────
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({
        check_ts  = true,
        ts_config = { lua = { "string" }, javascript = { "template_string" } },
      })
      local cmp_ok, cmp = pcall(require, "cmp")
      if cmp_ok then
        local handler = require("nvim-autopairs.completion.cmp")
        cmp.event:on("confirm_done", handler.on_confirm_done())
      end
    end,
  },

  -- ── Surround (ysa, yss, ds, cs) ─────────────────────────────────────
  {
    "kylechui/nvim-surround",
    event  = "VeryLazy",
    config = function()
      require("nvim-surround").setup()
    end,
  },

  -- ── Comment (gcc / gc) ──────────────────────────────────────────────
  {
    "numToStr/Comment.nvim",
    event  = { "BufReadPost", "BufNewFile" },
    config = function()
      require("Comment").setup({
        toggler  = { line = "gcc", block = "gbc" },
        opleader = { line = "gc",  block = "gb" },
      })
    end,
  },

  -- ── Todo-comments ───────────────────────────────────────────────────
  {
    "folke/todo-comments.nvim",
    cmd   = { "TodoTrouble", "TodoTelescope" },
    event = { "BufReadPost", "BufNewFile" },
    keys  = {
      { "]t",         function() require("todo-comments").jump_next() end, desc = "Sonraki TODO" },
      { "[t",         function() require("todo-comments").jump_prev() end, desc = "Önceki TODO" },
      { "<leader>ft", "<cmd>TodoTelescope<cr>",                            desc = "TODO'ları bul" },
    },
    config = function()
      require("todo-comments").setup({ signs = true })
    end,
  },

  -- ── Trouble ─────────────────────────────────────────────────────────
  {
    "folke/trouble.nvim",
    cmd  = "Trouble",
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",              desc = "Tanılar" },
      { "<leader>xb", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer tanıları" },
      { "<leader>xL", "<cmd>Trouble loclist toggle<cr>",                  desc = "Konum listesi" },
      { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>",                   desc = "Quickfix" },
      { "<leader>xs", "<cmd>Trouble symbols toggle<cr>",                  desc = "Semboller" },
    },
    config = function()
      require("trouble").setup({
        use_diagnostic_signs = true,
        modes = {
          diagnostics = { title = "Tanılar" },
          symbols     = { title = "Semboller" },
          lsp         = { title = "LSP" },
          loclist     = { title = "Konum Listesi" },
          qflist      = { title = "Quickfix Listesi" },
        },
      })
    end,
  },

  -- ── Fidget (LSP ilerleme) ────────────────────────────────────────────
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    config = function()
      require("fidget").setup({
        progress = {
          display = {
            progress_icon = { pattern = "dots", period = 1 },
            done_icon     = "✓",
            done_style    = "Constant",
          },
        },
        notification = {
          window  = { winblend = 0 },
          -- LSP ilerleme mesajları Türkçe
          override_vim_notify = false,
        },
      })
    end,
  },

  -- ── Mason ───────────────────────────────────────────────────────────
  {
    "williamboman/mason.nvim",
    cmd    = "Mason",
    config = function()
      require("mason").setup({
        ui = {
          border  = "rounded",
          icons   = {
            package_installed   = "✓",
            package_pending     = "➜",
            package_uninstalled = "✗",
          },
          keymaps = {
            toggle_help          = "?",
            toggle_package_expand = "<CR>",
            install_package      = "i",
            update_package       = "u",
            check_package_version = "c",
            update_all_packages  = "U",
            check_outdated_packages = "C",
            uninstall_package    = "X",
            cancel_installation  = "<C-c>",
          },
          -- Başlıklar Türkçe
          headings = {
            lsp       = "Dil Sunucuları",
            dap       = "Hata Ayıklayıcılar",
            formatter = "Formatleyiciler",
            linter    = "Kod Denetleyiciler",
          },
        },
      })
    end,
  },

  -- ── Mason-lspconfig ─────────────────────────────────────────────────
  {
    "williamboman/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    config = function()
      local ensure = {
        "lua_ls", "ts_ls", "pyright",
        "html", "cssls", "jsonls", "marksman",
      }
      if is_win then
        table.insert(ensure, "powershell_es")
      end
      require("mason-lspconfig").setup({
        ensure_installed    = ensure,
        automatic_installation = true,
      })
    end,
  },

  -- ── LSP ─────────────────────────────────────────────────────────────
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "hrsh7th/cmp-nvim-lsp" },
    config = function()
      local lsp  = require("lspconfig")
      local caps = require("cmp_nvim_lsp").default_capabilities()

      -- Tanılama ayarları
      vim.diagnostic.config({
        underline        = true,
        update_in_insert = false,
        virtual_text     = { spacing = 4, source = "if_many", prefix = "●" },
        severity_sort    = true,
        float            = { border = "rounded", source = "always" },
      })

      -- On attach: her LSP bağlandığında tuş haritaları kur
      local on_attach = function(_, buf)
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
        end
        map("n", "gd",  vim.lsp.buf.definition,     "Tanıma git")
        map("n", "gD",  vim.lsp.buf.declaration,    "Bildirimine git")
        map("n", "gr",  vim.lsp.buf.references,     "Referanslar")
        map("n", "gI",  vim.lsp.buf.implementation, "Uygulama")
        map("n", "gy",  vim.lsp.buf.type_definition,"Tür tanımı")
        map("n", "K",   vim.lsp.buf.hover,          "Belge (hover)")
        map("n", "gK",  vim.lsp.buf.signature_help, "İmza yardımı")
        map("i", "<C-k>", vim.lsp.buf.signature_help, "İmza yardımı")
        map("n", "<leader>rn", vim.lsp.buf.rename,              "Yeniden adlandır")
        map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Kod aksiyonu")
        map("n", "<leader>cf", function()
          vim.lsp.buf.format({ async = true })
        end, "LSP ile formatla")
      end

      -- Sunucu konfigürasyonları
      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              runtime   = { version = "LuaJIT" },
              workspace = {
                checkThirdParty = false,
                library = { vim.env.VIMRUNTIME, "${3rd}/luv/library" },
              },
              diagnostics = { globals = { "vim" } },
              completion  = { callSnippet = "Replace" },
              hint        = { enable = true },
              telemetry   = { enable = false },
            },
          },
        },
        ts_ls = {
          settings = {
            typescript   = { inlayHints = { includeInlayParameterNameHints = "all" } },
            javascript   = { inlayHints = { includeInlayParameterNameHints = "all" } },
          },
        },
        pyright = {
          settings = {
            python = { analysis = { typeCheckingMode = "basic", autoImportCompletions = true } },
          },
        },
        html         = { filetypes = { "html", "twig", "hbs" } },
        cssls        = {},
        jsonls       = {},
        marksman     = {},
      }

      if is_win then
        servers["powershell_es"] = {}
      end

      for name, cfg in pairs(servers) do
        cfg.capabilities = caps
        cfg.on_attach    = on_attach
        lsp[name].setup(cfg)
      end
    end,
  },

  -- ── Tamamlama (nvim-cmp) ────────────────────────────────────────────
  {
    "hrsh7th/nvim-cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-nvim-lua",
      {
        "L3MON4D3/LuaSnip",
        version  = "v2.*",
        build    = is_win and "" or "make install_jsregexp",
        dependencies = { "rafamadriz/friendly-snippets" },
        config   = function()
          require("luasnip.loaders.from_vscode").lazy_load()
        end,
      },
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp     = require("cmp")
      local luasnip = require("luasnip")

      local kind_icons = {
        Text          = "󰉿", Method    = "󰆧", Function    = "󰊕",
        Constructor   = "",  Field     = "󰜢", Variable    = "󰀫",
        Class         = "󰠱", Interface = "",  Module      = "",
        Property      = "󰜢", Unit      = "󰑭", Value       = "󰎠",
        Enum          = "",  Keyword   = "󰌋", Snippet     = "",
        Color         = "󰏘", File      = "󰈙", Reference   = "󰈇",
        Folder        = "󰉋", EnumMember= "",  Constant    = "󰏿",
        Struct        = "󰙅", Event     = "",  Operator    = "󰆕",
        TypeParameter = "",
      }

      cmp.setup({
        snippet  = { expand = function(a) luasnip.lsp_expand(a.body) end },
        completion = { completeopt = "menu,menuone,noinsert" },
        window = {
          completion    = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"]     = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-p>"]     = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-b>"]     = cmp.mapping.scroll_docs(-4),
          ["<C-f>"]     = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"]     = cmp.mapping.abort(),
          ["<CR>"]      = cmp.mapping.confirm({ select = false }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 1000 },
          { name = "luasnip",  priority = 750  },
          { name = "nvim_lua", priority = 500  },
          { name = "buffer",   priority = 250, keyword_length = 3 },
          { name = "path",     priority = 200  },
        }),
        formatting = {
          fields = { "kind", "abbr", "menu" },
          format = function(_, item)
            local icon = kind_icons[item.kind]
            if icon then
              item.kind = icon .. " " .. item.kind
            end
            if #item.abbr > 40 then
              item.abbr = item.abbr:sub(1, 40) .. "…"
            end
            return item
          end,
        },
        experimental = {
          ghost_text = { hl_group = "Comment" },
        },
      })

      -- Komut satırı tamamlama
      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = { { name = "buffer" } },
      })
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
        matching = { disallow_symbol_nonprefix_matching = false },
      })
    end,
  },

  -- ── Conform (otomatik formatlama) ────────────────────────────────────
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd   = "ConformInfo",
    keys  = {
      {
        "<leader>cf",
        function() require("conform").format({ async = true, lsp_fallback = true }) end,
        desc = "Dosyayı formatla",
      },
    },
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          lua              = { "stylua" },
          python           = { "ruff_format", "black" },
          javascript       = { "prettier" },
          typescript       = { "prettier" },
          javascriptreact  = { "prettier" },
          typescriptreact  = { "prettier" },
          css              = { "prettier" },
          html             = { "prettier" },
          json             = { "prettier" },
          jsonc            = { "prettier" },
          yaml             = { "prettier" },
          markdown         = { "prettier" },
        },
        format_on_save = { lsp_fallback = true, timeout_ms = 500 },
      })
    end,
  },

}, {
  ui = {
    border = "rounded",
    icons  = {
      cmd     = " ", config  = "", event  = "",
      ft      = " ", init    = " ", keys   = " ",
      plugin  = " ", runtime = " ", source = " ",
      start   = " ", task    = "✔ ", require = "󰢱 ",
    },
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip", "matchit", "matchparen", "netrwPlugin",
        "tarPlugin", "tohtml", "tutor", "zipPlugin",
      },
    },
  },
  checker          = { enabled = false },
  change_detection = { notify  = false },
})
