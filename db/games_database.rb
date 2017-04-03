require 'test/unit/assertions'
include Test::Unit::Assertions

require 'json'

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

    def create_pre_cond(new_object)
        assert(new_object.respond_to?(:to_json), 'New object must be convertible to json')
        assert(new_object.key?(:type), 'New object must have a type')
        assert(OBJECT_TYPES.include?(new_object[:type]), "#{new_object[:type]} is not one of the valid types")
    end

    def create_post_cond(new_object, id)
        assert_not_empty(query(new_object.merge({:id => id})), 'New object was not stored')
    end

    def create(new_object)
        create_pre_cond(new_object)
        # TODO
        id = 0
        create_post_cond(new_object, id)
        check_class_invariants
    end

    def update_pre_cond(id, object_content)
        assert_not_empty(query({:id => id}), "There must be an object with id #{id}")
    end

    def update_post_cond(id, object_content)
        objs = query(object_content.merge({:id => id}))
        assert_not_empty(objs, 'Object should have been inserted in DB')
        assert(objs.length == 1, 'Object must be unique in the DB')
    end

    def update(id, object_content)
        update_pre_cond(id, object_content)
        # TODO
        update_post_cond(id, object_content)
        check_class_invariants
    end

    def delete_pre_cond(id)
        assert_not_empty(query({:id => id}), "There must be an object with id #{id}")
    end

    def delete_post_cond(id)
        assert_empty(query({:id => id}), "Object with id #{id} should have been removed")
    end

    def delete(id)
        delete_pre_cond(id)
        # TODO
        delete_post_cond(id)
        check_class_invariants
    end

    def delete_if_pre_cond(query_hash)
        valid_query_hash(query_hash)
    end

    def delete_if_post_cond(query_hash)
        assert_empty(query(query_hash), 'Object should have been removed')
    end

    def delete_if(query_hash)
        delete_if_pre_cond(query_hash)
        # TODO
        delete_if_post_cond(query_hash)
        check_class_invariants
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

    private
    def valid_query_hash(query_hash)
        assert(query_hash.respond_to?(:[]), 'Query must respond to square bracket operator')
    end
end