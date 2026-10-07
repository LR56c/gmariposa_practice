import { TestBed } from '@angular/core/testing';
import { OrderCardComponent } from './order-card.component';

describe('OrderCardComponent', () => {
  it('emits the order id when "Ver detalle" is clicked', () => {
    const fixture = TestBed.createComponent(OrderCardComponent);
    fixture.componentRef.setInput('order', { id: 5, userId: 1, total: 10, products: [] });
    const emitted: number[] = [];
    fixture.componentInstance.viewDetail.subscribe((id) => emitted.push(id));
    fixture.detectChanges();
    const button: HTMLButtonElement = fixture.nativeElement.querySelector('button');
    button.click();
    expect(emitted).toEqual([5]);
    expect(button.getAttribute('aria-label')).toBe('Ver detalle de la orden 5');
  });
});
