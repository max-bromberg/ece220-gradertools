# ECE 220 Grader Tools
> LunarVim/Neovim config which adds useful grader functions and keybinds for UIUC ECE 220 Course Staff

## Setup & Configuration
Follow [Old Abe's EWS](https://courses.grainger.illinois.edu/ece220/sp2025/pages/resources/old_abes_ews/) instructions to install LunarVim. Once it's installed open LunarVim with `lvim` and press `c` to open the configuration. From here you can paste in some or all of `config.lua` and make changes as needed. You will want to restart LunarVim to install new plugins.
> There are a few places where the grading directory is baked in, maybe one day I will add a semester/year option. Until then, just CTRL+F and change the directories to match the semester you are grading for.

## Usage
`<leader>zg` - Begin a grading session. Prompt will ask for the number for the MP to grade, and the name of the file in each student's repository which you can inspect for intro paragraph and comments.

`<leader>ze` - Enter grade for current student. Prompt will ask for intro paragraph and comments scores, will calculate the total, and modify the open buffer for that student's grade.txt

`<leader>zn` - Move to next student and save grade.txt buffer for current student. Updates grading notification with current progress.

## TODO List
If anyone would like to contribute here are some ideas:
- Add a semester/year config option to easily switch to a different semester
- Store grader state to a cache to resume grading session from where you left off
- Add range option to grade only those students assigned to you
