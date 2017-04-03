require 'test/unit/assertions'
include Test::Unit::Assertions

require 'json'

class GamesDatabase

    TABLES = [:PROGRESS, :RESULT, :SERVER]

    GAME_IN_PROGRESS_FILE = 'game_in_progress.json'
    GAME_RESULT_FILE = 'game_result.json'
    GAME_SERVER_FILE = 'game_server.json'

    def initialize
        initialize_pre_cond
        @in_progress_cache = {}
        @result_cache = {}
        @server_cache = {}
        # TODO
        load_from_files
        initialize_post_cond
        check_class_invariants
    end

    def register_game_server(address)
        register_game_server_pre_cond(address)
        # TODO
        register_game_server_post_cond(address)
        check_class_invariants
    end

    def remove_game_server(address)
        remove_game_server_pre_cond(address)
        # TODO
        remove_game_server_post_cond(address)
        check_class_invariants
    end

    def available_servers
        # TODO
        check_class_invariants
        @server_cache.values
    end

    def load_from_files
        load_from_files_pre_cond
        # TODO
        # Creates the files if they don't exist
        load_from_files_post_cond
        check_class_invariants
    end

    def store_to_files
        store_to_files_pre_cond
        # TODO
        store_to_files_post_cond
        check_class_invariants
    end

    def create(table, new_object)
        create_pre_cond(table, new_object)
        # TODO
        id = 0
        create_post_cond(table, new_object, id)
        check_class_invariants
    end

    def update(id, table, object_content)
        update_pre_cond(id, table, object_content)
        # TODO
        update_post_cond(id, table, object_content)
        check_class_invariants
    end

    def delete(id, table)
        delete_pre_cond(id, table)
        # TODO
        delete_post_cond(id, table)
        check_class_invariants
    end

    def delete_if(table, query_hash)
        delete_if_pre_cond(table, query_hash)
        # TODO
        delete_if_post_cond(table, query_hash)
        check_class_invariants
    end

    def query(table, query_hash)
        query_pre_cond(table, query_hash)
        # TODO
        ret = []
        query_post_cond(table, query_hash, ret)
        check_class_invariants
    end

    def aggregate_query(table, query_hash, field, &aggregating_function)
        aggregate_query_pre_cond(table, query_hash, field, aggregating_function)
        # TODO
        ret = query_hash.merge({:result => 0})
        aggregate_query_post_cond(table, query_hash, field, aggregating_function, ret)
    end

    def top_players(n)
        top_players_pre_cond(n)
        # pre-made query that returns the top n players and their scores
        # TODO
        ret = []
        top_players_post_cond(n, ret)
    end

    private

    def check_class_invariants
        assert(@in_progress_cache, 'There must be a stopped games cache')
        assert(@result_cache, 'There must be a games results cache')
        assert(@server_cache, 'There must be a game server cache')
        assert(@in_progress_cache.each_value.all? { |o| o[:table] == :PROGRESS}, 'All data objects in stopped cache must be in table STOP')
        assert(@result_cache.each_value.all? { |o| o[:table] == :RESULT}, 'All data objects in results cache must be in table RESULT')
        assert(@server_cache.each_value.all? { |o| o[:table] == :SERVER}, 'All data objects in servers cache must be in table SERVER')
    end

    def initialize_pre_cond
    end

    def initialize_post_cond
    end

    def load_from_files_pre_cond
    end

    def load_from_files_post_cond
    end

    def store_to_files_pre_cond
        assert(File.exist?(GAME_IN_PROGRESS_FILE), 'There must a file for stopped games')
        assert(File.exist?(GAME_RESULT_FILE), 'There must a file for game results')
        assert(File.exist?(GAME_SERVER_FILE), 'There must a file for game servers')

        assert(File.writable?(GAME_IN_PROGRESS_FILE), 'File for stopped games must be writable')
        assert(File.writable?(GAME_RESULT_FILE), 'File for game results must be writable')
        assert(File.writable?(GAME_SERVER_FILE), 'File for game servers must be writable')
    end

    def store_to_files_post_cond
    end

    def create_pre_cond(table, new_object)
        assert(new_object.respond_to?(:to_json), 'New object must be convertible to json')
        valid_table(table)
    end

    def create_post_cond(table, new_object, id)
        assert_not_empty(query(table, new_object.merge({:id => id})), 'New object was not stored')
    end

    def update_pre_cond(id, table, object_content)
        assert_not_empty(query(table, {:id => id}), "There must be an object with id #{id}")
    end

    def update_post_cond(id, table, object_content)
        objs = query(table, object_content.merge({:id => id}))
        assert_not_empty(objs, 'Object should have been inserted in DB')
        assert(objs.length == 1, 'Object must be unique in the DB')
    end

    def delete_pre_cond(id, table)
        assert_not_empty(query(table, {:id => id}), "There must be an object with id #{id}")
    end

    def delete_post_cond(id, table)
        assert_empty(query(table, {:id => id}), "Object with id #{id} should have been removed")
    end

    def delete_if_pre_cond(table, query_hash)
        valid_query_hash(query_hash)
        valid_table(table)
    end

    def delete_if_post_cond(table, query_hash)
        valid_table(table)
        assert_empty(query(table, query_hash), 'Object should have been removed')
    end

    def query_pre_cond(table, query_hash)
        valid_table(table)
        valid_query_hash(query_hash)
    end

    def query_post_cond(table, query_hash, ret)
        valid_table(table)
        ret.each do |obj|
            assert(query_hash.each_pair.all? {|k,v| obj.key?(k) && obj[k] == v},
                   "Object in return value #{obj} doesn't match query")
        end
    end

    def valid_query_hash(query_hash)
        assert(query_hash.respond_to?(:[]), 'Query must respond to square bracket operator')
        assert(query_hash.respond_to?(:each_pair), 'Query must be enumerable by pairs')
    end

    def valid_table(table)
        assert(TABLES.include?(table), "#{table} is not one of the valid tables")
    end

    def aggregate_query_pre_cond(table, query_hash, field, func)
        valid_table(table)
        valid_query_hash(query_hash)
        assert(func.arity == 2, 'Aggregating function must be binary')
    end

    def aggregate_query_post_cond(table, query_hash, field, func, ret)
        valid_table(table)
        assert(query_hash.each_pair.all? {|k,v| ret.key?(k) && ret[k] == v},
               "Object in return value #{ret} doesn't match query")
        assert(ret.key?(:result), 'The return value should have a :result field')
    end

    def top_players_pre_cond(n)
        assert(n.respond_to?(:to_i), 'The number of players must be convertible to integer')
        assert(n.to_i > 0, 'The number of player must be greater than zero')
    end

    def top_players_post_cond(n, ret)
        assert(ret.length <= n, 'The number of objects in result must match n')
        ret.each do |obj|
            assert(obj.key?(:position), "Object #{obj} must have a position")
            assert(obj.key?(:player), "Object #{obj} must have a player field")
            assert(obj.key?(:score), "Object #{obj} must have a score field")
        end

        if ret.length > 1
            (1..(ret.length-1)).each do |i|
                assert(ret[i][:position] >= ret[i-1][:position], 'Positions in return value are not monotonic')
                assert(ret[i][:score] >= ret[i-1][:score], 'Scores in return value are not monotonic')
            end
        end
    end

    def register_game_server_pre_cond(address)
        assert_empty(query(:SERVER, {:address => address}), "There must be no server with address #{address}")
    end

    def register_game_server_post_cond(address)
        assert_not_empty(query(:SERVER, {:address => address}), "There must be a server with address #{address}")
    end

    def remove_game_server_pre_cond(address)
        assert_not_empty(query(:SERVER, {:address => address}), "There must be a server with address #{address}")
    end

    def remove_game_server_post_cond(address)
        assert_empty(query(:SERVER, {:address => address}), "There must be no server with address #{address}")
    end

end