'use babel';

import MultiThemeApplicator from '../lib/multi-theme-applicator';

// Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
//
// To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
// or `fdescribe`). Remove the `f` to unfocus the block.

describe('dummy test', () => {
  it('has one valid test', () => {
    expect(7).toEqual(7);
  });
  it('has two valid test', () => {
    expect(7).toEqual(7);
  });
  it('has three valid test', () => {
    expect(7).toEqual(7);
  });
});

describe('MultiThemeApplicator', () => {
  let workspaceElement, activationPromise;

  beforeEach(() => {
    workspaceElement = atom.views.getView(atom.workspace);
    activationPromise = atom.packages.activatePackage('multi-theme-applicator');
  });

  describe('when the multi-theme-applicator:toggle event is triggered', () => {
    xit('hides and shows the modal panel', () => {
      // Before the activation event the view is not on the DOM, and no panel
      // has been created
      expect(workspaceElement.querySelector('.multi-theme-applicator')).not.toExist();

      // This is an activation event, triggering it will cause the package to be
      // activated.
      atom.commands.dispatch(workspaceElement, 'multi-theme-applicator:toggle');

      waitsForPromise(() => {
        return activationPromise;
      });

      runs(() => {
        expect(workspaceElement.querySelector('.local-theme-selector-view')).toExist();

        let multiThemeApplicatorElement = workspaceElement.querySelector('.local-theme-selector-view');
        expect(multiThemeApplicatorElement).toExist();

        let multiThemeApplicatorPanel = atom.workspace.panelForItem(multiThemeApplicatorElement);
        expect(multiThemeApplicatorPanel.isVisible()).toBe(true);
        atom.commands.dispatch(workspaceElement, 'multi-theme-applicator:toggle');
        expect(multiThemeApplicatorPanel.isVisible()).toBe(false);
      });
    });
  });

});
