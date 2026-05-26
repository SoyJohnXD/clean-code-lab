const FIRST_PRODUCT_NUMBER = 1;

export class InMemoryProductRepository {
  constructor() {
    this.productsById = new Map();
  }

  save(product) {
    this.productsById.set(product.id, cloneProduct(product));
    return product;
  }

  findById(productId) {
    const product = this.productsById.get(productId);
    return product ? cloneProduct(product) : null;
  }

  findAll() {
    return Array.from(this.productsById.values(), cloneProduct);
  }
}

export class SequentialProductIdGenerator {
  constructor() {
    this.nextProductNumber = FIRST_PRODUCT_NUMBER;
  }

  nextId() {
    const productId = `product-${this.nextProductNumber}`;
    this.nextProductNumber += 1;
    return productId;
  }
}

function cloneProduct(product) {
  return Object.freeze({ ...product });
}
