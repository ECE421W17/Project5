require 'observer'
require 'test/unit/assertions'

include Test::Unit::Assertions

class Board

    def check_class_invariants
        assert(@n_rows > 0, 'Number of rows must be greater than zero')
        assert(@n_cols > 0, 'Number of columns must be greater than zero')
    end

    def initialize_pre_cond(n_rows, n_cols)
        assert(n_rows > 0, 'Number of rows must be greater than zero')
        assert(n_cols > 0, 'Number of columns must be greater than zero')
    end

    def initialize_post_cond
    end

    def initialize(n_rows, n_cols)
        initialize_pre_cond(n_rows, n_cols)

        @n_rows = n_rows
        @n_cols = n_cols
        @columns = @n_cols.times.map { Array.new(n_rows) }
        @diagonal_indices = diagonal_indices(n_rows, n_cols)

        initialize_post_cond
        check_class_invariants
    end

    def positions
        @columns.transpose.reverse
    end

    def add_piece_pre_cond(col, piece)
        assert(0 <= col && col < @n_cols, 'Column number is invalid')
        assert(!column_full?(col), 'Column is full')
    end

    def add_piece_post_cond(col, piece)
        assert(piece_in_column?(col, piece), 'The piece was not added to column')
    end

    def add_piece(col, piece)
        add_piece_pre_cond(col, piece)

        idx = @columns[col].index(nil)
        @columns[col][idx] = piece

        add_piece_post_cond(col, piece)
        check_class_invariants
    end

    def remove_piece(col, piece)

        idx = @columns[col].index(nil)
        if (idx == nil)
            idx = @n_rows
        end
        @columns[col][idx-1] = nil
    end

    def column_full?(col)
        !@columns[col].index(nil)
    end

    def piece_in_column?(col, piece)
        @columns[col].include? piece
    end

    def valid_columns_pre_cond
    end

    def valid_columns_post_cond
    end

    def valid_columns
        valid_columns_pre_cond

        res = @n_cols.times.select {|i| !column_full?(i)}

        valid_columns_post_cond
        res
    end

    def pattern_found_pre_cond(pattern)
        assert(pattern.length <= @n_rows, 'Pattern cannot be larger than the number of rows')
        assert(pattern.length <= @n_cols, 'Pattern cannot be larger than the number of columns')
    end

    def pattern_found_post_cond
    end

    def pattern_found(pattern)
        pattern_found_pre_cond(pattern)
        check_class_invariants

        # returns the positions of the pattern or nil
        rows = positions

        # find rows with the pattern
        rows.each_with_index do |row, row_index|
            pattern_position = find_linear_pattern(row, pattern)
            if pattern_position
                return pattern_position.map{|i| [row_index, i]}
            end
        end

        # find columns with the pattern
        cols = rows.transpose
        cols.each_with_index do |col, col_index|
            pattern_position = find_linear_pattern(col, pattern)
            if pattern_position
                return pattern_position.map{|i| [i, col_index]}
            end
        end

        # find diagonals with the pattern
        @diagonal_indices.select {|d| d.length >= pattern.length}.each do |diagonal_index|
            diagonal = diagonal_index.map {|i,j| rows[i][j]}
            pattern_position = find_linear_pattern(diagonal, pattern)
            if pattern_position
                return pattern_position.map{|i| diagonal_index[i]}
            end
        end

        pattern_found_post_cond
        nil
    end

    def find_linear_pattern(line, pattern)
        slices = line.each_cons(pattern.length).to_a
        pattern_index = slices.index(pattern)
        if pattern_index
            return pattern.length.times.map{|i| pattern_index + i}
        end

        pattern_index_reverse = slices.index(pattern.reverse)
        if pattern_index_reverse
            return pattern.length.times.map{|i| pattern_index_reverse + i}.reverse
        end

        nil
    end

    def diagonal_indices(n_rows, n_cols)
        # returns the indices of the diagonals of a matrix of size (n_rows x n_cols),
        # as a collection of arrays of pairs (i,j)
        #
        # A square matrix 2x2 would have diagonal_indices
        # [ [1,0] ],
        # [ [0,0],[1,1] ],
        # [ [0,1] ],
        # [ [0,0] ],
        # [ [0,1], [1,0]],
        # [ [1,1] ]
        all_index_pairs = n_rows.times.flat_map {|r| n_cols.times.map{ |c| [r,c]}}
        left_right = all_index_pairs.group_by{|i,j| i - j}.values
        right_left = all_index_pairs.group_by{|i,j| i + j}.values
        left_right + right_left
    end
end