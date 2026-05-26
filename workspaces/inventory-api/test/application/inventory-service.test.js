import test from 'node:test';
import assert from 'node:assert/strict';
import { InventoryService } from '../../src/application/inventory-service.js';
import { INVENTORY_ERROR_CODES } from '../../src/domain/inventory-errors.js';
import { InMemoryProductRepository, SequentialProductIdGenerator } from '../../src/infrastructure/in-memory-product-repository.js';

const PRODUCT_NAME = 'Keyboard';
const INITIAL_STOCK = 5;
const RESERVATION_QUANTITY = 3;
const EXCESSIVE_RESERVATION_QUANTITY = 6;
const EXPECTED_PRODUCT_ID = 'product-1';
const FIRST_PRODUCT_INDEX = 0;

function createInventoryService() {
  return new InventoryService({
    productRepository: new InMemoryProductRepository(),
    productIdGenerator: new SequentialProductIdGenerator()
  });
}

test('InventoryService creates and lists products', () => {
  const inventoryService = createInventoryService();

  const createdProduct = inventoryService.createProduct({
    name: PRODUCT_NAME,
    stock: INITIAL_STOCK
  });
  const products = inventoryService.listProducts();

  assert.equal(createdProduct.id, EXPECTED_PRODUCT_ID);
  assert.deepEqual(products[FIRST_PRODUCT_INDEX], createdProduct);
});

test('InventoryService reserves stock for an existing product', () => {
  const inventoryService = createInventoryService();
  const product = inventoryService.createProduct({ name: PRODUCT_NAME, stock: INITIAL_STOCK });

  const reservedProduct = inventoryService.reserveStock({
    productId: product.id,
    quantity: RESERVATION_QUANTITY
  });

  assert.equal(reservedProduct.reservedStock, RESERVATION_QUANTITY);
});

test('InventoryService rejects reservations that exceed available stock', () => {
  const inventoryService = createInventoryService();
  const product = inventoryService.createProduct({ name: PRODUCT_NAME, stock: INITIAL_STOCK });

  assert.throws(
    () => inventoryService.reserveStock({ productId: product.id, quantity: EXCESSIVE_RESERVATION_QUANTITY }),
    { code: INVENTORY_ERROR_CODES.INSUFFICIENT_STOCK }
  );
});

test('InventoryService rejects reservations for unknown products', () => {
  const inventoryService = createInventoryService();
  const unknownProductId = 'unknown-product';

  assert.throws(
    () => inventoryService.reserveStock({ productId: unknownProductId, quantity: RESERVATION_QUANTITY }),
    { code: INVENTORY_ERROR_CODES.PRODUCT_NOT_FOUND }
  );
});
