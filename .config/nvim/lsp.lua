vim.lsp.stop_client(vim.lsp.buf_get_clients())

local nvim_lsp = require "nvim_lsp"
local util = require "nvim_lsp/util"

vim.lsp.handlers["textDocument/publishDiagnostics"] =
  vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics,
  {
    virtual_text = false,
    underline = false
  }
)

function vim.lsp.buf.formatting_sync(options, timeout_ms)
  local params = vim.lsp.util.make_formatting_params(options)
  local results = vim.lsp.buf_request_sync(0, "textDocument/formatting", params, timeout_ms)
  if not results or vim.tbl_isempty(results) then
    return
  end
  for _, result in ipairs(results) do
    if result and not vim.tbl_isempty(result) then
      vim.lsp.util.apply_text_edits(result.result)
    end
  end
end

local function set_lsp_config(_)
  vim.api.nvim_command [[setlocal omnifunc=v:lua.vim.lsp.omnifunc]]
  vim.api.nvim_command [[setlocal signcolumn=yes]]
  vim.api.nvim_command [[nnoremap <buffer><silent> K :lua vim.lsp.buf.hover()<CR>]]
  vim.api.nvim_command [[nnoremap <buffer><silent> gd :lua vim.lsp.buf.definition()<CR>]]
  vim.api.nvim_command [[nnoremap <buffer><silent> [d :lua vim.lsp.buf.definition()<CR>]]
  vim.api.nvim_command [[nnoremap <buffer><silent> [<C-d> :lua vim.lsp.buf.definition()<CR>]]
  vim.api.nvim_command [[nnoremap <buffer><silent> <C-w><C-d> :split <bar> lua vim.lsp.buf.definition()<CR>]]
  vim.api.nvim_command [[nnoremap <buffer><silent> [t :lua vim.lsp.buf.type_definition()<CR>]]
  vim.api.nvim_command [[nnoremap <buffer><silent> [<C-t> :lua vim.lsp.buf.type_definition()<CR>]]
  vim.api.nvim_command [[nnoremap <buffer><silent> <C-w><C-t> :lua vim.lsp.buf.type_definition()<CR>]]
  vim.api.nvim_command [[nnoremap <buffer><silent> gr :lua vim.lsp.buf.references()<CR>]]
  vim.api.nvim_command [[nnoremap <buffer><silent> gs :lua vim.lsp.buf.workspace_symbol()<CR>]]
  vim.api.nvim_command [[nnoremap <buffer><silent> gR :lua vim.lsp.buf.rename()<CR>]]
  vim.api.nvim_command [[nnoremap <buffer><silent> <M-CR> :lua vim.lsp.buf.code_action()<CR>]]
  vim.api.nvim_command [[vnoremap <buffer><silent> <M-CR> :lua vim.lsp.buf.range_code_action()<CR>]]
  vim.api.nvim_command [[nnoremap <buffer><silent> <C-space> :lua vim.lsp.diagnostic.show_line_diagnostics()<CR>]]
  vim.api.nvim_command [[nnoremap <buffer><silent> ]g :lua vim.lsp.diagnostic.goto_next()<CR>]]
  vim.api.nvim_command [[nnoremap <buffer><silent> [g :lua vim.lsp.diagnostic.goto_prev()<CR>]]
  vim.api.nvim_command [[nnoremap <buffer><silent> <space>d :lua vim.lsp.diagnostic.set_loclist()<CR>]]
  vim.api.nvim_command [[command! -buffer Fmt lua vim.lsp.buf.formatting_sync(nil, 1000)]]
end

nvim_lsp.pyls.setup {
  on_attach = set_lsp_config,
  settings = {
    pyls = {
      configurationSources = {"flake8"},
      plugins = {
        pycodestyle = {enabled = true},
        pyflakes = {enabled = true},
        yapf = {enabled = false}
      }
    }
  }
}

nvim_lsp.tsserver.setup {
  on_attach = set_lsp_config
}

local efm_settings = {
  version = 2
}

local js_filetypes = {
  "javascript",
  "javascriptreact",
  "javascript.jsx",
  "typescript",
  "typescript.tsx",
  "typescriptreact"
}

local eslint_config = {
  lintCommand = "eslint_d -f unix --stdin --stdin-filename ${INPUT}",
  lintStdin = true,
  lintFormats = {"%f:%l:%c: %m"},
  lintIgnoreExitCode = true,
  formatCommand = "eslint_d --fix-to-stdout --stdin --stdin-filename=${INPUT}",
  formatStdin = true
}

local prettier_config = {
  formatCommand = "prettier --parser typescript",
  formatStdin = true
}

local js_config = vim.fn.glob(".prettierrc*") and {eslint_config, prettier_config} or {eslint_config}

for _, js_filetype in ipairs(js_filetypes) do
  efm_settings[js_filetype] = js_config
end

nvim_lsp.efm.setup {
  on_attach = set_lsp_config,
  default_config = {
    cmd = {
      "efm-langserver"
      -- "-c",
      -- [["$HOME/.config/efm-langserver/config.yaml"]]
    },
    root_dir = vim.fn.getcwd
  },
  settings = efm_settings,
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescript.tsx",
    "typescriptreact"
  }
}
