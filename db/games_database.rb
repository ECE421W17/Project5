require 'xmlrpc/server'

class GamesDatabase

    OBJECT_TYPES = [:STOP, :RESULT]

    STOPPED_GAME_FILE = 'stopped_game.json'
    GAME_RESULT_FILE = 'game_result.json'

    def check_class_invariants

    end

    def initialize
        @queue = Queue.new
        @server = XMLRPC::Server.new(8080)
        @stopped_cache = nil
        @result_cache = nil
        # TODO
        # spawn thread with server serving request
        load_from_files
    end

    def load_from_files
        # TODO
    end

    def store_to_files
        # TODO
    end

    def create(new_object)
        # TODO
    end

    def update(id, object_content)
        # TODO
        # Also does creation
    end

    def delete

    end

    def commit
        # TODO: implement
        # Stores caches in files
    end

    def query(query_hash)
        # TODO
    end

    def aggregate_query(query_hash, field, &aggregating_function)
        # TODO
    end

    def top_players(n)
        # TODO
        # pre-made query that returns the top n players and their scores
    end
end