:house_with_garden: dotfiles, sweet dotfiles
========

## deploy

In Linux first we need to setup WiFi:

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

Now let's install everything
```
git clone git@github.com:unbalancedparentheses/dotfiles.git ~/dotfiles
make
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

## Nix

Install Nix for macOS
```
sh <(curl -L https://nixos.org/nix/install) --darwin-use-unencrypted-nix-store-volume --daemon
```
and in Linux
```
sh <(curl -L https://nixos.org/nix/install) --daemon
```

Burke Libbey's [Nixology](https://www.youtube.com/playlist?list=PLRGI9KQ3_HP_OFRG6R-p4iFgMSK1t5BHs) youtube playlist and [nix.dev](https://nix.dev/) are the best way to learn how to use Nix.
