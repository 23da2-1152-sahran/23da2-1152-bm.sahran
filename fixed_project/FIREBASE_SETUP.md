## Firebase Integration Guide

This document provides comprehensive Firebase setup instructions for the Fashion Store mobile application.

### 1. Firebase Console Setup

#### Step 1: Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Create a project"
3. Name it "senior-fashion-store" (or your preferred name)
4. Enable Google Analytics (optional)

#### Step 2: Enable Authentication
1. In Firebase Console, go to **Authentication** > **Sign-in method**
2. Enable "Email/Password"
3. Enable "Anonymous" (optional, for guest checkout)

#### Step 3: Create Firestore Database
1. Go to **Firestore Database**
2. Click "Create database"
3. Start in **Production mode**
4. Select region (choose closest to your users)
5. Click "Enable"

#### Step 4: Enable Storage
1. Go to **Storage**
2. Click "Get started"
3. Create in **Production mode**
4. Use default rules initially (we'll update them)

#### Step 5: Download Configuration
1. Go to **Project Settings** > **General**
2. Scroll to "Your apps"
3. Click the iOS or Android app
4. Download configuration file:
   - iOS: `GoogleService-Info.plist` (already in macos/)
   - Android: `google-services.json` (already in android/app/)

---

## Firestore Database Structure

### Collection: `products`
Products available in the store. Each document has an auto-generated ID or custom ID like "1".

```json
{
  "id": "1",
  "name": "Sculptural Wool Overcoat",
  "subtitle": "Oatmeal Melange",
  "price": 480.00,
  "badge": "NEW",
  "imageUrl": "assets/sculptural_wool_overcoat.png",
  "collection": "WINTER COLLECTION '24",
  "colors": ["Oatmeal", "Charcoal", "Camel"],
  "sizes": ["XS", "S", "M", "L", "XL"],
  "description": "A masterclass in minimal structure...",
  "category": "Outerwear",
  "stock": 15,
  "createdAt": "2024-01-15T10:30:00Z",
  "updatedAt": "2024-01-15T10:30:00Z"
}
```

### Collection: `users`
User profiles. Each document ID is the Firebase Auth UID.

```json
{
  "uid": "{auth_uid}",
  "email": "user@example.com",
  "displayName": "John Doe",
  "phoneNumber": "+1234567890",
  "profileImageUrl": "gs://bucket/profiles/{uid}/image.jpg",
  "shippingAddress": "123 Main St",
  "city": "New York",
  "postalCode": "10001",
  "country": "USA",
  "createdAt": "2024-01-10T08:00:00Z",
  "updatedAt": "2024-01-15T12:00:00Z"
}
```

### Collection: `orders`
Completed orders. Each document has an auto-generated ID.

```json
{
  "id": "{order_id}",
  "userId": "{auth_uid}",
  "items": [
    {
      "productId": "1",
      "productName": "Sculptural Wool Overcoat",
      "price": 480.00,
      "imageUrl": "assets/...",
      "selectedColor": "Oatmeal",
      "selectedSize": "M",
      "quantity": 1
    }
  ],
  "subtotal": 480.00,
  "tax": 48.00,
  "shipping": 15.00,
  "total": 543.00,
  "status": "pending",
  "createdAt": "2024-01-15T14:30:00Z",
  "updatedAt": "2024-01-15T14:30:00Z",
  "shippingAddress": "123 Main St, New York, NY 10001"
}
```

### Collection: `carts`
User shopping carts (optional, for persistence). Document ID is the Firebase Auth UID.

```json
{
  "items": [
    {
      "productId": "1",
      "productName": "Sculptural Wool Overcoat",
      "price": 480.00,
      "imageUrl": "assets/...",
      "selectedColor": "Oatmeal",
      "selectedSize": "M",
      "quantity": 1
    }
  ],
  "updatedAt": "2024-01-15T15:00:00Z"
}
```

---

## Firestore Security Rules

Replace the default security rules with these:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Public products - anyone can read
    match /products/{document=**} {
      allow read: if true;
      allow write: if false; // Only admin panel or backend can write
    }
    
    // User profiles - read own, update own
    match /users/{userId} {
      allow read: if request.auth.uid == userId;
      allow create: if request.auth.uid == userId;
      allow update: if request.auth.uid == userId;
      allow delete: if false;
    }
    
    // Orders - read own, create own, admin can update status
    match /orders/{orderId} {
      allow read: if request.auth.uid == resource.data.userId;
      allow create: if request.auth.uid == request.resource.data.userId;
      allow update: if request.auth.uid == resource.data.userId
                      || request.auth.token.admin == true;
      allow delete: if false;
    }
    
    // Shopping carts - read own, update own
    match /carts/{userId} {
      allow read: if request.auth.uid == userId;
      allow write: if request.auth.uid == userId;
    }
  }
}
```

---

## Firebase Storage Security Rules

Replace the default storage rules with these:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    
    // User profile images - user can upload own, anyone can read
    match /profiles/{userId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth.uid == userId;
    }
    
    // Product images - only admin can upload
    match /products/{productId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth.token.admin == true;
    }
  }
}
```

