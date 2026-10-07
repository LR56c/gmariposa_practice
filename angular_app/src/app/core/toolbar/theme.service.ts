import { DOCUMENT } from '@angular/common';
import { Injectable, inject, signal } from '@angular/core';

export type Theme = 'system' | 'light' | 'dark';

export const THEME_KEY = 'theme';
const THEMES: readonly Theme[] = ['system', 'light', 'dark'];

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
    localStorage.setItem(THEME_KEY, theme);
    this.apply();
  }

  private read(): Theme {
    const saved = localStorage.getItem(THEME_KEY) as Theme | null;
    return saved && THEMES.includes(saved) ? saved : 'system';
  }

  private apply(): void {
    const theme = this.state();
    const dark = theme === 'dark' || (theme === 'system' && !!this.darkQuery?.matches);
    this.document.documentElement.classList.toggle('dark', dark);
  }
}
