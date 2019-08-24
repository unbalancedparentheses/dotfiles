:house_with_garden: dotfiles, sweet dotfiles
========

## deploy

```
git clone git@github.com:unbalancedparentheses/dotfiles.git ~/dotfiles
```

I always forget how to get good font rendering in Void Linux:
```
sudo xbps-install -S google-fonts-ttf
```

Firefox (about:config):
```
gfx.font_rendering.fontconfig.max_generic_substitutions = 127
```

```
sudo ln -s /usr/share/fontconfig/conf.avail/10-hinting-slight.conf /etc/fonts/conf.d/
sudo ln -s /usr/share/fontconfig/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d/
sudo ln -s /usr/share/fontconfig/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d/
sudo ln -s /usr/share/fontconfig/conf.avail/50-user.conf /etc/fonts/conf.d/
sudo ln -s /usr/share/fontconfig/conf.avail/70-no-bitmaps.conf /etc/fonts/conf.d/
```
