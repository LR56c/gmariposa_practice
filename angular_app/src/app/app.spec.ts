import { TestBed } from '@angular/core/testing';
import { App } from './app';

describe('App', () => {
  it('renders the Órdenes title', async () => {
    const fixture = TestBed.createComponent(App);
    await fixture.whenStable();
    const title = (fixture.nativeElement as HTMLElement).querySelector('h1');
    expect(title?.textContent).toContain('Órdenes');
  });
});
