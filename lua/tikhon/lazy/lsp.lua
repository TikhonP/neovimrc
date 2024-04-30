local pylsp_settings = {
    pylsp = {
        plugins = {
            pycodestyle = {
                -- ignore = { 'W391' },
                maxLineLength = 100
            },
        },
    },
}

local lua_ls_settings = {
    Lua = {
        runtime = {
            version = 'LuaJIT'
        },
        diagnostics = {
            globals = { "vim", "it", "describe", "before_each", "after_each" },
        },
        workspace = {
            library = {
                vim.env.VIMRUNTIME,
            }
        }
    },
}

return {

    "neovim/nvim-lspconfig",

    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/nvim-cmp",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "j-hui/fidget.nvim",
    },

    config = function()
        local cmp_lsp = require("cmp_nvim_lsp")
        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_lsp.default_capabilities())

        local default_setup = function(server)
            require("lspconfig")[server].setup({
                capabilities = capabilities,
            })
        end

        require("fidget").setup({})
        require("mason").setup({})
        require("mason-lspconfig").setup({
            ensure_installed = {
                "lua_ls",
                "gopls",
                "templ",
                "html",
                "tailwindcss",
                "pylsp",
                "tsserver",
                "bashls",
            },
            handlers = {
                default_setup,
                pylsp = function()
                    require("lspconfig").pylsp.setup({
                        capabilities = capabilities,
                        settings = pylsp_settings,
                    })
                end,
                lua_ls = function()
                    require("lspconfig").lua_ls.setup({
                        capabilities = capabilities,
                        settings = lua_ls_settings,
                    })
                end,
                html = function()
                    require("lspconfig").html.setup({
                        capabilities = capabilities,
                        filetypes = { "html", "templ" },
                    })
                end,
                tailwindcss = function()
                    require("lspconfig").tailwindcss.setup({
                        capabilities = capabilities,
                        filetypes = { "templ", "astro", "javascript", "typescript", "react" },
                        init_options = { userLanguages = { templ = "html" } },
                    })
                end
            }
        })

        require("lspconfig")["sourcekit"].setup({
            -- cmd = { "sourcekit-lsp", "--log-level", "info" },
            capabilities = capabilities,
        })

        local cmp = require("cmp")
        local cmp_select = { behavior = cmp.SelectBehavior.Select }
        cmp.setup({
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body)
                end,
            },
            sources = {
                { name = "path" },
                { name = "nvim_lsp" },
                { name = "luasnip", keyword_length = 2 },
                { name = "buffer",  keyword_length = 3 },
            },
            window = {
                completion = cmp.config.window.bordered(),
                documentation = cmp.config.window.bordered(),
            },
            mapping = cmp.mapping.preset.insert({
                ["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
                ["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
                ["<C-y>"] = cmp.mapping.confirm({ select = true }),
            }),
        })

        vim.keymap.set("n", "<leader>vlr", "<cmd>LspRestart<CR>", { desc = "[V]im [L]sp [R]estart" })

        vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
            border = "rounded",
        })
        vim.diagnostic.config {
            float = { border = "rounded" },
        }
    end,
}
