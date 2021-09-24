using LightGraphs
using CausalInference
using StatsBase
using Random
using Test
Random.seed!(1)

@testset "backdoor" begin
for j in 1:100
    local d, v, Z
    d = 9
    d2 = 3
    adj = [ i < j ? rand()<0.1 : false for i in 1:d, j in 1:d]

    for i in 1:100
        gd = DiGraph(copy(adj))

        u, v = minmax(sample(1:d, 2, replace=false)...)
        Z = sample(1:d, d2, replace=false)
        (u in Z || v in Z) && continue
        #has_edge(gd, u, v) && continue
        bd = backdoor_criterion(gd, u, v, Z)
        hasap = has_a_path(gd, [u], Z, [])
        @test !(hasap && bd)
        @test hasap == any(has_path(gd, u, z) for z in Z)
        gd0 = DiGraph(copy(adj))
        for w in collect(outneighbors(gd0, u))
            rem_edge!(gd0, Edge(u, w)) || error()
        end
        ds = dsep(gd0, u, v, Z)
        if (ds && !hasap) !=  bd
            backdoor_criterion(gd, u, v, Z, verbose=true)

            @show (ds && !hasap),  bd
            display(adj)
            println(collect(edges(gd)))
            println(collect(edges(gd0)))
            println("$u $v $Z")
            error("")
        end
        @test (ds && !hasap) ==  bd
        
    end    
end
end
