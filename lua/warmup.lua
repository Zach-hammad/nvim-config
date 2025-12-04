-- ===========================================
-- WARMUP GAME v3
-- Practice your keybindings!
--
-- Commands:
--   :Warmup [count]     - Random challenges
--   :Warmup [category]  - Practice specific category
--   :WarmupStats        - View your progress
--   :WarmupWeak         - Practice your weak spots
--   :WarmupExplain      - Learn keybindings with explanations
--
-- Categories:
--   motions, editing, search, lsp, navigation, tmux, splits,
--   commands, textobjects, registers, marks, macros, plugins
-- ===========================================

local M = {}

-- File to persist stats
local stats_file = vim.fn.stdpath("data") .. "/warmup_stats.json"

-- ===========================================
-- CHALLENGES DATABASE
-- ===========================================
M.all_challenges = {
    -- BASIC VIM MOTIONS
    {
        keys = "w",
        desc = "Move forward one word",
        mode = "n",
        category = "motions",
        before = "hello |world foo bar",
        after  = "hello world |foo bar",
    },
    {
        keys = "b",
        desc = "Move backward one word",
        mode = "n",
        category = "motions",
        before = "hello world |foo bar",
        after  = "hello |world foo bar",
    },
    {
        keys = "e",
        desc = "Move to end of word",
        mode = "n",
        category = "motions",
        before = "|hello world",
        after  = "hell|o world",
    },
    {
        keys = "0",
        desc = "Move to start of line",
        mode = "n",
        category = "motions",
        before = "hello wor|ld",
        after  = "|hello world",
    },
    {
        keys = "$",
        desc = "Move to end of line",
        mode = "n",
        category = "motions",
        before = "|hello world",
        after  = "hello worl|d",
    },
    {
        keys = "gg",
        desc = "Go to first line of file",
        mode = "n",
        category = "motions",
        before = "line 1\nline 2\n|line 3",
        after  = "|line 1\nline 2\nline 3",
    },
    {
        keys = "G",
        desc = "Go to last line of file",
        mode = "n",
        category = "motions",
        before = "|line 1\nline 2\nline 3",
        after  = "line 1\nline 2\n|line 3",
    },
    {
        keys = "f",
        desc = "Find character forward (then type char)",
        mode = "n",
        category = "motions",
        before = "|hello world",
        after  = "hello |world  (after fx)",
    },
    {
        keys = "%",
        desc = "Jump to matching bracket",
        mode = "n",
        category = "motions",
        before = "if |(condition) {",
        after  = "if (condition|) {",
    },

    -- EDITING
    {
        keys = "dd",
        desc = "Delete current line",
        mode = "n",
        category = "editing",
        before = "line 1\n|line 2\nline 3",
        after  = "line 1\n|line 3",
    },
    {
        keys = "yy",
        desc = "Yank (copy) current line",
        mode = "n",
        category = "editing",
        before = "|hello world",
        after  = "|hello world  (line in clipboard)",
    },
    {
        keys = "p",
        desc = "Paste after cursor",
        mode = "n",
        category = "editing",
        before = "|hello  (clipboard: 'world')",
        after  = "hello\n|world",
    },
    {
        keys = "P",
        desc = "Paste before cursor",
        mode = "n",
        category = "editing",
        before = "|hello  (clipboard: 'world')",
        after  = "|world\nhello",
    },
    {
        keys = "u",
        desc = "Undo",
        mode = "n",
        category = "editing",
        before = "(after deleting 'world')",
        after  = "hello |world  (restored)",
    },
    {
        keys = "<C-r>",
        desc = "Redo",
        mode = "n",
        category = "editing",
        before = "(after undo)",
        after  = "(change re-applied)",
        aliases = { "ctrl+r", "ctrl-r", "ctrl r" },
    },
    {
        keys = "ciw",
        desc = "Change inner word",
        mode = "n",
        category = "editing",
        before = "hello |world foo",
        after  = "hello | foo  (INSERT mode)",
    },
    {
        keys = "diw",
        desc = "Delete inner word",
        mode = "n",
        category = "editing",
        before = "hello |world foo",
        after  = "hello | foo",
    },
    {
        keys = "yiw",
        desc = "Yank inner word",
        mode = "n",
        category = "editing",
        before = "hello |world foo",
        after  = "hello |world foo  ('world' in clipboard)",
    },
    {
        keys = "ci\"",
        desc = "Change inside quotes",
        mode = "n",
        category = "editing",
        before = 'name = "|hello world"',
        after  = 'name = "|"  (INSERT mode)',
        aliases = { 'ci"', "ci'", },
    },
    {
        keys = "di{",
        desc = "Delete inside braces",
        mode = "n",
        category = "editing",
        before = "func() { |code here }",
        after  = "func() {|}",
    },
    {
        keys = ">>",
        desc = "Indent line",
        mode = "n",
        category = "editing",
        before = "|hello",
        after  = "    |hello",
    },
    {
        keys = "<<",
        desc = "Unindent line",
        mode = "n",
        category = "editing",
        before = "    |hello",
        after  = "|hello",
    },
    {
        keys = "o",
        desc = "New line below and insert",
        mode = "n",
        category = "editing",
        before = "|line 1\nline 2",
        after  = "line 1\n|\nline 2  (INSERT mode)",
    },
    {
        keys = "O",
        desc = "New line above and insert",
        mode = "n",
        category = "editing",
        before = "line 1\n|line 2",
        after  = "line 1\n|\nline 2  (INSERT mode)",
    },
    {
        keys = "x",
        desc = "Delete character under cursor",
        mode = "n",
        category = "editing",
        before = "hel|lo",
        after  = "hel|o",
    },
    {
        keys = "r",
        desc = "Replace single character",
        mode = "n",
        category = "editing",
        before = "h|ello  (then press 'a')",
        after  = "h|allo",
    },
    {
        keys = ".",
        desc = "Repeat last change",
        mode = "n",
        category = "editing",
        before = "(after doing dd once)",
        after  = "(deletes another line)",
    },
    {
        keys = "J",
        desc = "Join line below to current",
        mode = "n",
        category = "editing",
        before = "|hello\nworld",
        after  = "|hello world",
    },

    -- SEARCH
    {
        keys = "/",
        desc = "Search forward",
        mode = "n",
        category = "search",
        before = "|hello world hello",
        after  = "hello world |hello  (after /hello<CR>)",
    },
    {
        keys = "?",
        desc = "Search backward",
        mode = "n",
        category = "search",
        before = "hello world |hello",
        after  = "|hello world hello  (after ?hello<CR>)",
    },
    {
        keys = "*",
        desc = "Search for word under cursor",
        mode = "n",
        category = "search",
        before = "|hello world hello",
        after  = "hello world |hello  (searched 'hello')",
    },
    {
        keys = "#",
        desc = "Search backward for word under cursor",
        mode = "n",
        category = "search",
        before = "hello world |hello",
        after  = "|hello world hello",
    },
    {
        keys = "n",
        desc = "Next search result",
        mode = "n",
        category = "search",
        before = "|match ... match ... match",
        after  = "match ... |match ... match",
    },
    {
        keys = "N",
        desc = "Previous search result",
        mode = "n",
        category = "search",
        before = "match ... |match ... match",
        after  = "|match ... match ... match",
    },

    -- LSP
    {
        keys = "gd",
        desc = "Go to definition",
        mode = "n",
        category = "lsp",
        before = "my_|func()  # calling function",
        after  = "def |my_func():  # jumped to definition",
    },
    {
        keys = "K",
        desc = "Hover documentation",
        mode = "n",
        category = "lsp",
        before = "print|()",
        after  = "[floating window with docs]",
    },
    {
        keys = "gr",
        desc = "Go to references",
        mode = "n",
        category = "lsp",
        before = "def |my_func():",
        after  = "[list of all places my_func is used]",
    },
    {
        keys = "<Space>rn",
        desc = "Rename symbol",
        mode = "n",
        category = "lsp",
        before = "def |old_name():",
        after  = "[prompt to rename everywhere]",
        aliases = { "space rn", " rn", "leader rn" },
    },
    {
        keys = "<Space>ca",
        desc = "Code actions",
        mode = "n",
        category = "lsp",
        before = "|unused_import",
        after  = "[menu: remove import, etc]",
        aliases = { "space ca", " ca", "leader ca" },
    },
    {
        keys = "<Space>e",
        desc = "Show error in float",
        mode = "n",
        category = "lsp",
        before = "x = 1 + |'string'  # error here",
        after  = "[floating window with error details]",
        aliases = { "space e", " e", "leader e" },
    },
    {
        keys = "[d",
        desc = "Previous diagnostic/error",
        mode = "n",
        category = "lsp",
        before = "error1\n|error2",
        after  = "|error1\nerror2",
    },
    {
        keys = "]d",
        desc = "Next diagnostic/error",
        mode = "n",
        category = "lsp",
        before = "|error1\nerror2",
        after  = "error1\n|error2",
    },

    -- NAVIGATION
    {
        keys = "<C-o>",
        desc = "Jump back (older position)",
        mode = "n",
        category = "navigation",
        before = "(after using gd to jump)",
        after  = "(back to where you were)",
        aliases = { "ctrl+o", "ctrl-o", "ctrl o" },
    },
    {
        keys = "<C-i>",
        desc = "Jump forward (newer position)",
        mode = "n",
        category = "navigation",
        before = "(after jumping back)",
        after  = "(forward to where you jumped to)",
        aliases = { "ctrl+i", "ctrl-i", "ctrl i" },
    },
    {
        keys = "<C-u>",
        desc = "Scroll up half page",
        mode = "n",
        category = "navigation",
        before = "[viewing line 50]",
        after  = "[viewing line 25]",
        aliases = { "ctrl+u", "ctrl-u", "ctrl u" },
    },
    {
        keys = "<C-d>",
        desc = "Scroll down half page",
        mode = "n",
        category = "navigation",
        before = "[viewing line 25]",
        after  = "[viewing line 50]",
        aliases = { "ctrl+d", "ctrl-d", "ctrl d" },
    },
    {
        keys = "zz",
        desc = "Center cursor on screen",
        mode = "n",
        category = "navigation",
        before = "[cursor at top of screen]",
        after  = "[cursor centered on screen]",
    },
    {
        keys = "-",
        desc = "Open file explorer (Oil)",
        mode = "n",
        category = "navigation",
        before = "[editing file.py]",
        after  = "[viewing directory as buffer]",
    },

    -- TMUX
    {
        keys = "<C-h>",
        desc = "Move to left pane (nvim/tmux)",
        mode = "n",
        category = "tmux",
        before = "[cursor in right pane]",
        after  = "[cursor in left pane]",
        aliases = { "ctrl+h", "ctrl-h", "ctrl h" },
    },
    {
        keys = "<C-j>",
        desc = "Move to pane below (nvim/tmux)",
        mode = "n",
        category = "tmux",
        before = "[cursor in top pane]",
        after  = "[cursor in bottom pane]",
        aliases = { "ctrl+j", "ctrl-j", "ctrl j" },
    },
    {
        keys = "<C-k>",
        desc = "Move to pane above (nvim/tmux)",
        mode = "n",
        category = "tmux",
        before = "[cursor in bottom pane]",
        after  = "[cursor in top pane]",
        aliases = { "ctrl+k", "ctrl-k", "ctrl k" },
    },
    {
        keys = "<C-l>",
        desc = "Move to right pane (nvim/tmux)",
        mode = "n",
        category = "tmux",
        before = "[cursor in left pane]",
        after  = "[cursor in right pane]",
        aliases = { "ctrl+l", "ctrl-l", "ctrl l" },
    },

    -- SPLITS
    {
        keys = "<C-w>v",
        desc = "Vertical split",
        mode = "n",
        category = "splits",
        before = "[single window]",
        after  = "[two windows side by side]",
        aliases = { "ctrl+w v", "ctrl-w v" },
    },
    {
        keys = "<C-w>s",
        desc = "Horizontal split",
        mode = "n",
        category = "splits",
        before = "[single window]",
        after  = "[two windows stacked]",
        aliases = { "ctrl+w s", "ctrl-w s" },
    },
    {
        keys = "<C-w>q",
        desc = "Close current split",
        mode = "n",
        category = "splits",
        before = "[two windows]",
        after  = "[one window]",
        aliases = { "ctrl+w q", "ctrl-w q" },
    },
    {
        keys = "<C-w>=",
        desc = "Equal size splits",
        mode = "n",
        category = "splits",
        before = "[uneven splits]",
        after  = "[equal sized splits]",
        aliases = { "ctrl+w =", "ctrl-w =" },
    },
    {
        keys = "<C-w>w",
        desc = "Cycle through windows",
        mode = "n",
        category = "splits",
        before = "[in window 1]",
        after  = "[in window 2]",
        aliases = { "ctrl+w w", "ctrl-w w" },
    },

    -- COMMANDS
    {
        keys = ":w",
        desc = "Save file",
        mode = "n",
        category = "commands",
        before = "[unsaved changes]",
        after  = "[file saved to disk]",
    },
    {
        keys = ":q",
        desc = "Quit",
        mode = "n",
        category = "commands",
        before = "[in neovim]",
        after  = "[back to terminal]",
    },
    {
        keys = ":wq",
        desc = "Save and quit",
        mode = "n",
        category = "commands",
        before = "[unsaved changes]",
        after  = "[saved and quit]",
    },
    {
        keys = "ZZ",
        desc = "Save and quit (shortcut)",
        mode = "n",
        category = "commands",
        before = "[unsaved changes]",
        after  = "[saved and quit]",
    },
    {
        keys = ":e",
        desc = "Open/edit file",
        mode = "n",
        category = "commands",
        before = "[type :e filename]",
        after  = "[opens file]",
    },
    {
        keys = ":vs",
        desc = "Vertical split with file",
        mode = "n",
        category = "commands",
        before = "[type :vs filename]",
        after  = "[split with file]",
    },

    -- TEXT OBJECTS (the real vim superpower)
    {
        keys = "iw",
        desc = "Inner word (no surrounding space)",
        mode = "n",
        category = "textobjects",
        before = "hello |world foo",
        after  = "[selects 'world' only]",
        explanation = "Use with operators: diw, ciw, yiw. The 'inner' version excludes surrounding whitespace.",
    },
    {
        keys = "aw",
        desc = "A word (includes trailing space)",
        mode = "n",
        category = "textobjects",
        before = "hello |world foo",
        after  = "[selects 'world ' with space]",
        explanation = "Use with operators: daw removes word AND space, keeping text clean.",
    },
    {
        keys = "i\"",
        desc = "Inner quotes",
        mode = "n",
        category = "textobjects",
        before = 'name = "|hello"',
        after  = '[selects hello]',
        explanation = "Works with \", ', and `. Cursor can be anywhere between quotes.",
        aliases = { 'i"', "iquote" },
    },
    {
        keys = "a\"",
        desc = "A quoted string (includes quotes)",
        mode = "n",
        category = "textobjects",
        before = 'name = "|hello"',
        after  = '[selects "hello" with quotes]',
        aliases = { 'a"', "aquote" },
    },
    {
        keys = "i(",
        desc = "Inner parentheses",
        mode = "n",
        category = "textobjects",
        before = "func(|arg1, arg2)",
        after  = "[selects arg1, arg2]",
        explanation = "Also works: i), ib. Essential for changing function arguments.",
        aliases = { "i)", "ib" },
    },
    {
        keys = "a(",
        desc = "A parenthesized block",
        mode = "n",
        category = "textobjects",
        before = "func(|arg1, arg2)",
        after  = "[selects (arg1, arg2)]",
        aliases = { "a)", "ab" },
    },
    {
        keys = "i{",
        desc = "Inner braces",
        mode = "n",
        category = "textobjects",
        before = "if true {| code }",
        after  = "[selects code]",
        explanation = "Also: i}, iB. Perfect for deleting/changing function bodies.",
        aliases = { "i}", "iB" },
    },
    {
        keys = "a{",
        desc = "A braced block",
        mode = "n",
        category = "textobjects",
        before = "if true {| code }",
        after  = "[selects { code }]",
        aliases = { "a}", "aB" },
    },
    {
        keys = "ip",
        desc = "Inner paragraph",
        mode = "n",
        category = "textobjects",
        before = "[cursor in middle of paragraph]",
        after  = "[selects paragraph without blanks]",
        explanation = "Paragraphs are separated by blank lines. Great for reformatting.",
    },
    {
        keys = "ap",
        desc = "A paragraph (includes trailing blank)",
        mode = "n",
        category = "textobjects",
        before = "[cursor in paragraph]",
        after  = "[selects paragraph + blank line]",
    },
    {
        keys = "it",
        desc = "Inner tag (HTML/XML)",
        mode = "n",
        category = "textobjects",
        before = "<div>|content</div>",
        after  = "[selects content]",
        explanation = "Works with any HTML/XML tag. cit changes tag content.",
    },
    {
        keys = "at",
        desc = "A tag (includes tags)",
        mode = "n",
        category = "textobjects",
        before = "<div>|content</div>",
        after  = "[selects <div>content</div>]",
    },
    {
        keys = "is",
        desc = "Inner sentence",
        mode = "n",
        category = "textobjects",
        before = "First sentence. |Second one. Third.",
        after  = "[selects Second one.]",
    },

    -- REGISTERS
    {
        keys = "\"ay",
        desc = "Yank into register 'a'",
        mode = "n",
        category = "registers",
        before = "|hello world",
        after  = "[line yanked to register a]",
        explanation = "Named registers a-z store text separately. Uppercase (A-Z) appends.",
        aliases = { '"ay', '"ayy' },
    },
    {
        keys = "\"ap",
        desc = "Paste from register 'a'",
        mode = "n",
        category = "registers",
        before = "[cursor here]",
        after  = "[contents of register a pasted]",
        aliases = { '"ap' },
    },
    {
        keys = "\"0p",
        desc = "Paste last yank (not delete)",
        mode = "n",
        category = "registers",
        before = "[after yy then dd]",
        after  = "[pastes the yy, not the dd]",
        explanation = "Register 0 always has your last yank. Deletions go to \"1-9 and \"\".",
        aliases = { '"0p' },
    },
    {
        keys = "\"_d",
        desc = "Delete to black hole (no register)",
        mode = "n",
        category = "registers",
        before = "hello |world",
        after  = "hello (nothing in any register)",
        explanation = "Black hole register _ discards text. Use when you don't want to overwrite clipboard.",
        aliases = { '"_d', '"_dd' },
    },
    {
        keys = "\"+y",
        desc = "Yank to system clipboard",
        mode = "n",
        category = "registers",
        before = "|hello world",
        after  = "[available for Ctrl+V anywhere]",
        explanation = "Register + is system clipboard. Your config has clipboard=unnamedplus so yy does this automatically.",
        aliases = { '"+y', '"+yy' },
    },
    {
        keys = ":reg",
        desc = "Show all registers",
        mode = "n",
        category = "registers",
        before = "[any state]",
        after  = "[displays all register contents]",
        explanation = "See what's in each register. Useful for debugging clipboard issues.",
    },

    -- MARKS
    {
        keys = "ma",
        desc = "Set mark 'a' at cursor",
        mode = "n",
        category = "marks",
        before = "line 5, col 10",
        after  = "[mark 'a' saved at this position]",
        explanation = "Lowercase marks (a-z) are local to file. Uppercase (A-Z) are global across files.",
    },
    {
        keys = "'a",
        desc = "Jump to line of mark 'a'",
        mode = "n",
        category = "marks",
        before = "[anywhere in file]",
        after  = "[at start of line with mark a]",
        aliases = { "'a" },
    },
    {
        keys = "`a",
        desc = "Jump to exact position of mark 'a'",
        mode = "n",
        category = "marks",
        before = "[anywhere in file]",
        after  = "[exact line AND column of mark a]",
        explanation = "Backtick is more precise - goes to exact column, not just line.",
        aliases = { "`a" },
    },
    {
        keys = "``",
        desc = "Jump to position before last jump",
        mode = "n",
        category = "marks",
        before = "[after using gd or /search]",
        after  = "[back where you were]",
        explanation = "Like Ctrl+O but only for jumps, not general movement.",
    },
    {
        keys = "`.",
        desc = "Jump to last change",
        mode = "n",
        category = "marks",
        before = "[anywhere after editing]",
        after  = "[where you last edited]",
        explanation = "Automatic mark - vim remembers where you made changes.",
    },
    {
        keys = ":marks",
        desc = "Show all marks",
        mode = "n",
        category = "marks",
        before = "[any state]",
        after  = "[displays all marks and positions]",
    },

    -- MACROS
    {
        keys = "qa",
        desc = "Start recording macro into 'a'",
        mode = "n",
        category = "macros",
        before = "[normal mode]",
        after  = "[recording... shown in statusline]",
        explanation = "Everything you type is recorded. Press q again to stop.",
    },
    {
        keys = "q",
        desc = "Stop recording macro",
        mode = "n",
        category = "macros",
        before = "[while recording]",
        after  = "[recording stopped]",
    },
    {
        keys = "@a",
        desc = "Play macro from register 'a'",
        mode = "n",
        category = "macros",
        before = "[after recording macro]",
        after  = "[replays all recorded keys]",
        explanation = "Macros are just text in registers. You can even edit them!",
    },
    {
        keys = "@@",
        desc = "Replay last macro",
        mode = "n",
        category = "macros",
        before = "[after running a macro]",
        after  = "[runs same macro again]",
    },
    {
        keys = "5@a",
        desc = "Run macro 'a' five times",
        mode = "n",
        category = "macros",
        before = "[5 similar lines to process]",
        after  = "[macro applied to all 5]",
        explanation = "Prefix any macro with count. Macro stops early if it hits an error.",
    },

    -- NEW PLUGIN KEYBINDINGS
    -- Telescope
    {
        keys = "<Space>ff",
        desc = "Find files (Telescope)",
        mode = "n",
        category = "plugins",
        before = "[any state]",
        after  = "[fuzzy file finder popup]",
        explanation = "Fuzzy search across all project files. Type partial names.",
        aliases = { "space ff", " ff", "leader ff" },
    },
    {
        keys = "<Space>fg",
        desc = "Live grep (Telescope)",
        mode = "n",
        category = "plugins",
        before = "[any state]",
        after  = "[search file contents]",
        explanation = "Search for text across all files. Requires ripgrep.",
        aliases = { "space fg", " fg", "leader fg" },
    },
    {
        keys = "<Space>fb",
        desc = "Find buffers (Telescope)",
        mode = "n",
        category = "plugins",
        before = "[multiple files open]",
        after  = "[buffer picker popup]",
        aliases = { "space fb", " fb", "leader fb" },
    },
    {
        keys = "<Space>fr",
        desc = "Recent files (Telescope)",
        mode = "n",
        category = "plugins",
        before = "[any state]",
        after  = "[recently opened files]",
        aliases = { "space fr", " fr", "leader fr" },
    },

    -- Leap
    {
        keys = "s",
        desc = "Leap forward (s + 2 chars)",
        mode = "n",
        category = "plugins",
        before = "|hello world foo bar",
        after  = "hello world |foo bar  (after sfo)",
        explanation = "Type s then 2 chars to jump. Shows labels if multiple matches.",
    },
    {
        keys = "S",
        desc = "Leap backward (S + 2 chars)",
        mode = "n",
        category = "plugins",
        before = "hello world foo |bar",
        after  = "|hello world foo bar  (after She)",
    },

    -- Mini.surround
    {
        keys = "sa",
        desc = "Add surrounding",
        mode = "n",
        category = "plugins",
        before = "|hello",
        after  = '"hello"  (after saiw")',
        explanation = "sa + motion + char. saiw\" surrounds word with quotes.",
    },
    {
        keys = "sd",
        desc = "Delete surrounding",
        mode = "n",
        category = "plugins",
        before = '"hello|"',
        after  = "hello  (after sd\")",
        explanation = "sd + char. Removes the surrounding char on both sides.",
    },
    {
        keys = "sr",
        desc = "Replace surrounding",
        mode = "n",
        category = "plugins",
        before = '"hello|"',
        after  = "'hello'  (after sr\"')",
        explanation = "sr + old + new. Changes surrounding from one char to another.",
    },

    -- Trouble
    {
        keys = "<Space>xx",
        desc = "Toggle diagnostics (Trouble)",
        mode = "n",
        category = "plugins",
        before = "[any state]",
        after  = "[diagnostics panel]",
        explanation = "Shows all errors/warnings in a nice list. Much better than :copen.",
        aliases = { "space xx", " xx", "leader xx" },
    },
    {
        keys = "<Space>xd",
        desc = "Buffer diagnostics (Trouble)",
        mode = "n",
        category = "plugins",
        before = "[any state]",
        after  = "[current file errors only]",
        aliases = { "space xd", " xd", "leader xd" },
    },

    -- Gitsigns
    {
        keys = "]h",
        desc = "Next git hunk",
        mode = "n",
        category = "plugins",
        before = "[in git repo]",
        after  = "[cursor on next changed line]",
        explanation = "Jump between changes in the file. Works with gitsigns.",
    },
    {
        keys = "[h",
        desc = "Previous git hunk",
        mode = "n",
        category = "plugins",
        before = "[in git repo]",
        after  = "[cursor on previous changed line]",
    },
    {
        keys = "<Space>gs",
        desc = "Stage git hunk",
        mode = "n",
        category = "plugins",
        before = "[on a changed line]",
        after  = "[change staged for commit]",
        aliases = { "space gs", " gs", "leader gs" },
    },
    {
        keys = "<Space>gr",
        desc = "Reset git hunk",
        mode = "n",
        category = "plugins",
        before = "[on a changed line]",
        after  = "[change reverted]",
        aliases = { "space gr", " gr", "leader gr" },
    },
    {
        keys = "<Space>gp",
        desc = "Preview git hunk",
        mode = "n",
        category = "plugins",
        before = "[on a changed line]",
        after  = "[floating diff of change]",
        aliases = { "space gp", " gp", "leader gp" },
    },
    {
        keys = "<Space>gb",
        desc = "Git blame line",
        mode = "n",
        category = "plugins",
        before = "[on any line]",
        after  = "[shows who wrote this line]",
        aliases = { "space gb", " gb", "leader gb" },
    },

    -- Comment.nvim
    {
        keys = "gcc",
        desc = "Toggle comment on line",
        mode = "n",
        category = "plugins",
        before = "|hello = 'world'",
        after  = "# hello = 'world'",
        explanation = "Toggles comment. Works with any language's comment style.",
    },
    {
        keys = "gc",
        desc = "Toggle comment (motion/visual)",
        mode = "n",
        category = "plugins",
        before = "[select 3 lines in visual]",
        after  = "[all 3 lines commented]",
        explanation = "In normal: gc + motion (gcap = comment paragraph). In visual: gc.",
    },

    -- Escape insert mode
    {
        keys = "jk",
        desc = "Exit insert mode (custom)",
        mode = "i",
        category = "plugins",
        before = "[typing in insert mode]",
        after  = "[back to normal mode]",
        explanation = "Your custom mapping. Faster than reaching for Esc key.",
    },
}

