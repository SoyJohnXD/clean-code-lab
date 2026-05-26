import { InventoryService } from './application/inventory-service.js';
import { createInventoryServer } from './http/create-server.js';
import { InMemoryProductRepository, SequentialProductIdGenerator } from './infrastructure/in-memory-product-repository.js';

const DEFAULT_PORT = 3000;
const LISTEN_HOST = '127.0.0.1';
const PORT_ENVIRONMENT_VARIABLE = 'PORT';

const inventoryService = new InventoryService({
  productRepository: new InMemoryProductRepository(),
  productIdGenerator: new SequentialProductIdGenerator()
});

const server = createInventoryServer({ inventoryService });
const port = Number(process.env[PORT_ENVIRONMENT_VARIABLE]) || DEFAULT_PORT;

server.listen(port, LISTEN_HOST, () => {
  console.log(`Inventory API listening on http://${LISTEN_HOST}:${port}`);
});
