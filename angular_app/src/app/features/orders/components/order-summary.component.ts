import { ChangeDetectionStrategy, Component, input } from '@angular/core';
import { AmountPipe } from '../pipes/amount.pipe';
import { Order } from '../data/order.schema';

/** Id, userId and totals block shared by the order card and the detail (Stitch "Órdenes"). */
@Component({
  selector: 'app-order-summary',
  imports: [AmountPipe],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './order-summary.component.html',
})
export class OrderSummaryComponent {
  readonly order = input.required<Order>();
}
