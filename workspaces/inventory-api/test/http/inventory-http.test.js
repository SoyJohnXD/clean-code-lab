import test from 'node:test';
import assert from 'node:assert/strict';
import { InventoryService } from '../../src/application/inventory-service.js';
import { createInventoryServer } from '../../src/http/create-server.js';
import {
  buildProductReservationPath,
  HTTP_ERROR_MESSAGES,
  HTTP_METHODS,
  HTTP_STATUS,
  ROUTES
} from '../../src/http/http-constants.js';
import { InMemoryProductRepository, SequentialProductIdGenerator } from '../../src/infrastructure/in-memory-product-repository.js';
import { INVENTORY_ERROR_CODES } from '../../src/domain/inventory-errors.js';

const LOCALHOST = '127.0.0.1';
const EPHEMERAL_PORT = 0;
const PRODUCT_NAME = 'Keyboard';
const INITIAL_STOCK = 5;
const RESERVATION_QUANTITY = 2;
const EXCESSIVE_RESERVATION_QUANTITY = 6;
const EXPECTED_PRODUCT_ID = 'product-1';
const FIRST_PRODUCT_INDEX = 0;
const UNEXPECTED_ERROR_MESSAGE = 'database connection failed';

function createTestServer() {
  const inventoryService = new InventoryService({
    productRepository: new InMemoryProductRepository(),
    productIdGenerator: new SequentialProductIdGenerator()
  });
  const server = createInventoryServer({ inventoryService });

  return startServer(server);
}

function startServer(server) {
  return new Promise(resolve => {
    server.listen(EPHEMERAL_PORT, LOCALHOST, () => {
      const address = server.address();
      resolve({ server, baseUrl: `http://${address.address}:${address.port}` });
    });
  });
}

async function closeServer(server) {
  await new Promise((resolve, reject) => {
    server.close(error => (error ? reject(error) : resolve()));
  });
}

async function requestJson(baseUrl, { method, path, body }) {
  const response = await fetch(`${baseUrl}${path}`, {
    method,
    body: body ? JSON.stringify(body) : undefined,
    headers: body ? { 'content-type': 'application/json' } : undefined
  });

  return {
    status: response.status,
    body: await response.json()
  };
}

test('HTTP API creates and lists products', async () => {
  const { server, baseUrl } = await createTestServer();

  try {
    const createResponse = await requestJson(baseUrl, {
      method: HTTP_METHODS.POST,
      path: ROUTES.PRODUCTS,
      body: { name: PRODUCT_NAME, stock: INITIAL_STOCK }
    });
    const listResponse = await requestJson(baseUrl, {
      method: HTTP_METHODS.GET,
      path: ROUTES.PRODUCTS
    });

    assert.equal(createResponse.status, HTTP_STATUS.CREATED);
    assert.equal(createResponse.body.product.id, EXPECTED_PRODUCT_ID);
    assert.equal(listResponse.status, HTTP_STATUS.OK);
    assert.deepEqual(listResponse.body.products[FIRST_PRODUCT_INDEX], createResponse.body.product);
  } finally {
    await closeServer(server);
  }
});

test('HTTP API reserves stock for a product', async () => {
  const { server, baseUrl } = await createTestServer();

  try {
    const createResponse = await requestJson(baseUrl, {
      method: HTTP_METHODS.POST,
      path: ROUTES.PRODUCTS,
      body: { name: PRODUCT_NAME, stock: INITIAL_STOCK }
    });
    const reserveResponse = await requestJson(baseUrl, {
      method: HTTP_METHODS.POST,
      path: buildProductReservationPath(createResponse.body.product.id),
      body: { quantity: RESERVATION_QUANTITY }
    });

    assert.equal(reserveResponse.status, HTTP_STATUS.OK);
    assert.equal(reserveResponse.body.product.reservedStock, RESERVATION_QUANTITY);
  } finally {
    await closeServer(server);
  }
});

test('HTTP API rejects reservations above available stock', async () => {
  const { server, baseUrl } = await createTestServer();

  try {
    const createResponse = await requestJson(baseUrl, {
      method: HTTP_METHODS.POST,
      path: ROUTES.PRODUCTS,
      body: { name: PRODUCT_NAME, stock: INITIAL_STOCK }
    });
    const reserveResponse = await requestJson(baseUrl, {
      method: HTTP_METHODS.POST,
      path: buildProductReservationPath(createResponse.body.product.id),
      body: { quantity: EXCESSIVE_RESERVATION_QUANTITY }
    });

    assert.equal(reserveResponse.status, HTTP_STATUS.BAD_REQUEST);
    assert.equal(reserveResponse.body.code, INVENTORY_ERROR_CODES.INSUFFICIENT_STOCK);
  } finally {
    await closeServer(server);
  }
});

test('HTTP API logs unexpected errors before returning a generic server error', async () => {
  const capturedErrors = [];
  const logger = {
    error(error) {
      capturedErrors.push(error);
    }
  };
  const failingInventoryService = {
    createProduct() {
      throw new Error(UNEXPECTED_ERROR_MESSAGE);
    }
  };
  const server = createInventoryServer({ inventoryService: failingInventoryService, logger });

  const { baseUrl } = await startServer(server);

  try {
    const createResponse = await requestJson(baseUrl, {
      method: HTTP_METHODS.POST,
      path: ROUTES.PRODUCTS,
      body: { name: PRODUCT_NAME, stock: INITIAL_STOCK }
    });

    assert.equal(createResponse.status, HTTP_STATUS.INTERNAL_SERVER_ERROR);
    assert.equal(createResponse.body.error, HTTP_ERROR_MESSAGES.INTERNAL_SERVER_ERROR);
    assert.equal(capturedErrors[0].message, UNEXPECTED_ERROR_MESSAGE);
  } finally {
    await closeServer(server);
  }
});
