# SWP391 Smartphone Store - Product module

Java Web (Jakarta EE 10 / Servlet 6), JSP/JSTL, JDBC MySQL and NetBeans Ant.

## Implemented screens

- `/products`: public product list with brand filter and price/name sorting.
- `/products?action=detail&id=1`: public product detail.
- `/manager/products`: search/filter and manage products.
- `/manager/categories`: manage categories.
- `/manager/brands`: manage brands.

The UI is stored under `web/views`, static resources under `web/assets`, controllers
under `src/java/controller`, DAO classes under `src/java/DAO`, and JavaBeans under
`src/java/model`.

## Database

Import `database_swp391.sql` into MySQL. The default connection in
`config.DBContext` is:

- Database: `database_swp391`
- User: `root`
- Password: `123456`

The values can be overridden without changing source code by starting Tomcat with:

```text
-Dsmartphone.db.url=jdbc:mysql://localhost:3306/database_swp391
-Dsmartphone.db.user=root
-Dsmartphone.db.password=your_password
```

Product create/update writes `Product` and `Inventory` in one JDBC transaction.
Product delete is implemented as status deactivation to preserve order, cart,
wishlist, feedback and inventory foreign-key history.

## Build

Open the project in NetBeans and run Clean and Build, or run Ant from the project root:

```text
ant clean dist
```

The generated WAR is `dist/SWP391_E_BL5_SmartPhone.war`.
