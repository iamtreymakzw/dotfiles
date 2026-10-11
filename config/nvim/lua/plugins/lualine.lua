return {
	"nvim-lualine/lualine.nvim",
	config = function()
		-- Gruvbox dark hard. Same hex values as ~/.claude/statusline-command.sh and the tmux theme.
		local c = {
			bg0 = "#1d2021",
			bg1 = "#3c3836",
			bg2 = "#504945",
			muted = "#a89984",
			fg = "#ebdbb2",
			fg0 = "#fbf1c7",
			red = "#cc241d",
			green = "#98971a",
			yellow = "#d79921",
			blue = "#458588",
			purple = "#b16286",
			aqua = "#689d6a",
			orange = "#d65d0e",
		}

		-- Accent block, quiet blocks, empty middle: the grammar of the Claude Code row and the tmux bar
		local function mode_theme(accent, on_accent)
			return {
				a = { fg = on_accent, bg = accent, gui = "bold" },
				b = { fg = c.fg, bg = c.bg2 },
				c = { fg = c.muted, bg = c.bg0 },
			}
		end
		local theme = {
			normal = mode_theme(c.blue, c.fg0),
			insert = mode_theme(c.green, c.bg0),
			visual = mode_theme(c.orange, c.bg0),
			replace = mode_theme(c.red, c.fg0),
			command = mode_theme(c.yellow, c.bg0),
			terminal = mode_theme(c.aqua, c.bg0),
			inactive = mode_theme(c.bg1, c.muted),
		}

		local sep = { left = "\u{e0b0}", right = "\u{e0b2}" }

		local mode = {
			"mode",
			fmt = function(str)
				return " " .. str
				-- return ' ' .. str:sub(1, 1) -- displays only the first character of the mode
			end,
		}

		-- Full branch name whenever it fits; shorten it before it can push the file path out
		local branch = {
			"branch",
			fmt = function(name)
				local max = math.max(12, vim.o.columns - 80)
				if #name > max then
					return name:sub(1, max - 1) .. "…"
				end
				return name
			end,
		}

		local filename = {
			"filename",
			file_status = true, -- displays file status (readonly status, modified status)
			path = 1, -- 0 = just filename, 1 = relative path, 2 = absolute path
			shorting_target = 60, -- only abbreviate the path when the bar would otherwise overflow
			color = { fg = c.fg, bg = c.bg1 },
			separator = { right = sep.left },
		}

		local hide_in_width = function()
			return vim.fn.winwidth(0) > 100
		end

		local diagnostics = {
			"diagnostics",
			sources = { "nvim_diagnostic" },
			sections = { "error", "warn" },
			symbols = { error = " ", warn = " ", info = " ", hint = " " },
			colored = false,
			update_in_insert = false,
			always_visible = false,
			cond = hide_in_width,
		}

		local diff = {
			"diff",
			colored = false,
			symbols = { added = " ", modified = " ", removed = " " }, -- changes diff symbols
			cond = hide_in_width,
		}

		require("lualine").setup({
			options = {
				icons_enabled = true,
				theme = theme,
				-- Some useful glyphs:
				-- https://www.nerdfonts.com/cheat-sheet
				--        
				section_separators = sep,
				component_separators = "",
				globalstatus = true, -- one full-width bar, so splits and the tree never clip it
				disabled_filetypes = { "alpha", "neo-tree" },
				always_divide_middle = true,
			},
			sections = {
				lualine_a = { mode },
				lualine_b = { branch },
				lualine_c = { filename },
				lualine_x = {
					diagnostics,
					diff,
					{ "encoding", cond = hide_in_width },
					{ "filetype", cond = hide_in_width },
				},
				lualine_y = { "location" },
				lualine_z = { "progress" },
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = { { "filename", path = 1 } },
				lualine_x = { { "location", padding = 0 } },
				lualine_y = {},
				lualine_z = {},
			},
			tabline = {},
			extensions = { "fugitive" },
		})
	end,
}
