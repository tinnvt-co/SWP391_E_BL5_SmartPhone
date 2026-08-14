package model;

import java.io.Serializable;

public class CheckoutInfoModel implements Serializable {
    private String fullName;
    private String email;
    private String phone;
    private String city;
    private String district;
    private String ward;
    private String address;
    private String notes;

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }
    public String getDistrict() { return district; }
    public void setDistrict(String district) { this.district = district; }
    public String getWard() { return ward; }
    public void setWard(String ward) { this.ward = ward; }
    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }
    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public String deliveryAddress() {
        StringBuilder result = new StringBuilder();
        append(result, address);
        append(result, ward);
        append(result, district);
        append(result, city);
        if (notes != null && !notes.isBlank()) {
            append(result, "Note: " + notes.trim());
        }
        String value = result.toString();
        return value.length() > 255 ? value.substring(0, 255) : value;
    }

    private void append(StringBuilder builder, String value) {
        if (value == null || value.isBlank()) {
            return;
        }
        if (builder.length() > 0) {
            builder.append(", ");
        }
        builder.append(value.trim());
    }
}
