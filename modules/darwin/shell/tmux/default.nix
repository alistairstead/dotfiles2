{ config
, pkgs
, ...
}:
let
  cfg = config.security.pam;
  mkSudoTouchIdAuthScript = isEnabled:
  let
    file   = "/etc/pam.d/sudo";
    option = "tmux.pam-reattach";
    sed = "${pkgs.gnused}/bin/sed";
  in ''
    ${if isEnabled then ''
      # Enable sudo pam-reattach, if not already enabled
      if ! grep 'pam_reattach.so' ${file} > /dev/null; then
        ${sed} -i '2i\
      auth       optional       ${pkgs.pam-reattach}/lib/pam/pam_reattach.so # enable for: ${option}
        ' ${file}
      fi
    '' else ''
      # Disable sudo pam-reattach, if added by nix-darwin
      if grep '${option}' ${file} > /dev/null; then
        ${sed} -i '/${option}/d' ${file}
      fi
    ''}
  '';
in
{
  config = {
    home-manager.users.${config.user} = {
      home.packages = with pkgs; [
        pam-reattach
      ];
    };

    system.activationScripts.pam.text = ''
      # PAM pam-reattach settings
      echo >&2 "setting up tmux pam-reattach..."
      ${mkSudoTouchIdAuthScript cfg.enableSudoTouchIdAuth}
    '';
  };
}
