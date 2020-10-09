module ParticlePlots

using Plots

# functions from partViz
export plotWalls!,
       plotParticles!

using StokesParticles

function plotWalls!(p,wallList::Vector)
    N = length(wallList)
  
    for i=1:N
      plotWall!(p,wallList[i])
    end
  
    return p
  end

function plotParticles!(plotObj,pList)
    colorInd = [:black,:red,:green,:yellow,:purple,:orange,:blue]
    N = length(pList)

    for i=1:N
        if mod(i,20) == 0
            tc = mod(i,length(colorInd))+1
            plotParticle!(plotObj,pList[i],colorInd[tc])
        else
            plotParticle!(plotObj,pList[i],:white)
        end
    end

    nothing
end

function plotParticle!(plotObj::Plots.Plot,particle,colorSym::Symbol)
    θ = range(0,stop=2*pi,length=40)
    xs = particle.pos.x .+ particle.radius*cos.(θ)
    ys = particle.pos.y .+ particle.radius*sin.(θ)

    plot!(plotObj,xs,ys,label="",
        seriestype=[:shape,],color=colorSym,
        linewidth=1,linecolor=:black)
end

function plotWall!(plotObj::Plots.Plot,wall::StokesParticles.LineWall)
    radius = wall.thickness/2

    x1 = wall.nodes[1].x; x2 = wall.nodes[2].x
    y1 = wall.nodes[1].y; y2 = wall.nodes[2].y
    θWALL = atan(y2-y1,x2-x1)

    Nθ = 15
    θ1 = range(-pi/2 + θWALL,stop=pi/2 + θWALL,length=Nθ)
    θ2 = range( pi/2 + θWALL,stop = 3*pi/2 + θWALL,length=Nθ)

    nx = wall.n[1]
    ny = wall.n[2]

    # 1 arc
    x = [x2 + radius*cos(θ1[i]) for i=1:Nθ]
    y = [y2 + radius*sin(θ1[i]) for i=1:Nθ]
    plot!(plotObj,x,y,label="",color=:black)

    # 2 line
    x = [x2 + radius*nx,x1 + radius*nx]
    y = [y2 + radius*ny,y1 + radius*ny]
    plot!(plotObj,x,y,label="",color=:black)

    # 3 arc
    x = [x1 + radius*cos(θ2[i]) for i=1:Nθ]
    y = [y1 + radius*sin(θ2[i]) for i=1:Nθ]
    plot!(plotObj,x,y,label="",color=:black)

    # 4 line
    x = [x1 - radius*nx,x2 - radius*nx]
    y = [y1 - radius*ny,y2 - radius*ny]
    plot!(plotObj,x,y,label="",color=:black)
end
function plotWall!(plotObj::Plots.Plot,wall::StokesParticles.CircleWall)
    radius = wall.thickness/2
    Nplot = 50; Δθ = 2*pi/(Nplot-1)
    curvex = [wall.center.x + (wall.radius + radius)*cos((i-1)*Δθ) for i=1:Nplot]
    curvey = [wall.center.y + (wall.radius + radius)*sin((i-1)*Δθ) for i=1:Nplot]
    plot!(plotObj,curvex,curvey,label="",color=:black)
    curvex = [wall.center.x + (wall.radius - radius)*cos((i-1)*Δθ) for i=1:Nplot]
    curvey = [wall.center.y + (wall.radius - radius)*sin((i-1)*Δθ) for i=1:Nplot]
    plot!(plotObj,curvex,curvey,label="",color=:black)
end
function plotWall!(plotObj::Plots.Plot,wall::StokesParticles.ArcWall)
    radius = wall.thickness/2

    pa = [wall.nodes[1].x,wall.nodes[1].y]
    c  = [wall.nodes[2].x,wall.nodes[2].y]
    pb = [wall.nodes[3].x,wall.nodes[3].y]
    r = sqrt((pa[1]-c[1])^2 + (pa[2]-c[2])^2)
    θ1 = atan(pa[2]-c[2],pa[1]-c[1])
    θ2 = atan(pb[2]-c[2],pb[1]-c[1])

    if θ1 > θ2
        θ2 += 2*pi
    end

    Nplot = 50; Δθ = (θ2 - θ1)/(Nplot-1)

    # 1 big arc -- done
    curvex = [c[1] + (r+radius)*cos((i-1)*Δθ+θ1) for i=1:Nplot]
    curvey = [c[2] + (r+radius)*sin((i-1)*Δθ+θ1) for i=1:Nplot]
    plot!(plotObj,curvex,curvey,label="",color=:black)

    # 2 far cap
    θWALL = θ2 + pi/2
    θ2cap = range(-pi/2 + θWALL, stop=pi/2 + θWALL,length=Nplot)
    x = [pb[1] + radius*cos(θ2cap[i]) for i=1:Nplot]
    y = [pb[2] + radius*sin(θ2cap[i]) for i=1:Nplot]
    plot!(plotObj,x,y,label="",color=:black)

    # 3 small arc
    curvex = [c[1] + (r-radius)*cos((i-1)*Δθ+θ1) for i=1:Nplot]
    curvey = [c[2] + (r-radius)*sin((i-1)*Δθ+θ1) for i=1:Nplot]
    plot!(plotObj,curvex,curvey,label="",color=:black)

    # 4 close cap
    θWALL = θ1 + pi/2
    θ1cap = range( pi/2 + θWALL,stop = 3*pi/2 + θWALL,length=Nplot)
    x = [pa[1] + radius*cos(θ1cap[i]) for i=1:Nplot]
    y = [pa[2] + radius*sin(θ1cap[i]) for i=1:Nplot]
    plot!(plotObj,x,y,label="",color=:black)
end

end # ParticlePlots
