using GLMakie

include("consts.jl")

function tag(
    target, label;
    height=BUTTON_HEIGHT
)
    Button(
        target; 
        label=label,
        tellheight=true,
        padding=[12, 0, 5, 0],
        strokewidth=1,
        buttoncolor=:deepskyblue4,
        strokecolor=:deepskyblue4,
        font=:juliamono_light,
        fontsize=22,
        labelcolor=:gray98,
        cornerradius=7,
    )
end