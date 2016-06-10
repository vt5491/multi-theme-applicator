# multi-theme-applicator package
A package for the atom editor that allows you to apply multiple syntax themes to your editing session.  

![fig 1](https://github.com/vt5491/multi-theme-applicator/blob/master/assets/img/multi_themed_screen_shot_1.png?raw=true)
fig. 1: Screenshot of an Atom editing session with multiple syntax themes.

## Introduction
The Atom editor only allows for a [single _monolithic_ theme](http://stackoverflow.com/questions/36929817/is-there-a-way-to-apply-multiple-themes-to-an-atom-editor-session-e-g-per-pane/37606434#37606434)
  to be applied across all your tabs, panes, and windows.  This is a disappointing (and somewhat surprising) fact of life in the Atom ecosystem given its excellent overall customization capabilities.  Other editors such as _emacs_, have long allowed multiple themes to be applied at various levels of granularity (e.g. by window, by file, or file type).

Well no more.  

_Multi-theme-applicator_, in the spirit of the emacs package
[color-theme-buffer-local](https://github.com/vic/color-theme-buffer-local) , allows you to apply any installed syntax theme to the active text editor and, by extension, to each and every buffer in your editing session. With _multi-theme-applicator_, you now have this powerful capability available in Atom, making the best browser out there that much better.

### Motivation  
 Experienced developers know that they can easily have dozens of separate files open over a long-lived editing session, with anywhere from 12 to 20 of those files being on the "active" workflow at any one time.  Thus, being able to visually categorize your work files is essential:  decreasing the likelihood of "losing your place", and avoiding costly mistakes like editing the wrong file.  

In other words, _multi-theme-applicator_, is a tool for increasing your workflow efficiency.

Allowing multiple coloring themes allows you to group files, and serves as a visual reminder for what "document-set" you are currently in (for those who distribute their workload over multiple workspaces).

Additionally, since you don't have to commit to one all-encompassing theme, it allows you to experiment with many more of the outstanding themes available for Atom.  So it's no big deal to try out an "exotic" theme such as, say,  [fairyfloss](https://sailorhg.github.io/fairyfloss/), since you can restict it to a single file.    

Allowing editor level theming is also useful when your global themes looks good on one file type, but not so good on others.  Having this problem?  Simply pick another theme that looks good on the other file types and your problem is solved.  No more trying to find that one perfect theme that works on all your file types.


## Installation
Install from the Atom control panel as you would do for any standard Atom package.

## Usage
#### Overview
When you activate the _multi-theme-applicator_ (MTA) panel, you are presented with a list of the currently available themes.  The panel and theme selection can be entirely controlled with home-row friendly key bindings or via mouse.  Select the theme you want and click _Apply Local Theme_. You will then see the active editor assume that theme.  The dialog will stay active, allowing to quickly iterate through several themes, until you find just the right one.  When you're done, toggle the _multi-theme-applicator_ to close by pressing the _escape_ key, _ctrl-shift-v_, or clicking the "x" button, and resume working.

#### Typical Workflow
1. We start with a session with two panes and the monolithic default theme _atom-dark_:  
<br/>
![fig 1](https://github.com/vt5491/multi-theme-applicator/blob/master/assets/img/workflow_screen_shot_1.png?raw=true)

2. We want to apply the _humane_ theme to the left panel.  So make sure that is the active panel and type 'shift-ctrl-v' (or activate the command palette and type 'multi') to activate the MTA modal panel:
<br/>
![2](https://github.com/vt5491/multi-theme-applicator/blob/master/assets/img/workflow_screen_shot_2.png?raw=true)

3. The modal dialog should come up with keyboard focus.  If it doesn't have focus, you can either click on it with the mouse, or type 'alt-shift-v'.  
![3](https://github.com/vt5491/multi-theme-applicator/blob/master/assets/img/workflow_screen_shot_3.png?raw=true)
<br/>
Note how the syntax theme selected item is now a darker color and has a slightly larger border to denote its been selected.

4. At this point, press 'ctrl-n' and 'ctrl-p' or the arrow keys to scroll through the list.  Alternatively, you can press 'shift-alt-v' to "expand" the full list of themes (Unfortunately, if you expand the themes, ctrl-n and ctrl-p won't work for scrolling and you have to use the arrow keys)  
<br/>
![4](https://github.com/vt5491/multi-theme-applicator/blob/master/assets/img/workflow_screen_shot_4.png?raw=true)  
<br/>  
5. Hit Enter key, or press the _Apply Local Theme_ button to activate the new theme.

 Note: even after the theme is applied the dialog is still active, so you can scroll to another theme, hit Enter again, and apply that theme.  This allows you to quickly decide if you like the theme or not, without having to go through the whole selection process again.
![5](https://github.com/vt5491/multi-theme-applicator/blob/master/assets/img/workflow_screen_shot_5.png?raw=true)
<br/>

6. If you like your new theme, toggle the modal dialog off by by pressing _ctrl-shift-v_ or _escape_ (or invoke ctrl-shift-p and search for "multi").  You now have a mixed theme session!  Repeat as desired to your other editors.

Note: This change will only affect the current buffer.  Any new buffers you open will be the default monolithic theme.

<br/>
![6](https://github.com/vt5491/multi-theme-applicator/blob/master/assets/img/workflow_screen_shot_6.png?raw=true)
<br/>

#### Tips
1. If you don't like all the different themes and want to return to the default, just press 'ctrl-alt-r' which will refresh Atom (while keeping your pane and file hierarchy) and restore the default theme to every panel i.e. no need to hard cycle (close and re-open) the editor itself.   


#### Keybindings
The following default key bindings are in effect:  

shift-ctrl-v : Toggle MTA (mult-theme-applicator)  
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
1) The package does not yet currently allow for any higher-level grouping such as by file, by file type, or by window.  

What this means is that if you apply a new theme to the editor for a file, when you split the file into a new pane, the newly opened buffer will _not_ have the new theme, but will have the default theme.  This is because (currently) the package only supports theming at the text-editor level. If you want to apply the new theme to this editor as well, you have to manually apply the new theme _again_  

Future enhancements such as specifying a theme at the file level, or by file type (say all '.js' files are light themed, all 'java' are dark-themed etc), or physical theming at the window level are certainly possible.  The current iteration of this package provides the raw mechanism to set the theme at the individual "node" level. A higher level application layer that keeps track of themes for logical groups can be added in the future.

2) While the vast majority of themes work fine, some themes don't work quite right.  Other themes don't properly "activate" until the MTA dialog is closed.  This is probably due to the fact that there is no standard DOM representation for themes.  Most themes use the same conventions, so it's not much of a problem.  MTA achieves its effect through standard DOM manipulation techniques.
