# multi-theme-applicator package
A package for the atom editor that allows you to apply multiple syntax themes to your editing session.  

![fig 1](tmp/multi_themed_screen_shot_1.png)

fig. 1: Screenshot of an Atom editing session with multiple syntax themes.

## Introduction
The atom editor, out of the box, only allows a single _global_ theme to be applied across your tabs, panes, and yes, even across all your Atom windows.  Other editors, such as _emacs_, have long allowed multiple themes to be applied at various levels of granularity (e.g. by window or by file).  Experienced developers know that you can easily have dozens of separate files open over a long-lived editing session, with anywhere from 12 to 20 files on the "active" workflow at any one time. Being able to graphically categorize your work files is essential, greatly increasing your flow, and helping avoid costly mistakes like "losing your place", or even editing the wrong file,

Allowing multiple coloring schemes allows you to more quickly group files, serves as a visual reminder for what "window-set" you are currently in (for those who distriubte their workload over multiple workspaces), and also allows you to sample more of the many excellent themes avaiable for Atom.   

This package allows you to apply any intalled syntax theme to the active buffer.  In the spirit of the emacs package
[load-theme-buffer-local](https://github.com/vic/color-theme-buffer-local), you can now add this powerful feature to Atom, making a great browser even better.

## About
_Multi-theme-Applicator_ sets the foundation to act as a sort of _shadow_ theme manager.

When you activate the _multi-theme-applicator_ panel, you are presented with a list of the currently aviable themes.  The panel and theme selection can be entirely controlled with home-row friendly key bindings or via mouse.  Select the theme you want and click apply. You will then see the active editor assume that theme.  The dialog will stay active, allowing to quickly iterate through several themes, until you find just the right one.  When you're done, toggle the _multi-theme-applicator_ to close the modal dialog and resume working.

#### Limitations
Unfortunately, the package does not yet currently allow for any higher-level grouping such as by file, by file type, or by window.  

What this means is that if the default theme is _atom-dark_, and you apply _seti_ to the "buffer" for _file-a.js_, when you split _file-a.js_ into a new pane, the newly opened buffer will _not_ have the new theme, but will have the default theme.  This is because (currently) the package only supports theming at the text-editor level.  

Future enhancements such as specifying a theme at the file level, or by file type (say all '.js' files are light themed, all 'java' are dark-themed etc), or physical theming at the window level are certainly possible.  The current iteration of the package provide the raw mechanism to set the theme at the individual "node" level, and a higher level application layer that keeps track of themes for logical groups should straigt-forward to add in the future.

## Installation

## Usage
(walk through a typical workflow, with screen prints)
