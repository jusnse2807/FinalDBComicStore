use('comicStoreDB');


// Colección de cómics
db.comics.insertMany([
  { title: "Superman en Calzoncillos con Batman Asustado", description: "Un cómic cómico", price: 19.99, category: "Comedia" },
  { title: "Batman: El Caballero Oscuro", description: "Una historia seria", price: 25.99, category: "Acción" },
  { title: "La Liga de la Justicia", description: "Un equipo de héroes", price: 15.49, category: "Aventura" }
]);

// Colección de personajes
db.characters.insertMany([
  { name: "Superman", powers: ["flight", "super strength"], weaknesses: ["kryptonite"], affiliations: ["Justice League"] },
  { name: "Batman", powers: ["intellect", "combat"], weaknesses: ["none"], affiliations: ["Justice League"] },
  { name: "Wonder Woman", powers: ["super strength", "speed"], weaknesses: ["none"], affiliations: ["Justice League"] }
]);

// Colección de armas y objetos
db.villagersAndArms.insertMany([
  { name: "Espada de luz", description: "Un arma legendaria", availability: true },
  { name: "Escudo de Vibranium", description: "Defensa impenetrable", availability: true },
  { name: "Látigo mágico", description: "Control del enemigo", availability: false }
]);

// Colección de clientes
db.customers.insertMany([
  { name: "Juan Pérez", birthday: new Date("1990-05-15"), email: "juanp@gmail.com", purchase_history: [] },
  { name: "Ana López", birthday: new Date("1985-09-10"), email: "anal@gmail.com", purchase_history: [] }
]);

// Colección de transacciones
db.transactions.insertMany([
  { comic_id: ObjectId(), customer_id: ObjectId(), purchase_date: new Date("2024-01-01"), total_amount: 19.99 }
]);

// Colección de batallas
db.battles.insertMany([
  { comic_id: ObjectId(), hero_id: ObjectId(), villain_id: ObjectId(), mortal_arm_id: ObjectId(), winner_id: ObjectId() }
]);


// Consultas ----------------------------------------------------------------------------------------------

// 1. List all comics priced below $20, sorted alphabetically by title.
db.comics.find({ price: { $lt: 20 } }).sort({ title: 1 });

// 2. Display all superheroes with powers that include "flight," ordered by name.
db.characters.find({ powers: "flight" }).sort({ name: 1 });

//0. Find all villains who have been defeated by a superhero more than three times.
db.battles.aggregate([
  { $match: { "winner_id": { $ne: null } } },
  { $group: { _id: "$villain_id", defeats: { $sum: 1 } } },
  { $match: { defeats: { $gt: 3 } } }
]);

//1. Retrieve a list of customers who have purchased more than five comics, along with the total amount spent.
db.transactions.aggregate([
  { $group: { _id: "$customer_id", total_spent: { $sum: "$total_amount" }, purchases: { $sum: 1 } } },
  { $match: { purchases: { $gt: 5 } } }
]);

//0. Find the most popular comic category based on the number of purchases.
db.transactions.aggregate([
  { $lookup: { from: "comics", localField: "comic_id", foreignField: "_id", as: "comic" } },
  { $unwind: "$comic" },
  { $group: { _id: "$comic.category", total_purchases: { $sum: 1 } } },
  { $sort: { total_purchases: -1 } },
  { $limit: 1 }
]);

//1. Retrieve all characters affiliated with both the "Justice League" and the "Avengers."
db.characters.find({ affiliations: { $all: ["Justice League", "Avengers"] } });

//2. Identify comics that feature epic hero-villain battles and include at least one "mortal arm."
db.battles.aggregate([
  { $lookup: { from: "comics", localField: "comic_id", foreignField: "_id", as: "comic" } },
  { $lookup: { from: "villagersAndArms", localField: "mortal_arm_id", foreignField: "_id", as: "arm" } },
  { $unwind: "$comic" },
  { $unwind: "$arm" },
  { $match: { "arm.name": { $exists: true } } },
  { $project: { "comic.title": 1, "arm.name": 1 } }
]);



// 3. Encontrar la categoría de cómics con más compras.
db.transactions.aggregate([
  { $lookup: { from: "comics", localField: "comic_id", foreignField: "_id", as: "comic" } },
  { $unwind: "$comic" },
  { $group: { _id: "$comic.category", total_purchases: { $sum: 1 } } },
  { $sort: { total_purchases: -1 } },
  { $limit: 1 }
]);

// 4. Personajes que pertenecen tanto a "Justice League" como a "Avengers".
db.characters.find({ affiliations: { $all: ["Justice League", "Avengers"] } });

// 5. Armas utilizadas en batallas junto con el título del cómic.
db.battles.aggregate([
  { $lookup: { from: "comics", localField: "comic_id", foreignField: "_id", as: "comic" } },
  { $lookup: { from: "villagersAndArms", localField: "mortal_arm_id", foreignField: "_id", as: "arm" } },
  { $unwind: "$comic" },
  { $unwind: "$arm" },
  { $project: { "comic.title": 1, "arm.name": 1 } }
]);
