export const INVENTORY_ERROR_CODES = Object.freeze({
  INVALID_PRODUCT_NAME: 'INVALID_PRODUCT_NAME',
  INVALID_STOCK_QUANTITY: 'INVALID_STOCK_QUANTITY',
  INVALID_RESERVATION_QUANTITY: 'INVALID_RESERVATION_QUANTITY',
  INSUFFICIENT_STOCK: 'INSUFFICIENT_STOCK',
  PRODUCT_NOT_FOUND: 'PRODUCT_NOT_FOUND'
});

export const INVENTORY_ERROR_MESSAGES = Object.freeze({
  [INVENTORY_ERROR_CODES.INVALID_PRODUCT_NAME]: 'Product name must not be empty.',
  [INVENTORY_ERROR_CODES.INVALID_STOCK_QUANTITY]: 'Product stock must be a whole number greater than or equal to zero.',
  [INVENTORY_ERROR_CODES.INVALID_RESERVATION_QUANTITY]: 'Reservation quantity must be a whole number greater than zero.',
  [INVENTORY_ERROR_CODES.INSUFFICIENT_STOCK]: 'Reservation quantity exceeds available stock.',
  [INVENTORY_ERROR_CODES.PRODUCT_NOT_FOUND]: 'Product was not found.'
});

export class InventoryDomainError extends Error {
  constructor(code, details = {}) {
    super(INVENTORY_ERROR_MESSAGES[code]);
    this.name = 'InventoryDomainError';
    this.code = code;
    this.details = details;
  }
}
