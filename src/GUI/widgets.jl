using GLMakie

include("consts.jl")

function tag(
    target, label;
    height=BUTTON_HEIGHT
)
    Button(
        target; 
        label=label, 
        height=height,
        strokewidth=1,
        buttoncolor=:deepskyblue4,
        strokecolor=:deepskyblue4,
        font=:juliamono_regular,
        fontsize=18,
        labelcolor=:gray98,
        cornerradius=5,
    )
end