-- ===========================================
-- STATS PERSISTENCE
-- ===========================================
M.stats = {
    total_sessions = 0,
    total_correct = 0,
    total_wrong = 0,
    best_streak = 0,
    challenges_seen = {},  -- { [keys] = { correct = N, wrong = N } }
}

function M.load_stats()
    local f = io.open(stats_file, "r")
    if f then
        local content = f:read("*all")
        f:close()
        local ok, data = pcall(vim.fn.json_decode, content)
        if ok and data then
            M.stats = vim.tbl_deep_extend("force", M.stats, data)
        end
    end
end

function M.save_stats()
    local f = io.open(stats_file, "w")
    if f then
        f:write(vim.fn.json_encode(M.stats))
        f:close()
    end
end

function M.record_result(keys, correct)
    if not M.stats.challenges_seen[keys] then
        M.stats.challenges_seen[keys] = { correct = 0, wrong = 0 }
    end
    if correct then
        M.stats.challenges_seen[keys].correct = M.stats.challenges_seen[keys].correct + 1
        M.stats.total_correct = M.stats.total_correct + 1
    else
        M.stats.challenges_seen[keys].wrong = M.stats.challenges_seen[keys].wrong + 1
        M.stats.total_wrong = M.stats.total_wrong + 1
    end
end

