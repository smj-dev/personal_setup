-- Setts a themed bottom bar to display info --
return {
    "L3MON4D3/LuaSnip",
    version = "v2.*",  -- Use the latest v2 release
    build = "make install_jsregexp",  -- Install jsregexp dependency
    config = function()
        local luasnip = require("luasnip")

        -- Load snippets from friendly-snippets
        require("luasnip.loaders.from_vscode").lazy_load()

        -- Example key mappings for expanding and jumping through snippets
        vim.keymap.set({"i", "s"}, "<C-K>", function()
            if luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            end
        end, {silent = true})

        vim.keymap.set({"i", "s"}, "<C-J>", function()
            if luasnip.jumpable(-1) then
                luasnip.jump(-1)
            end
        end, {silent = true})

        vim.keymap.set("i", "<C-L>", function()
            if luasnip.choice_active() then
                luasnip.change_choice(1)
            end
        end)
    end,
    dependencies = {
        "rafamadriz/friendly-snippets"  -- Collection of snippets
    }
}
