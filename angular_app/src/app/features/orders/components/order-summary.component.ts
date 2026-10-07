import { ChangeDetectionStrategy, Component, input } from '@angular/core';
import { AmountPipe } from '../pipes/amount.pipe';
import { Order } from '../data/order.schema';

/** Id, userId and totals block shared by the order card and the detail (Stitch "Órdenes"). */
@Component({
  selector: 'app-order-summary',
  imports: [AmountPipe],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div class="flex items-center justify-between border-b border-divider pb-4">
      <div>
        <span
          class="text-label-md font-semibold uppercase tracking-wide text-primary"
          i18n="@@order.idLabel"
        >
          ID de orden
        </span>
        <h2 class="mt-0.5 text-title-lg">{{ order().id }}</h2>
      </div>
      <div class="text-right">
        <span class="text-label-md text-on-surface-muted" i18n="@@order.userLabel">Usuario</span>
        <p class="text-body-md font-medium">{{ order().userId }}</p>
      </div>
    </div>
    <dl class="my-4 grid grid-cols-2 gap-4 rounded-lg bg-surface/60 p-3.5">
      <div>
        <dt class="text-label-md text-on-surface-muted" i18n="@@order.totalLabel">Total</dt>
        <dd class="text-title-md">{{ order().total | amount }}</dd>
      </div>
      @if (order().discountedTotal; as discounted) {
        <div>
          <dt class="text-label-md text-on-surface-muted" i18n="@@order.discountedLabel">
            Total con descuento
          </dt>
          <dd class="text-price">{{ discounted | amount }}</dd>
        </div>
      }
    </dl>
  `,
})
export class OrderSummaryComponent {
  readonly order = input.required<Order>();
}
