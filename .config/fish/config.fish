set -g fish_greeting "Hello!!"


# starship init fish | source

alias ls="li -1"
alias lsa="llai"
alias fishconfig="nvim ~/dotfiles/.config/fish/config.fish"
alias nvimconfig="cd ~/dotfiles/.config/kicknvim/ && nvim ."

set -gx EDITOR nvim
set -gx VISUAL nvim

alias sshfs='/usr/bin/sshfs'
alias fusermount3='/usr/bin/fusermount3'

set -x NVIM_APPNAME minvm

zoxide init --cmd cd fish | source

fish_add_path --move --prepend $HOME/.vite-plus/bin
fish_add_path $HOME/.opencode/bin
fish_add_path $HOME/.local/bin
fish_add_path /usr/local/bin
fish_add_path /snap/bin
fish_add_path $HOME/linuxbrew/.linuxbrew/bin

alias obsidian='/mnt/c/Program\ Files/Obsidian/Obsidian.com'

function ssh-github-agent
    ssh-agent -c | source
    ssh-add ~/.ssh/github/id_key
    ssh-add -l
end

function devpod-generate
    if not command -q gum
        echo "gum is required."
        echo "Install with:"
        echo "  brew install gum"
        return 1
    end

    set repo_url ""
    set provider "kubernetes"
    set workspace_id ""
    set dotfiles_url "https://github.com/zenitramf/dotfiles"
    set dotfiles_script "setup.sh"
    set recreate "false"
    set ide ""
    set branch ""

    function __devpod_slugify --argument-names repo
        set name (string replace -r '/$' '' "$repo")
        set name (string replace -r '^.*[:/]' '' "$name")
        set name (string replace -r '\.git$' '' "$name")
        set name (string lower "$name")
        set name (string replace -ra '[^a-z0-9-]+' '-' "$name")
        set name (string replace -r '^-+' '' "$name")
        set name (string replace -r '-+$' '' "$name")
        echo "$name"
    end

    function __devpod_edit_value --argument-names label current
        gum input \
            --header "$label" \
            --placeholder "$current" \
            --value "$current"
    end

    function __devpod_toggle_bool --argument-names value
        if test "$value" = "true"
            echo "false"
        else
            echo "true"
        end
    end

    function __devpod_components_window
        set shown_repo "not set"
        set shown_workspace "auto"
        set shown_dotfiles "none"
        set shown_dotfiles_script "none"
        set shown_ide "default"
        set shown_branch "default"

        if test -n "$repo_url"
            set shown_repo "$repo_url"
        end

        if test -n "$workspace_id"
            set shown_workspace "$workspace_id"
        end

        if test -n "$dotfiles_url"
            set shown_dotfiles "$dotfiles_url"
        end

        if test -n "$dotfiles_script"
            set shown_dotfiles_script "$dotfiles_script"
        end

        if test -n "$ide"
            set shown_ide "$ide"
        end

        if test -n "$branch"
            set shown_branch "$branch"
        end

        set content "
Repository:      $shown_repo
Provider:        $provider
Workspace ID:    $shown_workspace
Dotfiles URL:    $shown_dotfiles
Dotfiles script: $shown_dotfiles_script
IDE:             $shown_ide
Branch:          $shown_branch
Debug:           true
Recreate:        $recreate
"

        gum style \
            --border rounded \
            --padding "1 2" \
            --margin "1 0" \
            --border-foreground 212 \
            --foreground 255 \
            "$content"
    end

    function __devpod_show_header
        gum style \
            --bold \
            --foreground 212 \
            "Generic DevPod Launcher"

        gum style \
            --foreground 245 \
            "Select or edit components, then run the generated devpod command."

        __devpod_components_window
    end

    function __devpod_build_command
        set -g __devpod_cmd devpod up "$repo_url"

        if test -n "$provider"
            set -a __devpod_cmd --provider "$provider"
        end

        if test -n "$workspace_id"
            set -a __devpod_cmd --id "$workspace_id"
        end

        if test -n "$dotfiles_url"
            set -a __devpod_cmd --dotfiles "$dotfiles_url"
        end

        if test -n "$dotfiles_script"
            set -a __devpod_cmd --dotfiles-script "$dotfiles_script"
        end

        if test -n "$ide"
            set -a __devpod_cmd --ide "$ide"
        end

        if test -n "$branch"
            set -a __devpod_cmd --branch "$branch"
        end

        set -a __devpod_cmd --debug

        if test "$recreate" = "true"
            set -a __devpod_cmd --recreate
        end
    end

    function __devpod_ensure_required_values
        if test -z "$repo_url"
            set repo_url (__devpod_edit_value "Repository URL or path" "")
        end

        if test -z "$workspace_id"; and test -n "$repo_url"
            set workspace_id (__devpod_slugify "$repo_url")
        end
    end

    while true
        clear
        __devpod_show_header

        set action (gum choose \
            --header "Choose an action" \
            "Run devpod up" \
            "Edit repository" \
            "Edit provider" \
            "Edit workspace ID" \
            "Edit dotfiles URL" \
            "Edit dotfiles script" \
            "Edit IDE" \
            "Edit branch" \
            "Toggle recreate" \
            "Show command" \
            "Quit")

        switch "$action"
            case "Run devpod up"
                __devpod_ensure_required_values
                __devpod_build_command

                clear
                __devpod_show_header

                gum style --bold "Generated command:"
                string escape -- $__devpod_cmd
                echo
                echo

                if gum confirm "Run this command?"
                    command $__devpod_cmd
                    return $status
                end

            case "Edit repository"
                set repo_url (__devpod_edit_value "Repository URL or local path" "$repo_url")

                if test -z "$workspace_id"; and test -n "$repo_url"
                    set workspace_id (__devpod_slugify "$repo_url")
                end

            case "Edit provider"
                set provider (gum choose \
                    --header "Provider" \
                    "kubernetes" \
                    "docker" \
                    "ssh" \
                    "custom")

                if test "$provider" = "custom"
                    set provider (__devpod_edit_value "Custom provider" "")
                end

            case "Edit workspace ID"
                set workspace_id (__devpod_edit_value "Workspace ID" "$workspace_id")

            case "Edit dotfiles URL"
                set dotfiles_url (__devpod_edit_value "Dotfiles URL" "$dotfiles_url")

            case "Edit dotfiles script"
                set dotfiles_script (__devpod_edit_value "Dotfiles script" "$dotfiles_script")

            case "Edit IDE"
                set ide (gum choose \
                    --header "IDE" \
                    "default" \
                    "vscode" \
                    "openvscode" \
                    "none" \
                    "custom")

                if test "$ide" = "default"
                    set ide ""
                else if test "$ide" = "custom"
                    set ide (__devpod_edit_value "Custom IDE" "")
                end

            case "Edit branch"
                set branch (__devpod_edit_value "Branch" "$branch")

            case "Toggle recreate"
                set recreate (__devpod_toggle_bool "$recreate")

            case "Show command"
                __devpod_ensure_required_values
                __devpod_build_command

                clear
                __devpod_show_header

                gum style --bold "Generated command:"
                string escape -- $__devpod_cmd
                echo
                gum input --placeholder "Press Enter to continue..." > /dev/null

            case "Quit"
                return 0
        end
    end
end

# Win32Yank
# function win32yank
#     /mnt/c/Users/marti/scoop/shims/win32yank.exe $argv
# end
