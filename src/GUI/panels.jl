using Match
using GLMakie
using Parameters
using Printf

include("widgets.jl")

function drawpanels!(appstate::AppState)
    drawleftpanel!(appstate)
    on(appstate.topbar.leftpanel) do _state
        drawleftpanel!(appstate)
    end
    drawrightpanel!(appstate)
    on(appstate.topbar.rightpanel) do _state
        drawrightpanel!(appstate)
    end
end

function drawleftpanel!(appstate::AppState)
    state = appstate.topbar.leftpanel[]
    panel = appstate.leftpanel
    clearpanel!(panel)
    @match state begin
        $sources => drawsources!(appstate)
        $samples => drawsamples(appstate)
        $algorithms => drawalgorithms(appstate)
        nothing => nothing
    end
end

function drawrightpanel!(appstate::AppState)
    state = appstate.topbar.rightpanel[]
    panel = appstate.rightpanel
    clearpanel!(panel)
    @match state begin
        $results => drawresults(appstate)
        $settings => drawsettings(appstate)
        nothing => nothing
    end
end

function clearpanel!(panel::GridLayout)
    for c in contents(panel)
        delete!(c)
    end
    trim!(panel)
end

function drawsources!(appstate::AppState)
    @unpack leftpanel, datasources = appstate
    index = Ref(0)
    style = currentstyle(appstate)
    header(leftpanel[nextint(index), 1], "⛁ data sources", style)
    list(
        leftpanel,
        index,
        datasources,
        style
    )
    expander(leftpanel[nextint(index), 1])
end

function drawsamples(appstate::AppState)
    @unpack leftpanel, series = appstate
    index = Ref(0)
    style = currentstyle(appstate)
    header(leftpanel[nextint(index), 1:2], "𝝣 data samples", style)
    gridlist(
        leftpanel,
        index,
        series,
        style;
        rowitems=2
    )
    expander(leftpanel[nextint(index), :])
end

function drawalgorithms(appstate::AppState)
    style = currentstyle(appstate)
    @unpack leftpanel, flexpoints, databounds, applychanges = appstate
    @unpack ∂1, ∂2, ∂3, ∂4, mfilter, noisefilter = flexpoints
    @unpack m1, m2, m3 = mfilter
    index = Ref(0)
    header(leftpanel[nextint(index), 1:5], "∂ algorithm settings", currentstyle(appstate))

    text(leftpanel[nextint(index), 1], "derivatie:", style)
    tag(leftpanel[index[], 2], rich("∂", subscript("1")), ∂1, style)
    tag(leftpanel[index[], 3], rich("∂", subscript("2")), ∂2, style)
    tag(leftpanel[index[], 4], rich("∂", subscript("3")), ∂3, style)
    tag(leftpanel[index[], 5], rich("∂", subscript("4")), ∂4, style)

    for (i, m) in enumerate((m1, m2, m3))
        slider(
            leftpanel,
            nextint(index)[],
            rich("∂", subscript(string(i)), rich(" m", subscript("filter"), ":")),
            m,
            databounds,
            style;
            defaultrate=DEFAULT_MFILTER_RATE,
            scalefactor=DEFAULT_MFILTER_SCALE_FACTOR
        )
    end

    text(leftpanel[nextint(index), 1], rich("n", subscript("filter"), " for:"), style)
    tag(leftpanel[index[], 2:3], "data", noisefilter.data, style)
    tag(leftpanel[index[], 4:5], "derivatives", noisefilter.derivatives, style)
    sliderunsigned(
        leftpanel,
        nextint(index)[],
        rich("n", subscript("filter"), " size:"),
        noisefilter.filtersize,
        Observable((UInt(1), UInt(20))),
        style
    )

    button(leftpanel[nextint(index), 1:5], "apply", applychanges, style)

    expander(leftpanel[nextint(index), 1:5])
end

function drawresults(appstate::AppState)
    target = appstate.rightpanel
    index = Ref(0)
    style = currentstyle(appstate)
    @unpack cf, rmse, nrmse, minrmse, prd, nprd, qs, nqs = appstate.performance

    header(target[nextint(index), 1:2], "ஃ results", currentstyle(appstate))
    keyvalue(target, nextint(index), "cf", cf, style)
    keyvalue(target, nextint(index), "rmse", rmse, style)
    keyvalue(target, nextint(index), "nrmse", nrmse, style)
    keyvalue(target, nextint(index), "minrmse", minrmse, style)
    keyvalue(target, nextint(index), "prd", prd, style)
    keyvalue(target, nextint(index), "nprd", nprd, style)
    keyvalue(target, nextint(index), "qs", qs, style)
    keyvalue(target, nextint(index), "nqs", nqs, style)

    expander(target[nextint(index), 1:2])
end

function drawsettings(appstate::AppState)
    target = appstate.rightpanel
    header(target[1, 1], "🞿 settings", currentstyle(appstate))
    expander(target[2, 1])
end