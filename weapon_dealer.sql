CREATE TABLE IF NOT EXISTS weapon_dealers (
    citizenid VARCHAR(50) PRIMARY KEY,
    reputation INT DEFAULT 0,
    total_sales INT DEFAULT 0,
    active_orders TEXT,
    workshop_level INT DEFAULT 1,
    storage_level INT DEFAULT 1,
    heat_level INT DEFAULT 0,
    last_delivery TIMESTAMP NULL DEFAULT NULL,
    total_deliveries INT DEFAULT 0,
    successful_deliveries INT DEFAULT 0,
    failed_deliveries INT DEFAULT 0
);

CREATE TABLE IF NOT EXISTS weapon_orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    dealer_id VARCHAR(50),
    customer_id VARCHAR(50),
    weapon_type VARCHAR(50),
    quantity INT,
    price INT,
    status VARCHAR(20),
    risk_level VARCHAR(20),
    delivery_type VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    delivery_date TIMESTAMP NULL DEFAULT NULL,
    completed_at TIMESTAMP NULL DEFAULT NULL,
    FOREIGN KEY (dealer_id) REFERENCES weapon_dealers(citizenid)
);

CREATE TABLE IF NOT EXISTS weapon_inventory (
    id INT AUTO_INCREMENT PRIMARY KEY,
    dealer_id VARCHAR(50),
    item_type VARCHAR(50),
    quantity INT,
    quality FLOAT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (dealer_id) REFERENCES weapon_dealers(citizenid)
);

CREATE TABLE IF NOT EXISTS weapon_deliveries (
    id INT AUTO_INCREMENT PRIMARY KEY,
    dealer_id VARCHAR(50),
    order_id INT,
    route_type VARCHAR(20),
    vehicle_type VARCHAR(20),
    start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_time TIMESTAMP NULL DEFAULT NULL,
    success BOOLEAN DEFAULT FALSE,
    heat_level INT DEFAULT 1,
    police_encounters INT DEFAULT 0,
    distance_traveled FLOAT DEFAULT 0,
    earnings INT DEFAULT 0,
    reputation_gained INT DEFAULT 0,
    FOREIGN KEY (dealer_id) REFERENCES weapon_dealers(citizenid),
    FOREIGN KEY (order_id) REFERENCES weapon_orders(id)
);

CREATE TABLE IF NOT EXISTS weapon_police_reports (
    id INT AUTO_INCREMENT PRIMARY KEY,
    delivery_id INT,
    officer_id VARCHAR(50),
    report_type VARCHAR(20),
    description TEXT,
    location VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (delivery_id) REFERENCES weapon_deliveries(id)
);