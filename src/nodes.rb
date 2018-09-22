
$functions = {} #Global scope for functions
$scopes = [{}]

def open_scope
    $scopes.push({})
end

def close_scope
    $scopes.pop
end

def write_scope(name, value)
    max = $scopes.length - 1
    i = 0
    while (not $scopes[i][name]) and (i < max)
        i = i+1
    end
    $scopes[i][name] = value
end

def write_scope_local(name, value)
    i = $scopes.length - 1
    $scopes[i][name] = value
end

def read_scope(name)
    i = $scopes.length - 1
    val = $scopes[i][name]
    while (not val) and (i > 0)
        i = i-1
        val = $scopes[i][name]
    end
    return val
    #TODO: Handle non-existant values
end



# ============ FLOW ============

class Statement_List
    def initialize(s)
        @statements = [s]
    end
    def +(s)
        @statements.push(s)
    end

    def eval
        @statements.each do |s|
            s.eval
        end
    end
end

class List_Index
    def initialize(variable, index)
        @variable = variable
        @index = index
    end
    def eval
        list = @variable.eval
        index = @index.eval
        val = list[index]
        return val
    end
end

class List_Assign
    def initialize(variable, index, value)
        @variable = variable
        @index = index
        @value = value
    end
    def eval
        list = read_scope(@variable)
        list[@index.eval] = @value.eval
        write_scope(@variable, list)
    end
end

class Variable
    attr_reader :var
    def initialize(name)
        @var = name
    end
    def eval
        return read_scope(@var)
    end
end

class Assign
    def initialize(name, value)
        @var = name
        @val = value
    end
    def name
        @var
    end
    def eval
        val = @val.eval
        write_scope(@var, val)
    end
end

class For
    # TODO Implement break
    def initialize(n, sl)
        @n = n
        @sl = sl
    end
    def eval
        open_scope
        for i in 1..@n do
            @sl.eval
        end
        close_scope
    end
end

class While
    # TODO Implement break
    def initialize(cond, sl)
        @cond = cond
        @sl = sl
    end
    def eval
        open_scope
        while @cond.eval == true
            @sl.eval
        end
        close_scope
    end
end

class Argument_List
    def initialize(arg)
        @args = [arg]
    end
    def +(arg)
        @args = @args.push(arg)
    end
    def eval
        return @args
    end
end

class Function
    #TODO Implement return
    def initialize(name, sl, params)
        @name = name
        @sl = sl
        if params
            @params = params.eval
        else
            @params = []
        end
    end
    def eval
        $functions[@name] = {:sl => @sl, :params => @params}
    end
end

class Call
    def initialize(name, args)
        @name = name
        if args
            @args = args.eval
        else
            @args = []
        end
    end
    def eval
        fun = $functions[@name]
        sl = fun[:sl]
        params = fun[:params]
        open_scope
        i = 0
        #TODO Handle more arguments than params (reverse allowed)
        for arg in @args
            write_scope_local(params[i], arg.eval)
            i = i + 1
        end
        sl.eval
        close_scope
    end
end

class Condition_List
    def initialize(comp, sl)
        @list = [{:if => comp, :then => sl}]
    end
    def +(pair)
        comp = pair[0]
        sl = pair[1]
        @list.push({:if => comp, :then => sl})
    end
    def eval
        @list
    end
end

class If
    def initialize(if_then)
        @if = if_then
        @elseif = nil
        @else = nil
    end
    def elseif(blocks)
        @elseif =  blocks.eval
    end
    def else(sl)
        @else = sl
    end
    def eval
        if @if[:if].eval
            @if[:then].eval
        else
            if @elseif
                e = true
                for ei in @elseif
                    if ei[:if].eval
                        ei[:then].eval
                        e = false
                        break
                    end
                end
                if e and @else
                    @else.eval
                end
            else
                if @else
                    @else.eval
                end
            end
        end
    end
end



# ============ DATA ============

class Number
    def initialize(n)
        @value = n
    end
    def eval
        return @value
    end
end

class Text
    def initialize(t)
        @value = t
    end
    def eval
        return @value
    end
end

class Boolean
    def initialize(val)
        @value = val
    end
    def eval
        return @value
    end
end

class List
    def initialize(val)
        @list = [val.eval]
    end
    def +(val)
        @list.push(val.eval)
    end
    def index(index, val)
        @list[index.eval] = val.eval
    end
    def eval
        @list
    end
end



# ============ OPERATIONS ============

class Addition
    def initialize(a, b, reverse = false)
        @a = a
        @b = b
        @reverse = reverse
    end

    def eval
        a = @a.eval
        b = @b.eval
        if @reverse
            return a - b
        else
            return a + b
        end
    end
end

class Multiplication
    def initialize(a, b, reverse = false)
        @a = a
        @b = b
        @reverse = reverse
    end

    def eval
        a = @a.eval
        b = @b.eval
        if @reverse
            return a.to_f / b
        else
            return a * b
        end
    end
end

class Concat
    def initialize(a,b)
        @a = a
        @b = b
    end
    def eval
        return @a.eval + (@b.eval).to_s
    end
end



# ============ COMPARISONS ============

class Comparison
    def initialize(a, b, sym)
        @a = a
        @b = b
        @sym = sym
    end

    def eval
        #TODO Special rules depending on data type
        a = @a.eval
        b = @b.eval
        if a.public_send(@sym, b)
            return true
        else
            return false
        end
    end
end



# ============ INPUT/OUTPUT ============

class Output
    def initialize(expr)
        @out = expr
    end
    def eval
        puts (@out.eval).to_s
    end
end

class Warn
    def initialize(expr)
        @out = expr
    end
    def eval
        puts "[WARNING] " + (@out.eval).to_s
    end
end
