import test from 'node:test';
import assert from 'node:assert/strict';
import { createProduct, getAvailableStock, reserveStock } from '../../src/domain/product.js';
import { INVENTORY_ERROR_CODES } from '../../src/domain/inventory-errors.js';

const PRODUCT_ID = 'product-1';
const PRODUCT_NAME_WITH_PADDING = '  Keyboard  ';
const NORMALIZED_PRODUCT_NAME = 'Keyboard';
const INITIAL_STOCK = 5;
const RESERVATION_QUANTITY = 2;
const EXCESSIVE_RESERVATION_QUANTITY = 6;
const ZERO_STOCK = 0;
const ZERO_RESERVATION_QUANTITY = 0;

test('createProduct normalizes the name and starts with no reserved stock', () => {
  const product = createProduct({
    id: PRODUCT_ID,
    name: PRODUCT_NAME_WITH_PADDING,
    stock: INITIAL_STOCK
  });

  assert.deepEqual(product, {
    id: PRODUCT_ID,
    name: NORMALIZED_PRODUCT_NAME,
    stock: INITIAL_STOCK,
    reservedStock: ZERO_STOCK
  });
});

test('createProduct rejects an empty product name', () => {
  assert.throws(
    () => createProduct({ id: PRODUCT_ID, name: ' ', stock: INITIAL_STOCK }),
    { code: INVENTORY_ERROR_CODES.INVALID_PRODUCT_NAME }
  );
});

test('createProduct rejects negative stock', () => {
  const negativeStock = -1;

  assert.throws(
    () => createProduct({ id: PRODUCT_ID, name: NORMALIZED_PRODUCT_NAME, stock: negativeStock }),
    { code: INVENTORY_ERROR_CODES.INVALID_STOCK_QUANTITY }
  );
});

test('reserveStock increases reserved stock and lowers available stock', () => {
  const product = createProduct({
    id: PRODUCT_ID,
    name: NORMALIZED_PRODUCT_NAME,
    stock: INITIAL_STOCK
  });

  const reservedProduct = reserveStock(product, RESERVATION_QUANTITY);

  assert.equal(reservedProduct.reservedStock, RESERVATION_QUANTITY);
  assert.equal(getAvailableStock(reservedProduct), INITIAL_STOCK - RESERVATION_QUANTITY);
});

test('reserveStock rejects reservation quantities above available stock', () => {
  const product = createProduct({
    id: PRODUCT_ID,
    name: NORMALIZED_PRODUCT_NAME,
    stock: INITIAL_STOCK
  });

  assert.throws(
    () => reserveStock(product, EXCESSIVE_RESERVATION_QUANTITY),
    { code: INVENTORY_ERROR_CODES.INSUFFICIENT_STOCK }
  );
});

test('reserveStock rejects non-positive reservation quantities', () => {
  const product = createProduct({
    id: PRODUCT_ID,
    name: NORMALIZED_PRODUCT_NAME,
    stock: INITIAL_STOCK
  });

  assert.throws(
    () => reserveStock(product, ZERO_RESERVATION_QUANTITY),
    { code: INVENTORY_ERROR_CODES.INVALID_RESERVATION_QUANTITY }
  );
});
