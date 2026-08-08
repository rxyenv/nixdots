{ inputs, ... }:

{
  # Provides the `flake.modules.<class>.<name>` option used by every feature file
  imports = [ inputs.flake-parts.flakeModules.modules ];
}
