puts "Clearing existing data..."
Match.delete_all
Player.delete_all

puts "Creating players..."
names = %w[Alice Bob Charlie Diana Eve Frank]
players = names.map { |name| Player.create!(name: name) }

puts "Recording matches..."
fixtures = [
  { winner: "Alice",   loser: "Bob",     days_ago: 10 },
  { winner: "Alice",   loser: "Charlie", days_ago: 8  },
  { winner: "Bob",     loser: "Diana",   days_ago: 7  },
  { winner: "Charlie", loser: "Eve",     days_ago: 6  },
  { winner: "Diana",   loser: "Frank",   days_ago: 5  },
  { winner: "Alice",   loser: "Eve",     days_ago: 4  },
  { winner: "Frank",   loser: "Bob",     days_ago: 3  },
  { winner: "Charlie", loser: "Diana",   days_ago: 2  },
  { winner: "Eve",     loser: "Frank",   days_ago: 1  },
  { winner: "Bob",     loser: "Charlie", days_ago: 0  },
]

fixtures.each do |f|
  winner = players.find { |p| p.name == f[:winner] }
  loser  = players.find { |p| p.name == f[:loser]  }
  Match.create!(winner: winner, loser: loser, played_on: f[:days_ago].days.ago.to_date)
end

puts "Done! #{Player.count} players, #{Match.count} matches seeded."
