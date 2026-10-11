-- Standalone plugins with less than 10 lines of config go here
return {
	{
		-- Tmux & split window navigation
		"christoomey/vim-tmux-navigator",
	},
	{
		-- Detect tabstop and shiftwidth automatically
		"tpope/vim-sleuth",
	},
	{ "nvim-neotest/nvim-nio" },
	{
		-- Powerful Git integration for Vim
		"tpope/vim-fugitive",
	},
	{
		-- GitHub integration for vim-fugitive
		"tpope/vim-rhubarb",
	},
	{
		-- Hints keybinds
		"folke/which-key.nvim",
	},
	{
		-- Autoclose parentheses, brackets, quotes, etc.
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
		opts = {},
	},
	{
		-- Highlight todo, notes, etc in comments
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { signs = false },
	},
	{
		-- High-performance color highlighter
		"norcalli/nvim-colorizer.lua",
		config = function()
			require("colorizer").setup()
		end,
	},
	{
		"b0o/incline.nvim",
		event = "BufReadPre",
		priority = 1200,
		config = function()
			require("incline").setup({
				highlight = {
					-- Same block colours as the statusline, tmux bar and Claude Code row
					groups = {
						InclineNormal = { guibg = "#3c3836", guifg = "#ebdbb2" },
						InclineNormalNC = { guibg = "none", guifg = "#a89984" },
					},
				},
				window = { margin = { vertical = 0, horizontal = 1 } },
				hide = { cursorline = true },
				render = function(props)
					local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
					if vim.bo[props.buf].modified then
						filename = "[*]" .. filename
					end

					local icon, color = require("nvim-web-devicons").get_icon_color(filename)

					return { { icon, guifg = color }, { " " }, { filename } }
				end,
			})
		end,
	},
}
