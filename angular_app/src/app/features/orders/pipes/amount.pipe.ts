import { Pipe, PipeTransform } from '@angular/core';

// Two decimals, dot, no thousands separator, no currency symbol (UX-DR15).
@Pipe({ name: 'amount' })
export class AmountPipe implements PipeTransform {
  transform(value: number): string {
    return value.toFixed(2);
  }
}
