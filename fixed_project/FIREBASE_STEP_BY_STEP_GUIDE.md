# Firebase Backend Step-by-Step Guide

## 1. Enable Firebase Products

Open Firebase Console for project `senior-fashion`.

Enable:

- Authentication -> Sign-in method -> Email/Password
- Firestore Database -> Create database
- Storage -> Get started

## 2. Deploy Secure Rules

From the project root:

```bash
firebase login
firebase use senior-fashion
firebase deploy --only firestore:rules,storage
```

Rules are in:

- `firestore.rules`
- `storage.rules`

## 3. Add Products to Firestore with Product IDs

Create a collection named `products`.

Use these document IDs from `firestore_seed_products.json`:

- `sculptural-wool-overcoat`
- `archival-leather-bag`
- `pleated-flux-trousers`
- `ribbed-cashmere-knit`
- `structured-linen-blazer`
- `classic-archive-trench`

Each product document must contain:

```json
{
  "name": "Sculptural Wool Overcoat",
  "subtitle": "Oatmeal Melange",
  "price": 480.0,
  "badge": "NEW",
  "imageUrl": "assets/sculptural_wool_overcoat.png",
  "collection": "WINTER COLLECTION '24",
  "colors": ["Oatmeal", "Charcoal", "Camel"],
  "sizes": ["XS", "S", "M", "L", "XL"],
  "description": "A masterclass in minimal structure...",
  "category": "Outerwear",
  "stock": 15,
  "createdAt": "2024-01-01T00:00:00.000Z"
}
```

For Firebase Storage images, upload images to `products/{productId}/main.jpg`, copy the download URL, and replace the `imageUrl` field with that URL.

## 4. Firestore Structure

```text
products/{productId}
users/{uid}
carts/{uid}
orders/{orderId}
```

Cart document:

```json
{
  "items": [
    {
      "productId": "sculptural-wool-overcoat",
      "productName": "Sculptural Wool Overcoat",
      "price": 480.0,
      "imageUrl": "assets/sculptural_wool_overcoat.png",
      "selectedColor": "Oatmeal",
      "selectedSize": "M",
      "quantity": 1
    }
  ],
  "updatedAt": "server timestamp"
}
```

Order document:

```json
{
  "id": "auto-generated-order-id",
  "userId": "firebase-auth-uid",
  "items": [],
  "subtotal": 480.0,
  "tax": 48.0,
  "shipping": 15.0,
  "total": 543.0,
  "status": "pending",
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "shippingAddress": "Customer address"
}
```

## 5. App Flow

- Register creates Firebase Auth user and `users/{uid}` profile.
- Login reads Firebase Auth state.
- Products load from `products`.
- Cart saves to `carts/{uid}`.
- Checkout creates an `orders/{orderId}` document and clears the cart.
- Profile Settings updates `users/{uid}`.
- Order History reads only the logged-in user's orders.
