require_relative '../db/games_database'

require 'test/unit/assertions'

include Test::Unit::Assertions

class TestGamesDatabase
    def self.test_CRUD

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
        assert(q3.empty?)
    end
end

TestGamesDatabase.test_CRUD