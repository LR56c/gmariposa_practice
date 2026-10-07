import { Schema } from 'effect';

const OrderProductSchema = Schema.Struct({
  id: Schema.Number,
  title: Schema.String,
  quantity: Schema.Number,
  price: Schema.Number,
});

export const OrderSchema = Schema.Struct({
  id: Schema.Number,
  userId: Schema.Number,
  total: Schema.Number,
  discountedTotal: Schema.optionalKey(Schema.Number),
  products: Schema.Array(OrderProductSchema),
});

export type Order = Schema.Schema.Type<typeof OrderSchema>;

export const OrdersResponseSchema = Schema.Struct({ carts: Schema.Array(OrderSchema) });
