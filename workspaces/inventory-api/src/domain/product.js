import { InventoryDomainError, INVENTORY_ERROR_CODES } from './inventory-errors.js';

const MINIMUM_INITIAL_STOCK = 0;
const MINIMUM_RESERVATION_QUANTITY = 1;
const NO_RESERVED_STOCK = 0;

export function createProduct({ id, name, stock }) {
  const productName = normalizeProductName(name);
  ensureValidInitialStock(stock);

  return Object.freeze({
    id,
    name: productName,
    stock,
    reservedStock: NO_RESERVED_STOCK
  });
}

export function reserveStock(product, reservationQuantity) {
  ensureValidReservationQuantity(reservationQuantity);

  const availableStock = getAvailableStock(product);
  if (reservationQuantity > availableStock) {
    throw new InventoryDomainError(INVENTORY_ERROR_CODES.INSUFFICIENT_STOCK, {
      productId: product.id,
      requestedQuantity: reservationQuantity,
      availableStock
    });
  }

  return Object.freeze({
    ...product,
    reservedStock: product.reservedStock + reservationQuantity
  });
}

export function getAvailableStock(product) {
  return product.stock - product.reservedStock;
}

function normalizeProductName(name) {
  if (typeof name !== 'string') {
    throw new InventoryDomainError(INVENTORY_ERROR_CODES.INVALID_PRODUCT_NAME);
  }

  const productName = name.trim();
  if (productName.length === 0) {
    throw new InventoryDomainError(INVENTORY_ERROR_CODES.INVALID_PRODUCT_NAME);
  }

  return productName;
}

function ensureValidInitialStock(stock) {
  if (!Number.isInteger(stock) || stock < MINIMUM_INITIAL_STOCK) {
    throw new InventoryDomainError(INVENTORY_ERROR_CODES.INVALID_STOCK_QUANTITY, { stock });
  }
}

function ensureValidReservationQuantity(reservationQuantity) {
  if (!Number.isInteger(reservationQuantity) || reservationQuantity < MINIMUM_RESERVATION_QUANTITY) {
    throw new InventoryDomainError(INVENTORY_ERROR_CODES.INVALID_RESERVATION_QUANTITY, {
      reservationQuantity
    });
  }
}
