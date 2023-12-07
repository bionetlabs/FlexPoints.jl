using GLMakie
using Colors
using Match

include("states.jl")

function header(target, label, style::CurrentStyle)
    Label(
        target,
        label,
        font=:juliamono_light,
        fontsize=HEADER_FONT_SIZE,
        color=style.disabledbuttonlabelcolor
    )
end

function tagenum(
    target,
    label,
    state::Observable{Union{T,Nothing}},
    id::T,
    style::CurrentStyle
)::Button where {T<:Enum{<:Integer}}
    buttoncolor = @lift begin
        $state == id ? $(style.enabledbuttoncolor) : $(style.disabledbuttoncolor)
    end
    buttoncolor_hover = @lift begin
        $state == id ? $(style.enabledbuttoncolor_hover) : $(style.disabledbuttoncolor_hover)
    end
    buttoncolor_active = @lift begin
        $state == id ? $(style.enabledbuttoncolor_active) : $(style.disabledbuttoncolor_active)
    end
    labelcolor = @lift begin
        $state == id ? $(style.enabledbuttonlabelcolor) : $(style.disabledbuttonlabelcolor)
    end

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
        fontsize=FONT_SIZE,
        labelcolor=labelcolor,
        labelcolor_active=labelcolor,
        labelcolor_hover=labelcolor,
        cornerradius=5,
    )

    on(button.clicks) do _c
        if state[] == id
            state[] = nothing
        else
            state[] = id
        end
        # notify(state)
    end

    button
end

function tagexclusive(
    target, label, state::Observable{Vector{Bool}}, index::Integer, style::CurrentStyle;
)::Button
    buttoncolor = @lift begin
        $(state)[index] ? $(style.enabledbuttoncolor) : $(style.disabledbuttoncolor)
    end
    buttoncolor_hover = @lift begin
        $(state)[index] ? $(style.enabledbuttoncolor_hover) : $(style.disabledbuttoncolor_hover)
    end
    buttoncolor_active = @lift begin
        $(state)[index] ? $(style.enabledbuttoncolor_active) : $(style.disabledbuttoncolor_active)
    end
    labelcolor = @lift begin
        $(state)[index] ? $(style.enabledbuttonlabelcolor) : $(style.disabledbuttonlabelcolor)
    end

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
        fontsize=FONT_SIZE,
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
    target, label, state::Observable{Bool}, style::CurrentStyle;
)::Button
    buttoncolor = @lift begin
        $(state) ? $(style.enabledbuttoncolor) : $(style.disabledbuttoncolor)
    end
    buttoncolor_hover = @lift begin
        $(state) ? $(style.enabledbuttoncolor_hover) : $(style.disabledbuttoncolor_hover)
    end
    buttoncolor_active = @lift begin
        $(state) ? $(style.enabledbuttoncolor_active) : $(style.disabledbuttoncolor_active)
    end
    labelcolor = @lift begin
        $(state) ? $(style.enabledbuttonlabelcolor) : $(style.disabledbuttonlabelcolor)
    end

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
        fontsize=FONT_SIZE,
        labelcolor=labelcolor,
        labelcolor_active=labelcolor,
        labelcolor_hover=labelcolor,
        cornerradius=5,
    )

    on(button.clicks) do _c
        state[] = !state[]
        notify(state)
    end

    button
end

function tagpositive(
    target, label, state::Observable{Bool}, style::CurrentStyle;
)::Button
    buttoncolor = @lift begin
        $(state) ? $(style.enabledbuttoncolor) : $(style.disabledbuttoncolor)
    end
    buttoncolor_hover = @lift begin
        $(state) ? $(style.enabledbuttoncolor_hover) : $(style.disabledbuttoncolor_hover)
    end
    buttoncolor_active = @lift begin
        $(state) ? $(style.enabledbuttoncolor_active) : $(style.disabledbuttoncolor_active)
    end
    labelcolor = @lift begin
        $(state) ? $(style.enabledbuttonlabelcolor) : $(style.disabledbuttonlabelcolor)
    end

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
        fontsize=FONT_SIZE,
        labelcolor=labelcolor,
        labelcolor_active=labelcolor,
        labelcolor_hover=labelcolor,
        cornerradius=5,
    )

    on(button.clicks) do _c
        state[] = true
        notify(state)
    end

    button
end

function tagnegative(
    target, label, state::Observable{Bool}, style::CurrentStyle;
)::Button
    buttoncolor = @lift begin
        !$(state) ? $(style.enabledbuttoncolor) : $(style.disabledbuttoncolor)
    end
    buttoncolor_hover = @lift begin
        !$(state) ? $(style.enabledbuttoncolor_hover) : $(style.disabledbuttoncolor_hover)
    end
    buttoncolor_active = @lift begin
        !$(state) ? $(style.enabledbuttoncolor_active) : $(style.disabledbuttoncolor_active)
    end
    labelcolor = @lift begin
        !$(state) ? $(style.enabledbuttonlabelcolor) : $(style.disabledbuttonlabelcolor)
    end

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
        fontsize=FONT_SIZE,
        labelcolor=labelcolor,
        labelcolor_active=labelcolor,
        labelcolor_hover=labelcolor,
        cornerradius=5,
    )

    on(button.clicks) do _c
        state[] = false
        notify(state)
    end

    button
end

function daynight(uistate::UIState, target1::GridPosition, target2::GridPosition)::Tuple{Button,Button}
    nightmode = uistate.nightmode

    darkbutton = tagpositive(target1, "☽ dark mode", nightmode, currentstyle(uistate))
    on(darkbutton.clicks) do _
        applystyle(uistate)
    end
    lightbutton = tagnegative(target2, "☼ light mode", nightmode, currentstyle(uistate))
    on(lightbutton.clicks) do _
        applystyle(uistate)
    end

    darkbutton, lightbutton
end

function separator(target::GridPosition, style::CurrentStyle)::Box
    Box(
        target,
        color=style.enabledbuttoncolor,
        height=SEPARATOR_HEIGHT,
        width=SEPARATOR_WIDTH,
        strokevisible=false
    )
end

function blankseparator(target::GridPosition)::Box
    Box(
        target,
        color=RGBA(0, 0, 0, 0),
        height=0,
        width=0,
        strokevisible=false
    )
end

function expander(target::GridPosition)::Box
    Box(target, color=RGBAf(0, 0, 0, 0), strokevisible=false)
end