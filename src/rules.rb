require './rdparse'
require './nodes'

class Rules

    def initialize(file)
        @file = file
        @ruleparser = Parser.new("rules") do

            # ======= TOKENS =======
            # To protect tokens from variable matching add "_" prefix (:_token)

            # Ignore
            token(/#.+/) # comments
            token(/\s/) # whitespaces

            # Boolean
            token(/true/) {|x| :_true}
            token(/false/) {|x| :_false}

            # Number
            token(/\d+\.\d+/) {|x| x.to_f} # float
            token(/\d+/) {|x| x.to_i} # integer

            # Text
            token(/"[^"]*"/) {|x| x} # "string"
            token(/'[^']*'/) {|x| x} # 'string'

            # Function
            token(/function/) {|x| :_function}
            token(/end function/) {|x| :_endfunction}
            token(/return/) {|x| :_return} # not implemented

            # If-block
            token(/if/) {|x| :_if}
            token(/then/) {|x| :_then}
            token(/elseif/) {|x| :_elseif}
            token(/else/) {|x| :_else}
            token(/end if/) {|x| :_endif}

            # Output
            token(/print/) {|x| :_print}
            token(/warn/) {|x| :_warn}

            # Loops (used in both for & while)
            token(/do/) {|x| :_do}
            token(/break/) {|x| :_break} # not implemented

            # For-loop
            token(/for/) {|x| :_for}
            token(/end for/) {|x| :_endfor}

            # While-loop
            token(/while/) {|x| :_while}
            token(/end while/) {|x| :_endwhile}

            # Operators
            token(/(==|>=|<=|>|<|!=)/) {|x| x}
            #[\+\=\*\/]
            token(/(\+|\=|\*|\/)/) {|x| x}

            # Symbols
            token(/([|])/) {|x| x}

            # Variables
            #[A-Za-z]+[A-Za-z0-9_]*
            #[A-Za-z]{1}[A-Za-z0-9_]{0,*}
            #^[A-Za-z]+[A-Za-z0-9_]*
            token(/^[A-Za-z]+[A-Za-z0-9_]*/) {|x| x} #Cannot begin with _

            # Catch "all" (one character)
            token(/./) {|x| x}


            # ======= RULES =======
            start :program do
                match(:statement_list) {|sl| sl}
            end

            rule :statement_list do
                match(:statement_list, :statement) {|sl, s| sl + s; sl}
                match(:statement) {|s| Statement_List.new(s)}
            end

            rule :statement do
                match(:if_block) {|x| x}
                match(:function) {|x| x}
                match(:call) {|x| x}
                match(:for_loop) {|x| x}
                match(:while_loop) {|x| x}
                match(:print) {|x| x}
                match(:warn) {|x| x}
                match(:assign) {|x| x}
                match(:list_assign) {|x| x}
                match(:expr) {|x| x} # Do nothing (Last)
            end



            # Statement #

            rule :expr do
                #TODO Add parentheses math
                match(:list) {|x| x}
                match(:list_index)
                match(:text) {|x| x}
                match(:math) {|x| x}
                match(:variable) {|x| x}
                match(:boolean) {|x| x}
            end

            rule :print do
                match(:_print,"(",:expr,")") {|_, _, expr, _| Output.new(expr)}
                match(:_print,"(",:comparison,")") {|_, _, comp, _| Output.new(comp)}
            end

            rule :warn do
                match(:_warn,"(",:expr,")") {|_, _, expr, _| Warn.new(expr)}
                match(:_warn,"(",:comparison,")") {|_, _, comp, _| Warn.new(comp)}
            end

            rule :list_index do
                match(:variable,"[",Integer,"]") {|var, _, i, _| List_Index.new(var, Number.new(i))}
                match(:variable,"[",:variable,"]") {|var, _, ivar, _| List_Index.new(var, ivar)}
            end

            rule :list_assign do
                match(:var,"[",Integer,"]","=",:expr) {|var, _, i, _, _, val| List_Assign.new(var, Number.new(i), val)}
                match(:var,"[",:variable,"]","=",:expr) {|var, _, ivar, _, _, val| List_Assign.new(var, ivar, val)}
            end

            # Expression #

            # Math #

            rule :list do
                match("[", :list_items, "]") {|_, li, _| li}
            end

            rule :list_items do
                match(:list_items,",", :expr) {|li, _, val| li + val; li}
                match(:expr) {|val| List.new(val)}
            end


            rule :math do
                match(:addition) {|x| x}
            end

            rule :addition do
                match(:multiplication) {|x| x}
                match(:addition, "+", :multiplication) {|a,_,b| Addition.new(a,b)}
                match(:addition, "-", :multiplication) {|a,_,b| Addition.new(a,b,true)}
            end

            rule :multiplication do
                match(:multiplication, "*", :number) {|a,_,b| Multiplication.new(a,b)}
                match(:multiplication, "/", :number) {|a,_,b| Multiplication.new(a,b,true)}
                match(:multiplication, "*", :variable) {|a,_,b| Multiplication.new(a,b)}
                match(:multiplication, "/", :variable) {|a,_,b| Multiplication.new(a,b,true)}
                match(:number) {|x| x}
                match(:variable) {|x| x}
            end

            # Text #
            rule :text do
                match(:string) {|x| x}
                match(:text, "+", :string) {|a,_,b| Concat.new(a,b)}
                match(:text, "+", :math) {|a,_,b| Concat.new(a,b)}
            end

            rule :string do
                match(/"[^"]*"/) {|x| Text.new(x[1, x.length-2])} # "string"
                match(/'[^']*'/) {|x| Text.new(x[1, x.length-2])} # 'string'
            end

            rule :number do
                match("-", Integer) {|x| Number.new(-x)}
                match(Integer) {|x| Number.new(x)}
                match("-", Float) {|x| Number.new(-x)}
                match(Float) {|x| Number.new(x)}
            end

            # Boolean

            rule :boolean do
                match(:_true) {|x| Boolean.new(true)}
                match(:_false) {|x| Boolean.new(false)}
            end



            # Variables #

            rule :var do
                #[A-Za-z]+[A-Za-z0-9_]*
                #[A-Za-z]{1}+[A-Za-z0-9_]{0,*}
                #^[A-Za-z]+[A-Za-z0-9_]*
                match(/^[A-Za-z]+[A-Za-z0-9_]*/) {|x| x}
            end

            # Assign
            rule :assign do
                match(:var, "=", :expr) {|var,_,val| Assign.new(var, val)}
            end

            # Lookup
            rule :variable do
                match(:var) {|var| Variable.new(var)} # No initial (0-9|_)
            end



            # Functions #

            rule :params do
                match(:params, ",", :var) {|params, _, param| params + param; params}
                match(:var) {|param| Argument_List.new(param)}
            end

            rule :args do
                match(:args, ",", :expr) {|args, _, arg| args + arg; args}
                match(:expr) {|arg| Argument_List.new(arg)}
            end

            # Declare
            rule :function do
                match(:_function, :var, "(", :params, ")", :statement_list, :_endfunction ) {|_, name, _, params, _, sl, _| Function.new(name, sl, params)}
                match(:_function, :var, "(",")", :statement_list, :_endfunction ) {|_, name, _, _, sl, _| Function.new(name, sl, nil)}
            end

            # Call
            rule :call do
                match(:var, "(", :args, ")") {|name, _, args, _| Call.new(name, args)}
                match(:var, "(", ")") {|name, _, _| Call.new(name, nil)}
            end



            # Loops #

            # For #

            rule :for_loop do
                match(:_for, Integer, :_do, :statement_list, :_endfor){|_, n, _, sl, _| For.new(n, sl)}
            end

            rule :while_loop do
                match(:_while, :comparison, :_do, :statement_list, :_endwhile){|_, cond, _, sl, _| While.new(cond, sl)}
            end



            # Comparisons #
            rule :comperand do
                match(/(==|>=|<=|>|<|!=)/) {|x| x}
            end

            rule :comparison do
                match(:expr, :comperand, :expr) {|a, sym, b| Comparison.new(a,b,sym)}
                match(:_true) {|x| Boolean.new(true)}
                match(:_false) {|x| Boolean.new(false)}
            end


            # Conditions #
            # if endif
            # if else endif
            # if elseif (*) endif
            # if elseif (*) else endif

            rule :if_block do
                match(:if, :elseif, :else,:_endif) {|i, ei, e| i.elseif(ei); i.else(e); i}
                match(:if, :elseif, :_endif) {|i, ei| i.elseif(ei); i}
                match(:if, :else, :_endif) {|i, e| i.else(e); i}
                match(:if, :_endif) {|i| i}
            end

            rule :if do
                match(:_if, :comparison, :_then, :statement_list) {|_, comp, _, sl| If.new({:if => comp, :then => sl})}
            end

            rule :elseif do #recursive
                match(:elseif, :_elseif, :comparison, :_then, :statement_list) {|elseif, _, comp, _, sl| elseif + [comp, sl]; elseif}

                match(:_elseif, :comparison, :_then, :statement_list) {|_, comp, _, sl| Condition_List.new(comp, sl)}
            end

            rule :else do
                match(:_else, :statement_list) {|_, sl| sl}
            end


            # ======= END of RULES =======
        end
    end

    def start
        @ruleparser.logger.level = Logger::WARN
        #puts "\n[+] Program Finished\n=> #{(@ruleparser.parse @file).eval}"
        (@ruleparser.parse @file).eval
        nil
    end
end

filename = ARGV[0]
debug = false
if ARGV[1] and ARGV[1] == "-d"
    debug = true
end
code = File.read(filename)
if debug
    puts("Debug")
    debug_code = ""
    code.each_line do |line|
        debug_code = debug_code + "print('[D] " + line + "')" # Unstable
        debug_code = debug_code + line
    end
    rules = Rules.new(debug_code)
    rules.start
else
    puts("Normal")
    rules = Rules.new(code)
    rules.start
end
