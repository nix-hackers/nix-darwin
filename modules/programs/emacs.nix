{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.emacs;

  emacs = pkgs.emacsWithPackages(emacsPackages: with {
    elpa = emacsPackages.elpaPackages;
    melpa = emacsPackages.melpaPackages;
  }; with melpa; [
    # back-button
    # centered-window-mode
    # diff-hl
    # elixir-mode
    fill-column-indicator
    # TODO: flycheck
    # TODO: ghc
    # TODO: helm
    # helm-projectile
    # ido-ubiquitous
    # TODO: intero
    # js2-mode
    # TODO: json-mode
    # TODO: markdown-mode
    # TODO: magit
    # mwim
    # neotree
    # nix-sandbox
    nix-mode
    # TODO: elpa.org
    # projectile
    # purescript-mode
    # python-mode
    # scala-mode
    # scss-mode
    # tabbar
    # transpose-frame
    # web-mode
    # ws-butler
    # TODO: yaml-mode
  ]);

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
