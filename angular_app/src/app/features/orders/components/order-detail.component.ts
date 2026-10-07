import {
  ChangeDetectionStrategy,
  Component,
  computed,
  effect,
  inject,
  input,
  untracked,
} from '@angular/core';
import { RouterLink } from '@angular/router';
import { AmountPipe } from '../pipes/amount.pipe';
import { OrderSummaryComponent } from './order-summary.component';
import { OrdersStore } from '../state/orders.store';
import { Errors, ServerException, toErrorInfo } from '../../../core/errors/errors';

@Component({
  selector: 'app-order-detail',
  imports: [AmountPipe, OrderSummaryComponent, RouterLink],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './order-detail.component.html',
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
