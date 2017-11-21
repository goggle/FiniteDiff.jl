x = collect(linspace(-2π, 2π, 100))
y = sin.(x)
df = zeros(100)
epsilon = zeros(100)
df_ref = cos.(x)
J_ref = diagm(cos.(x))
J = zeros(J_ref)

err_func(a,b) = maximum(abs.(a-b))

# TODO: add tests for GPUArrays
# TODO: add tests for DEDataArrays

# StridedArray tests start here
# derivative tests for real-valued callables
@time @testset "Derivative StridedArray real-valued tests" begin
    @test err_func(DiffEqDiffTools.finite_difference(sin, x, Val{:forward}), df_ref) < 1e-4
    @test err_func(DiffEqDiffTools.finite_difference(sin, x, Val{:central}), df_ref) < 1e-8
    @test err_func(DiffEqDiffTools.finite_difference(sin, x, Val{:complex}), df_ref) < 1e-15

    @test err_func(DiffEqDiffTools.finite_difference(sin, x, Val{:forward}, Val{:Real}, y), df_ref) < 1e-4
    @test err_func(DiffEqDiffTools.finite_difference(sin, x, Val{:central}, Val{:Real}, y), df_ref) < 1e-8
    @test err_func(DiffEqDiffTools.finite_difference(sin, x, Val{:complex}, Val{:Real}, y), df_ref) < 1e-15

    @test err_func(DiffEqDiffTools.finite_difference(sin, x, Val{:forward}, Val{:Real}, y, epsilon), df_ref) < 1e-4
    @test err_func(DiffEqDiffTools.finite_difference(sin, x, Val{:central}, Val{:Real}, y, epsilon), df_ref) < 1e-8
    @test err_func(DiffEqDiffTools.finite_difference(sin, x, Val{:complex}, Val{:Real}, y, epsilon), df_ref) < 1e-15

    @test err_func(DiffEqDiffTools.finite_difference!(df, sin, x, Val{:forward}), df_ref) < 1e-4
    @test err_func(DiffEqDiffTools.finite_difference!(df, sin, x, Val{:central}), df_ref) < 1e-8
    @test err_func(DiffEqDiffTools.finite_difference!(df, sin, x, Val{:complex}), df_ref) < 1e-15

    @test err_func(DiffEqDiffTools.finite_difference!(df, sin, x, Val{:forward}, Val{:Real}, y), df_ref) < 1e-4
    @test err_func(DiffEqDiffTools.finite_difference!(df, sin, x, Val{:central}, Val{:Real}, y), df_ref) < 1e-8
    @test err_func(DiffEqDiffTools.finite_difference!(df, sin, x, Val{:complex}, Val{:Real}, y), df_ref) < 1e-15

    @test err_func(DiffEqDiffTools.finite_difference!(df, sin, x, Val{:forward}, Val{:Real}, y, epsilon), df_ref) < 1e-4
    @test err_func(DiffEqDiffTools.finite_difference!(df, sin, x, Val{:central}, Val{:Real}, y, epsilon), df_ref) < 1e-8
    @test err_func(DiffEqDiffTools.finite_difference!(df, sin, x, Val{:complex}, Val{:Real}, y, epsilon), df_ref) < 1e-15
end

# derivative tests for complex-valued callables
x = x + im*x
f(x) = cos(real(x)) + im*sin(imag(x))
y = f.(x)
df = zeros(x)
epsilon = zeros(length(x))
df_ref = -sin.(real(x)) + im*cos.(imag(x))

