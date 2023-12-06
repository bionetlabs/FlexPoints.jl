using Parameters
using GLMakie

const BUTTON_HEIGHT = 28.0
const LAYOUT_PADDING = 2.0
const TOP_BAR_HEIGHT = BUTTON_HEIGHT + 2LAYOUT_PADDING

abstract type Style end

@with_kw struct DarkStyle <: Style
    theme::Attributes = theme_black()
    background::RGBA = colorant"gray8"
    ticklabelcolor::RGBA = colorant"gray92"
    flexpointcolor::RGBA = colorant"steelblue1"
    signalcolor::RGBA = colorant"sienna1"
end

@with_kw struct LightStyle <: Style
    theme::Attributes = theme_light()
    background::RGBA = colorant"white"
    ticklabelcolor::RGBA = colorant"gray8"
    flexpointcolor::RGBA = colorant"dodgerblue3"
    signalcolor::RGBA = colorant"brown1"
end

struct CurrentStyle
    theme::Observable{Attributes}
    background::Observable{RGBA}
    ticklabelcolor::Observable{RGBA}
    flexpointcolor::Observable{RGBA}
    signalcolor::Observable{RGBA}
end

function CurrentStyle(style::Style)::CurrentStyle
    CurrentStyle(
        Observable(style.theme),
        Observable(style.background),
        Observable(style.ticklabelcolor),
        Observable(style.flexpointcolor),
        Observable(style.signalcolor)
    )
end

function updatestyle!(currentstyle::CurrentStyle, newstyle::Style)
    currentstyle.theme[] = newstyle.theme
    currentstyle.background[] = newstyle.background
    currentstyle.ticklabelcolor[] = newstyle.ticklabelcolor
    currentstyle.flexpointcolor[] = newstyle.flexpointcolor
    currentstyle.signalcolor[] = newstyle.signalcolor
end

mutable struct Styles
    dark::DarkStyle
    light::LightStyle
    current::CurrentStyle
end

function Styles()
    darkstyle = DarkStyle()
    Styles(darkstyle, LightStyle(), CurrentStyle(darkstyle))
end

function parseattribute(value)
    try
        @match value begin
            ::Tuple{Symbol,Number} || ::Tuple{AbstractString,Number} => begin
                parse(Colorant, value[1]) .* value[2]
            end
            ::Symbol || ::AbstractString => parse(Colorant, value)
            _ => value
        end
    catch e
        println("error $e")
        value
    end
end