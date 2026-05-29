## Firebase Backend API Reference

Complete API documentation for all Firebase services and providers.

---

## Table of Contents

1. [AuthService](#authservice)
2. [FirestoreService](#firestoreservice)
3. [StorageService](#storageservice)
4. [AuthProvider](#authprovider)
5. [ProductProvider](#productprovider)
6. [CartProvider](#cartprovider)
7. [OrderProvider](#orderprovider)
8. [Models](#models)

---

## AuthService

Handles Firebase Authentication operations. Singleton pattern.

### Constructor
```dart
final authService = AuthService();
```

### Methods

#### signIn(email, password)
```dart
Future<User?> signIn(String email, String password)
```
- **Parameters:**
  - `email`: User email address
  - `password`: User password
- **Returns:** Firebase User object or null
- **Throws:** `FirebaseAuthException` with specific error codes
- **Example:**
  ```dart
  try {
    final user = await authService.signIn('user@example.com', 'password123');
    print('Logged in as: ${user?.email}');
  } on FirebaseAuthException catch (e) {
    print('Login error: ${e.code}');
  }
  ```

#### register(email, password, displayName)
```dart
Future<User?> register(
  String email,
  String password,
  {String? displayName}
)
```
- **Parameters:**
  - `email`: Email address for new account
  - `password`: Password for account
  - `displayName`: (Optional) User's display name
- **Returns:** Firebase User object
- **Throws:** `FirebaseAuthException`
- **Example:**
  ```dart
  final user = await authService.register(
    'newuser@example.com',
    'password123',
    displayName: 'John Doe'
  );
  ```

#### logout()
```dart
Future<void> logout()
```
- **Returns:** Completes when user is signed out
- **Example:**
  ```dart
  await authService.logout();
  ```

### Properties

#### currentUser
```dart
User? get currentUser
```
- **Returns:** Current logged-in user or null
- **Example:**
  ```dart
  if (authService.currentUser != null) {
    print('Logged in as: ${authService.currentUser!.email}');
  }
  ```

#### authStateChanges
```dart
Stream<User?> get authStateChanges
```
- **Returns:** Stream of authentication state changes
- **Example:**
  ```dart
  authService.authStateChanges.listen((user) {
    if (user != null) {
      print('User logged in');
    } else {
      print('User logged out');
    }
  });
  ```

---

## FirestoreService

Handles Firestore database operations. Singleton pattern.

### Constructor
```dart
final firestoreService = FirestoreService();
```

### Methods

#### fetchAllProducts()
```dart
Future<List<Product>> fetchAllProducts()
```
- **Returns:** List of all products
- **Throws:** Exception on database error
- **Example:**
  ```dart
  final products = await firestoreService.fetchAllProducts();
  print('Found ${products.length} products');
  ```

#### fetchProductsByCategory(category)
```dart
Future<List<Product>> fetchProductsByCategory(String category)
```
- **Parameters:**
  - `category`: Product category name
- **Returns:** Filtered list of products
- **Example:**
  ```dart
  final outerwear = await firestoreService.fetchProductsByCategory('Outerwear');
  ```

#### fetchProductById(productId)
```dart
Future<Product?> fetchProductById(String productId)
```
- **Parameters:**
  - `productId`: Unique product ID
- **Returns:** Product object or null if not found
- **Example:**
  ```dart
  final product = await firestoreService.fetchProductById('1');
  ```

#### searchProducts(query)
```dart
Future<List<Product>> searchProducts(String query)
```
- **Parameters:**
  - `query`: Search text (case-insensitive)
- **Returns:** List of matching products
- **Example:**
  ```dart
  final results = await firestoreService.searchProducts('wool');
  ```

#### createOrder(order)
```dart
Future<String> createOrder(Order order)
```
- **Parameters:**
  - `order`: Order object to save
- **Returns:** Order ID in Firestore
- **Example:**
  ```dart
  final orderId = await firestoreService.createOrder(myOrder);
  ```

#### fetchUserOrders(userId)
```dart
Future<List<Order>> fetchUserOrders(String userId)
```
- **Parameters:**
  - `userId`: Firebase Auth UID
- **Returns:** List of user's orders (newest first)
- **Example:**
  ```dart
  final orders = await firestoreService.fetchUserOrders(authProvider.currentUser!.uid);
  ```

#### fetchOrderById(orderId)
```dart
Future<Order?> fetchOrderById(String orderId)
```
- **Parameters:**
  - `orderId`: Firestore order document ID
- **Returns:** Order object or null
- **Example:**
  ```dart
  final order = await firestoreService.fetchOrderById('order_123');
  ```

#### updateOrderStatus(orderId, status)
```dart
Future<void> updateOrderStatus(String orderId, String status)
```
- **Parameters:**
  - `orderId`: Order document ID
  - `status`: New status ('pending', 'processing', 'shipped', 'delivered')
- **Example:**
  ```dart
  await firestoreService.updateOrderStatus('order_123', 'shipped');
  ```

#### saveUserProfile(profile)
```dart
Future<void> saveUserProfile(UserProfile profile)
```
- **Parameters:**
  - `profile`: UserProfile object
- **Example:**
  ```dart
  await firestoreService.saveUserProfile(userProfile);
  ```

#### fetchUserProfile(userId)
```dart
Future<UserProfile?> fetchUserProfile(String userId)
```
- **Parameters:**
  - `userId`: Firebase Auth UID
- **Returns:** UserProfile object or null
- **Example:**
  ```dart
  final profile = await firestoreService.fetchUserProfile(currentUserId);
  ```

#### updateUserProfile(userId, data)
```dart
Future<void> updateUserProfile(String userId, Map<String, dynamic> data)
```
- **Parameters:**
  - `userId`: Firebase Auth UID
  - `data`: Fields to update
- **Example:**
  ```dart
  await firestoreService.updateUserProfile(userId, {
    'displayName': 'New Name',
    'phoneNumber': '1234567890',
  });
  ```

#### saveCart(userId, cartItems)
```dart
Future<void> saveCart(String userId, List<Map<String, dynamic>> cartItems)
```
- **Parameters:**
  - `userId`: Firebase Auth UID
  - `cartItems`: List of cart item maps
- **Example:**
  ```dart
  await firestoreService.saveCart(userId, cartData);
  ```

#### fetchCart(userId)
```dart
Future<List<Map<String, dynamic>>> fetchCart(String userId)
```
- **Parameters:**
  - `userId`: Firebase Auth UID
- **Returns:** List of cart items
- **Example:**
  ```dart
  final cartData = await firestoreService.fetchCart(userId);
  ```

#### clearCart(userId)
```dart
Future<void> clearCart(String userId)
```
- **Parameters:**
  - `userId`: Firebase Auth UID
- **Example:**
  ```dart
  await firestoreService.clearCart(userId);
  ```

---

## StorageService

Handles Firebase Storage image uploads. Singleton pattern.

### Constructor
```dart
final storageService = StorageService();
```

### Methods

#### uploadProfileImage(userId, imageFile)
```dart
Future<String> uploadProfileImage(String userId, File imageFile)
```
- **Parameters:**
  - `userId`: Firebase Auth UID
  - `imageFile`: Image file to upload
- **Returns:** Download URL of uploaded image
- **Example:**
  ```dart
  final url = await storageService.uploadProfileImage(userId, imageFile);
  ```

#### uploadProductImage(productId, imageFile)
```dart
Future<String> uploadProductImage(String productId, File imageFile)
```
- **Parameters:**
  - `productId`: Product ID
  - `imageFile`: Image file to upload
- **Returns:** Download URL
- **Example:**
  ```dart
  final url = await storageService.uploadProductImage(productId, imageFile);
  ```

#### deleteFile(fileUrl)
```dart
Future<void> deleteFile(String fileUrl)
```
- **Parameters:**
  - `fileUrl`: Download URL of file to delete
- **Example:**
  ```dart
  await storageService.deleteFile(imageUrl);
  ```

#### deleteProfileImage(userId)
```dart
Future<void> deleteProfileImage(String userId)
```
- **Parameters:**
  - `userId`: Firebase Auth UID
- **Example:**
  ```dart
  await storageService.deleteProfileImage(userId);
  ```

---

## AuthProvider

Manages authentication state. Use with Provider pattern.

### Usage
```dart
final authProvider = context.read<AuthProvider>();
// or
Consumer<AuthProvider>(
  builder: (context, authProvider, _) {
    // Use authProvider here
  },
)
```

### Methods

#### initialize()
```dart
void initialize()
```
- Initializes auth state listener. Called automatically.
- **Example:**
  ```dart
  authProvider.initialize();
  ```

#### login(email, password)
```dart
Future<bool> login(String email, String password)
```
- **Returns:** true if login successful
- **Sets error** message if failed
- **Example:**
  ```dart
  final success = await authProvider.login('user@example.com', 'password');
  if (success) {
    // Navigate to home
  } else {
    print('Error: ${authProvider.error}');
  }
  ```

#### register(email, password, displayName)
```dart
Future<bool> register(String email, String password, String displayName)
```
- **Returns:** true if registration successful
- **Example:**
  ```dart
  final success = await authProvider.register('email@example.com', 'pass', 'John');
  ```

#### logout()
```dart
Future<void> logout()
```
- **Example:**
  ```dart
  await authProvider.logout();
  ```

#### updateUserProfile(...)
```dart
Future<bool> updateUserProfile({
  String? displayName,
  String? phoneNumber,
  String? shippingAddress,
  String? city,
  String? postalCode,
  String? country,
})
```
- **Returns:** true if update successful
- **Example:**
  ```dart
  final success = await authProvider.updateUserProfile(
    displayName: 'New Name',
    phoneNumber: '1234567890',
  );
  ```

### Properties

#### currentUser
```dart
User? get currentUser
```
- Current Firebase User object or null

#### userProfile
```dart
UserProfile? get userProfile
```
- Current user's profile data

#### isAuthenticated
```dart
bool get isAuthenticated
```
- true if user is logged in

#### isLoading
```dart
bool get isLoading
```
- true while async operation is in progress

#### error
```dart
String? get error
```
- Error message or null

---

## ProductProvider

Manages product catalog state. Use with Provider pattern.

### Usage
```dart
Consumer<ProductProvider>(
  builder: (context, productProvider, _) {
    // Access products here
  },
)
```

### Methods

#### fetchProducts()
```dart
Future<void> fetchProducts()
```
- Fetches all products from Firestore
- **Example:**
  ```dart
  await productProvider.fetchProducts();
  ```

#### filterByCategory(category)
```dart
void filterByCategory(String category)
```
- Filters products by category
- **Example:**
  ```dart
  productProvider.filterByCategory('Outerwear');
  ```

#### searchProducts(query)
```dart
Future<void> searchProducts(String query)
```
- Searches products by name or description
- **Example:**
  ```dart
  await productProvider.searchProducts('wool');
  ```

#### resetFilter()
```dart
void resetFilter()
```
- Shows all products again
- **Example:**
  ```dart
  productProvider.resetFilter();
  ```

### Properties

#### allProducts
```dart
List<Product> get allProducts
```
- All available products

#### filteredProducts
```dart
List<Product> get filteredProducts
```
- Products after filtering/search

#### categories
```dart
List<String> get categories
```
- Available categories including 'All'

#### selectedCategory
```dart
String get selectedCategory
```
- Currently selected category

#### isLoading
```dart
bool get isLoading
```
- true while fetching data

#### error
```dart
String? get error
```
- Error message or null

---

## CartProvider

Manages shopping cart state. Use with Provider pattern.

### Usage
```dart
Consumer<CartProvider>(
  builder: (context, cartProvider, _) {
    // Use cart here
  },
)
```

### Methods

#### initializeCart(userId)
```dart
Future<void> initializeCart(String userId)
```
- Must call after user logs in
- **Example:**
  ```dart
  await cartProvider.initializeCart(authProvider.currentUser!.uid);
  ```

#### addToCart(product, color, size)
```dart
void addToCart(Product product, String color, String size)
```
- Adds item to cart or increases quantity
- **Example:**
  ```dart
  cartProvider.addToCart(product, 'Black', 'M');
  ```

#### removeFromCart(item)
```dart
void removeFromCart(CartItem item)
```
- Removes entire cart item
- **Example:**
  ```dart
  cartProvider.removeFromCart(cartItem);
  ```

#### updateQuantity(item, newQuantity)
```dart
void updateQuantity(CartItem item, int newQuantity)
```
- Updates item quantity (removes if ≤ 0)
- **Example:**
  ```dart
  cartProvider.updateQuantity(item, 3);
  ```

#### clearCart()
```dart
void clearCart()
```
- Empties entire cart
- **Example:**
  ```dart
  cartProvider.clearCart();
  ```

#### isInCart(productId, color, size)
```dart
bool isInCart(String productId, String color, String size)
```
- Checks if item variant is in cart
- **Returns:** true if item is in cart
- **Example:**
  ```dart
  if (cartProvider.isInCart(product.id, 'Black', 'M')) {
    print('Item already in cart');
  }
  ```

### Properties

#### cart
```dart
List<CartItem> get cart
```
- All cart items

#### itemCount
```dart
int get itemCount
```
- Total quantity of all items

#### subtotal
```dart
double get subtotal
```
- Sum of all item prices × quantities

#### tax
```dart
double get tax
```
- Tax (10% of subtotal)

#### shipping
```dart
double get shipping
```
- Shipping cost ($15 or $0 if empty)

#### total
```dart
double get total
```
- Subtotal + tax + shipping

#### isLoading
```dart
bool get isLoading
```
- true while saving to Firestore

#### error
```dart
String? get error
```
- Error message or null

---

## OrderProvider

Manages orders and order history. Use with Provider pattern.

### Usage
```dart
Consumer<OrderProvider>(
  builder: (context, orderProvider, _) {
    // Use orders here
  },
)
```

### Methods

#### setUserId(userId)
```dart
void setUserId(String userId)
```
- Must call after user logs in
- **Example:**
  ```dart
  orderProvider.setUserId(authProvider.currentUser!.uid);
  ```

#### fetchOrders()
```dart
Future<void> fetchOrders()
```
- Loads user's order history from Firestore
- **Example:**
  ```dart
  await orderProvider.fetchOrders();
  ```

#### createOrder(order)
```dart
Future<String?> createOrder(Order order)
```
- Creates new order in Firestore
- **Returns:** Order ID or null if failed
- **Example:**
  ```dart
  final orderId = await orderProvider.createOrder(myOrder);
  ```

#### fetchOrderDetails(orderId)
```dart
Future<void> fetchOrderDetails(String orderId)
```
- Loads single order details
- **Example:**
  ```dart
  await orderProvider.fetchOrderDetails(orderId);
  ```

#### updateOrderStatus(orderId, newStatus)
```dart
Future<bool> updateOrderStatus(String orderId, String newStatus)
```
- Updates order status
- **Returns:** true if successful
- **Example:**
  ```dart
  await orderProvider.updateOrderStatus(orderId, 'shipped');
  ```

#### getOrdersByStatus(status)
```dart
List<Order> getOrdersByStatus(String status)
```
- Filters orders by status
- **Example:**
  ```dart
  final pending = orderProvider.getOrdersByStatus('pending');
  ```

#### clearCurrentOrder()
```dart
void clearCurrentOrder()
```
- Clears currently displayed order

### Properties

#### orders
```dart
List<Order> get orders
```
- All user orders (newest first)

#### currentOrder
```dart
Order? get currentOrder
```
- Currently viewed order

#### isLoading
```dart
bool get isLoading
```
- true while saving/fetching

#### error
```dart
String? get error
```
- Error message or null

---

## Models

### Product
```dart
class Product {
  final String id;
  final String name;
  final String subtitle;
  final double price;
  final String? badge;
  final String imageUrl;
  final String collection;
  final List<String> colors;
  final List<String> sizes;
  final String description;
  final String? category;
  final int stock;

  // Methods:
  // - toMap(): Converts to Firestore map
  // - fromMap(map): Creates from Firestore map
}
```

### CartItem
```dart
class CartItem {
  final Product product;
  final String selectedColor;
  final String selectedSize;
  int quantity;

  double get subtotal; // price × quantity

  // Methods:
  // - toMap(): Converts to Firestore map
  // - fromMap(map, product): Creates from Firestore map
}
```

### Order
```dart
class Order {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double subtotal;
  final double tax;
  final double shipping;
  final double total;
  final String status; // 'pending', 'processing', 'shipped', 'delivered'
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? shippingAddress;

  // Methods:
  // - toMap(): Converts to Firestore map
  // - fromMap(map): Creates from Firestore map
}
```

### UserProfile
```dart
class UserProfile {
  final String uid;
  final String email;
  final String? displayName;
  final String? phoneNumber;
  final String? profileImageUrl;
  final String? shippingAddress;
  final String? city;
  final String? postalCode;
  final String? country;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Methods:
  // - toMap(): Converts to Firestore map
  // - fromMap(map): Creates from Firestore map
  // - copyWith(...): Creates copy with modified fields
}
```

---

## Error Handling

All services throw exceptions. Providers set `.error` property instead.

### Service Exception Handling
```dart
try {
  final products = await firestoreService.fetchAllProducts();
} catch (e) {
  print('Error: $e');
}
```

### Provider Error Handling
```dart
final success = await authProvider.login(email, password);
if (!success) {
  print('Error: ${authProvider.error}');
}
```

### Common Error Codes (Firebase Auth)
- `weak-password`: Password too weak
- `email-already-in-use`: Email registered
- `invalid-email`: Invalid email format
- `user-not-found`: User doesn't exist
- `wrong-password`: Incorrect password
- `too-many-requests`: Too many login attempts

---

## Best Practices

1. **Initialize after login:**
   ```dart
   if (authProvider.currentUser != null) {
     cartProvider.initializeCart(authProvider.currentUser!.uid);
     orderProvider.setUserId(authProvider.currentUser!.uid);
   }
   ```

2. **Listen to changes:**
   ```dart
   Consumer<AuthProvider>(
     builder: (context, authProvider, _) {
       if (authProvider.isAuthenticated) {
         // Show authenticated UI
       } else {
         // Show login UI
       }
     },
   )
   ```

3. **Handle loading states:**
   ```dart
   if (provider.isLoading) {
     return CircularProgressIndicator();
   }
   ```

4. **Show errors to user:**
   ```dart
   if (provider.error != null) {
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text(provider.error!)),
     );
   }
   ```

---

End of API Reference.
