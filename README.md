![Example image of grader tools in use](https://cdn.blulight.show/raw/XH6BjM.png)
# ECE 220 Grader Tools
> This config creates a grading environment for UIUC ECE 220 Course Staff by adding functions and keybinds to [LunarVim](https://www.lunarvim.org/)/Neovim

## Setup & Configuration
Follow [Old Abe's EWS](https://courses.grainger.illinois.edu/ece220/fa2025/pages/resources/old_abes_ews/) instructions to install Ranger and LunarVim. Once it's installed open LunarVim with `lvim` and press `c` to open the configuration. From here you can paste in some or all of `config.lua` and make changes as needed. You will want to restart LunarVim to install new plugins.

Now, uninstall `vale-ls` as it's not compatible with `glibc` on EWS and will cause many warnings when opening `grade.txt` files; run the following commands in LunarVim:

`:MasonUninstall vale-ls`

`:LspUninstall vale_ls`

> [!NOTE]
> There are one or two places where the grading directory is baked in, maybe one day I will add a semester/year option. Until then, just <kbd>CTRL</kbd>+<kbd>F</kbd> (or <kbd>/</kbd> in Vim) and change the directories to match the semester you are grading for.

## Usage
 - `<leader>zg` - Begin a grading session. Prompt will ask for the number for the MP to grade, and the name of the file in each student's repository which you can inspect for intro paragraph and comments.

 - `<leader>ze` - Enter grade for current student. Prompt will ask for intro paragraph and comments scores, will calculate the total, and modify the open buffer for that student's `grade.txt`

 - `<leader>zn` - Move to next student and save grade.txt buffer for current student. Updates grading notification with current progress.

 - `<leader>r` - Open floating ranger window for manually opening files. If making an edit to a single student, navigate to their MP grade folder, hit `enter` on their code file and `CTRL+V` on their `grade.txt` to open the same side-by-side view as the grader, then manually edit and save grade.txt.


> [!TIP]
> In my instance I set a bookmark to the current semester's grade directory. Navigate there in ranger normally, then press `m` followed by `g` to bind that location to the `g` bookmark. Then, next time you need to open the grade directory to find a specific student, just open ranger by hitting `<leader>r`, then press `'g` to go to the grade directory!

## TODO List
If anyone would like to contribute here are some ideas:
- Add a semester/year config option to easily switch to a different semester
- Store grader state to a cache to resume grading session from where you left off
- Add range option to grade only those students assigned to you
