class Foo
    def method
        b = Bar.new
        @lam = lambda do |param|
            b.method(param)
        end

        return b
    end

    def method2(val)
        @lam.call(val)
    end
end

class Bar
    def initialize
        @state = 1
    end

    def method(val)
        @state = val
    end

    def get_state
        @state
    end
end

f = Foo.new

b = f.method

puts b.get_state

f.method2(2)

puts b.get_state