dmemcg-booster usage:

```nix
{
  imports = [
    inputs.niri-focused-booster.nixosModules.default
  ];

  services.dmemcg-booster.enable = true;
}
```
