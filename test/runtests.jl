using FlexPoints, Test

@testset "FlexPoints" begin
    @testset "Approximation" begin
        data = [(1.0, 3.0), (2.0, 5.0), (3.0, 7.0), (5.0, 11.0)]
        
        @test linapprox(data, 1.5) == 4.0
        @test linapprox(data, 4.0) == 9.0

        @test_throws AssertionError linapprox(data, 0.0)
        @test_throws AssertionError linapprox(data, 7.0)
        @test_throws AssertionError linapprox(Points2D{Float64}(), 4.0)
    end

    @testset "Measures" begin
        data = [(1.0, 1.0), (2.0, 2.0), (3.0, 3.0), (4.0, 4.0), (5.0, 5.0)]

        @testset "CF" begin
            @test cf(50, 5) == 10.0
            @test cf(5, 5) == 1.0
            @test cf(1, 5) == 0.2
            @test cf(data, [(1.0, 1.0)]) == 5.0
            @test cf(data, [(1, 1), (5, 5)]) == 2.5
            
            @test_throws AssertionError cf(0, 5)
            @test_throws AssertionError cf(5, 0)
            @test_throws AssertionError cf(-1, 0)
            @test_throws AssertionError cf(1, -2)
        end

        @testset "RMSE" begin
            @test rmse(data, [(1, 1), (5, 5)]) == 0.0
            @test rmse(data, [(1.0, 1.0), (5.0, 4.0)]) != 0.0

            @test_throws AssertionError rmse(Points2D{Float64}(), data)
            @test_throws AssertionError rmse(data, Points2D{Float64}())
        end

        @testset "NRMSE" begin
            @test nrmse(data, [(1, 1), (5, 5)]) == 0.0
            @test nrmse(data, [(1.0, 1.0), (5.0, 4.0)]) != 0.0

            @test_throws AssertionError nrmse(Points2D{Float64}(), data)
            @test_throws AssertionError nrmse(data, Points2D{Float64}())
        end
        
        @testset "MINRMSE" begin
            @test minrmse(data, [(1, 1), (5, 5)]) == 0.0
            @test minrmse(data, [(1.0, 1.0), (5.0, 4.0)]) != 0.0

            @test_throws AssertionError minrmse(Points2D{Float64}(), data)
            @test_throws AssertionError minrmse(data, Points2D{Float64}())
        end

        @testset "PRD" begin
            @test prd(data, [(1, 1), (5, 5)]) == 0.0
            @test prd(data, [(1.0, 1.0), (5.0, 4.0)]) != 0.0

            @test_throws AssertionError prd(Points2D{Float64}(), data)
            @test_throws AssertionError prd(data, Points2D{Float64}())
        end
        
        @testset "NPRD" begin
            @test nprd(data, [(1, 1), (5, 5)]) == 0.0
            @test nprd(data, [(1.0, 1.0), (5.0, 4.0)]) != 0.0

            @test_throws AssertionError nprd(Points2D{Float64}(), data)
            @test_throws AssertionError nprd(data, Points2D{Float64}())
        end
        
        @testset "QS" begin
            @test !isfinite(qs(data, [(1, 1), (5, 5)]))
            @test qs(data, [(1.0, 1.0), (5.0, 4.0)]) != 0.0

            @test_throws AssertionError qs(Points2D{Float64}(), data)
            @test_throws AssertionError qs(data, Points2D{Float64}())
        end
        
        @testset "NQS" begin
            @test !isfinite(nqs(data, [(1, 1), (5, 5)]))
            @test nqs(data, [(1.0, 1.0), (5.0, 4.0)]) != 0.0

            @test_throws AssertionError nqs(Points2D{Float64}(), data)
            @test_throws AssertionError nqs(data, Points2D{Float64}())
        end
    end

    @testset "Algorithm" begin
        data = [
            (1.0, 1.0),
            (2.0, 2.0),
            (3.0, 3.0),
            (4.0, 4.0),
            (5.0, 5.0),
            (6.0, 6.0),
            (7.0, 7.0)
        ]

        @testset "Derivatives" begin
            @test ∂(data) == [1.0, 1.0, 1.0, 1.0, 1.0]
            @test ∂(data, 1) == [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
            @test ∂(data, 2) == [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]

            @test_throws AssertionError ∂([(1.0, 1.0), (2.0, 2.0)], 1)
            @test_throws AssertionError ∂([(1.0, 1.0), (2.0, 2.0)])
            @test_throws AssertionError ∂(data, 0)
            @test_throws AssertionError ∂(data, 3)
        end

        @testset "FlexPoints" begin
            data = [
                (1.0, 5.0),
                (2.0, 7.0),
                (3.0, 8.0),
                (4.0, 8.0),
                (5.0, 8.0),
                (6.0, 8.0),
                (7.0, 8.0),
                (8.0, 9.0),
                (9.0, 10.0)
            ]

            results1 = flexpoints(data, (true, false, true, false))
            @test length(results1) > 0
        end
    end
end