function M.get_weak_challenges()
    local weak = {}
    for _, c in ipairs(M.all_challenges) do
        local s = M.stats.challenges_seen[c.keys]
        if s then
            local total = s.correct + s.wrong
            local ratio = total > 0 and (s.wrong / total) or 0
            if ratio > 0.3 or s.wrong > 2 then
                table.insert(weak, c)
            end
        end
    end
    return weak
end

-- ===========================================
-- GAME STATE
-- ===========================================
M.state = {
    challenges = {},
    current = 1,
    correct = 0,
    wrong = 0,
    streak = 0,
    best_streak = 0,
    start_time = nil,
    buf = nil,
    win = nil,
    missed = {},  -- Track what was missed this session
}

-- ===========================================
-- UTILITIES
-- ===========================================
local function shuffle(tbl)
    local shuffled = {}
    for i, v in ipairs(tbl) do shuffled[i] = v end
    for i = #shuffled, 2, -1 do
        local j = math.random(i)
        shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
    end
    return shuffled
end

local function normalize_answer(str)
    return str:lower()
        :gsub("^%s+", ""):gsub("%s+$", "")  -- trim
        :gsub("ctrl%+", "<c-")
        :gsub("ctrl%-", "<c-")
        :gsub("ctrl ", "<c-")
        :gsub("control%+", "<c-")
        :gsub("control ", "<c-")
        :gsub("<c%-(%w)>?", "<c-%1>")
        :gsub("space%+?", "<space>")
        :gsub("leader%+?", "<space>")
        :gsub(" ", "")  -- remove all spaces after conversions
        :gsub("enter", "<cr>")
        :gsub("return", "<cr>")
