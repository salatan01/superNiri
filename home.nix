# Thin Home Manager entrypoint — real config lives in ./home/default.nix.
{ ... }:
{
  imports = [ ./home ];
}
