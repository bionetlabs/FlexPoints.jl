using FlexPoints, Test

@testset "FlexPoints" begin
    @testset "Approximation" begin
        data = [(1.0, 3.0), (2.0, 5.0), (3.0, 7.0), (5.0, 11.0)]
        
        @test linapprox(data, 4.0) == 9.0
        @test_throws AssertionError linapprox(data, 0.0)
        @test_throws AssertionError linapprox(data, 7.0)
        @test_throws AssertionError linapprox(Vector{Tuple{Int, Int}}(), 4.0)
        @test_throws MethodError linapprox([], 4.0)
    end
end
