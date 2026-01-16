# Neovim configuration with LSP and Treesitter
{ config, pkgs, lib, ... }:

let
  lsp = import ./lsp.nix { inherit pkgs; };
in
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [
      # Theme
      catppuccin-nvim

      # Treesitter
      nvim-treesitter.withAllGrammars

      # LSP
      nvim-lspconfig

      # Diagnostics
      trouble-nvim

      # Completion
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      luasnip
      cmp_luasnip

      # Telescope
      telescope-nvim
      plenary-nvim

      # File tree
      nvim-tree-lua
      nvim-web-devicons

      # Git
      gitsigns-nvim

      # Status line
      lualine-nvim

      # Utilities
      comment-nvim
      nvim-autopairs
      which-key-nvim
      indent-blankline-nvim
    ];

    extraPackages = lsp.servers ++ lsp.tools;

    extraLuaConfig = ''
      -- Basic settings
      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.expandtab = true
      vim.opt.shiftwidth = 2
      vim.opt.tabstop = 2
      vim.opt.smartindent = true
      vim.opt.wrap = false
      vim.opt.cursorline = true
      vim.opt.termguicolors = true
      vim.opt.signcolumn = "yes"
      vim.opt.scrolloff = 8
      vim.opt.updatetime = 50
      vim.opt.colorcolumn = "100"
      vim.opt.ignorecase = true
      vim.opt.smartcase = true
      vim.opt.hlsearch = false
      vim.opt.incsearch = true
      vim.opt.clipboard = "unnamedplus"
      vim.opt.splitright = true
      vim.opt.splitbelow = true
      vim.g.mapleader = " "

      -- Theme
      require("catppuccin").setup({ flavour = "mocha" })
      vim.cmd.colorscheme "catppuccin"

      -- Treesitter (grammars installed via Nix)
      vim.treesitter.language.register("bash", "sh")
      vim.opt.foldmethod = "expr"
      vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
      vim.opt.foldenable = false

      -- LSP
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local servers = { "lua_ls", "nil_ls", "rust_analyzer", "gopls", "pyright", "ts_ls", "html", "cssls", "jsonls" }
      for _, lsp in ipairs(servers) do
        lspconfig[lsp].setup({ capabilities = capabilities })
      end

      -- LSP keymaps
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local opts = { buffer = args.buf }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, opts)
          vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
          vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
        end,
      })

      -- Completion
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })

      -- Telescope
      local telescope = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", telescope.find_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>fg", telescope.live_grep, { desc = "Live grep" })
      vim.keymap.set("n", "<leader>fb", telescope.buffers, { desc = "Buffers" })
      vim.keymap.set("n", "<leader>fh", telescope.help_tags, { desc = "Help" })
      vim.keymap.set("n", "<leader>fr", telescope.oldfiles, { desc = "Recent files" })
      vim.keymap.set("n", "<leader>fs", telescope.lsp_document_symbols, { desc = "Symbols" })

      -- File tree
      require("nvim-tree").setup()
      vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "File tree" })

      -- Git signs
      require("gitsigns").setup()

      -- Lualine
      require("lualine").setup({
        options = { theme = "catppuccin" }
      })

      -- Comment
      require("Comment").setup()

      -- Autopairs
      require("nvim-autopairs").setup()

      -- Which-key
      require("which-key").setup()

      -- Trouble (diagnostics)
      require("trouble").setup()
      vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics" })
      vim.keymap.set("n", "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Buffer diagnostics" })
      vim.keymap.set("n", "<leader>xs", "<cmd>Trouble symbols toggle<cr>", { desc = "Symbols" })
      vim.keymap.set("n", "<leader>xr", "<cmd>Trouble lsp_references toggle<cr>", { desc = "LSP references" })

      -- Indent blankline
      require("ibl").setup()

      -- Basic keymaps
      vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save" })
      vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit" })
      vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down" })
      vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up" })
      vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
      vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })
      vim.keymap.set("n", "<C-h>", "<C-w>h")
      vim.keymap.set("n", "<C-j>", "<C-w>j")
      vim.keymap.set("n", "<C-k>", "<C-w>k")
      vim.keymap.set("n", "<C-l>", "<C-w>l")
    '';
  };
}
