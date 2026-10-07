import { TestBed } from '@angular/core/testing';
import { THEME_KEY, ThemeService, isTheme } from '../../../app/core/toolbar/theme.service';

describe('ThemeService', () => {
  beforeEach(() => {
    localStorage.clear();
    document.documentElement.classList.remove('dark');
  });

  afterEach(() => vi.restoreAllMocks());

  it('applies the dark class and persists the choice', () => {
    const service = TestBed.inject(ThemeService);
    service.set('dark');
    expect(document.documentElement.classList.contains('dark')).toBe(true);
    expect(localStorage.getItem(THEME_KEY)).toBe('dark');
    service.set('light');
    expect(document.documentElement.classList.contains('dark')).toBe(false);
  });

  it('ignores an invalid stored value', () => {
    localStorage.setItem(THEME_KEY, 'neon');
    expect(TestBed.inject(ThemeService).theme()).toBe('system');
  });

  it('still works when storage is blocked', () => {
    const blocked = () => {
      throw new Error('blocked');
    };
    vi.spyOn(Storage.prototype, 'getItem').mockImplementation(blocked);
    vi.spyOn(Storage.prototype, 'setItem').mockImplementation(blocked);

    const service = TestBed.inject(ThemeService);
    expect(service.theme()).toBe('system');
    service.set('dark');

    expect(service.theme()).toBe('dark');
    expect(document.documentElement.classList.contains('dark')).toBe(true);
  });

  it('isTheme accepts only the three themes', () => {
    for (const ok of ['system', 'light', 'dark']) expect(isTheme(ok)).toBe(true);
    for (const bad of ['neon', '', null, undefined, 1]) expect(isTheme(bad)).toBe(false);
  });
});
