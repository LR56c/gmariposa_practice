import { ChangeDetectionStrategy, Component, computed, effect, inject, input, untracked } from '@angular/core';
import { RouterLink } from '@angular/router';
import { AmountPipe } from './amount.pipe';
import { OrdersStore } from './orders.store';
import { Errors, ServerException, toErrorInfo } from '../../core/errors/errors';

@Component({
  selector: 'app-order-detail',
  imports: [AmountPipe, RouterLink],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <main class="mx-auto max-w-5xl p-4">
      <a
        routerLink="/"
        class="mb-4 inline-block text-label-md underline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-focus"
        i18n="@@detail.back"
        >Volver a órdenes</a
      >
      <div aria-live="polite">
        @if (invalidId()) {
          <p role="alert">{{ notFound.message }}</p>
        } @else if (order(); as o) {
          <h1 class="mb-2 text-title-lg" i18n="@@order.title">Orden {{ o.id }}</h1>
          <p class="text-on-surface-muted" i18n="@@order.user">Usuario {{ o.userId }}</p>
          <p class="text-price" i18n="@@order.total">Total {{ o.total | amount }}</p>
          @if (o.discountedTotal; as discounted) {
            <p class="text-body-md text-on-surface-muted" i18n="@@order.discounted">
              Con descuento {{ discounted | amount }}
            </p>
          }
          @if (o.products.length === 0) {
            <p class="mt-4 text-on-surface-muted" i18n="@@detail.empty">Esta orden no tiene productos</p>
          } @else {
            <table class="mt-4 w-full text-left">
              <thead>
                <tr>
                  <th scope="col" i18n="@@detail.colTitle">Título</th>
                  <th scope="col" i18n="@@detail.colQuantity">Cantidad</th>
                  <th scope="col" i18n="@@detail.colPrice">Precio</th>
                </tr>
              </thead>
              <tbody>
                @for (p of o.products; track p.id) {
                  <tr>
                    <td>{{ p.title }}</td>
                    <td>{{ p.quantity }}</td>
                    <td>{{ p.price | amount }}</td>
                  </tr>
                }
              </tbody>
            </table>
          }
        } @else if (status() === 'error') {
          <div role="alert" class="flex flex-col items-start gap-2">
            <p>{{ error()?.message }}</p>
            <button
              type="button"
              class="rounded-full bg-placeholder px-4 py-2 text-label-md text-on-placeholder focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-focus"
              (click)="load()"
              i18n="@@orders.retry"
            >
              Reintentar
            </button>
          </div>
        } @else {
          <div role="status" class="flex flex-col gap-2">
            <span class="sr-only" i18n="@@detail.loading">Cargando orden</span>
            <span aria-hidden="true" class="block h-7 w-1/4 animate-pulse rounded bg-outline/40"></span>
            <span aria-hidden="true" class="block h-4 w-1/5 animate-pulse rounded bg-outline/40"></span>
            <span aria-hidden="true" class="block h-6 w-1/3 animate-pulse rounded bg-outline/40"></span>
            @for (n of skeletons; track n) {
              <span aria-hidden="true" class="mt-2 block h-5 w-full animate-pulse rounded bg-outline/40"></span>
            }
          </div>
        }
      </div>
    </main>
  `,
})
export class OrderDetailComponent {
  private readonly store = inject(OrdersStore);
  protected readonly skeletons = [1, 2, 3];

  /** Parsed to number (or null if not numeric) by the route resolver, once. */
  readonly id = input.required<number | null>();

  protected readonly notFound = toErrorInfo(new Errors([new ServerException(404)]));
  protected readonly invalidId = computed(() => this.id() === null);
  protected readonly order = computed(() => {
    const id = this.id();
    return id === null ? undefined : this.store.order(id);
  });
  protected readonly status = computed(() => {
    const id = this.id();
    return id === null ? 'idle' : this.store.orderStatus(id);
  });
  protected readonly error = computed(() => {
    const id = this.id();
    return id === null ? null : this.store.orderError(id);
  });

  constructor() {
    // Inputs are not set in the constructor; untracked so a failed load is not retried by the effect.
    effect(() => {
      const id = this.id();
      if (id !== null) untracked(() => this.store.loadOrder(id));
    });
  }

  protected load(): void {
    const id = this.id();
    if (id !== null) this.store.loadOrder(id);
  }
}
