return {
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    opts = {},
    dependencies = { { 'nvim-treesitter/nvim-treesitter', opts = {} } },
    config = function()
      require('nvim-treesitter.configs').setup {
        textobjects = {
          move = {
            enable = true,
            setjumps = true,
            goto_next_start = {
              [']m'] = '@function.outer',
            },
            goto_previous_start = {
              ['[m'] = '@function.outer',
            },
          },
        },
      }
      local ts_repeat_move = require 'nvim-treesitter.textobjects.repeatable_move'

      -- Repeat movement with ; and ,
      -- ensure ; goes forward and , goes backward regardless of the last direction
      vim.keymap.set({ 'n', 'x', 'o' }, ';', function()
        ts_repeat_move.repeat_last_move_next()
      end)
      vim.keymap.set({ 'n', 'x', 'o' }, ',', function()
        ts_repeat_move.repeat_last_move_previous()
      end)
    end,
  },
}
