package model;

import java.io.Serializable;

public class CategoryModel implements Serializable {
    private int id;
    private String name;
    private String description;
    private boolean active;
    private int productCount;

    public CategoryModel() {}
    public CategoryModel(int id, String name, String description, boolean active, int productCount) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.active = active;
        this.productCount = productCount;
    }
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public boolean isActive() { return active; }
    public boolean getActive() { return active; }
    public void setActive(boolean active) { this.active = active; }
    public int getProductCount() { return productCount; }
    public void setProductCount(int productCount) { this.productCount = productCount; }
    public String getInitial() {
        if (name == null || name.isBlank()) return "?";
        String[] words = name.trim().split("\\s+");
        return words.length == 1 ? words[0].substring(0, Math.min(2, words[0].length())).toUpperCase()
                : (words[0].substring(0, 1) + words[1].substring(0, 1)).toUpperCase();
    }
}