end

local function answers_match(input, challenge)
    local norm_input = normalize_answer(input)
    local norm_keys = normalize_answer(challenge.keys)

    if norm_input == norm_keys then return true end

    -- Check aliases
    if challenge.aliases then
        for _, alias in ipairs(challenge.aliases) do
            if norm_input == normalize_answer(alias) then
                return true
            end
        end
    end

    return false
end

local function get_category_list()
    local cats = {}
    for _, c in ipairs(M.all_challenges) do
        cats[c.category] = true
    end
    local list = {}
    for k in pairs(cats) do table.insert(list, k) end
    table.sort(list)
    return list
end

-- ===========================================
-- DISPLAY
-- ===========================================
function M.show_challenge()
    if M.state.current > #M.state.challenges then
        M.show_results()
        return
    end

    local c = M.state.challenges[M.state.current]
    local mode_name = ({ n = "NORMAL", i = "INSERT", v = "VISUAL" })[c.mode] or "NORMAL"

    local streak_display = ""
    if M.state.streak >= 3 then
        streak_display = string.format("  🔥 STREAK: %d", M.state.streak)
    end

    local lines = {
        "",
        "  ╔═══════════════════════════════════════════════════════════════╗",
        "  ║                       WARMUP GAME                             ║",
        "  ╚═══════════════════════════════════════════════════════════════╝",
        "",
        string.format("  Challenge %d / %d     ✓ %d  ✗ %d%s",
            M.state.current, #M.state.challenges,
            M.state.correct, M.state.wrong, streak_display),
        "",
        "  ─────────────────────────────────────────────────────────────────",
        "",
        string.format("  [%s]  %s", mode_name, c.category:upper()),
        "",
        string.format("  TASK: %s", c.desc),
        "",
    }

    if c.before and c.after then
        table.insert(lines, "  ─────────────────────────────────────────────────────────────────")
        table.insert(lines, "")
        table.insert(lines, "  EXAMPLE:  ( | = cursor position )")
        table.insert(lines, "")
        for line in c.before:gmatch("[^\n]+") do
            table.insert(lines, string.format("    BEFORE:  %s", line))
        end
        table.insert(lines, "")
        for line in c.after:gmatch("[^\n]+") do
            table.insert(lines, string.format("    AFTER:   %s", line))
        end
        table.insert(lines, "")
    end

    table.insert(lines, "  ─────────────────────────────────────────────────────────────────")
    table.insert(lines, "")
    table.insert(lines, "  KEY:  <C-x>=Ctrl+x    <Space>=Spacebar    <CR>=Enter")
    table.insert(lines, "")
    table.insert(lines, "  What keys?  [Type '?' if you don't know, 'q' to quit]")
    table.insert(lines, "")

    vim.api.nvim_buf_set_lines(M.state.buf, 0, -1, false, lines)

    vim.defer_fn(function()
        if M.state.win and vim.api.nvim_win_is_valid(M.state.win) then
            vim.api.nvim_set_current_win(M.state.win)
            M.prompt_input()
        end
    end, 200)
