import { ChangeDetectionStrategy, Component, computed, input, output } from '@angular/core';
import { Order } from '../data/order.schema';
import { OrderSummaryComponent } from './order-summary.component';

@Component({
  selector: 'app-order-card',
  imports: [OrderSummaryComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './order-card.component.html',
})
export class OrderCardComponent {
  readonly order = input.required<Order>();
  readonly viewDetail = output<number>();

  protected readonly detailLabel = computed(
    () => $localize`:@@order.detailLabel:Ver detalle de la orden ${this.order().id}:id:`,
  );
}
