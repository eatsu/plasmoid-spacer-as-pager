# Spacer as Pager

A panel spacer with virtual desktop switching for KDE Plasma.

This widget is suitable for people who want to quickly switch between virtual desktops
only with mouse, but find [Pager](https://userbase.kde.org/Plasma/Pager) uncomfortable
due to its size (too small or too big) and appearance (cluttered and distracting).

## Features

- Supports both flexible and fixed sizes.
- Navigation can wrap around.
- You can left-click/middle-click/right-click the spacer to:
  - Peek at Desktop
  - Show Overview (default for left-click)
  - Show Desktop Grid
  - Show Present Windows
  - Run Command

## Known issue

You cannot combine this widget with the built-in panel spacer to center other widgets.
Instead, place this widget on each side.

## Installation

### From GUI

1. Right-click the desktop or panel and select `Add Widgets…`.
2. Select `Get New Widgets…` and then `Download New Plasma Widgets`.
3. Search for `Spacer as Pager` and press `Install`.

### From the source

```sh
git clone https://github.com/eatsu/plasmoid-spacer-as-pager.git
cd plasmoid-spacer-as-pager
kpackagetool5 -i package
```

## TODO

- Allow directly switching virtual desktops via the context menu.
- Allow displaying the current desktop name.
- Bundle the icon into the package (if possible).

## License

GPLv2+

## References

- [Panel Spacer](https://invent.kde.org/plasma/plasma-workspace/-/tree/master/applets/panelspacer)
- [Pager](https://invent.kde.org/plasma/plasma-desktop/-/tree/master/applets/pager)
