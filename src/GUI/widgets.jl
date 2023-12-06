using GLMakie
using Colors
using Match

include("states.jl")

function tagexclusive(
    target, label, state::Observable{Vector{Bool}}, index::Integer;
)::Button
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

    button
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

function daynight(uistate::UIState)::Button
    target = uistate.topbar.layout[1, 1]
    nightmode = uistate.nightmode

    label = lift(nightmode) do state
        @match state begin
            false => "☼ light mode"
            true => "☽ dark mode"
        end
    end
    button = tag(target, label, nightmode)

    on(button.clicks) do _
        applystyle(uistate)
    end

    button
end