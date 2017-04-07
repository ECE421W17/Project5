require_relative '../db/games_database'

require 'test/unit/assertions'

include Test::Unit::Assertions

class TestGamesDatabase
    def self.test_crud

        # This test assumes empty files
        db = GamesDatabase.new

        db.create(:RESULT, {:p1 => 'joe', :p2 => 'bob'})
        db.create(:RESULT, {:p1 => 'joe', :p2 => 'john'})
        db.create(:RESULT, {:p1 => 'jack', :p2 => 'john'})

        res1 = {:p1 => 'joe', :p2 => 'bob', :id => 0}
        res2 = {:p1 => 'joe', :p2 => 'john', :id => 1}
        res3 = {:p1 => 'jack', :p2 => 'john', :id => 2}

        q1 = db.query(:RESULT, {:p1 => 'joe'})
        q2 = db.query(:RESULT, {:p2 => 'john'})
        q3 = db.query(:RESULT, {:p2 => 'joe'})

        assert(q1.all? {|res| res == res1 || res == res2})
        assert(q2.all? {|res| res == res2 || res == res3})
        assert_empty(q3)

        db.update(:RESULT, 1, {:p2 => 'bill'})
        q3 = db.query(:RESULT, {:p1 => 'joe'})
        assert(Set.new(q3) == Set.new([res1, {:p1 => 'joe', :p2 => 'bill', :id => 1}]))

        db.delete_if(:RESULT, {:p1 => 'joe'})
        q4 = db.query(:RESULT, {})
        assert(q4 == [{:p1 => 'jack', :p2 => 'john', :id => 2}])

        db.delete_if(:RESULT, {})
        q5 = db.query(:RESULT, {})
        assert_empty(q5)
    end

    def self.test_aggregate
        # This test assumes empty files
        db = GamesDatabase.new

        db.create(:RESULT, {:p1 => 'joe', :score => 100})
        db.create(:RESULT, {:p1 => 'joe', :score => 20})
        db.create(:RESULT, {:p1 => 'jack', :score => 5})

        joe_result = db.aggregate_query(:RESULT, {:p1 => 'joe'}, :score) {|s1, s2| s1 + s2}
        jack_result = db.aggregate_query(:RESULT, {:p1 => 'jack'}, :score) {|s1, s2| s1 + s2}

        assert(joe_result == 120)
        assert(jack_result == 5)

        db.delete_if(:RESULT, {})
    end

    def self.test_top_n
        # This test assumes empty files
        db = GamesDatabase.new

        db.create(:RESULT, {:p1 => 'joe', :p2 => 'bob', :winner => :p1})
        db.create(:RESULT, {:p1 => 'joe', :p2 => 'john', :winner => :p1})
        db.create(:RESULT, {:p1 => 'jack', :p2 => 'john', :winner => :p2})
        db.create(:RESULT, {:p1 => 'joe', :p2 => 'bob'})
        db.create(:RESULT, {:p1 => 'jack', :p2 => 'bob', :winner => :p1})
        db.create(:RESULT, {:p1 => 'joe', :p2 => 'john', :winner => :p2})
        db.create(:RESULT, {:p1 => 'jack', :p2 => 'john', :winner => :p2})

        expected = [
            {:player => 'john', :score => 3},
            {:player => 'joe', :score => 2},
            {:player => 'jack', :score => 1},
            {:player => 'bob', :score => 0},
            nil, nil, nil, nil, nil, nil
        ]

        q1 = db.top_players(10)
        db.delete_if(:RESULT, {}) # clean files

        assert(q1 == expected)
    end
end

TestGamesDatabase.test_top_n