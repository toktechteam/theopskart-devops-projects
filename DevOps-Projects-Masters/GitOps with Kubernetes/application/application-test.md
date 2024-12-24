# Testing CRUD Operations with Postman

This guide provides step-by-step instructions to test the CRUD operations of your application running in a Docker container using Postman or any other API testing tool.

---

## 1. Get All Items

- **Method**: `GET`
- **URL**: `http://localhost:3000/items`

---

## 2. Create a New Item

- **Method**: `POST`
- **URL**: `http://localhost:3000/items`
- **Body**:

```json
{
  "name": "Item1",
  "description": "This is item 1"
}
```

- **Body Type**: `application/json`

---

## 3. Get a Specific Item by ID

- **Method**: `GET`
- **URL**: `http://localhost:3000/items/<id>`

Replace `<id>` with the actual ID of the item you want to retrieve.

---

## 4. Update an Item by ID

- **Method**: `PUT`
- **URL**: `http://localhost:3000/items/<id>`
- **Body**:

```json
{
  "name": "Updated Item",
  "description": "This is the updated item"
}
```

- **Body Type**: `application/json`

Replace `<id>` with the actual ID of the item you want to update.

---

## 5. Delete an Item by ID

- **Method**: `DELETE`
- **URL**: `http://localhost:3000/items/<id>`

Replace `<id>` with the actual ID of the item you want to delete.

---

By using Postman, you can easily test all the CRUD operations of your application without needing to run command-line tools. Simply configure the requests as described and observe the responses to verify the application's functionality.
