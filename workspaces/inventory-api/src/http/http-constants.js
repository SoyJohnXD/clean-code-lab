export const HTTP_METHODS = Object.freeze({
  GET: 'GET',
  POST: 'POST'
});

export const ROUTES = Object.freeze({
  PRODUCTS: '/products',
  PRODUCT_RESERVATIONS: '/products/:productId/reservations'
});

export function buildProductReservationPath(productId) {
  return `/products/${productId}/reservations`;
}

export const CONTENT_TYPES = Object.freeze({
  JSON: 'application/json'
});

export const HTTP_STATUS = Object.freeze({
  OK: 200,
  CREATED: 201,
  BAD_REQUEST: 400,
  NOT_FOUND: 404,
  METHOD_NOT_ALLOWED: 405,
  INTERNAL_SERVER_ERROR: 500
});

export const HTTP_ERROR_MESSAGES = Object.freeze({
  INVALID_JSON: 'Request body must be valid JSON.',
  ROUTE_NOT_FOUND: 'Route was not found.',
  METHOD_NOT_ALLOWED: 'HTTP method is not allowed for this route.',
  INTERNAL_SERVER_ERROR: 'Unexpected server error.'
});
