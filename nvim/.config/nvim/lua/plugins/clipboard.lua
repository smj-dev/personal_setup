-- Enable OSC52 only if running inside WSL
if vim.fn.has("wsl") == 1 then
  return {
    "ojroques/nvim-osc52",
    config = function()
      require("osc52").setup {
        max_length = 0,
        trim = false,
        silent = false,
        tmux_passthrough = true,
      }

      local function copy()
        if vim.v.event.operator == "y" and vim.v.event.regname == "" then
          require("osc52").copy_register("")
        end
      end

      vim.api.nvim_create_autocmd("TextYankPost", { callback = copy })
    end
  }
else
  return {}
end
