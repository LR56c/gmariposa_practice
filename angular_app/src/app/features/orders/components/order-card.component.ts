import { ChangeDetectionStrategy, Component, computed, input, output } from '@angular/core';
import { Order } from '../data/order.schema';
import { OrderSummaryComponent } from './order-summary.component';

@Component({
  selector: 'app-order-card',
  imports: [OrderSummaryComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <article class="flex flex-col rounded-lg bg-surface-tonal p-6">
      <app-order-summary [order]="order()" />
      <div class="flex justify-end pt-2">
        <button
          type="button"
          class="min-h-12 rounded-full bg-surface px-5 py-2 text-label-md text-primary hover:bg-divider focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-focus"
          [attr.aria-label]="detailLabel()"
          (click)="viewDetail.emit(order().id)"
          i18n="@@order.detail"
        >
          Ver detalle
        </button>
      </div>
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
