import { DOCUMENT } from '@angular/common';
import { Injectable, inject, signal } from '@angular/core';

export type Theme = 'system' | 'light' | 'dark';

export const THEME_KEY = 'theme';
const THEMES: readonly Theme[] = ['system', 'light', 'dark'];

export function isTheme(value: unknown): value is Theme {
  return THEMES.some((t) => t === value);
}

@Injectable({ providedIn: 'root' })
export class ThemeService {
  private readonly document = inject(DOCUMENT);
  private readonly darkQuery = this.document.defaultView?.matchMedia?.(
    '(prefers-color-scheme: dark)',
  );
  private readonly state = signal<Theme>(this.read());
  readonly theme = this.state.asReadonly();

  constructor() {
    this.apply();
    this.darkQuery?.addEventListener('change', () => this.apply());
  }

  set(theme: Theme): void {
    this.state.set(theme);
    try {
      localStorage.setItem(THEME_KEY, theme);
    } catch {
      // Storage blocked (private mode, quota): the choice just won't persist.
    }
    this.apply();
  }

  private read(): Theme {
    try {
      const saved = localStorage.getItem(THEME_KEY);
      return isTheme(saved) ? saved : 'system';
    } catch {
      return 'system'; // Storage blocked: follow the system theme.
    }
  }

  private apply(): void {
    const theme = this.state();
    const dark = theme === 'dark' || (theme === 'system' && !!this.darkQuery?.matches);
    this.document.documentElement.classList.toggle('dark', dark);
  }
}
