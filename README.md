# multi-theme-applicator package

A package for the Atom Editor that allows you to apply multiple syntax themes to your editing session at multiple scoping levels, including by window, by pane, by file type, by file, and by editor.

![fig 1](https://github.com/vt5491/multi-theme-applicator/blob/master/assets/img/mta_v110/mta_opening_screen.png?raw=true)
fig. 1: Screenshot of an Atom editing session with multiple syntax themes.

## Introduction
The Atom editor only allows for a [single _monolithic_ theme](http://stackoverflow.com/questions/36929817/is-there-a-way-to-apply-multiple-themes-to-an-atom-editor-session-e-g-per-pane/37606434#37606434)
  to be applied across all your tabs, panes, and windows.  This is a disappointing, and somewhat surprising fact of life in the Atom ecosystem given its excellent overall customization capabilities.  Other editors such as _emacs_, have long allowed multiple themes to be applied at various levels of granularity (e.g. by window, by file, or file type).

Well no more.  

_Multi-theme-applicator_, in the spirit of the emacs package
[color-theme-buffer-local](https://github.com/vic/color-theme-buffer-local) , allows you to apply any installed syntax theme, at file level granularity, to any of the editors in your editing session. With _multi-theme-applicator_, you now have this powerful capability available in Atom, making the best browser in its class that much better.

### Motivation  
 Experienced developers know that they can easily have dozens of separate files open over a long-lived editing session, with anywhere from 12 to 20 of those files being on the "active" workflow at any one time.  Thus being able to visually categorize your work files is essential:  decreasing the likelihood of "losing your place", and avoiding costly mistakes like editing the wrong file.  

In other words, _multi-theme-applicator_, is a tool for increasing your workflow efficiency.

Allowing multiple coloring themes allows you to group files, and serves as a visual reminder for what "document-plex" you are currently in (for those who distribute their workload over multiple workspaces).

Additionally, since you don't have to commit to one all-encompassing theme, it allows you to experiment with many more of the outstanding themes available for Atom.  So now it becomes no big deal to try out an "exotic" theme such as, say,  [fairyfloss](https://sailorhg.github.io/fairyfloss/), since you can restrict it to as small an "area" as a single file.    

Allowing editor level theming is also useful when your global themes looks good on one file type, but not so good on others.  Having this problem?  Simply pick another theme that looks good on the other file type and your problem is solved.  No more trying to find that one perfect theme that works across all your file types.

## Requirements
Requires Atom >=1.13.0.
Tested on Atom 1.13.0 on Mac, Windows 10, and Linux Mint 18.

## Installation
Install from the Atom control panel as you would for any standard Atom package.

## Usage
#### Overview
When you activate the _multi-theme-applicator_ (MTA) panel with _shift-ctrl-v_ (windows/linux) or _shift-cmd-v_ (mac), you are presented with a list of the currently available themes.  The panel and theme selection can be entirely controlled with home-row friendly key bindings or via mouse.  Select the theme you want and click _Apply Local Theme_ or press _Enter_. You will then see all the editors associated with the file of the active editor assume that theme.  Having selected a new theme, the dialog will still remain active, allowing you to quickly iterate through and apply several themes until you find just the right one.  When you're done, toggle the _multi-theme-applicator_ to close by pressing the _escape_ key, _ctrl-shift-v_, or clicking the "x" button, and resume working.

#### Typical Workflow
--> 2017-02-08: Note this describes how to use MTA v 0.9.0.  This will be updated in the future to support MTA v1.1.0.

1) We start in a session with three open files across three panes in the default monolithic theme _atom-dark_.    

  Note how two of the panes are open on one file and the third pane on another file and how relatively difficult it is to visually distinguish between them:  
<br/>  
![fig 1](https://github.com/vt5491/multi-theme-applicator/blob/master/assets/img/mta_workflow_start.png?raw=true)

2) We want to apply the _humane_ theme to file 'utils.coffee' that is visually active in the left pane (pane 1), and upper right pane (pane 2), and in a non-selected tab in the lower right pane (pane 3).  

  While either pane 1 or pane 2 is active, type _shift-ctrl-v_ or _shift-cmd-v_ (or activate the command palette and type 'multi') and activate the MTA modal panel.  The modal dialog should come up with keyboard focus:
  <br/>
  ![2](https://github.com/vt5491/multi-theme-applicator/blob/master/assets/img/mta_workflow_dialog.png?raw=true)
    Note how the syntax theme selected item is a darker color and has a slightly larger border to denote its been selected.


3) At this point, press 'ctrl-n' and 'ctrl-p' or the arrow keys to scroll through the list.  Alternatively, you can press 'shift-alt-v' to "expand" the full list of themes (Unfortunately, if you expand the themes, ctrl-n and ctrl-p won't work for scrolling and you have to use the arrow keys).  
  * If you know the theme you want to apply, you can quickly narrow down on it by typing the first letter of the theme.  For instance, if I type "d" on my system, the dropdown jumps to "dracula" in the list, allowing me to select it right away. If this is not the "d" theme you had in mind, then you can press _ctrl-n_ and _ctrl-p_ to scroll through its neighbors, or keep pressing the letter to get the next theme that starts with that letter.  
<br/>

Here we type 'h' to quickly locate the _humane_ theme:
![3](https://github.com/vt5491/multi-theme-applicator/blob/master/assets/img/mta_workflow_humane_pre_apply.png?raw=true)  
<br/>  
4) Hit Enter key, or press the _Apply Local Theme_ button to activate the new theme.


![4](https://github.com/vt5491/multi-theme-applicator/blob/master/assets/img/mta_workflow_humane_post_apply.png?raw=true)
<br/>

 Note 1: The theme was applied at the file level, not the editor level (new feature added in v 0.8.0).  All three editors that are opened on file 'utils.cofee' will have the new theme, saving you the hassle of having to apply it three times.  Of course, only two editors with the selected file are visible in this current example since the editor in pane 3 is in a tab that is not currently visible.  However, if we do activate the file's tab in that pane, it will also have the new theme.

 Note 2: Even after the theme is applied the dialog is still active, so you can scroll to another theme, hit Enter again, and apply that theme.  This allows you to quickly decide if you like the theme or not, without having to go through the whole selection process again.  

 Note 3: Observe how much easier it is to distinguish between the files with multi-themes.

5) If you like your new theme, toggle the modal dialog off by by pressing _ctrl-shift-v_ or _escape_ (or invoke ctrl-shift-p and search for "multi"), or clicking the "x" button. If we swtich to pane 3 and activate the hidden tab, you'll see that it too has the new theme.  Congratulations, you now have a mixed theme session!  Repeat as desired to your other files.

Note: with version 0.9.0, MTA remembers the theme applied to each file. See release notes below for more details.

Screenshot showing all three editors for the selected file sucessfully themed:
<br/>
![5](https://github.com/vt5491/multi-theme-applicator/blob/master/assets/img/mta_workflow_humane_post_apply_2.png?raw=true)
<br/>

#### Tips
1. If you don't like all the different themes and want to return to the default, just press 'ctrl-alt-r' which will refresh Atom (while keeping your pane and file hierarchy) and restore the default theme to every panel i.e. no need to hard cycle (close and re-open) the editor itself.   


#### Keybindings
The following default key bindings are in effect:  

shift-ctrl-v : Toggle MTA (mult-theme-applicator) (window/linux)
shift-cmd-v : Toggle MTA (mult-theme-applicator) (Mac)
shift-alt-v: Give MTA dialog keyboard focus (in editor context)  
ctrl-n: scroll down through themes  
ctrl-p: scroll up through themes  
shift-alt-v: expand the theme list (in modal dialog context)  
escape: close the MTA dialog (when it has keyboard focus)

You can also close the MTA dialog by clicking the "x" button.

Note 1: 'shift-alt-v' is used twice: once in the editor context, and the other in the modal dialog context.  

Note 2: Quite frankly, some of these are kind of tricky key bindings.  I have emacs and vim key bindings in effect on Atom, and finding free key bindings is difficult.  If you don't have this problem, you can probably make better choices.  See note 3 about how to do this.

Note 3: to change the keybindings, edit $HOME/.atom/packages/mult-theme-applicator/multi-theme-applicator.cson, or use the keybindings section of the Settings panel.

#### Limitations
1. Sticky themes does not work on window, pane, or editor scoped themes.
2. Because Atom no longer uses a Shadow DOM, which isolated editor level themes, there can now be "bleed over" between themes.   That is to say, some elements of your theme may be overridden by a higher level theme.  This is just a property of Cascading Style Sheets.  


### Release History
2017-02-08 - version 1.1.0
1. New *File Type* Scope
 * allows you to apply a theme by file type e.g. make all currently opened and to-be-opened javascript files be one theme, and all .html files be another theme etc.
2. Improved reset
 * Invoking *MTA reset* from the command pallet will remove all themes dynamically, without requiring a restart
   * This is necessary because the theming can get very convoluted if you're not careful.  Sometimes you just want to start from scratch.
3. New *Refresh Themes* command
 * Selecting *MTA Refresh Thems* from the command pallet allows you to dynamically add themes for the main dropdown, without restarting Atom.

2017-02-02 - version 1.0.0
1. Atom 1.13 support
 * Atom 1.13 [removed the shadow DOM](http://blog.atom.io/2016/11/14/removing-shadow-dom-boundary-from-text-editor-elements.html) which was relied upon by _Multi-theme-applicator_ to achive its styling.  Thus a re-architecting of the styling mechansim was required.  
2. Scope level theming added.
  * The new styling architecture allows for easier theming at different levels of granularity.  Thus window, pane, file, and editor level scope was added.
3. New *Remove Scoped Theme* button.
  * Allows for finer control over backing off applied themes.  This is necessary becuase there can now be multiple layers of themes applied.

2016-09-03 - version 0.9.0  
This release introduces quite a large amount of new functionality.  Basically, local theming has been made much more "sticky", and requires less manual intervention and re-application.  In short, it's starting to work a lot more like one "would expect", and fixes several edge cases where themes were previously not applied as expected.  

1. The package now listens on pane events, such as splitting the screen, and will automatically apply the appropriate theme for that file.  In other words, you should only have to apply the file theme once, and that theme should show on all editors for that file, across all life-cycle events including adding new editors.
2. file level theming is now persisted across atom cyclings i.e. if you close atom completely, and then start it again, once you invoke mta (shift-ctrl-v) then the local themes you supplied for any open files will be re-themed automatically.  
3. Added a new command 'mta-reset' to reset the "theme memory", but you should normally not want to use this.
4. Fixed a bug on mac where the "apply local theme" button was not driving the appropriate event handler.

2016-06-30 - version 0.8.0  
1. Added file level theming.  
2. Added Mac-friendly key binding _shift-cmd-v_  
3. Added a little better styling to the modal dialog.  
4. Updated README to reflect new changes.  

2016-06-09 - version 0.7.0  
1. Improved key binding support  
  * Modal dialog now comes up with focus -- no need to press _alt-shift-v_ first.
  * _ESC_ key now closes the dialog.  

2. Added close button on modal dialog

2016-05-29 - version 0.6.1
- Initial release.
