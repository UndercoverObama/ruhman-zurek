using Plots
include("utils.jl")


# creating plotting animation and saving the gif
# saving the gif through plotly didn't work, so i'm using animation
# https://docs.juliaplots.org/latest/recipes/
# http://docs.juliaplots.org/latest/animations/
#plotting1 plots the r alone
#plotting2 plots both r and θ on xy plane of bloch sphere
N=10
spreadNum = 3


@userplot BlochPlot
@recipe function f(cp::BlochPlot)
    X,Y,t = cp.args
    inds = 1:t
    xlims --> (-1.5,1.5)
    ylims --> (-1.5,1.5)
    aspect_ratio --> 1
    # label --> "Entanglement Distillation on Bloch Sphere"
    X[inds] , Y[inds]
end

function plotAverage(data)
    gc = data[1,4]
    plt = plot(
        title=string("Entanglement distillation ; N=$N ; gc=$gc"),
        xguide="Number of Evolutions",
        yguide="r",
        ylims=(0,1)
    )
    for Ngb in 1:Int(data[1,5])
        # println(data[1,3])
        R=getAverage(data,Ngb)
        display(plot!(
            0:(Int64(data[1,3])-1),
            R,
            label = string("gb=",round(0.1*(Ngb-1),digits=3)),
        ))
    end

    str = "average N="*string(N,pad=2)
    savefig(str)
end


function getAverage(data,Ngb)
# first line: [Nbath, Nrealizations, Range, gc, Ngbs]
    rep = Int64(data[1,2])
    range = Int64(data[1,3])

    R = zeros(range)

    for i in 1 : rep

        R += getArrayFromData(data,Ngb,i,1,rep)
    end
    R /= rep

    R
end

function getArrayFromData(data,Ngb,Nrealization,type,rep)
    rowNum = 1 + (Ngb-1)*rep*2 + (Nrealization-1)*2 + type
    data[rowNum,:]
end

function plotting2(data)
    range = size(data)[2]
    X,Y = zeros(range,3), zeros(range,3)
    for i in 1:spreadNum
        R = data[2*i,:]
        θ = data[2*i+1,:]

        for j∈1:range
            X[j,i] = R[j]*cos(θ[j])
            Y[j,i] = R[j]*sin(θ[j])
        end
    end
    anim = @animate for t ∈ 1:range-1
        for k in 1:spreadNum
            if k==1 blochplot(X[:,k],Y[:,k],t)
            else blochplot!(X[:,k],Y[:,k],t) end
        end
    end
    gif(anim,"blochsphere.gif", fps=15)
end


let
    gr()
    data = readData(N)
    plotAverage(data)
    # plotting2(data)
end
