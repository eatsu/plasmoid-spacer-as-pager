# Spacer as Pager

A panel spacer with virtual desktop switching for KDE Plasma.

This widget is suitable for people who want to quickly switch between virtual desktops
only with mouse, but find [Pager](https://userbase.kde.org/Plasma/Pager) uncomfortable
due to its size (too small or too big) and appearance (cluttered and distracting).

Like the built-in panel spacer, this widget supports both flexible and fixed sizes.

> **Note**: You cannot combine this widget with the built-in panel spacer to
> center other widgets. Instead, place this widget on each side.


## Installation

```
git clone https://github.com/eatsu/plasmoid-spacer-as-pager.git
cd plasmoid-spacer-as-pager
kpackagetool5 -i package
```


## TODO

- Allow directly switching virtual desktops via the context menu.
- Allow displaying the current desktop name.
- Have icon.


## License

GPLv2+


## References

- [Panel Spacer](https://invent.kde.org/plasma/plasma-workspace/-/tree/master/applets/panelspacer)
- [Pager](https://invent.kde.org/plasma/plasma-desktop/-/tree/master/applets/pager)
