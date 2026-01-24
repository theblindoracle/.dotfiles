return {
  'JoosepAlviste/nvim-ts-context-commentstring',
  opts = {},
  config = function()
    require('ts_context_commentstring').setup {
      enable_autocmd = false,
      pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
    }
  end,
}
