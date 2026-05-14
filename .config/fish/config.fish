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

    if not command -q devpod
        echo "devpod is required."
        return 1
    end

    # Temporary function state.
    set -g __devpod_repo_url ""
    set -g __devpod_git_ref ""
    set -g __devpod_provider "kubernetes"
    set -g __devpod_workspace_id ""
    set -g __devpod_dotfiles_url "https://github.com/zenitramf/dotfiles"
    set -g __devpod_dotfiles_script "setup.sh"
    set -g __devpod_ide ""
    set -g __devpod_devcontainer_path ""
    set -g __devpod_fallback_image ""
    set -g __devpod_recreate "false"
    set -g __devpod_reset "false"
    set -g __devpod_open_ide "false"
    set -g __devpod_configure_ssh "true"

    function __devpod_cleanup
        functions -e __devpod_cleanup
        functions -e __devpod_slugify
        functions -e __devpod_edit_value
        functions -e __devpod_toggle_bool
        functions -e __devpod_workspace_target
        functions -e __devpod_components_window
        functions -e __devpod_divider
        functions -e __devpod_show_header
        functions -e __devpod_build_command
        functions -e __devpod_ensure_required_values

        set -e __devpod_repo_url
        set -e __devpod_git_ref
        set -e __devpod_provider
        set -e __devpod_workspace_id
        set -e __devpod_dotfiles_url
        set -e __devpod_dotfiles_script
        set -e __devpod_ide
        set -e __devpod_devcontainer_path
        set -e __devpod_fallback_image
        set -e __devpod_recreate
        set -e __devpod_reset
        set -e __devpod_open_ide
        set -e __devpod_configure_ssh
        set -e __devpod_cmd
    end

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

    function __devpod_workspace_target
        if test -n "$__devpod_git_ref"
            echo "$__devpod_repo_url@$__devpod_git_ref"
        else
            echo "$__devpod_repo_url"
        end
    end

    function __devpod_components_window
        set shown_repo "not set"
        set shown_ref "default"
        set shown_workspace_target "not set"
        set shown_workspace_id "auto"
        set shown_dotfiles "none"
        set shown_dotfiles_script "none"
        set shown_ide "default"
        set shown_devcontainer_path "default"
        set shown_fallback_image "default"

        if test -n "$__devpod_repo_url"
            set shown_repo "$__devpod_repo_url"
            set shown_workspace_target (__devpod_workspace_target)
        end

        if test -n "$__devpod_git_ref"
            set shown_ref "$__devpod_git_ref"
        end

        if test -n "$__devpod_workspace_id"
            set shown_workspace_id "$__devpod_workspace_id"
        end

        if test -n "$__devpod_dotfiles_url"
            set shown_dotfiles "$__devpod_dotfiles_url"
        end

        if test -n "$__devpod_dotfiles_script"
            set shown_dotfiles_script "$__devpod_dotfiles_script"
        end

        if test -n "$__devpod_ide"
            set shown_ide "$__devpod_ide"
        end

        if test -n "$__devpod_devcontainer_path"
            set shown_devcontainer_path "$__devpod_devcontainer_path"
        end

        if test -n "$__devpod_fallback_image"
            set shown_fallback_image "$__devpod_fallback_image"
        end

        echo "Workspace target:     $shown_workspace_target"
        echo
        echo "Repository:           $shown_repo"
        echo "Git ref:              $shown_ref"
        echo "Provider:             $__devpod_provider"
        echo "Workspace ID:         $shown_workspace_id"
        echo "Dotfiles URL:         $shown_dotfiles"
        echo "Dotfiles script:      $shown_dotfiles_script"
        echo "IDE:                  $shown_ide"
        echo "Devcontainer path:    $shown_devcontainer_path"
        echo "Fallback image:       $shown_fallback_image"
        echo "Debug:                true"
        echo "Recreate:             $__devpod_recreate"
        echo "Reset:                $__devpod_reset"
        echo "Open IDE:             $__devpod_open_ide"
        echo "Configure SSH:        $__devpod_configure_ssh"
    end

    function __devpod_divider
        set width (tput cols 2>/dev/null)

        if test -z "$width"
            set width 80
        end

        string repeat -n "$width" "-"
    end

    function __devpod_show_header
        gum style --bold "Generic DevPod Launcher"

        gum style \
            --foreground 245 \
            "Git refs are appended as repo@ref, for example repo.git@main."

        echo
        __devpod_components_window
        echo
        __devpod_divider
        echo
    end

    function __devpod_build_command
        set workspace_target (__devpod_workspace_target)

        set -g __devpod_cmd devpod up "$workspace_target"

        if test -n "$__devpod_provider"
            set -a __devpod_cmd --provider "$__devpod_provider"
        end

        if test -n "$__devpod_workspace_id"
            set -a __devpod_cmd --id "$__devpod_workspace_id"
        end

        if test -n "$__devpod_dotfiles_url"
            set -a __devpod_cmd --dotfiles "$__devpod_dotfiles_url"
        end

        if test -n "$__devpod_dotfiles_script"
            set -a __devpod_cmd --dotfiles-script "$__devpod_dotfiles_script"
        end

        if test -n "$__devpod_ide"
            set -a __devpod_cmd --ide "$__devpod_ide"
        end

        if test -n "$__devpod_devcontainer_path"
            set -a __devpod_cmd --devcontainer-path "$__devpod_devcontainer_path"
        end

        if test -n "$__devpod_fallback_image"
            set -a __devpod_cmd --fallback-image "$__devpod_fallback_image"
        end

        if test "$__devpod_recreate" = "true"
            set -a __devpod_cmd --recreate
        end

        if test "$__devpod_reset" = "true"
            set -a __devpod_cmd --reset
        end

        if test "$__devpod_open_ide" = "false"
            set -a __devpod_cmd --open-ide=false
        end

        if test "$__devpod_configure_ssh" = "false"
            set -a __devpod_cmd --configure-ssh=false
        end

        # Always enabled.
        set -a __devpod_cmd --debug
    end

    function __devpod_ensure_required_values
        if test -z "$__devpod_repo_url"
            set -g __devpod_repo_url (__devpod_edit_value "Repository URL, path, or workspace name" "")
        end

        if test -z "$__devpod_workspace_id"; and test -n "$__devpod_repo_url"
            set -g __devpod_workspace_id (__devpod_slugify "$__devpod_repo_url")
        end
    end

    while true
        clear
        __devpod_show_header

        set action (gum choose \
            --header "Choose an action" \
            "Run devpod up" \
            "Edit repository/path" \
            "Edit git ref" \
            "Edit provider" \
            "Edit workspace ID" \
            "Edit dotfiles URL" \
            "Edit dotfiles script" \
            "Edit IDE" \
            "Edit devcontainer path" \
            "Edit fallback image" \
            "Toggle recreate" \
            "Toggle reset" \
            "Toggle open IDE" \
            "Toggle configure SSH" \
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
                    set exit_status $status
                    __devpod_cleanup
                    return $exit_status
                end

            case "Edit repository/path"
                set -g __devpod_repo_url (__devpod_edit_value "Repository URL, local path, or workspace name" "$__devpod_repo_url")

                if test -z "$__devpod_workspace_id"; and test -n "$__devpod_repo_url"
                    set -g __devpod_workspace_id (__devpod_slugify "$__devpod_repo_url")
                end

            case "Edit git ref"
                set -g __devpod_git_ref (__devpod_edit_value "Git ref, branch, commit, or PR ref" "$__devpod_git_ref")

            case "Edit provider"
                set selected_provider (gum choose \
                    --header "Provider" \
                    "kubernetes" \
                    "docker" \
                    "ssh" \
                    "custom")

                if test "$selected_provider" = "custom"
                    set -g __devpod_provider (__devpod_edit_value "Custom provider" "$__devpod_provider")
                else
                    set -g __devpod_provider "$selected_provider"
                end

            case "Edit workspace ID"
                set -g __devpod_workspace_id (__devpod_edit_value "Workspace ID" "$__devpod_workspace_id")

            case "Edit dotfiles URL"
                set -g __devpod_dotfiles_url (__devpod_edit_value "Dotfiles URL" "$__devpod_dotfiles_url")

            case "Edit dotfiles script"
                set -g __devpod_dotfiles_script (__devpod_edit_value "Dotfiles script" "$__devpod_dotfiles_script")

            case "Edit IDE"
                set selected_ide (gum choose \
                    --header "IDE" \
                    "default" \
                    "vscode" \
                    "openvscode" \
                    "none" \
                    "custom")

                if test "$selected_ide" = "default"
                    set -g __devpod_ide ""
                else if test "$selected_ide" = "custom"
                    set -g __devpod_ide (__devpod_edit_value "Custom IDE" "$__devpod_ide")
                else
                    set -g __devpod_ide "$selected_ide"
                end

            case "Edit devcontainer path"
                set -g __devpod_devcontainer_path (__devpod_edit_value "Devcontainer path" "$__devpod_devcontainer_path")

            case "Edit fallback image"
                set -g __devpod_fallback_image (__devpod_edit_value "Fallback image" "$__devpod_fallback_image")

            case "Toggle recreate"
                set -g __devpod_recreate (__devpod_toggle_bool "$__devpod_recreate")

            case "Toggle reset"
                set -g __devpod_reset (__devpod_toggle_bool "$__devpod_reset")

            case "Toggle open IDE"
                set -g __devpod_open_ide (__devpod_toggle_bool "$__devpod_open_ide")

            case "Toggle configure SSH"
                set -g __devpod_configure_ssh (__devpod_toggle_bool "$__devpod_configure_ssh")

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
                __devpod_cleanup
                return 0
        end
    end
end

# Win32Yank
# function win32yank
#     /mnt/c/Users/marti/scoop/shims/win32yank.exe $argv
# end
