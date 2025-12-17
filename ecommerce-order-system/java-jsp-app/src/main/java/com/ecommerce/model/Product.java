package com.ecommerce.model;

public class Product {
    private int product_id;
    private String product_name;
    private double price;
    private int stock_quantity;
    private String category;
    private String image;
    private String description;

    // Constructors
    public Product() {
    }

    public Product(int product_id, String product_name, double price, int stock_quantity, 
                   String category, String image, String description) {
        this.product_id = product_id;
        this.product_name = product_name;
        this.price = price;
        this.stock_quantity = stock_quantity;
        this.category = category;
        this.image = image;
        this.description = description;
    }

    // Getters and Setters
    public int getProduct_id() {
        return product_id;
    }

    public void setProduct_id(int product_id) {
        this.product_id = product_id;
    }

    public String getProduct_name() {
        return product_name;
    }

    public void setProduct_name(String product_name) {
        this.product_name = product_name;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public int getStock_quantity() {
        return stock_quantity;
    }

    public void setStock_quantity(int stock_quantity) {
        this.stock_quantity = stock_quantity;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getImage() {
        return image;
    }

    public void setImage(String image) {
        this.image = image;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }
}