end

function M.show_results()
    local elapsed = os.time() - M.state.start_time
    local total = M.state.correct + M.state.wrong
    local percent = total > 0 and math.floor((M.state.correct / total) * 100) or 0

    -- Update best streak
    if M.state.best_streak > M.stats.best_streak then
        M.stats.best_streak = M.state.best_streak
    end
    M.stats.total_sessions = M.stats.total_sessions + 1
    M.save_stats()

    local lines = {
        "",
        "  ╔═══════════════════════════════════════════════════════════════╗",
        "  ║                    WARMUP COMPLETE!                           ║",
        "  ╚═══════════════════════════════════════════════════════════════╝",
        "",
        string.format("  Time: %d seconds", elapsed),
        string.format("  Score: %d / %d (%d%%)", M.state.correct, total, percent),
        string.format("  Best streak this session: %d", M.state.best_streak),
        string.format("  All-time best streak: %d", M.stats.best_streak),
        "",
    }

    if percent == 100 then
        table.insert(lines, "  🏆 PERFECT! You're a vim master!")
    elseif percent >= 80 then
        table.insert(lines, "  🎉 Great job! Keep practicing!")
    elseif percent >= 60 then
        table.insert(lines, "  👍 Good effort! Room to improve.")
    else
        table.insert(lines, "  💪 Keep practicing! You'll get there.")
    end

    -- Show missed challenges
    if #M.state.missed > 0 then
        table.insert(lines, "")
        table.insert(lines, "  ─────────────────────────────────────────────────────────────────")
        table.insert(lines, "")
        table.insert(lines, "  REVIEW - Keys you missed:")
        table.insert(lines, "")
        for _, m in ipairs(M.state.missed) do
            table.insert(lines, string.format("    %-12s  %s", m.keys, m.desc))
        end
    end

    table.insert(lines, "")
    table.insert(lines, "  ─────────────────────────────────────────────────────────────────")
    table.insert(lines, "  Press 'q' to close, 'r' to restart, 'w' to practice weak spots")
    table.insert(lines, "")

    vim.api.nvim_buf_set_lines(M.state.buf, 0, -1, false, lines)

    vim.keymap.set("n", "q", function() M.close() end, { buffer = M.state.buf })
    vim.keymap.set("n", "r", function() M.start() end, { buffer = M.state.buf })
    vim.keymap.set("n", "w", function() M.start_weak() end, { buffer = M.state.buf })
