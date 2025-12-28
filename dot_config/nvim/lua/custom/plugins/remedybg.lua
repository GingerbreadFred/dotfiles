return {
  {

    'GingerbreadFred/remedybg.nvim',
    config = function()
      local remedybg = require 'remedybg'
      remedybg.setup {
        get_debugger_targets = function()
          return Get_Debugger_Targets
        end,
      }

      vim.keymap.set('n', '<leader>db', remedybg.toggle_breakpoint, { desc = '[D]ebug [B]reakpoint' })
      vim.keymap.set('n', '<leader>dc', remedybg.continue_execution, { desc = '[D]ebug [C]ontinue' })
      vim.keymap.set('n', '<leader>di', remedybg.step_into, { desc = '[D]ebug Step [I]nto' })
      vim.keymap.set('n', '<leader>do', remedybg.step_over, { desc = '[D]ebug Step [O]ver' })
      vim.keymap.set('n', '<leader>dO', remedybg.step_out, { desc = '[D]ebug Step [O]ut' })
      -- vim.keymap.set('n', '<leader>ds', remedybg.terminate, { desc = '[D]ebug [S]top' })
      -- vim.keymap.set('n', '<leader>dp', remedybg.pause, { desc = '[D]ebug [P]ause' })
    end,
  },
}
