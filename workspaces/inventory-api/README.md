# Inventory API

Small dependency-free Node.js inventory API using in-memory persistence.

## Routes

- `POST /products` with `{ "name": "Keyboard", "stock": 5 }`
- `GET /products`
- `POST /products/:productId/reservations` with `{ "quantity": 2 }`

Domain rules live in `src/domain`; HTTP routing lives in `src/http`; in-memory persistence lives in `src/infrastructure`.

## Commands

```bash
npm test
npm run check
npm start
```
