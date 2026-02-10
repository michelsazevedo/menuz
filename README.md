## Menuz

A lightweight REST API microservice built with **Sinatra** and **Sidekiq** for managing restaurants, menus, and menu items with search, pagination, bulk import, and Redis caching.

### Built With
- [Sinatra](http://sinatrarb.com/)
- [Sidekiq](https://sidekiq.org/)
- [Redis](https://redis.io/)

Plus *some* packages, a complete list of which is at [/main/Gemfile](https://github.com/michelsazevedo/menuz/blob/main/Gemfile).

### Instructions

#### Install with Docker
[Docker](https://www.docker.com) is an open platform for developers and sysadmins to build, ship, and run distributed applications, whether on laptops, data center VMs, or the cloud.

If you haven't used Docker before, it would be a good idea to read this article first: Install [Docker Engine](https://docs.docker.com/engine/installation/)

Install [Docker](https://www.docker.com/what-docker) and then [Docker Compose](https://docs.docker.com/compose/), and then follow the steps below:

1. Run `docker compose build --no-cache` to build the image for the project.

2. Setup database:
    `docker compose run --rm test rake db:setup`

3. Finally, start your local server with `docker compose up web` and menuz should be up and running on your localhost!

4. Aaaaand, you can run the automated tests suite running a `docker compose run --rm test` with no other parameters!

### Example Requests

#### List Restaurants
```bash
curl -X GET "http://localhost:3000/restaurants?q=pizza&page=1&per_page=10" \
  -H "Content-Type: application/json"
```

#### Create Restaurant
```bash
curl -X POST http://localhost:3000/restaurants \
  -H "Content-Type: application/json" \
  -d '{"name": "Pizza Palace", "location": "New York"}'
```

#### Get Restaurant
```bash
curl -X GET http://localhost:3000/restaurants/1 \
  -H "Content-Type: application/json"
```

#### Get Restaurant Menus
```bash
curl -X GET http://localhost:3000/restaurants/1/menus \
  -H "Content-Type: application/json"
```

#### Create Menu
```bash
curl -X POST http://localhost:3000/menus \
  -H "Content-Type: application/json" \
  -d '{"name": "Lunch Special", "description": "Weekday lunch menu", "restaurant_id": 1}'
```

#### Get Menu with Items
```bash
curl -X GET http://localhost:3000/menus/1 \
  -H "Content-Type: application/json"
```

#### Add Menu Items
```bash
curl -X POST http://localhost:3000/menus/1/menu_items \
  -H "Content-Type: application/json" \
  -d '{"menu_items": [{"name": "Margherita", "price": 12.99}, {"name": "Pepperoni", "price": 14.99}]}'
```

#### Import Restaurants (Bulk)
```bash
curl -X POST http://localhost:3000/restaurants/import \
  -F "file=@restaurants.json"
```

## License
Copyright © 2026
