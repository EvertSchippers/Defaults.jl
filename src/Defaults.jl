module Defaults

export @define, @setkey, default, jsonkey, gettype

jsonkey(s) = lowercasefirst(s)    
jsonkey(s::Symbol) = jsonkey("$s")
jsonkey(::Type{T}) where T = jsonkey(nameof(T))

macro setkey(keyassignment)
    if !( keyassignment.head == :call && keyassignment.args[1] == :(=>))
        error("Incorrect key assingment. Expected e.g. `@setkey ParameterName => \"parameterName\"`")
    end
    
    name = keyassignment.args[2]
    string = "$(keyassignment.args[3])"

    @eval begin
        struct $name end
        jsonkey(::Type{$name}) = $string
    end
end

macro define(assignment, description = nothing)
    
    if !( assignment.head == :(=))
        error("Expected assignment expression.")
    end

    default_value = eval(assignment.args[2])

    type = typeof(default_value)
    name = assignment.args[1]
    
    if !(name isa Symbol)
        typed = name
        
        if !(typed.head == :(::))
            error("Unexpected default assignment.")
        end

        name = typed.args[1]
        type = typed.args[2]
    end
    
    key = jsonkey(name)
    
    @eval begin
        struct $name end
        export $name
        default(::Type{$name})::$type = $default_value
        gettype(::Type{$name}) = $type
        jsonkey(::Type{$name}) = $key
        Base.get(dict, ::Type{$name})::$type = get(dict, jsonkey($name), default($name))
    end

    return nothing
end

end # module
