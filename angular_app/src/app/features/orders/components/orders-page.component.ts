import { ChangeDetectionStrategy, Component, effect, inject } from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { Router } from '@angular/router';
import { FormControl, ReactiveFormsModule } from '@angular/forms';
import { OrderCardComponent } from './order-card.component';
import { OrdersStore } from '../state/orders.store';

@Component({
  selector: 'app-orders-page',
  imports: [OrderCardComponent, ReactiveFormsModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './orders-page.component.html',
})
export class OrdersPageComponent {
  protected readonly store = inject(OrdersStore);
  private readonly router = inject(Router);
  protected readonly skeletons = [1, 2, 3, 4, 5, 6];

  protected readonly minTotal = new FormControl(String(this.store.minTotal() ?? ''), {
    nonNullable: true,
  });

  constructor() {
    this.minTotal.valueChanges
      .pipe(takeUntilDestroyed())
      .subscribe((v) => this.store.setMinTotal(v));
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
