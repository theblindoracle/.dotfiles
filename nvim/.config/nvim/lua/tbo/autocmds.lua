vim.opt.autoread = true
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'VimResume', 'CursorHold' }, {
  pattern = '*',
  command = 'checktime',
})
