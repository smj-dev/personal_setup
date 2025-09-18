-- lua/plugins/dap.lua
return {
  {
    "mfussenegger/nvim-dap",
    event = "VeryLazy",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "theHamsta/nvim-dap-virtual-text",
      "jay-babu/mason-nvim-dap.nvim",
      "williamboman/mason.nvim",
    },
    keys = {
      -- load on keypress; nothing loads until you hit these
      {
        "<F5>",
        function()
          require("dap").continue()
        end,
        desc = "DAP Continue/Start",
      },
      {
        "<F10>",
        function()
          require("dap").step_over()
        end,
        desc = "DAP Step Over",
      },
      {
        "<F11>",
        function()
          require("dap").step_into()
        end,
        desc = "DAP Step Into",
      },
      {
        "<S-F11>",
        function()
          require("dap").step_out()
        end,
        desc = "DAP Step Out",
      },
      {
        "<leader>db",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "DAP Toggle Breakpoint",
      },
      {
        "<leader>dB",
        function()
          vim.ui.input({ prompt = "Breakpoint condition: " }, function(cond)
            if cond then
              require("dap").set_breakpoint(cond)
            end
          end)
        end,
        desc = "DAP Conditional Breakpoint",
      },
      {
        "<leader>dl",
        function()
          vim.ui.input({ prompt = "Log point message: " }, function(msg)
            if msg then
              require("dap").set_breakpoint(nil, nil, msg)
            end
          end)
        end,
        desc = "DAP Logpoint",
      },
      {
        "<leader>dr",
        function()
          require("dap").repl.toggle()
        end,
        desc = "DAP REPL",
      },
      {
        "<leader>du",
        function()
          require("dapui").toggle()
        end,
        desc = "DAP UI Toggle",
      },
      {
        "<leader>dx",
        function()
          require("dap").terminate()
        end,
        desc = "DAP Terminate",
      },
    },
    config = function()
      local dap = require("dap")

      -- 1) Comment out/guard VS Code launch loading (this is what reintroduces the JSON error)
      -- Only load if a real, simple launch.json exists (no "inputs" blocks).
      do
        local launch = vim.fn.getcwd() .. "/.vscode/launch.json"
        if vim.fn.filereadable(launch) == 1 then
          -- If your launch.json is clean (no "inputs"), keep this. Otherwise, comment it out.
          -- require("dap.ext.vscode").load_launchjs(launch, {
          --   codelldb = { "c", "cpp", "rust" },
          --   lldb     = { "c", "cpp", "rust" },
          --   cppdbg   = { "c", "cpp" },
          -- })
        end
      end

      -- 2) CodeLLDB adapter via mason (adjust if not using mason)
      local codelldb = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/adapter/codelldb"
      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = { command = codelldb, args = { "--port", "${port}" } },
      }

      -- 3) Cache the last chosen program so you don't retype it
      local function get_cached_program()
        if vim.g.dap_last_program and vim.fn.filereadable(vim.g.dap_last_program) == 1 then
          return vim.g.dap_last_program
        end
        -- sensible default inside your repo
        local default = vim.fn.getcwd() .. "/build/src/main_binary_artefacts/Debug/Standalone/Monophon"
        return default
      end

      local function choose_program()
        local choice = vim.fn.input("Path to executable: ", get_cached_program(), "file")
        if choice ~= nil and choice ~= "" then
          vim.g.dap_last_program = choice
        end
        return choice
      end

      local common = {
        name = "Launch (codelldb)",
        type = "codelldb",
        request = "launch",
        program = choose_program, -- <- prompts once, then reuses cached path
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
      }

      dap.configurations.cpp = { vim.tbl_deep_extend("force", {}, common) }
      dap.configurations.c = dap.configurations.cpp
      dap.configurations.rust = dap.configurations.cpp

      -- 4) Make DAP keys only active in real source files (avoid neo-tree noise)
      local function set_dap_keys(buf)
        local opts = { buffer = buf }
        vim.keymap.set("n", "<F5>", dap.continue, opts)
        vim.keymap.set("n", "<F10>", dap.step_over, opts)
        vim.keymap.set("n", "<F11>", dap.step_into, opts)
        vim.keymap.set("n", "<F12>", dap.step_out, opts)
        vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, opts)
      end

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "c", "cpp", "rust" },
        callback = function(a)
          set_dap_keys(a.buf)
        end,
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "neo-tree",
        callback = function()
          vim.keymap.set("n", "<F5>", function()
            vim.notify("F5 (DAP) is disabled in neo-tree. Focus a source file.", vim.log.levels.WARN)
          end, { buffer = true })
        end,
      })
    end,
  },
}
