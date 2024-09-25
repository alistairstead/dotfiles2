function fish_user_key_bindings
    fish_vi_key_bindings
    bind -M insert -m default jk backward-char force-repaint
    bind -M insert \ce forward-char
end

# function fish_user_key_bindings
#     # Bind 'jk' to exit insert mode
#     function fish_vi_mode_change
#         if test (commandline -P) = j
#             if test (commandline -P) = jk
#                 commandline -f backward-char
#                 commandline -f backward-delete-char
#                 commandline -f vi-normal-mode
#             end
#         end
#     end
#
#     bind -m insert j fish_vi_mode_change
#     bind -m insert k fish_vi_mode_change
#     bind \ce accept-autosuggestion
# end
