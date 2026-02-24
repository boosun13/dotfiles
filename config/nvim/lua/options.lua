-- ============================================
-- Options
-- ============================================

local opt = vim.opt

-- 行番号
opt.number = true
opt.relativenumber = true

-- インデント
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

-- 検索
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- 表示
opt.termguicolors = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false

-- ファイル
opt.swapfile = false
opt.backup = false
opt.undofile = true
opt.undodir = vim.fn.stdpath("data") .. "/undo"

-- 分割
opt.splitright = true
opt.splitbelow = true

-- クリップボード
opt.clipboard = "unnamedplus"

-- その他
opt.mouse = "a"
opt.updatetime = 250
opt.timeoutlen = 300
opt.completeopt = "menuone,noselect"
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"