---

## Example Products Data

Use this JSON to populate your `products` collection (via Firestore console or your admin app):

```json
[
  {
    "id": "1",
    "name": "Sculptural Wool Overcoat",
    "subtitle": "Oatmeal Melange",
    "price": 480,
    "badge": "NEW",
    "imageUrl": "assets/sculptural_wool_overcoat.png",
    "collection": "WINTER COLLECTION '24",
    "colors": ["Oatmeal", "Charcoal", "Camel"],
    "sizes": ["XS", "S", "M", "L", "XL"],
    "description": "A masterclass in minimal structure. Crafted from premium 100% virgin wool, this coat features defined shoulders and a sleek, hidden placket for a clean editorial silhouette.",
    "category": "Outerwear",
    "stock": 15
  },
  {
    "id": "2",
    "name": "Archival Leather Bag",
    "subtitle": "Noir Calfskin",
    "price": 1250,
    "imageUrl": "assets/archival_leather_bag.png",
    "collection": "ACCESSORIES",
    "colors": ["Noir", "Cognac"],
    "sizes": ["One Size"],
    "description": "Structured calfskin leather bag with architectural form and minimal hardware.",
    "category": "Accessories",
    "stock": 8
  },
  {
    "id": "3",
    "name": "Essential Linen Shirt",
    "subtitle": "Natural White",
    "price": 180,
    "badge": "BESTSELLER",
    "imageUrl": "assets/essential_linen_shirt.png",
    "collection": "BASICS",
    "colors": ["White", "Cream", "Navy"],
    "sizes": ["XS", "S", "M", "L", "XL", "XXL"],
    "description": "Pure linen classic shirt with refined details and perfect versatility.",
    "category": "Shirts",
    "stock": 50
  }
]
```

---

## Integration Checklist

- [x] Firebase initialized in `main.dart`
- [x] AuthService created for authentication
- [x] FirestoreService created for database operations
- [x] StorageService created for image uploads
- [x] AuthProvider, ProductProvider, CartProvider, OrderProvider created
- [x] Models updated with Firestore serialization
- [ ] Firestore rules deployed
- [ ] Storage rules deployed
- [ ] Sample products added to Firestore
- [ ] Test login/register/logout
- [ ] Test cart persistence
- [ ] Test order creation
- [ ] Test user profile update

---

## Testing

### Test Account Credentials
Use these for testing:
- Email: `test@example.com`
- Password: `Test123456!`

### Test Data Initialization
Call `FirestoreService().initializeWithDemoData()` once to populate demo products.

---

## Troubleshooting

### Products not loading
1. Check Firestore `products` collection exists
2. Verify Firestore security rules allow read access
3. Check console logs for Firestore errors

### Login fails
1. Ensure Email/Password auth is enabled
2. Check user exists in Firebase Authentication
3. Verify email and password are correct

### Cart not persisting
1. Check `carts` collection exists
2. Verify Firestore security rules allow user to write
3. Ensure CartProvider is initialized after login

### Images not uploading
1. Check Storage bucket is created
2. Verify Storage security rules allow user uploads
3. Ensure file path is correct in StorageService

---

## Backend Implementation Notes

- Services use singleton pattern for consistency
- Providers use ChangeNotifier for reactive updates
- Error messages are user-friendly
- All Firestore operations include error handling
- Cart persists per user in Firestore
- Order history tracked with timestamps
