:house_with_garden: dotfiles, sweet dotfiles
========

## deploy

```
git clone git@github.com:unbalancedparentheses/dotfiles.git ~/dotfiles
```

```
wpa_supplicant -B -i wlp0s20f3 -c /etc/wpa_supplicant/wpa_supplicant.conf
wpa_cli
> scan
OK
<3>CTRL-EVENT-SCAN-RESULTS
> scan_results
bssid / frequency / signal level / flags / ssid
00:00:00:00:00:00 2462 -49 [WPA2-PSK-CCMP][ESS] MYSSID
11:11:11:11:11:11 2437 -64 [WPA2-PSK-CCMP][ESS] ANOTHERSSID
> add_network
0
> set_network 0 ssid "MYSSID"
> set_network 0 psk "passphrase"
> enable_network 0
<2>CTRL-EVENT-CONNECTED - Connection to 00:00:00:00:00:00 completed (reauth) [id=0 id_str=]
> save_config
OK
> quit
```

install all packages:
```
cat packages | xargs echo "xbps-install -Sy" | bash
```

Fix sound:
```
echo 'GRUB_CMDLINE_LINUX="snd_hda_intel.dmic_detect=0"' >> /etc/default/grub
update-grub
```

Better fonts in Firefox (about:config):
```
gfx.font_rendering.fontconfig.max_generic_substitutions = 127
```

```
home-manager
vim .config/nixpkgs/home.nix
home-manager switch
```