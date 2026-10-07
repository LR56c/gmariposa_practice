import { DOCUMENT } from '@angular/common';
import { ChangeDetectionStrategy, Component, LOCALE_ID, inject } from '@angular/core';
import { Theme, ThemeService } from './theme.service';

@Component({
  selector: 'app-toolbar',
  templateUrl: './toolbar.component.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ToolbarComponent {
  private readonly location = inject(DOCUMENT).location;
  protected readonly locale = inject(LOCALE_ID);
  protected readonly themes = inject(ThemeService);

  // build-time i18n ships one bundle per locale (/es/, /en/), so switching language
  // means loading the other bundle. `ng serve` serves a single locale, where this is a no-op.
  protected setLanguage(target: string): void {
    const next = this.location.pathname.replace(`/${this.locale}/`, `/${target}/`);
    if (next !== this.location.pathname) {
      this.location.assign(next + this.location.search + this.location.hash);
    }
  }

  protected setTheme(theme: string): void {
    this.themes.set(theme as Theme);
  }
}
