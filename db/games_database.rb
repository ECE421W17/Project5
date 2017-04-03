require 'file'

require 'test/unit/assertions'
include Test::Unit::Assertions

class GamesDatabase

    OBJECT_TYPES = [:STOP, :RESULT]

    STOPPED_GAME_FILE = 'stopped_game.json'
    GAME_RESULT_FILE = 'game_result.json'

    def check_class_invariants
        assert(@stopped_cache, 'There must be a stopped games cache')
        assert(@result_cache, 'There must be a games results cache')
        assert(@stopped_cache.all? { |o| o.type == :STOP}, 'All data object in stopped cache must be of type STOP')
        assert(@stopped_cache.all? { |o| o.type == :RESULT}, 'All data objects in results cache must be of type RESULT')
    end

    def initialize_pre_cond
    end

    def initialize_post_cond
    end

    def initialize
        initialize_pre_cond
        @stopped_cache = []
        @result_cache = []
        # TODO
        load_from_files
        initialize_post_cond
        check_class_invariants
    end

    def load_from_files_pre_cond
    end

    def load_from_files_post_cond
    end

    def load_from_files
        load_from_files_pre_cond
        # TODO
        # Creates the files if they don't exist
        load_from_files_post_cond
        check_class_invariants
    end

    def store_to_files_pre_cond
        assert(File.exist?(STOPPED_GAME_FILE), 'There must a file for stopped games')
        assert(File.exist?(GAME_RESULT_FILE), 'There must a file for game results')
        assert(File.writable?(STOPPED_GAME_FILE), 'File for stopped games must be writable')
        assert(File.writable?(GAME_RESULT_FILE), 'File for game results must be writable')
    end

    def store_to_files_post_cond
    end

    def store_to_files
        store_to_files_pre_cond
        # TODO
        store_to_files_post_cond
        check_class_invariants
    end

    def create(new_object)
        # TODO
    end

    def update(id, object_content)
        # TODO
        # Also does creation
    end

    def delete(id)
        # TODO
    end

    def delete_if(query_hash)
        # TODO
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