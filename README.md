# ece220-gradertools
>>> LunarVim/Neovim config which adds useful grader functions and keybinds for UIUC ECE 220 Course Staff

## Usage
`<leader>zg` - Begin a grading session. Prompt will ask for the number for the MP to grade, and the name of the file in each student's repository which you can expect for intro paragraph and comments.
`<leader>ze` - Enter grade for current student. Prompt will ask for intro paragrapha and comments scores, will calculate the total, and modify the open buffer for that student's grade.txt
`<leader>zn` - Move to next student and save grade.txt buffer for current student. Updates grading notification with current progress.
