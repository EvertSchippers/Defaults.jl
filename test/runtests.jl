using Defaults
using Test

struct TestType 
    item
end

Base.convert(::Type{Main.TestType}, whatever::T) where T = TestType(whatever)

@testset "Defaults" begin

    @define SomeThreshold = 42.0
    @test default(SomeThreshold) == 42.0

    @define SomeThreshold2 = "42"
    @test default(SomeThreshold2) == "42"
    @test gettype(SomeThreshold2) == String
    
    # When defining the type of the value, the default value will be converted.
    @define SomeThreshold3::Float64 = 42
    @test default(SomeThreshold3) isa Float64

    @define SomeThreshold4::Main.TestType = "42"
    @test default(SomeThreshold4) == TestType("42")

    dict = Dict{String,Any}()
    @test get(dict, SomeThreshold) == 42.0
    dict["someThreshold"] = 10

    @test get(dict, SomeThreshold) isa Float64
    @test get(dict, SomeThreshold) == 10.0

    dict["someThreshold4"] = 3.1415
    @test get(dict, SomeThreshold4) == TestType(3.1415)
    
    # override the json key name if needed
    dict["bla"] = 100
    @setkey SomeThreshold3 => "bla"
    @test get(dict, SomeThreshold3) == 100.0

end