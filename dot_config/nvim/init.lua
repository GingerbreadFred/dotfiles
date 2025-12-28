vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.have_nerd_font = true

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.mouse = 'a'

vim.schedule(function()
	vim.opt.clipboard = "unnamedplus"
end)

vim.opt.breakindent = true
vim.opt.undofile = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.signcolumn = 'yes'
vim.opt.showmode = false

vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.inccommand = 'split'
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4

vim.opt.wrap = false
vim.opt.exrc = true
vim.opt.secure = true
vim.opt.errorbells = true
vim.opt.belloff = ''

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

vim.keymap.set('n', '<left>', '<cmd>echoerr "Use h to move!!"<CR>')
vim.keymap.set('n', '<right>', '<cmd>echoerr "Use l to move!!"<CR>')
vim.keymap.set('n', '<up>', '<cmd>echoerr "Use k to move!!"<CR>')
vim.keymap.set('n', '<down>', '<cmd>echoerr "Use j to move!!"<CR>')

vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")

vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')

vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- lsp
vim.lsp.enable({ "lua_ls", "rust_analyzer", "clangd" })
vim.keymap.set('n', '<leader>f', vim.lsp.buf.format)

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
	local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
	local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
	if vim.v.shell_error ~= 0 then
		error('Error cloning lazy.nvim:\n' .. out)
	end
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
	{
		'folke/tokyonight.nvim',
		priority = 1000,
		init = function()
			vim.cmd.colorscheme 'tokyonight-night'
			vim.cmd.hi 'Comment gui=none'
		end,
	},
	{
		'mason-org/mason.nvim',
		init = function()
			require('mason').setup()
		end
	},
	{
		'neovim/nvim-lspconfig',
		init = function()
			vim.keymap.set('n', 'gd', require('telescope.builtin').lsp_definitions, { desc = '[G]oto [D]efinition' })
			vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references, { desc = '[G]oto [R]eferences' })
			vim.keymap.set('n', 'gI', require('telescope.builtin').lsp_implementations,
				{ desc = '[G]oto [I]mplementation' })
			vim.keymap.set('n', '<leader>D', require('telescope.builtin').lsp_type_definitions,
				{ desc = 'Type [D]efinition' })
			vim.keymap.set('n', '<leader>sds', function()
				require('telescope.builtin').lsp_document_symbols { symbol_width = 50 }
			end, { desc = '[S]earch [D]ocument [S]ymbols' })
			vim.keymap.set('n', '<leader>sdf', function()
				require('telescope.builtin').lsp_document_symbols { symbol_width = 50, symbols = { 'method', 'function', 'constructor', 'destructor' } }
			end, { desc = '[S]earch [D]ocument [F]unctions' })
			vim.keymap.set('n', '<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols,
				{ desc = '[W]orkspace [S]ymbols' })
			vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = '[R]e[n]ame' })
			vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = '[C]ode [A]ction' })
			vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { desc = '[G]oto [D]eclaration' })
		end
	},
	{
		'stevearc/oil.nvim',
		init = function()
			require('oil').setup()
			vim.keymap.set('n', '-', "<CMD>Oil<CR>")
		end
	},
	{
		'nvim-mini/mini.statusline',
		init = function()
			require('mini.statusline').setup({ use_icons = vim.g.have_nerd_font })
		end
	},
	{
		'nvim-mini/mini.completion',
		init = function()
			require('mini.completion').setup()
		end
	},
	{
		'nvim-telescope/telescope.nvim',
		event = 'VimEnter',
		dependencies = {
			'nvim-lua/plenary.nvim',
			{
				'nvim-telescope/telescope-fzf-native.nvim',
				build = 'make',
				cond = function()
					return vim.fn.executable 'make' == 1
				end,
			},
			{ 'nvim-telescope/telescope-ui-select.nvim' },
			{ 'nvim-tree/nvim-web-devicons',            enabled = vim.g.have_nerd_font },
		},
		config = function()
			require('telescope').setup {
				--
				defaults = {
					layout_strategy = 'vertical',
					initial_mode = 'insert',
				},
				extensions = {
					['ui-select'] = {
						require('telescope.themes').get_dropdown(),
					},
				},
			}

			pcall(require('telescope').load_extension, 'fzf')
			pcall(require('telescope').load_extension, 'ui-select')

			local builtin = require 'telescope.builtin'
			vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
			vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
			vim.keymap.set('n', '<leader>sf', function()
				builtin.find_files {}
			end, { desc = '[S]earch [F]iles' })
			vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
			vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
			vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
			vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
			vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
			vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
			vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

			vim.keymap.set('n', '<leader>/', function()
				builtin.current_buffer_fuzzy_find()
			end, { desc = '[/] Fuzzily search in current buffer' })

			vim.keymap.set('n', '<leader>s/', function()
				builtin.live_grep {
					grep_open_files = true,
					prompt_title = 'Live Grep in Open Files',
				}
			end, { desc = '[S]earch [/] in Open Files' })

			vim.keymap.set('n', '<leader>sn', function()
				builtin.find_files { cwd = vim.fn.stdpath 'config', hidden = true }
			end, { desc = '[S]earch [N]eovim files' })
		end,
	},
})
