# gitline.vim

A collection of functions that provide git related information for displaying on your favorite line.

![gitline example](https://i.imgur.com/yIEUDFJ.png)
_Above configuration for lightline can be found in the example section. Font used for icons is "FuraCode Nerd Font Mono"_

## Installation

#### vim-plug

1. Add the following line to your `init.vim` or `.vimrc`:

```
Plug 'APZelos/gitline.vim'
```

2. Run `:PlugInstall`.

## Configuration

| variable           | type         | default | description                  |
| ------------------ | ------------ | ------- | ---------------------------- |
| g:gitline_enabled  | boolean      | 1       | enables / disables gitline   |
| g:gitline_interval | milliseconds | 1000    | the time between each update |

#### File count

| variable                      | type         | default            | description                          |
| ----------------------------- | ------------ | ------------------ | ------------------------------------ |
| g:gitline_file_count_enabled  | boolean      | 1                  | enables / disables file count        |
| g:gitline_file_count_interval | milliseconds | g:gitline_interval | the time between each update         |
| g:gitline_file_count_prefix   | string       | ""                 | prefix added to the file count value |

### Branch name

| variable                       | type         | default            | description                           |
| ------------------------------ | ------------ | ------------------ | ------------------------------------- |
| g:gitline_branch_name_enabled  | boolean      | 1                  | enables / disables branch name        |
| g:gitline_branch_name_interval | milliseconds | g:gitline_interval | the time between each update          |
| g:gitline_branch_name_prefix   | string       | ""                 | prefix added to the branch name value |

### Fetch status

| variable                        | type         | default            | description                                   |
| ------------------------------- | ------------ | ------------------ | --------------------------------------------- |
| g:gitline_fetch_status_enabled  | boolean      | 1                  | enables / disables fetch status               |
| g:gitline_fetch_status_interval | milliseconds | g:gitline_interval | the time between each update                  |
| g:gitline_ahead_prefix          | string       | "⇡"                | prefix added to the fetch status ahead value  |
| g:gitline_behind_prefix         | string       | "⇣"                | prefix added to the fetch status behind value |

### File status

| variable                        | type    | default | description                    |
| ------------------------------- | ------- | ------- | ------------------------------ |
| g:gitline_file_status_enabled   | boolean | 1       | enables / disables file status |
| g:gitline_file_status_untracked | string  | "U"     | untracked file                 |
| g:gitline_file_status_modified  | string  | "M"     | modified file                  |

## Example

#### Lightline

```
let g:gitline_branch_name_prefix = " "
let g:gitline_file_count_prefix = " "

let g:lightline = {
      \ 'subseparator': { 'left': '', 'right': '' },
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'readonly', 'branchname', 'fetchstatus', 'filecount', 'filename', 'filestatus', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'filecount': 'gitline#FileCount',
      \   'branchname': 'gitline#BranchName',
      \   'filestatus': 'gitline#FileStatus',
      \   'fetchstatus': 'gitline#FetchStatus'
      \ },
      \ }
```

## Author

[APZelos](https://github.com/APZelos)

## License

This software is released under the MIT License.
