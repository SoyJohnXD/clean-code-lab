import http from 'node:http';
import { InventoryDomainError, INVENTORY_ERROR_CODES } from '../domain/inventory-errors.js';
import { sendJson } from './json-response.js';
import { HTTP_ERROR_MESSAGES, HTTP_METHODS, HTTP_STATUS, ROUTES } from './http-constants.js';

const EMPTY_BODY = '';
const BODY_CHUNK_ENCODING = 'utf8';
const PRODUCT_RESERVATION_PATH_PATTERN = /^\/products\/([^/]+)\/reservations$/;

export function createInventoryServer({ inventoryService, logger = console }) {
  return http.createServer(async (request, response) => {
    try {
      await routeInventoryRequest({ request, response, inventoryService });
    } catch (error) {
      handleErrorResponse(response, error, logger);
    }
  });
}

async function routeInventoryRequest({ request, response, inventoryService }) {
  const path = new URL(request.url, getRequestOrigin(request)).pathname;

  if (path === ROUTES.PRODUCTS) {
    await routeProductsRequest({ request, response, inventoryService });
    return;
  }

  const reservationMatch = path.match(PRODUCT_RESERVATION_PATH_PATTERN);
  if (reservationMatch) {
    await routeReservationRequest({ request, response, inventoryService, productId: reservationMatch[1] });
    return;
  }

  sendJson(response, HTTP_STATUS.NOT_FOUND, { error: HTTP_ERROR_MESSAGES.ROUTE_NOT_FOUND });
}

async function routeProductsRequest({ request, response, inventoryService }) {
  if (request.method === HTTP_METHODS.POST) {
    const requestBody = await readJsonBody(request);
    const product = inventoryService.createProduct(requestBody);
    sendJson(response, HTTP_STATUS.CREATED, { product });
    return;
  }

  if (request.method === HTTP_METHODS.GET) {
    sendJson(response, HTTP_STATUS.OK, { products: inventoryService.listProducts() });
    return;
  }

  sendJson(response, HTTP_STATUS.METHOD_NOT_ALLOWED, { error: HTTP_ERROR_MESSAGES.METHOD_NOT_ALLOWED });
}

async function routeReservationRequest({ request, response, inventoryService, productId }) {
  if (request.method !== HTTP_METHODS.POST) {
    sendJson(response, HTTP_STATUS.METHOD_NOT_ALLOWED, { error: HTTP_ERROR_MESSAGES.METHOD_NOT_ALLOWED });
    return;
  }

  const requestBody = await readJsonBody(request);
  const product = inventoryService.reserveStock({ productId, quantity: requestBody.quantity });
  sendJson(response, HTTP_STATUS.OK, { product });
}

async function readJsonBody(request) {
  const requestBody = await readRequestBody(request);
  if (requestBody === EMPTY_BODY) {
    return {};
  }

  try {
    return JSON.parse(requestBody);
  } catch {
    throw new ClientRequestError(HTTP_ERROR_MESSAGES.INVALID_JSON);
  }
}

function readRequestBody(request) {
  request.setEncoding(BODY_CHUNK_ENCODING);

  return new Promise((resolve, reject) => {
    let requestBody = EMPTY_BODY;

    request.on('data', chunk => {
      requestBody += chunk;
    });
    request.on('end', () => resolve(requestBody));
    request.on('error', reject);
  });
}

function handleErrorResponse(response, error, logger) {
  if (error instanceof ClientRequestError) {
    sendJson(response, HTTP_STATUS.BAD_REQUEST, { error: error.message });
    return;
  }

  if (error instanceof InventoryDomainError) {
    sendJson(response, getDomainErrorStatus(error), {
      error: error.message,
      code: error.code,
      details: error.details
    });
    return;
  }

  logger.error(error);
  sendJson(response, HTTP_STATUS.INTERNAL_SERVER_ERROR, { error: HTTP_ERROR_MESSAGES.INTERNAL_SERVER_ERROR });
}

function getDomainErrorStatus(error) {
  if (error.code === INVENTORY_ERROR_CODES.PRODUCT_NOT_FOUND) {
    return HTTP_STATUS.NOT_FOUND;
  }

  return HTTP_STATUS.BAD_REQUEST;
}

function getRequestOrigin(request) {
  return `http://${request.headers.host}`;
}

class ClientRequestError extends Error {
  constructor(message) {
    super(message);
    this.name = 'ClientRequestError';
  }
}
