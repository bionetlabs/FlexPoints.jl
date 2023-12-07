using Match
using GLMakie

include("widgets.jl")

function drawpanels(uistate::UIState)
    drawleftpanel(uistate)
    on(uistate.topbar.leftpanel) do _state
        drawleftpanel(uistate)
    end
    drawrightpanel(uistate)
    on(uistate.topbar.rightpanel) do _state
        drawrightpanel(uistate)
    end
end

function drawleftpanel(uistate::UIState)
    state = uistate.topbar.leftpanel[]
    panel = uistate.leftpanel
    clearpanel!(panel)
    @match state begin
        $sources => drawsources(uistate)
        $samples => drawsamples(uistate)
        $algorithms => drawalgorithms(uistate)
        nothing => nothing
    end
end

function drawrightpanel(uistate::UIState)
    state = uistate.topbar.rightpanel[]
    panel = uistate.rightpanel
    clearpanel!(panel)
    @match state begin
        $results => drawresults(uistate)
        $settings => drawsettings(uistate)
        nothing => nothing
    end
end

function clearpanel!(panel::GridLayout)
    for c in contents(panel)
        delete!(c)
    end
    trim!(panel)
end

function drawsources(uistate::UIState)
    target = uistate.leftpanel
    header(target[1, 1], "⛁ sources", currentstyle(uistate))
    expander(target[2, 1])
end

function drawsamples(uistate::UIState)
    target = uistate.leftpanel
    header(target[1, 1], "𝝣 samples", currentstyle(uistate))
    expander(target[2, 1])
end

function drawalgorithms(uistate::UIState)
    target = uistate.leftpanel
    header(target[1, 1], "∂ algorithms", currentstyle(uistate))
    expander(target[2, 1])
end

function drawresults(uistate::UIState)
    target = uistate.rightpanel
    header(target[1, 1], "ஃ results", currentstyle(uistate))
    expander(target[2, 1])
end

function drawsettings(uistate::UIState)
    target = uistate.rightpanel
    header(target[1, 1], "🞿 settings", currentstyle(uistate))
    expander(target[2, 1])
end