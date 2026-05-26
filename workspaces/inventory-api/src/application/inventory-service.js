import { createProduct, reserveStock } from '../domain/product.js';
import { InventoryDomainError, INVENTORY_ERROR_CODES } from '../domain/inventory-errors.js';

export class InventoryService {
  constructor({ productRepository, productIdGenerator }) {
    this.productRepository = productRepository;
    this.productIdGenerator = productIdGenerator;
  }

  createProduct(productInput) {
    const product = createProduct({
      id: this.productIdGenerator.nextId(),
      name: productInput.name,
      stock: productInput.stock
    });

    this.productRepository.save(product);
    return product;
  }

  listProducts() {
    return this.productRepository.findAll();
  }

  reserveStock({ productId, quantity }) {
    const product = this.productRepository.findById(productId);
    if (!product) {
      throw new InventoryDomainError(INVENTORY_ERROR_CODES.PRODUCT_NOT_FOUND, { productId });
    }

    const reservedProduct = reserveStock(product, quantity);
    this.productRepository.save(reservedProduct);
    return reservedProduct;
  }
}
