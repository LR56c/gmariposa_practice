import { ChangeDetectionStrategy, Component, input } from '@angular/core';
import { AmountPipe } from './amount.pipe';
import { Order } from './order.schema';

@Component({
  selector: 'app-order-card',
  imports: [AmountPipe],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <article class="rounded-lg bg-surface-tonal p-4">
      <h2 class="text-title-md">Orden {{ order().id }}</h2>
      <p class="text-on-surface-muted">Usuario {{ order().userId }}</p>
      <p class="text-price">Total {{ order().total | amount }}</p>
      @if (order().discountedTotal; as discounted) {
        <p class="text-body-md text-on-surface-muted">Con descuento {{ discounted | amount }}</p>
      }
    </article>
  `,
})
export class OrderCardComponent {
  readonly order = input.required<Order>();
}
