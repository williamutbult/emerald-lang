# Emerald

## Installation
The language requires Ruby installed and can be downloaded from https://www.ruby-lang.org/en/  
(developed in version 2.5)  

To run in the terminal: `-d` flag for debug mode  
```shell
ruby rules.rb file [-d]
```

## Data types
* Boolean - true & false
* Number - This type represents both integers and floating point numbers (1 & 2.5) dot is used as a decimal point. You can also represent numbers with arithmetic expressions (1/3)
* Text - "Hello" alternatively 'world' (" or '), but not a mix of the two
* List - [3, 4, "text", true] can contain a mixture of all data types, every index is an integer.

## Operations
* Addition (number) +
* Subtraction (number) -
* Multiplication (number) *
* Division (number) /
* Concatenation (text) +

## Comparisons
* == (equal to)
* \>= (equal or greater than)
* <= (equal or less than)
* \> (greater than)
* < (less than)
* != (not equal to)

## Output
* Print - `$stdout`
* Warn - `$stdout` (warning label)

## Control flow
* Function - with parameters (return not implemented, but part of design specification)
* Variable - name may not start with number or underscore
* If-block - elseif & else
* For-loop - integer, without index
* While-loop - (break not implemented, but part of design specification)

## Syntax
The syntax is independent of whitespace and newline & uses keywords to mark the beginning and end of flow and declarations

### Comments
```rb
# Comments begin with a hash and ends at newline
# There is not syntax for multi-line comments
```

### Data types
```rb
# Boolean
true
false

# Number
1
2.5
1+2-3*1/3

# Text
"Hello, world!"
'Never gonna give you up'

# List
[3, 2.5, "text", true]
```

### Operations
```rb
# Addition
1 + 2 # => 3

# Subtraction
4 - 3 # => 1

# Multiplication
4 * 2 # => 8

# Division
9/3 # => 3

# Concatenation
"Hello " + "there" # => "Hello there"
"Number " + 42 # => "Number 42"
```

### Comparisons
```rb
# Equal to
2 == 1 # => false

# Equal or greater than
2 >= 1 # => true

# Equal or less than
2 <= 1 # => false

# Greater than
2 > 1 # => true

# Less than
2 < 1 # => false

# Not equal to
2 != 1 # => true
```

### Output
```rb
# Print
print("Hello world") # => Hello world

# Warn
warn("Heads up!") # => [WARNING] Heads up!
```

### Control flow
```rb
# Function
function print3(parameter) # declaration
	print(parameter)
	print(parameter)
	print(parameter)
end function

print3("Go!") # call

# Variable
variable_name = 13.37 # assignment
variable_name # reading

# If-block
if false then
	# an if-statement must have one if-block
elseif true then
	# an if-statement can have several (or no) elseif-blocks
else
	# an if-statement can have one else-block
end if

# For loop
for 10 do
	# a for loop requires one integer
end for

# While loop
index = 1
while index < 10 do
	index = index + 1
end while
```
