-- Disable vale LSP because it is not compatible with the version of glibc on EWS
lvim.lsp.installer.setup.automatic_installation.exclude = { "vale_ls" }
lvim.lsp.automatic_configuration.skipped_servers = vim.list_extend(
  lvim.lsp.automatic_configuration.skipped_servers or {},
  { "vale_ls" }
)

-- Plugin setup
lvim.plugins = {
  { "rcarriga/nvim-notify" },
  {
    "kevinhwang91/rnvimr",
    config = function()
      vim.g.rnvimr_draw_border = 1
      vim.g.rnvimr_pick_enable = 0
      vim.g.rnvimr_bw_enable = 1
    end,
  },
}
lvim.keys.normal_mode["<leader>r"] = ":RnvimrToggle<CR>"

-- Notification plugin setup, suppress LSP warnings
local notify = require('notify')
vim.notify = function(msg, log_level, opts)
  if type(msg) == "string" and msg:match("Client with id %d+ not attached to buffer %d+") then
    return
  end
  return notify(msg, log_level, opts)
end


-- Buffer settings (allows you to see entire intro paragraph on screen)
vim.opt.wrap = true
vim.opt.linebreak = true

-- Grading State
local grading_state = {
  student_dirs = {},
  current_index = 0,
  mp_number = 0,
  code_filename = "",
}
local grading_notify_id = nil

-- Progress bar function
local function progress_bar(percentage)
  local total_blocks = 30
  local filled = math.floor(total_blocks * (percentage / 100))
  local empty = total_blocks - filled
  return "[" .. string.rep("#", filled) .. string.rep("-", empty) .. "] " .. string.format("%.0f%%", percentage)
end

