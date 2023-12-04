using GLMakie
using Colors
using Match

include("styles.jl")
include("state.jl")

function tagexclusive(
    target, label, state::Observable{Vector{Bool}}, index::Integer;
)
    buttoncolor = lift(x -> x[index] ? :ivory3 : :gray7, state)
    buttoncolor_hover = lift(x -> x[index] ? :ivory2 : :gray14, state)
    buttoncolor_active = lift(x -> x[index] ? :ivory1 : :gray21, state)
    labelcolor = lift(x -> x[index] ? :gray8 : :gray95, state)

    button = Button(
        target;
        label=label,
        tellheight=true,
        padding=[12, 2, 2, 2],
        strokewidth=1,
        buttoncolor=buttoncolor,
        buttoncolor_hover=buttoncolor_hover,
        buttoncolor_active=buttoncolor_active,
        strokecolor=:transparent,
        font=:juliamono_light,
        fontsize=13.8,
        labelcolor=labelcolor,
        labelcolor_active=labelcolor,
        labelcolor_hover=labelcolor,
        cornerradius=5,
    )

    on(button.clicks) do _c
        state[][index] = !state[][index]
        if state[][index]
            for i in 1:length(state[])
                if i != index
                    state[][i] = false
                end
            end
        end
        notify(state)
    end
end

function tag(
    target, label, state::Observable{Bool};
)::Button
    buttoncolor = lift(x -> x ? :ivory3 : :gray7, state)
    buttoncolor_hover = lift(x -> x ? :ivory2 : :gray14, state)
    buttoncolor_active = lift(x -> x ? :ivory1 : :gray21, state)
    labelcolor = lift(x -> x ? :gray8 : :gray95, state)

    button = Button(
        target;
        label=label,
        tellheight=true,
        padding=[12, 2, 2, 2],
        strokewidth=1,
        buttoncolor=buttoncolor,
        buttoncolor_hover=buttoncolor_hover,
        buttoncolor_active=buttoncolor_active,
        strokecolor=:transparent,
        font=:juliamono_light,
        fontsize=13.8,
        labelcolor=labelcolor,
        labelcolor_hover=labelcolor,
        labelcolor_active=labelcolor,
        cornerradius=5,
    )

    on(button.clicks) do _c
        state[] = !state[]
        notify(state)
    end

    button
end

function daynight(target, nightmode::Observable{Bool}, figure::Figure, styles::Styles)::Button
    label = lift(nightmode) do state
        @match state begin
            false => "☼ light mode"
            true => "☽ night mode"
        end
    end
    button = tag(target, label, nightmode)

    applystyle(figure, nightmode, styles)

    button
end

function applystyle(figure::Figure, nightmode::Observable{Bool}, styles::Styles)
    on(nightmode) do nightmode
        if nightmode
            figure.scene.backgroundcolor[] = styles.darkmode.background
        else
            figure.scene.backgroundcolor[] = styles.lightmode.background
        end
    end
end