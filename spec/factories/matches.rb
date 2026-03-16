# spec/factories/matches.rb
FactoryBot.define do
  factory :match do
    association :winner, factory: :player
    association :loser,  factory: :player
    played_on { Date.today }
  end
end
