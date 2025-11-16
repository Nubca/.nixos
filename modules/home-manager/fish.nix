{ config, lib, inputs, ... }:
{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
### ADDING TO THE PATH
  # First line removes the path; second line sets it.  Without the first line,
  # your path gets massive and fish becomes very slow.
      set -e fish_user_paths
      set -U fish_user_paths $HOME/.local/bin $HOME/Applications /var/lib/flatpak/exports/bin/ $fish_user_paths

### EXPORT ###
      set fish_greeting # Supresses fish's intro message
      set -Ux XDG_CONFIG_HOME ~/.config
      set TERM kitty # Sets the terminal type
      set EDITOR nvim # $EDITOR use nvim in terminal
      set VISUAL nvim # $VISUAL use Emacs in GUI mode
      set GIT_EDITOR nvim

### "nvim" as manpager
      set -x MANPAGER "nvim +Man!"
      fish_vi_key_bindings

### Zellij
      if status is-interactive
        if not set -q ZELLIJ
          zellij
        end
      end
  ### Prevent nested Zellij Sessions
      function ssh
        set -l old_zellij $ZELLIJ
        set -e ZELLIJ
        command ssh $argv
        set -gx ZELLIJ $old_zellij
      end

### AUTOCOMPLETE AND HIGHLIGHT COLORS ###
      set fish_color_normal brcyan
      set fish_color_autosuggestion '#7d7d7d'
      set fish_color_command brcyan
      set fish_color_error '#ff6c6b'
      set fish_color_param brcyan
      set -e fish_user_paths
      set -U fish_user_paths $HOME/.local/bin $HOME/Applications /var/lib/flatpak/exports/bin/ $fish_user_paths
    '';

    shellAbbrs = {}; # Expands words at the command line

    shellAliases = {
      sdn = "shutdown now";
      ffv = "fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'";
      lg = "lazygit";

## Screen Brightness
      s9 = "echo 1000 | sudo tee /sys/class/backlight/gmux_backlight/brightness";
      s8 = "echo 800 | sudo tee /sys/class/backlight/gmux_backlight/brightness";
      s7 = "echo 620 | sudo tee /sys/class/backlight/gmux_backlight/brightness";
      s6 = "echo 480 | sudo tee /sys/class/backlight/gmux_backlight/brightness";
      s5 = "echo 360 | sudo tee /sys/class/backlight/gmux_backlight/brightness";
      s4 = "echo 260 | sudo tee /sys/class/backlight/gmux_backlight/brightness";
      s3 = "echo 150 | sudo tee /sys/class/backlight/gmux_backlight/brightness";
      s2 = "echo 70 | sudo tee /sys/class/backlight/gmux_backlight/brightness";
      s1 = "echo 35 | sudo tee /sys/class/backlight/gmux_backlight/brightness";
      s0 = "echo 10 | sudo tee /sys/class/backlight/gmux_backlight/brightness";

# navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      ".3" = "cd ../../..";
      ".4" = "cd ../../../..";
      ".5" = "cd ../../../../..";

# vim and emacs
      vim = "nvim";

# Changing "ls" to "exa"
      ls = "eza -al --color=always --group-directories-first"; # my preferred listing
      la = "eza -a --color=always --group-directories-first"; # all files and dir
      ll = "eza -l --color=always --group-directories-first"; # long format
      lt = "eza -aT --color=always --group-directories-first --level=3"; # tree listing
      tree = "tree -C --dirsfirst"; #Colorized tree with Directories firs

      pbcopy = "xsel --input --clipboard";
      pbpaste = "xsel --output --clipboard";

# Colorize grep output (good for log files)
      grep = "grep --color=auto";
      egrep = "egrep --color=auto";
      fgrep = "fgrep --color=auto";

# confirm before overwriting something
      cp = "cp -i";
      mv = "mv -i";
      rm = "rm -i";

# adding flags
      df = "df -h"; # human-readable sizes
      free = "free -m"; # show sizes in M"

      addup = "git add -u";
      addall = "git add .";
      branch = "git branch";
      checkout = "git checkout";
      clone = "git clone";
      commit = "git commit -m";
      fetch = "git fetch";
      pull = "git pull origin --rebase";
      push = "git push origin";
      tag = "git tag";
      newtag = "git tag -a";

# get error messages from journalctl
      jctl = "journalctl -p 3 -xb";

# send preceding command output to hosting link
      "0x0" = "curl -F 'file=@-' 0x0.st";
      tb = "nc termbin.com 9999";

# gpg encryption
  # verify signature for isos
      gpg-check = "gpg2 --keyserver-options auto-key-retrieve --verify";
  # receive the key of a developer
      gpg-retrieve = "gpg2 --keyserver-options auto-key-retrieve --receive-keys";

# Play video files in current dir by type
      playavi = "vlc *.avi";
      playmov = "vlc *.mov";
      playmp4 = "vlc *.mp4";

# yt-dlp
      yta-aac = "yt-dlp --extract-audio --audio-format aac";
      yta-best = "yt-dlp --extract-audio --audio-format best";
      yta-flac = "yt-dlp --extract-audio --audio-format flac";
      yta-m4a = "yt-dlp --extract-audio --audio-format m4a";
      yta-mp3 = "yt-dlp --extract-audio --audio-format mp3";
      yta-opus = "yt-dlp --extract-audio --audio-format opus";
      yta-vorbis = "yt-dlp --extract-audio --audio-format vorbis";
      yta-wav = "yt-dlp --extract-audio --audio-format wav";
      ytv-best = "yt-dlp -f bestvideo+bestaudio";
    };

    functions = {
      y = ''
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
	      yazi $argv --cwd-file="$tmp"
	      if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
		      builtin cd -- "$cwd"
	      end
	      rm -f -- "$tmp"
        '';
      backup = ''
        function backup --argument filename
          cp $filename $filename.bak
        end
      '';
      reverse_history_search = ''
        history | fzf --no-sort | read -l command
        if test $command
          commandline -rb $command
          end
        '';
      fish_user_key_bindings = ''
        bind -M default / reverse_history_search
      '';
      fish_mode_prompt = '''';
      fish_prompt = ''
        set -l retc red
        test $status = 0; and set retc green

        set -q __fish_git_prompt_showupstream
          or set -g __fish_git_prompt_showupstream auto

        function _nim_prompt_wrapper
          set retc $argv[1]
          set -l field_name $argv[2]
          set -l field_value $argv[3]

          set_color normal
          set_color $retc
          set_color -o green
          echo -n '['
          set_color normal
          test -n $field_name
          and echo -n $field_name:
          set_color $retc
          echo -n $field_value
          set_color -o green
          echo -n ']'
        end

        set_color $retc
        echo -n '┬─'
        set_color -o green
        echo -n ' '(date +%T)
        echo
        echo -n '│'

      # Vi-mode
      # The default mode prompt would be prefixed, which ruins our alignment.
        function fish_mode_prompt
        end

        if test "$fish_key_bindings" = fish_vi_key_bindings
          or test "$fish_key_bindings" = fish_hybrid_key_bindings
          set -l mode
          switch $fish_bind_mode
            case default
              set mode (set_color --bold red)N
            case insert
              set mode (set_color --bold green)I
            case replace_one
              set mode (set_color --bold green)R
            case replace
              set mode (set_color --bold cyan)R
            case visual
              set mode (set_color --bold magenta)V
          end
          set mode $mode(set_color normal)
            _nim_prompt_wrapper $retc "" $mode
        end


        if functions -q fish_is_root_user; and fish_is_root_user
          set_color -o red
        else
          set_color -o yellow
        end

        echo -n ' '$USER
        set_color -o white
        echo -n @

        if test -z "$SSH_CLIENT"
          set_color -o blue
        else
          set_color -o cyan
        end

        echo -n (prompt_hostname)
        set_color -o yellow
        echo -n ' in '
        set_color -o white
        echo -n (prompt_pwd -D 24)' '
        set_color -o green

      # Virtual Environment
        set -q VIRTUAL_ENV_DISABLE_PROMPT
        or set -g VIRTUAL_ENV_DISABLE_PROMPT true
        set -q VIRTUAL_ENV
        and _nim_prompt_wrapper $retc V (basename "$VIRTUAL_ENV")

      # git
        set -l prompt_git (fish_git_prompt '%s')
        test -n "$prompt_git"
        and _nim_prompt_wrapper $retc G $prompt_git

      # New line
        echo

      # Background jobs
        set_color normal

        for job in (jobs)
          set_color $retc
          echo -n '│ '
          set_color brown
          echo $job
        end

        set_color normal
        set_color $retc
        echo -n '╰─>'
        set_color -o red
        echo -n '$ '
        set_color normal
      '';
    };
    shellInitLast = "zoxide init --cmd cd fish | source";
  };
}
