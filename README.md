# Badminton League

A Ruby on Rails web application for managing a badminton league — add players, record match results, and track rankings on a live leaderboard.

---

## Requirements

- Ruby 3.2+
- Rails 7.1+
- SQLite3

---

## Setup

```bash
# 1. Install dependencies
bundle install

# 2. Create the database and run migrations
rails db:create db:migrate

# 3. (Optional) Seed sample data for development
rails db:seed

# 4. Start the server
rails server
```

Open [http://localhost:3000](http://localhost:3000) in your browser.

---

## Running Tests

```bash
bundle exec rspec
```

Test coverage includes:

- **Model specs** — validations, associations, instance methods, and scopes for both `Player` and `Match`
- **Request specs** — all controller actions covering happy paths, validation failures, and edge cases

---

## Data Model

```
players
  id         integer  PK
  name       string   NOT NULL, UNIQUE
  created_at datetime
  updated_at datetime

matches
  id         integer  PK
  winner_id  integer  FK → players.id  NOT NULL
  loser_id   integer  FK → players.id  NOT NULL
  played_on  date     NOT NULL
  created_at datetime
  updated_at datetime

  CHECK (winner_id != loser_id)
```

A **Player** `has_many :won_matches` and `has_many :lost_matches`, both pointing to the `matches` table via their respective foreign keys. Deleting a player cascades and removes all their match records.

---

## Routes

| Method | Path             | Action                       |
|--------|------------------|------------------------------|
| GET    | `/`              | Players index (leaderboard)  |
| GET    | `/players`       | Players index (leaderboard)  |
| GET    | `/players/new`   | Add player form              |
| POST   | `/players`       | Create player                |
| GET    | `/players/:id`   | Player profile & history     |
| DELETE | `/players/:id`   | Remove player                |
| GET    | `/matches`       | All match results            |
| GET    | `/matches/new`   | Record match form            |
| POST   | `/matches`       | Save match result            |
| DELETE | `/matches/:id`   | Delete match result          |

---

## Key Design Decisions

- **Separate foreign keys** (`winner_id` / `loser_id`) make the domain explicit and keep queries straightforward. A single `result` flag on a join table was considered but adds indirection with no benefit at this scale.
- **`Player.ranked`** uses a single SQL query with `COUNT(DISTINCT …)` aggregates and `LEFT JOIN` so players with zero matches still appear on the leaderboard — no N+1 queries.
- **`dependent: :destroy`** on both associations ensures referential integrity when a player is removed; no orphaned match rows.
- **DB-level constraint** (`winner_id != loser_id`) enforces data integrity even if validations are bypassed.
- **`before_validation :set_played_on`** defaults the match date to today without hiding it from the user, keeping the form pre-filled sensibly.