-- Check if student is graded by inspecting 3rd line from bottom in grade.txt
local function is_student_graded(grade_file)
  local lines = vim.fn.readfile(grade_file)
  if #lines < 3 then return false end
  local target_line = lines[#lines - 2]
  return target_line:match("^Total:%s*%d+")
end

-- Update persistent grading notification with progress bar
local function update_grading_notification(dir)
  local total = #grading_state.student_dirs
  local graded = 0
  for _, dir in ipairs(grading_state.student_dirs) do
    local grade_file = dir .. "/grade.txt"
    if vim.fn.filereadable(grade_file) == 1 and is_student_graded(grade_file) then
      graded = graded + 1
    end
  end
  local percent = (graded / total) * 100
  local bar = progress_bar(percent)

  grading_notify_id = vim.notify(
    "Grading student: " .. dir .. "\n" .. bar,
    vim.log.levels.INFO,
    {
      title = "Grading Progress",
      timeout = false,
      replace = grading_notify_id,
    }
  )
end

-- Start grading session
function StartGrading()
  grading_state.mp_number = vim.fn.input("MP Number: ")
  grading_state.code_filename = vim.fn.input("Code file name (e.g., mp1.c): ")

  grading_state.student_dirs = vim.fn.globpath("/class/ece220/Summer2025/grade", "*/mp" .. grading_state.mp_number, 1, 1)
  table.sort(grading_state.student_dirs)
  grading_state.current_index = 0

  OpenNextStudent()
end

-- Close current buffers safely
function CloseCurrentFiles()
  local current_dir = grading_state.student_dirs[grading_state.current_index]
  if not current_dir then
    return
  end

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local name = vim.api.nvim_buf_get_name(buf)
    if name:find(current_dir, 1, true) then
      if name:match("grade%.txt$") then
        vim.api.nvim_set_current_buf(buf)
        vim.cmd("write")
        vim.cmd("bdelete")
      elseif name:match(grading_state.code_filename .. "$") then
        vim.api.nvim_set_current_buf(buf)
        vim.cmd("bdelete!") -- discard changes
      end
    end
  end
end


-- Open next student or show completion
function OpenNextStudent()
  CloseCurrentFiles()

  while true do
    grading_state.current_index = grading_state.current_index + 1
    local dir = grading_state.student_dirs[grading_state.current_index]

    if dir == nil then
      grading_notify_id = vim.notify(
        "✅ Finished grading MP" .. grading_state.mp_number,
        vim.log.levels.INFO,
        {
          title = "Grading",
          timeout = 3000,
          replace = grading_notify_id,
        }
      )
      return
    end

    local code_file = dir .. "/" .. grading_state.code_filename
    local grade_file = dir .. "/grade.txt"

    if vim.fn.filereadable(code_file) == 0 or vim.fn.filereadable(grade_file) == 0 then
      vim.notify("Skipping: " .. dir, vim.log.levels.INFO, { title = "Grading", timeout = 3000 })
    else
      vim.cmd("silent! edit " .. code_file)
      vim.cmd("silent! vsplit " .. grade_file)

      -- Move cursor to bottom of grade.txt
      vim.cmd("wincmd l")
      vim.cmd("normal! G")
      vim.cmd("wincmd h")

      update_grading_notification(dir)
      return
    end
  end
end

-- Automatically enter Intro / Comments / Calculate Total
function EnterGrades()
  local intro_score = tonumber(vim.fn.input("Intro Paragraph score (0-5): "))
  local comments_score = tonumber(vim.fn.input("Comments & Style score (0-5): "))

  local current_dir = grading_state.student_dirs[grading_state.current_index]
  if not current_dir then
    vim.notify("No current student directory set!", vim.log.levels.ERROR)
    return
  end

  local expected_grade_path = current_dir .. "/grade.txt"

  -- Find buffer matching the current student's grade.txt path exactly
  local grade_buf = nil
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local name = vim.api.nvim_buf_get_name(buf)
    if name == expected_grade_path then
      grade_buf = buf
      break
    end
  end

  if not grade_buf then
    vim.notify("grade.txt buffer for current student not found: " .. expected_grade_path, vim.log.levels.ERROR)
    return
  end

  local lines = vim.api.nvim_buf_get_lines(grade_buf, 0, -1, false)
  local late, func, total_idx, comment_idx, intro_idx = 0, 0, nil, nil, nil

  for idx, line in ipairs(lines) do
    if line:match("^Late submission:") then
      -- Allow trailing spaces after number:
      late = tonumber(line:match("(%d+)%s*$")) or 0
    elseif line:match("^Functionality:") then
      func = tonumber(line:match("(%d+)%s*$")) or 0
    elseif line:match("^Comments and Style:") then
      comment_idx = idx
    elseif line:match("^Intro paragraph:") then
      intro_idx = idx
    elseif line:match("^Total:") then
      total_idx = idx
    end
  end

  if comment_idx then
    lines[comment_idx] = "Comments and Style: " .. comments_score
  end
  if intro_idx then
    lines[intro_idx] = "Intro paragraph: " .. intro_score
  end

  local total = func + comments_score + intro_score - late
  if total < 0 then total = 0 end
  if total_idx then
    lines[total_idx] = "Total: " .. total
  end

  -- Ensure buffer is modifiable
  vim.api.nvim_buf_set_option(grade_buf, "modifiable", true)
  -- Update buffer lines
  vim.api.nvim_buf_set_lines(grade_buf, 0, -1, false, lines)
  -- Mark buffer as modified so user can save if needed
  vim.api.nvim_buf_set_option(grade_buf, "modified", true)
  -- Optionally save buffer immediately:
  -- vim.api.nvim_buf_call(grade_buf, function() vim.cmd("write") end)

  vim.notify("Updated grade.txt: Intro=" .. intro_score .. ", Comments=" .. comments_score .. ", Total=" .. total, vim.log.levels.INFO)
end


-- Keymaps
lvim.keys.normal_mode["<leader>zg"] = ":lua StartGrading()<CR>"
lvim.keys.normal_mode["<leader>zn"] = ":lua OpenNextStudent()<CR>"
lvim.keys.normal_mode["<leader>ze"] = ":lua EnterGrades()<CR>"