end

function M.show_stats()
    local lines = {
        "",
        "  ╔═══════════════════════════════════════════════════════════════╗",
        "  ║                     YOUR STATS                                ║",
        "  ╚═══════════════════════════════════════════════════════════════╝",
        "",
        string.format("  Total sessions: %d", M.stats.total_sessions),
        string.format("  Total correct: %d", M.stats.total_correct),
        string.format("  Total wrong: %d", M.stats.total_wrong),
        string.format("  Best streak: %d", M.stats.best_streak),
        "",
        "  ─────────────────────────────────────────────────────────────────",
        "",
        "  WEAK AREAS (practice these!):",
        "",
    }

    local weak = M.get_weak_challenges()
    if #weak == 0 then
        table.insert(lines, "    None yet! Keep practicing to find your weak spots.")
    else
        for _, c in ipairs(weak) do
            local s = M.stats.challenges_seen[c.keys]
            table.insert(lines, string.format("    %-12s  %d✓ %d✗  %s",
                c.keys, s.correct, s.wrong, c.desc))
        end
    end

    table.insert(lines, "")
    table.insert(lines, "  Press 'q' to close, 'w' to practice weak spots")
    table.insert(lines, "")

    M.state.buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(M.state.buf, "buftype", "nofile")

    local width = 70
    local height = math.min(#lines + 2, 30)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    M.state.win = vim.api.nvim_open_win(M.state.buf, true, {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        style = "minimal",
        border = "rounded",
    })

    vim.api.nvim_buf_set_lines(M.state.buf, 0, -1, false, lines)

    vim.keymap.set("n", "q", function() M.close() end, { buffer = M.state.buf })
    vim.keymap.set("n", "w", function() M.close(); M.start_weak() end, { buffer = M.state.buf })
