using Test
using BSeries

using StaticArrays: @SArray
using Symbolics: Symbolics, @variables, Num


@testset "BSeries" begin


@testset "lazy representation of exact ODE solution" begin
  exact = BSeries.ExactSolution{Rational{Int}}()
  terms = collect(Iterators.take(exact, 4))
  @test terms == [1//1, 1//2, 1//6, 1//3]
end

@testset "subsitution" begin
  @variables a1 a2 a31 a32
  a = OrderedDict{RootedTrees.RootedTree{Int, Vector{Int}}, Num}(
        rootedtree(Int[])     => 1,
        rootedtree([1])       => a1,
        rootedtree([1, 2])    => a2,
        rootedtree([1, 2, 2]) => a31,
        rootedtree([1, 2, 3]) => a32)

  @variables b1 b2 b31 b32
  b = OrderedDict{RootedTrees.RootedTree{Int, Vector{Int}}, Num}(
        rootedtree(Int[])     => 0,
        rootedtree([1])       => b1,
        rootedtree([1, 2])    => b2,
        rootedtree([1, 2, 2]) => b31,
        rootedtree([1, 2, 3]) => b32)

  t = rootedtree([1])
  @inferred substitute(b, a, t)
  @test isequal(substitute(b, a, t), a1 * b1)

  t = rootedtree([1, 2, 3])
  @inferred substitute(b, a, t)
  @test isequal(substitute(b, a, t), a1 * b32 + 2 * a2 * b1 * b2 + a32 * b1^3)
end


@testset "modified_equation" begin
  t1  = rootedtree([1])
  t2  = rootedtree([1, 2])
  t31 = rootedtree([1, 2, 2])
  t32 = rootedtree([1, 2, 3])
  t41 = rootedtree([1, 2, 2, 2])
  t42 = rootedtree([1, 2, 2, 3])
  t43 = rootedtree([1, 2, 3, 3])
  t44 = rootedtree([1, 2, 3, 4])
  t51 = rootedtree([1, 2, 2, 2, 2])
  t52 = rootedtree([1, 2, 2, 2, 3])
  t53 = rootedtree([1, 2, 2, 3, 3])
  t54 = rootedtree([1, 2, 2, 3, 4])
  t55 = rootedtree([1, 2, 3, 2, 3])
  t56 = rootedtree([1, 2, 3, 3, 3])
  t57 = rootedtree([1, 2, 3, 3, 4])
  t58 = rootedtree([1, 2, 3, 4, 4])
  t59 = rootedtree([1, 2, 3, 4, 5])

  @testset "SSPRK(2, 2) aka Heun's method" begin
    A = @SArray [0.0 0.0;
                1.0 0.0]
    b = @SArray [1/2, 1/2]
    c = @SArray [0.0, 1.0]
    order = 5
    series = modified_equation(A, b, c, order)

    # tested with the python package BSeries
    @test series[t1 ] ≈ 1.0                   atol=10*eps()
    @test series[t2 ] ≈ 0                     atol=10*eps()
    @test series[t31] ≈ 0.166666666666667     atol=10*eps()
    @test series[t32] ≈ -0.166666666666667    atol=10*eps()
    @test series[t41] ≈ -1.11022302462516e-16 atol=10*eps()
    @test series[t42] ≈ -0.125000000000000    atol=10*eps()
    @test series[t43] ≈ -2.77555756156289e-17 atol=10*eps()
    @test series[t44] ≈ 0.125000000000000     atol=10*eps()
    @test series[t51] ≈ -0.0333333333333332   atol=10*eps()
    @test series[t52] ≈ -0.0583333333333333   atol=10*eps()
    @test series[t55] ≈ 0.0750000000000000    atol=10*eps()
    @test series[t53] ≈ 0.0583333333333333    atol=10*eps()
    @test series[t56] ≈ 0.0333333333333334    atol=10*eps()
    @test series[t54] ≈ 0.0500000000000000    atol=10*eps()
    @test series[t57] ≈ 0.0583333333333333    atol=10*eps()
    @test series[t58] ≈ -0.0583333333333333   atol=10*eps()
    @test series[t59] ≈ -0.0500000000000000   atol=10*eps()
  end


  @testset "SSPRK(3, 3)" begin
    A = @SArray [0.0 0.0 0.0;
                1.0 0.0 0.0;
                1/4 1/4 0.0]
    b = @SArray [1/6, 1/6, 2/3]
    c = @SArray [0.0, 1.0, 1/2]
    order = 5
    series = modified_equation(A, b, c, order)

    # tested with the python package BSeries
    @test series[t1 ] ≈ 1.0                  atol=10*eps()
    @test series[t2 ] ≈ 0                    atol=10*eps()
    @test series[t31] ≈ 0                    atol=10*eps()
    @test series[t32] ≈ 0                    atol=10*eps()
    @test series[t41] ≈ 0                    atol=10*eps()
    @test series[t42] ≈ -0.0416666666666667  atol=10*eps()
    @test series[t43] ≈ 0.0833333333333333   atol=10*eps()
    @test series[t44] ≈ -0.0416666666666667  atol=10*eps()
    @test series[t51] ≈ 0.00833333333333330  atol=10*eps()
    @test series[t52] ≈ -0.0166666666666667  atol=10*eps()
    @test series[t55] ≈ 0.0333333333333333   atol=10*eps()
    @test series[t53] ≈ 0.0166666666666667   atol=10*eps()
    @test series[t56] ≈ -0.00833333333333333 atol=10*eps()
    @test series[t54] ≈ 0.00833333333333333  atol=10*eps()
    @test series[t57] ≈ -0.0250000000000000  atol=10*eps()
    @test series[t58] ≈ -0.0166666666666667  atol=10*eps()
    @test series[t59] ≈ 0.0333333333333333   atol=10*eps()
  end


  @testset "Explicit midpoint method (Runge's method)" begin
    A = @SArray [0 0; 1//2 0]
    b = @SArray [0, 1//1]
    c = @SArray [0, 1//2]
    order = 5
    series = modified_equation(A, b, c, order)

    # tested with the python package BSeries
    @test series[t1 ] == 1
    @test series[t2 ] == 0
    @test series[t31] == -1//12
    @test series[t32] == -1//6
    @test series[t41] == 0
    @test series[t42] == 0
    @test series[t43] == 1//8
    @test series[t44] == 1//8
    @test series[t51] == 7//240
    @test series[t52] == 1//40
    @test series[t55] == 1//30
    @test series[t53] == 3//80
    @test series[t56] == -7//240
    @test series[t54] == 7//240
    @test series[t57] == -1//40
    @test series[t58] == -19//240
    @test series[t59] == -1//20
  end
end


@testset "modifying_integrator" begin
  t1  = rootedtree([1])
  t2  = rootedtree([1, 2])
  t31 = rootedtree([1, 2, 2])
  t32 = rootedtree([1, 2, 3])
  t41 = rootedtree([1, 2, 2, 2])
  t42 = rootedtree([1, 2, 2, 3])
  t43 = rootedtree([1, 2, 3, 3])
  t44 = rootedtree([1, 2, 3, 4])
  t51 = rootedtree([1, 2, 2, 2, 2])
  t52 = rootedtree([1, 2, 2, 2, 3])
  t53 = rootedtree([1, 2, 2, 3, 3])
  t54 = rootedtree([1, 2, 2, 3, 4])
  t55 = rootedtree([1, 2, 3, 2, 3])
  t56 = rootedtree([1, 2, 3, 3, 3])
  t57 = rootedtree([1, 2, 3, 3, 4])
  t58 = rootedtree([1, 2, 3, 4, 4])
  t59 = rootedtree([1, 2, 3, 4, 5])

  @testset "SSPRK(2, 2) aka Heun's method" begin
    A = @SArray [0.0 0.0;
                1.0 0.0]
    b = @SArray [1/2, 1/2]
    c = @SArray [0.0, 1.0]
    order = 5
    series = modifying_integrator(A, b, c, order)

    # tested with the python package BSeries
    @test series[t1 ] ≈ 1                    atol=10*eps()
    @test series[t2 ] ≈ 0                    atol=10*eps()
    @test series[t31] ≈ -0.166666666666667   atol=10*eps()
    @test series[t32] ≈ 1/6                  atol=10*eps()
    @test series[t41] ≈ 8.32667268468867e-17 atol=10*eps()
    @test series[t42] ≈ 0.125000000000000    atol=10*eps()
    @test series[t43] ≈ 1.38777878078145e-17 atol=10*eps()
    @test series[t44] ≈ -0.125000000000000   atol=10*eps()
    @test series[t51] ≈ 0.200000000000000    atol=10*eps()
    @test series[t52] ≈ 0.0583333333333333   atol=10*eps()
    @test series[t55] ≈ 0.00833333333333335  atol=10*eps()
    @test series[t53] ≈ -0.0583333333333333  atol=10*eps()
    @test series[t56] ≈ -0.200000000000000   atol=10*eps()
    @test series[t54] ≈ -0.133333333333333   atol=10*eps()
    @test series[t57] ≈ -0.0583333333333333  atol=10*eps()
    @test series[t58] ≈ 0.0583333333333333   atol=10*eps()
    @test series[t59] ≈ 0.133333333333333    atol=10*eps()
  end


  @testset "SSPRK(3, 3)" begin
    A = @SArray [0.0 0.0 0.0;
                1.0 0.0 0.0;
                1/4 1/4 0.0]
    b = @SArray [1/6, 1/6, 2/3]
    c = @SArray [0.0, 1.0, 1/2]
    order = 5
    series = modifying_integrator(A, b, c, order)

    # tested with the python package BSeries
    @test series[t1 ] ≈ 1                    atol=10*eps()
    @test series[t2 ] ≈ 0                    atol=10*eps()
    @test series[t31] ≈ 0                    atol=10*eps()
    @test series[t32] ≈ 0                    atol=10*eps()
    @test series[t41] ≈ 0                    atol=10*eps()
    @test series[t42] ≈ 0.0416666666666667   atol=10*eps()
    @test series[t43] ≈ -0.0833333333333333  atol=10*eps()
    @test series[t44] ≈ 1/24                 atol=10*eps()
    @test series[t51] ≈ -0.00833333333333330 atol=10*eps()
    @test series[t52] ≈ 0.0166666666666667   atol=10*eps()
    @test series[t55] ≈ -0.0333333333333333  atol=10*eps()
    @test series[t53] ≈ -0.0166666666666667  atol=10*eps()
    @test series[t56] ≈ 0.00833333333333332  atol=10*eps()
    @test series[t54] ≈ -0.00833333333333334 atol=10*eps()
    @test series[t57] ≈ 0.0250000000000000   atol=10*eps()
    @test series[t58] ≈ 1/60                 atol=10*eps()
    @test series[t59] ≈ -0.0333333333333333  atol=10*eps()
  end


  @testset "Explicit midpoint method (Runge's method)" begin
    A = @SArray [0 0; 1//2 0]
    b = @SArray [0, 1//1]
    c = @SArray [0, 1//2]
    order = 5
    series = modifying_integrator(A, b, c, order)

    # tested with the python package BSeries
    @test series[t1 ] == 1
    @test series[t2 ] == 0
    @test series[t31] == 1//12
    @test series[t32] == 1//6
    @test series[t41] == 0
    @test series[t42] == 0
    @test series[t43] == -1//8
    @test series[t44] == -1//8
    @test series[t51] == 1//80
    @test series[t52] == 1//60
    @test series[t55] == 7//240
    @test series[t53] == 1//240
    @test series[t56] == 9//80
    @test series[t54] == 1//80
    @test series[t57] == 13//120
    @test series[t58] == 13//80
    @test series[t59] == 2//15
  end
end


end # @testset "BSeries"
