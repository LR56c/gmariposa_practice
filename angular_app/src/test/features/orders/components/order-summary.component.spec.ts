import { TestBed } from '@angular/core/testing';
import { OrderSummaryComponent } from '../../../../app/features/orders/components/order-summary.component';

describe('OrderSummaryComponent', () => {
  function render(discountedTotal?: number): string {
    const fixture = TestBed.createComponent(OrderSummaryComponent);
    fixture.componentRef.setInput('order', {
      id: 1,
      userId: 2,
      total: 10,
      products: [],
      ...(discountedTotal === undefined ? {} : { discountedTotal }),
    });
    fixture.detectChanges();
    return fixture.nativeElement.textContent;
  }

  it('shows the discounted total, even when it is 0', () => {
    expect(render(0)).toContain('0.00');
    expect(render(7.5)).toContain('7.50');
  });

  it('hides the discounted block when there is none', () => {
    expect(render()).not.toContain('descuento');
  });
});