end

-- ===========================================
-- INPUT HANDLING
-- ===========================================
function M.prompt_input()
    vim.ui.input({ prompt = "Keys: " }, function(input)
        if input then
            M.check_answer(input)
        end
    end)
end

function M.check_answer(input)
    local c = M.state.challenges[M.state.current]
    input = input:gsub("^%s+", ""):gsub("%s+$", "")

    if input:lower() == "quit" or input:lower() == "q" then
        M.close()
        return
    end

    if input:lower() == "?" or input == "" then
        M.state.wrong = M.state.wrong + 1
        M.state.streak = 0
        M.record_result(c.keys, false)
        table.insert(M.state.missed, c)
        M.force_learn(c)
        return
    end

    if answers_match(input, c) then
        M.state.correct = M.state.correct + 1
        M.state.streak = M.state.streak + 1
        if M.state.streak > M.state.best_streak then
            M.state.best_streak = M.state.streak
        end
        M.record_result(c.keys, true)

        local msg = "✓ Correct!"
        if M.state.streak >= 5 then
            msg = string.format("🔥 %d IN A ROW!", M.state.streak)
        elseif M.state.streak >= 3 then
            msg = "✓ Correct! Keep it going!"
        end
        vim.notify(msg, vim.log.levels.INFO)

        M.state.current = M.state.current + 1
        vim.defer_fn(function()
            if M.state.win and vim.api.nvim_win_is_valid(M.state.win) then
                M.show_challenge()
            end
        end, 500)
    else
        M.state.wrong = M.state.wrong + 1
        M.state.streak = 0
        M.record_result(c.keys, false)
        table.insert(M.state.missed, c)
        M.force_learn(c)
    end
end

function M.force_learn(c)
    local lines = {
        "",
        "  ╔═══════════════════════════════════════════════════════════════╗",
        "  ║                      LEARN IT!                                ║",
        "  ╚═══════════════════════════════════════════════════════════════╝",
        "",
        string.format("  TASK: %s", c.desc),
        "",
        "  ─────────────────────────────────────────────────────────────────",
        "",
        string.format("  THE ANSWER IS:   %s", c.keys),
        "",
    }

    if c.before and c.after then
        table.insert(lines, "  ─────────────────────────────────────────────────────────────────")
        table.insert(lines, "")
        for line in c.before:gmatch("[^\n]+") do
            table.insert(lines, string.format("    BEFORE:  %s", line))
        end
        table.insert(lines, "")
        for line in c.after:gmatch("[^\n]+") do
            table.insert(lines, string.format("    AFTER:   %s", line))
        end
        table.insert(lines, "")
    end

    table.insert(lines, "  ─────────────────────────────────────────────────────────────────")
    table.insert(lines, "")
    table.insert(lines, "  Type it exactly to continue!")
    table.insert(lines, "")

    vim.api.nvim_buf_set_lines(M.state.buf, 0, -1, false, lines)

    vim.defer_fn(function()
        M.prompt_learn(c)
    end, 100)
end

function M.prompt_learn(c)
    vim.ui.input({ prompt = string.format("Type '%s': ", c.keys) }, function(input)
        if not input then
            M.close()
            return
        end

        if answers_match(input, c) then
            vim.notify("✓ Good! Remember: " .. c.keys, vim.log.levels.INFO)
            M.state.current = M.state.current + 1
            vim.defer_fn(function()
                if M.state.win and vim.api.nvim_win_is_valid(M.state.win) then
                    M.show_challenge()
                end
            end, 500)
        else
            vim.notify("✗ Try again! Type exactly: " .. c.keys, vim.log.levels.WARN)
            vim.defer_fn(function()
                if M.state.win and vim.api.nvim_win_is_valid(M.state.win) then
                    M.prompt_learn(c)
                end
            end, 300)
        end
    end)
end

-- ===========================================
-- GAME CONTROL
-- ===========================================
function M.close()
    if M.state.win and vim.api.nvim_win_is_valid(M.state.win) then
        vim.api.nvim_win_close(M.state.win, true)
    end
    if M.state.buf and vim.api.nvim_buf_is_valid(M.state.buf) then
        vim.api.nvim_buf_delete(M.state.buf, { force = true })
    end
    M.state.buf = nil
    M.state.win = nil
end

