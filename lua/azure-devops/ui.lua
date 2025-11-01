local M = {}

local api = vim.api
local buf, win

local function center_window(width, height)
  local screen_w = vim.o.columns
  local screen_h = vim.o.lines
  
  local row = math.ceil((screen_h - height) / 2 - 1)
  local col = math.ceil((screen_w - width) / 2)
  
  return row, col
end

function M.create_modal(title, lines)
  local width = 80
  local height = 20
  
  -- Create buffer
  buf = api.nvim_create_buf(false, true)
  api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  api.nvim_buf_set_option(buf, 'filetype', 'azuredevops')
  
  -- Add border
  local border_buf = api.nvim_create_buf(false, true)
  
  local border_lines = { '╔' .. string.rep('═', width) .. '╗' }
  local middle_line = '║' .. string.rep(' ', width) .. '║'
  
  for i = 1, height do
    table.insert(border_lines, middle_line)
  end
  
  table.insert(border_lines, '╚' .. string.rep('═', width) .. '╝')
  
  api.nvim_buf_set_lines(border_buf, 0, -1, false, border_lines)
  
  -- Calculate position
  local row, col = center_window(width, height)
  
  -- Create border window
  local border_opts = {
    style = 'minimal',
    relative = 'editor',
    width = width + 2,
    height = height + 2,
    row = row,
    col = col
  }
  
  local border_win = api.nvim_open_win(border_buf, true, border_opts)
  
  -- Create main window
  local opts = {
    style = 'minimal',
    relative = 'editor',
    width = width,
    height = height,
    row = row + 1,
    col = col + 1
  }
  
  win = api.nvim_open_win(buf, true, opts)
  
  -- Add title if provided
  if title then
    local title_line = '  ' .. title .. '  '
    api.nvim_buf_set_lines(buf, 0, 1, false, { title_line, string.rep('─', width) })
  end
  
  -- Set content
  api.nvim_buf_set_lines(buf, title and 2 or 0, -1, false, lines)
  
  -- Set buffer options
  api.nvim_buf_set_option(buf, 'modifiable', false)
  api.nvim_buf_set_option(buf, 'readonly', true)
  
  -- Set keymaps
  local keymaps = {
    'q',
    '<Esc>',
    '<CR>'
  }
  
  for _, key in ipairs(keymaps) do
    api.nvim_buf_set_keymap(buf, 'n', key, ':lua require("azure-devops.ui").close_modal()<CR>',
      { nowait = true, noremap = true, silent = true })
  end
  
  -- Highlight title
  if title then
    api.nvim_buf_add_highlight(buf, -1, 'Title', 0, 0, -1)
    api.nvim_buf_add_highlight(buf, -1, 'Comment', 1, 0, -1)
  end
end

function M.close_modal()
  if win and api.nvim_win_is_valid(win) then
    api.nvim_win_close(win, true)
  end
  
  if buf and api.nvim_buf_is_valid(buf) then
    api.nvim_buf_delete(buf, { force = true })
  end
end

function M.show_loading(message)
  message = message or 'Loading...'
  M.create_modal('Azure DevOps', { '', '  ' .. message, '' })
end

function M.update_modal_content(title, lines)
  if buf and api.nvim_buf_is_valid(buf) then
    api.nvim_buf_set_option(buf, 'modifiable', true)
    api.nvim_buf_set_lines(buf, 0, -1, false, {})
    
    if title then
      local width = 80
      api.nvim_buf_set_lines(buf, 0, 1, false, { '  ' .. title .. '  ', string.rep('─', width) })
      api.nvim_buf_set_lines(buf, 2, -1, false, lines)
      api.nvim_buf_add_highlight(buf, -1, 'Title', 0, 0, -1)
      api.nvim_buf_add_highlight(buf, -1, 'Comment', 1, 0, -1)
    else
      api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    end
    
    api.nvim_buf_set_option(buf, 'modifiable', false)
  end
end

return M
