
-- Criação das tabelas
CREATE TABLE customer (
    customer_id INT PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    birth_date DATE,
    address VARCHAR(255),
    phone_number VARCHAR(30)
);

CREATE TABLE category (
    category_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(255),
    category_path VARCHAR(255)
);

CREATE TABLE item (
    item_id INT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description VARCHAR(255),
    price DECIMAL(10,2) NOT NULL,
    status VARCHAR(50) NOT NULL,
    seller_id INT NOT NULL, -- item deve ter sido vendido por um seller (tabela customer)
    category_id INT,
    removal_date DATE,
    FOREIGN KEY (category_id) REFERENCES category(category_id),
    FOREIGN KEY(seller_id) REFERENCES customer(customer_id)
);

CREATE TABLE OrderData (
    order_id BIGINT PRIMARY KEY,
    customer_id INT NOT NULL,
    item_id INT NOT NULL,
    quantity SMALLINT NOT NULL,
    order_value_total DECIMAL(10,2) NOT NULL,
    order_date DATETIME NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    FOREIGN KEY (item_id) REFERENCES item(item_id)
);

CREATE TABLE ItemUpdate (
    update_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    item_id INT NOT NULL,
    date_update DATE NOT NULL, 
    price DECIMAL(10,2) NOT NULL,
    status VARCHAR(50) NOT NULL,
    update_timestamp DATETIME,
    FOREIGN KEY (item_id) REFERENCES item(item_id),
    UNIQUE (item_id, update_timestamp)
);
