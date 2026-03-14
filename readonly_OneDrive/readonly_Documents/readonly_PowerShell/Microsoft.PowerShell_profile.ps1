Import-Module PSReadLine
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows

## Oh-My-Posh
& 'C:\Users\conve\AppData\Local\Programs\oh-my-posh\bin\oh-my-posh.exe' init pwsh --config 'C:\Users\conve\eyco.omp.json' | Invoke-Expression
Set-PSReadLineOption -Colors @{
    Command            = 'Green'
    Number             = 'Cyan'
    Member             = 'Yellow'
    Operator           = 'Red'
    Type               = 'Blue'
    Variable           = 'Magenta'
    Parameter          = 'DarkCyan'
    ContinuationPrompt = 'DarkGray'
    Default            = 'DarkGray'
    String             = 'DarkGreen'
}

## Fzf
# Override default tab completion
Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }

## Zoxide
Invoke-Expression (& 'C:\Users\conve\AppData\Local\Microsoft\WinGet\Packages\ajeetdsouza.zoxide_Microsoft.Winget.Source_8wekyb3d8bbwe\zoxide.exe' init --cmd cd powershell | Out-String)

$env:FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
$env:FZF_DEFAULT_OPTS='
--layout=reverse
--border
--padding=1 
--margin=1
--info=inline
--ansi
--height=80%
--bind ctrl-u:preview-half-page-up
--bind ctrl-d:preview-half-page-down
--bind ctrl-f:preview-page-down
--bind ctrl-b:preview-page-up
--bind ctrl-g:preview-top
--bind ctrl-h:preview-bottom
--bind alt-w:toggle-preview-wrap
--bind ctrl-e:toggle-preview
'
$env:FZF_CTRL_T_COMMAND='fd --type f --hidden --follow --exclude .git'
$env:FZF_CTRL_T_OPTS='
--preview-label="Preview "
--preview-label-pos=1
--preview "bat --color=always --tabs=4 --style=numbers --line-range=:500 {1}"
--preview-window=bottom:border-top'
$env:FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
$env:FZF_ALT_C_OPTS='
--preview-window=right:50%:border-left
--preview "eza --tree --color=always --group-directories-first --git-ignore --icons=always --level=2 {}"'
$env:FZF_CTRL_R_OPTS='
--height=60%
--layout=reverse
--preview-window=0%
'

function fzfd
{
    $selectedItem = fd --type f --follow --hidden --exclude .git --exclude .ignore |
    fzf --prompt 'Files> ' `
        --header-first `
        --height=100% `
        --header 'CTRL-S: Switch between Files/Directories' `
        --multi --bind 'tab:replace-query+backward-delete-char'`
        --bind 'esc:cancel' `
        --bind 'ctrl-s:transform:if not "%FZF_PROMPT%"=="Files> " (echo ^change-prompt^(Files^> ^)^+^reload^(fd --type file^)) else (echo ^change-prompt^(Directory^> ^)^+^reload^(fd --type directory^))' `
        --preview 'if "%FZF_PROMPT%"=="Files> " (bat --color=always --tabs=4 --style=numbers --line-range=:500 {}) else (eza --tree --color=always --group-directories-first --git-ignore --icons=always --level=2 {})'`
        --preview-window=right:60%:border-left
    if ($selectedItem) {
        $selectedItem | Set-Clipboard
        Write-Output "Copied to clipboard: $selectedItem"}
}

function ezt {
    param(
        [Parameter(Position = 0)]
        [int]$Level,

        [Parameter(Position = 1)]
        [string]$Path = "." # Defaults to current directory
    )

    # Base arguments
    $ezaArgs = @(
        "-l", "--tree", "--all", "--icons", "-h", "--git-repos", "--git",
        "--time-style=+%b %d '%y  %l:%M %p", "-o", "--group-directories-first",
        "--ignore-glob=[nN][tT][uU][sS][eE][rR]*", "--no-symlinks"
    )

    # Add level if provided (checks if Level is greater than 0)
    if ($Level -gt 0) {
        $ezaArgs += "--level=$Level"
    }

    # Execute
    eza.exe $Path $ezaArgs
}

function ezg {
    param(
        [string]$Path # path for ls
    )
    eza.exe -l --grid --all --icons -h --git-repos --git --time-style="+%b %d '%y  %l:%M %p" -o --group-directories-first --ignore-glob='[nN][tT][uU][sS][eE][rR]*' --no-symlinks 
}

Set-Alias -Name lg -Value lazygit 
Set-Alias -Name e -Value explorer.exe
Set-Alias -Name c -Value cls
Set-Alias -Name ls -Value eza.exe
Set-Alias -Name ll -Value ezg
Set-Alias -Name lt -Value ezt
fnm env --use-on-cd --shell powershell | Out-String | Invoke-Expression
$env:EDITOR = "code --wait"