function M.start(arg)
    M.close()
    M.load_stats()

    -- Parse argument - could be number or category
    local num = tonumber(arg)
    local category = nil

    if not num and arg and arg ~= "" then
        category = arg:lower()
    end

    -- Filter challenges
    local pool = {}
    if category then
        for _, c in ipairs(M.all_challenges) do
            if c.category == category then
                table.insert(pool, c)
            end
        end
        if #pool == 0 then
            vim.notify("Unknown category: " .. category .. "\nAvailable: " .. table.concat(get_category_list(), ", "), vim.log.levels.WARN)
            return
        end
    else
        pool = M.all_challenges
    end

    -- Shuffle and limit
    M.state.challenges = shuffle(pool)
    if num and num > 0 then
        local limited = {}
        for i = 1, math.min(num, #M.state.challenges) do
            limited[i] = M.state.challenges[i]
        end
        M.state.challenges = limited
    end

    -- Reset state
    M.state.current = 1
    M.state.correct = 0
    M.state.wrong = 0
    M.state.streak = 0
    M.state.best_streak = 0
    M.state.start_time = os.time()
    M.state.missed = {}

    -- Create window
    M.state.buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(M.state.buf, "buftype", "nofile")
    vim.api.nvim_buf_set_option(M.state.buf, "bufhidden", "wipe")

    local width = 70
    local height = 28
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    M.state.win = vim.api.nvim_open_win(M.state.buf, true, {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        style = "minimal",
        border = "rounded",
    })

    vim.keymap.set("n", "<CR>", function() M.prompt_input() end, { buffer = M.state.buf })
    vim.keymap.set("n", "q", function() M.close() end, { buffer = M.state.buf })

    M.show_challenge()
end

function M.start_weak()
    M.close()
    M.load_stats()

    local weak = M.get_weak_challenges()
    if #weak == 0 then
        vim.notify("No weak areas found yet! Try :Warmup first to build history.", vim.log.levels.INFO)
        return
    end

    M.state.challenges = shuffle(weak)
    M.state.current = 1
    M.state.correct = 0
    M.state.wrong = 0
    M.state.streak = 0
    M.state.best_streak = 0
    M.state.start_time = os.time()
    M.state.missed = {}

    M.state.buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(M.state.buf, "buftype", "nofile")
    vim.api.nvim_buf_set_option(M.state.buf, "bufhidden", "wipe")

    local width = 70
    local height = 28
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    M.state.win = vim.api.nvim_open_win(M.state.buf, true, {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        style = "minimal",
        border = "rounded",
    })

    vim.keymap.set("n", "<CR>", function() M.prompt_input() end, { buffer = M.state.buf })
    vim.keymap.set("n", "q", function() M.close() end, { buffer = M.state.buf })

    M.show_challenge()
end

-- ===========================================
-- EXPLAIN MODE (browse keybindings by category)
-- ===========================================
M.explain_state = {
    buf = nil,
    win = nil,
    category = nil,
    scroll = 0,
}

function M.show_explain(category)
    if M.explain_state.win and vim.api.nvim_win_is_valid(M.explain_state.win) then
        vim.api.nvim_win_close(M.explain_state.win, true)
    end

    M.explain_state.category = category
    M.explain_state.scroll = 0

    -- Get challenges for category
    local challenges = {}
    if category then
        for _, c in ipairs(M.all_challenges) do
            if c.category == category then
                table.insert(challenges, c)
            end
        end
    else
        challenges = M.all_challenges
    end

    local lines = {
        "",
        "  ╔═══════════════════════════════════════════════════════════════╗",
        "  ║                    KEYBINDING REFERENCE                       ║",
        "  ╚═══════════════════════════════════════════════════════════════╝",
        "",
    }

    if category then
        table.insert(lines, string.format("  Category: %s (%d keybindings)", category:upper(), #challenges))
    else
        table.insert(lines, string.format("  All categories (%d keybindings)", #challenges))
    end
    table.insert(lines, "")
    table.insert(lines, "  ─────────────────────────────────────────────────────────────────")
    table.insert(lines, "")

    -- Group by category if showing all
    local current_cat = nil
    for _, c in ipairs(challenges) do
        if not category and c.category ~= current_cat then
            if current_cat then
                table.insert(lines, "")
            end
            current_cat = c.category
            table.insert(lines, string.format("  ═══ %s ═══", current_cat:upper()))
            table.insert(lines, "")
        end

        table.insert(lines, string.format("  %-14s  %s", c.keys, c.desc))
        if c.explanation then
            table.insert(lines, string.format("                  └─ %s", c.explanation))
        end
        if c.before and c.after then
            table.insert(lines, string.format("                  │  BEFORE: %s", c.before:gsub("\n.*", "...")))
            table.insert(lines, string.format("                  └─ AFTER:  %s", c.after:gsub("\n.*", "...")))
        end
        table.insert(lines, "")
    end

    table.insert(lines, "  ─────────────────────────────────────────────────────────────────")
    table.insert(lines, "  Press 'q' to close | j/k to scroll | number+category to practice")
    table.insert(lines, "")

    M.explain_state.buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(M.explain_state.buf, "buftype", "nofile")

    local width = 75
    local height = math.min(#lines + 2, vim.o.lines - 4)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    M.explain_state.win = vim.api.nvim_open_win(M.explain_state.buf, true, {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        style = "minimal",
        border = "rounded",
    })

    vim.api.nvim_buf_set_lines(M.explain_state.buf, 0, -1, false, lines)

    -- Keybindings for navigation
    vim.keymap.set("n", "q", function()
        if M.explain_state.win and vim.api.nvim_win_is_valid(M.explain_state.win) then
            vim.api.nvim_win_close(M.explain_state.win, true)
        end
    end, { buffer = M.explain_state.buf })

    vim.keymap.set("n", "j", function()
        vim.cmd("normal! j")
    end, { buffer = M.explain_state.buf })

    vim.keymap.set("n", "k", function()
        vim.cmd("normal! k")
    end, { buffer = M.explain_state.buf })

    vim.keymap.set("n", "<C-d>", function()
        vim.cmd("normal! <C-d>")
    end, { buffer = M.explain_state.buf })

    vim.keymap.set("n", "<C-u>", function()
        vim.cmd("normal! <C-u>")
    end, { buffer = M.explain_state.buf })
end

-- ===========================================
-- SETUP
-- ===========================================
function M.setup()
    M.load_stats()

    vim.api.nvim_create_user_command("Warmup", function(opts)
        M.start(opts.args)
    end, {
        nargs = "?",
        complete = function()
            local completions = get_category_list()
            table.insert(completions, 1, "10")
            table.insert(completions, 2, "20")
            return completions
        end
    })

    vim.api.nvim_create_user_command("WarmupStats", function()
        M.show_stats()
    end, {})

    vim.api.nvim_create_user_command("WarmupWeak", function()
        M.start_weak()
    end, {})

    vim.api.nvim_create_user_command("WarmupExplain", function(opts)
        local cat = opts.args ~= "" and opts.args:lower() or nil
        M.show_explain(cat)
    end, {
        nargs = "?",
        complete = function()
            return get_category_list()
        end
    })
end

return M