@time @testset "Derivative StridedArray complex-valued tests" begin
    @test err_func(DiffEqDiffTools.finite_difference(f, x, Val{:forward}, Val{:Complex}), df_ref) < 1e-4
    @test err_func(DiffEqDiffTools.finite_difference(f, x, Val{:central}, Val{:Complex}), df_ref) < 1e-8

    @test err_func(DiffEqDiffTools.finite_difference(f, x, Val{:forward}, Val{:Complex}, y), df_ref) < 1e-4
    @test err_func(DiffEqDiffTools.finite_difference(f, x, Val{:central}, Val{:Complex}, y), df_ref) < 1e-8

    @test err_func(DiffEqDiffTools.finite_difference(f, x, Val{:forward}, Val{:Complex}, y, epsilon), df_ref) < 1e-4
    @test err_func(DiffEqDiffTools.finite_difference(f, x, Val{:central}, Val{:Complex}, y, epsilon), df_ref) < 1e-8

    @test err_func(DiffEqDiffTools.finite_difference!(df, f, x, Val{:forward}, Val{:Complex}), df_ref) < 1e-4
    @test err_func(DiffEqDiffTools.finite_difference!(df, f, x, Val{:central}, Val{:Complex}), df_ref) < 1e-8

    @test err_func(DiffEqDiffTools.finite_difference!(df, f, x, Val{:forward}, Val{:Complex}, y), df_ref) < 1e-4
    @test err_func(DiffEqDiffTools.finite_difference!(df, f, x, Val{:central}, Val{:Complex}, y), df_ref) < 1e-8

    @test err_func(DiffEqDiffTools.finite_difference!(df, f, x, Val{:forward}, Val{:Complex}, y, epsilon), df_ref) < 1e-4
    @test err_func(DiffEqDiffTools.finite_difference!(df, f, x, Val{:central}, Val{:Complex}, y, epsilon), df_ref) < 1e-8
end

function f(fvec,x)
    fvec[1] = (x[1]+3)*(x[2]^3-7)+18
    fvec[2] = sin(x[2]*exp(x[1])-1)
end
x = rand(2); y = rand(2)
f(y,x)
J_ref = [[-7+x[2]^3 3*(3+x[1])*x[2]^2]; [exp(x[1])*x[2]*cos(1-exp(x[1])*x[2]) exp(x[1])*cos(1-exp(x[1])*x[2])]]
J = zeros(J_ref)
df = zeros(x)
df_ref = diag(J_ref)
epsilon = zeros(x)
forward_cache = DiffEqDiffTools.JacobianCache(similar(x),similar(x),similar(x),Val{:forward})
central_cache = DiffEqDiffTools.JacobianCache(similar(x),similar(x),similar(x))
complex_cache = DiffEqDiffTools.JacobianCache(
                Complex{eltype(x)}.(similar(x)),Complex{eltype(x)}.(similar(x)),
                Complex{eltype(x)}.(similar(x)),Val{:complex})

# Jacobian tests for real-valued callables
@time @testset "Jacobian StridedArray real-valued tests" begin
    @test err_func(DiffEqDiffTools.finite_difference_jacobian(f, x, forward_cache), J_ref) < 1e-4
    @test err_func(DiffEqDiffTools.finite_difference_jacobian(f, x, central_cache), J_ref) < 1e-8
    @test err_func(DiffEqDiffTools.finite_difference_jacobian(f, x), J_ref) < 1e-8
    @test err_func(DiffEqDiffTools.finite_difference_jacobian(f, x, complex_cache), J_ref) < 1e-14
end

function f(fvec,x)
    fvec[1] = (im*x[1]+3)*(x[2]^3-7)+18
    fvec[2] = sin(x[2]*exp(x[1])-1)
end
x = rand(2) + im*rand(2)
y = similar(x)
f(y,x)
J_ref = [[im*(-7+x[2]^3) 3*(3+im*x[1])*x[2]^2]; [exp(x[1])*x[2]*cos(1-exp(x[1])*x[2]) exp(x[1])*cos(1-exp(x[1])*x[2])]]
J = zeros(J_ref)
df = zeros(x)
df_ref = diag(J_ref)
epsilon = zeros(real.(x))
forward_cache = DiffEqDiffTools.JacobianCache(similar(x),similar(x),similar(x),Val{:forward})
central_cache = DiffEqDiffTools.JacobianCache(similar(x),similar(x),similar(x))

# Jacobian tests for complex-valued callables
@time @testset "Jacobian StridedArray complex-valued tests" begin
    @test err_func(DiffEqDiffTools.finite_difference_jacobian(f, x, forward_cache), J_ref) < 1e-4
    @test err_func(DiffEqDiffTools.finite_difference_jacobian(f, x, central_cache), J_ref) < 1e-8
    @test err_func(DiffEqDiffTools.finite_difference_jacobian(f, x), J_ref) < 1e-8
end

# StridedArray tests end here
