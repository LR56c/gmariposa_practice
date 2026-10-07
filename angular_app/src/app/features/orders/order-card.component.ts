import { ChangeDetectionStrategy, Component, computed, input, output } from '@angular/core';
import { AmountPipe } from './amount.pipe';
import { Order } from './order.schema';

@Component({
  selector: 'app-order-card',
  imports: [AmountPipe],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <article class="rounded-lg bg-surface-tonal p-4">
      <h2 class="text-title-md" i18n="@@order.title">Orden {{ order().id }}</h2>
      <p class="text-on-surface-muted" i18n="@@order.user">Usuario {{ order().userId }}</p>
      <p class="text-price" i18n="@@order.total">Total {{ order().total | amount }}</p>
      @if (order().discountedTotal; as discounted) {
        <p class="text-body-md text-on-surface-muted" i18n="@@order.discounted">
          Con descuento {{ discounted | amount }}
        </p>
      }
      <button
        type="button"
        class="mt-3 rounded-full bg-placeholder px-4 py-2 text-label-md text-on-placeholder focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-focus"
        [attr.aria-label]="detailLabel()"
        (click)="viewDetail.emit(order().id)"
        i18n="@@order.detail"
      >
        Ver detalle
      </button>
    </article>
  `,
})
export class OrderCardComponent {
  readonly order = input.required<Order>();
  readonly viewDetail = output<number>();

  protected readonly detailLabel = computed(
    () => $localize`:@@order.detailLabel:Ver detalle de la orden ${this.order().id}:id:`,
  );
}
