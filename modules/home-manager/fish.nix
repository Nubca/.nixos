{ config, pkgs, lib, ... }:

{
  programs.fish = {
    enable = true;
    functions = {
      ### SET EITHER DEFAULT EMACS MODE OR VI MODE ###
      function fish_user_key_bindings
          # fish_default_key_bindings
          fish_vi_key_bindings
      end
      ### END OF VI MODE ###

     function reverse_history_search
         history | fzf --no-sort | read -l command
         if test $command
             commandline -rb $command
         end
     end
     
     function fish_user_key_bindings
         bind -M default / reverse_history_search
     end
     
     # bind \"\cr\" fzf-history-widget
     # Functions needed for !! and !$
     function __history_previous_command
         switch (commandline -t)
             case "!"
                 commandline -t $history[1]
                 commandline -f repaint
             case "*"
                 commandline -i !
         end
     end
     
     function __history_previous_command_arguments
         switch (commandline -t)
             case "!"
                 commandline -t ""
                 commandline -f history-token-search-backward
             case "*"
                 commandline -i '$'
         end
     end
    };
  };
}
