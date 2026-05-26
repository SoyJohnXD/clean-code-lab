import { CONTENT_TYPES } from './http-constants.js';

export function sendJson(response, statusCode, payload) {
  const responseBody = JSON.stringify(payload);

  response.writeHead(statusCode, {
    'content-type': CONTENT_TYPES.JSON
  });
  response.end(responseBody);
}
