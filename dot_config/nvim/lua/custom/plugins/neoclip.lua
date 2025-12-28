return {
  {
    'AckslD/nvim-neoclip.lua',
    opts = {},
    -- Optional dependencies
    dependencies = { { 'nvim-telescope/telescope.nvim' } },
    config = function()
      require('neoclip').setup()
      vim.keymap.set({ 'n' }, '<leader>p', require('telescope').extensions.neoclip.default, { desc = '[P]aste History' })

      local last_clipboard = ''

      local function check_system_clipboard()
        local current_clipboard = vim.fn.getreg '+' -- Get system clipboard content
        local last_yank = vim.fn.getreg '"' -- Compare to the last yank

        if current_clipboard ~= last_clipboard and current_clipboard ~= '' and current_clipboard ~= last_yank then
          require('neoclip.storage').insert({
            regtype = 'l',
            contents = vim.split(current_clipboard, '\n'),
            filetype = vim.bo.filetype,
          }, 'yanks')
          last_clipboard = current_clipboard
        end
      end

      vim.fn.timer_start(1000, function()
        check_system_clipboard()
      end, { ['repeat'] = -1 })
    end,
  },
}
