{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.emacs;

  emacs = pkgs.emacsWithPackages(cfg.packages);

  text = import ../lib/write-text.nix {
    inherit lib;
    mkTextDerivation = name: text: pkgs.writeText "emacs-options-${name}" text;
  };

  emacsOptions = concatMapStringsSep "\n" (attr: attr.text) (attrValues cfg.emacsOptions);

in {
  options = {

    programs.emacs.enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to configure emacs.
      '';
    };

    programs.emacs.emacsOptions = mkOption {
      internal = true;
      type = types.attrsOf (types.submodule text);
      default = {};
    };

    programs.emacs.emacsConfig = mkOption {
      type = types.lines;
      default = "";
      description = ''
        Extra .emacs config to use for emacsWithPackages.
      '';
    };

    programs.emacs.packages = mkOption {
      # FIXME: type
      default = (_: []);
      description = ''
        A function from a package set to a list of packages
        (the packages that will be available in Emacs).

        N.B. This is passed to `emacsWithPackages` internally.
      '';
    };
  };

  config = mkIf cfg.enable {

    environment.systemPackages = [ emacs ];

    environment.variables.EDITOR = ''
      ${emacs}/bin/emacsclient -cnw -a ""
    '';

    environment.etc."emacs".text = ''
      ${emacsOptions}
      ${cfg.emacsConfig}
    '';
  };
}
