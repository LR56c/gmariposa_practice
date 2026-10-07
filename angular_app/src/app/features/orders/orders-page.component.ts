import { ChangeDetectionStrategy, Component, effect, inject } from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { Router } from '@angular/router';
import { FormControl, ReactiveFormsModule } from '@angular/forms';
import { OrderCardComponent } from './order-card.component';
import { OrdersStore } from './orders.store';

@Component({
  selector: 'app-orders-page',
  imports: [OrderCardComponent, ReactiveFormsModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <main class="mx-auto max-w-5xl p-4">
      <h1 class="mb-4 text-title-lg" i18n="@@orders.title">Órdenes</h1>
      <div class="mb-4 flex flex-col gap-1">
        <label for="min-total" class="text-label-md" i18n="@@orders.minTotal">Total mínimo</label>
        <input
          id="min-total"
          type="text"
          inputmode="decimal"
          autocomplete="off"
          class="w-48 rounded-lg border border-outline bg-surface px-3 py-2 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-focus disabled:opacity-50"
          [formControl]="minTotal"
        />
      </div>
      <div aria-live="polite">
        @switch (store.listStatus()) {
          @case ('loading') {
            <div role="status" class="mx-auto grid gap-4 lg:grid-cols-2">
              <span class="sr-only" i18n="@@orders.loading">Cargando órdenes</span>
              @for (n of skeletons; track n) {
                <div aria-hidden="true" class="flex flex-col gap-2 rounded-lg bg-surface-tonal p-4">
                  <span class="block h-5 w-1/3 animate-pulse rounded bg-outline/40"></span>
                  <span class="block h-4 w-1/4 animate-pulse rounded bg-outline/40"></span>
                  <span class="block h-6 w-1/2 animate-pulse rounded bg-outline/40"></span>
                  <span class="mt-1 block h-9 w-28 animate-pulse rounded-full bg-outline/40"></span>
                </div>
              }
            </div>
          }
          @case ('error') {
            <div role="alert" class="flex flex-col items-start gap-2">
              <p>{{ store.listError()?.message }}</p>
              <button
                type="button"
                class="rounded-full bg-placeholder px-4 py-2 text-label-md text-on-placeholder focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-focus"
                (click)="store.load()"
                i18n="@@orders.retry"
              >
                Reintentar
              </button>
            </div>
          }
          @case ('loaded') {
            <p class="sr-only" i18n="@@orders.count">
              {store.visibleOrders().length, plural, =1 {1 orden} other {{{ store.visibleOrders().length }} órdenes}}
            </p>
            <div class="mx-auto grid gap-4 lg:grid-cols-2">
              @for (order of store.visibleOrders(); track order.id) {
                <app-order-card [order]="order" (viewDetail)="openDetail($event)" />
              } @empty {
                <p class="text-on-surface-muted" i18n="@@orders.noMatch">
                  Ninguna orden alcanza ese total
                </p>
              }
            </div>
          }
        }
      </div>
    </main>
  `,
})
export class OrdersPageComponent {
  protected readonly store = inject(OrdersStore);
  private readonly router = inject(Router);
  protected readonly skeletons = [1, 2, 3, 4, 5, 6];

  protected readonly minTotal = new FormControl(String(this.store.minTotal() ?? ''), { nonNullable: true });

  constructor() {
    this.minTotal.valueChanges.pipe(takeUntilDestroyed()).subscribe((v) => this.store.setMinTotal(v));
    effect(() => {
      if (this.store.listStatus() === 'loaded') this.minTotal.enable({ emitEvent: false });
      else this.minTotal.disable({ emitEvent: false });
    });
    this.store.load();
  }

  protected openDetail(id: number): void {
    void this.router.navigate(['/orders', id]);
  }
}
