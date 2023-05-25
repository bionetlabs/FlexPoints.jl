using FlexPoints, Test

@testset "FlexPoints" begin
    @testset "Approximation" begin
        data = [(1.0, 3.0), (2.0, 5.0), (3.0, 7.0), (5.0, 11.0)]
        
        @test linapprox(data, 1.5) == 4.0
        @test linapprox(data, 4.0) == 9.0

        @test_throws AssertionError linapprox(data, 0.0)
        @test_throws AssertionError linapprox(data, 7.0)
        @test_throws AssertionError linapprox(Vector{Tuple{Int, Int}}(), 4.0)
        @test_throws MethodError linapprox([], 4.0)
    end

    @testset "Measures" begin
        data = [(1.0, 2.0), (2.0, 2.0), (3.0, 3.0), (4.0, 4.0), (5.0, 5.0)]

        @test compfactor(50, 5) == 10.0
        @test compfactor(5, 5) == 1.0
        @test compfactor(1, 5) == 0.2
        @test compfactor(data, [(1.0, 1.0)]) == 5.0
        @test compfactor(data, [(1, 1), (5, 5)]) == 2.5
        
        @test_throws AssertionError compfactor(0, 5)
        @test_throws AssertionError compfactor(5, 0)
        @test_throws AssertionError compfactor(-1, 0)
        @test_throws AssertionError compfactor(1, -2)
    end
end
