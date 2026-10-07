import { TestBed } from '@angular/core/testing';
import { THEME_KEY, ThemeService } from '../../../app/core/toolbar/theme.service';

describe('ThemeService', () => {
  beforeEach(() => {
    localStorage.clear();
    document.documentElement.classList.remove('dark');
  });

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
});
