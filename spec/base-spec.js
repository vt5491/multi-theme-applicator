/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const Base = require('../lib/base');

describe('Base', () => it('class variables are defined', function() {
  expect(Base.ElementLookup).toBeTruthy();
  expect(Base.ThemeLookup).toBeTruthy();
  return expect(Base.FileTypeLookup).toBeTruthy();
}));
