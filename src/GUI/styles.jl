using Parameters
using GLMakie

include("utils.jl")

const BUTTON_HEIGHT = 28.0
const SEPARATOR_HEIGHT = 15.8
const SEPARATOR_WIDTH = 2.0
const LAYOUT_PADDING = 2.0
const TOP_BAR_HEIGHT = BUTTON_HEIGHT + 2LAYOUT_PADDING
const FONT_SIZE = 12.4
const HEADER_FONT_SIZE = 15.8
const CORNER_RADIUS = 3.5
const LEFT_PANEL_WIDTH = 300
const RIGHT_PANEL_WIDTH = 200

abstract type Style end

@with_kw struct DarkStyle <: Style
    theme::Attributes = theme_black()
    background::RGBA = colorant"gray3"
    ticklabelcolor::RGBA = colorant"gray93"
    flexpointcolor::RGBA = colorant"steelblue1"
    signalcolor::RGBA = colorant"sienna1"
    enabledbuttoncolor::RGBA = colorant"ivory2"
    enabledbuttoncolor_hover::RGBA = colorant"ivory1"
    enabledbuttoncolor_active::RGBA = colorant"ivory1"
    enabledbuttonlabelcolor::RGBA = colorant"gray7"
    disabledbuttoncolor::RGBA = colorant"gray14"
    disabledbuttoncolor_hover::RGBA = colorant"gray21"
    disabledbuttoncolor_active::RGBA = colorant"gray28"
    disabledbuttonlabelcolor::RGBA = colorant"gray93"
    fadedlabelcolor::RGBA = colorant"gray80"
end

@with_kw struct LightStyle <: Style
    theme::Attributes = theme_light()
    background::RGBA = colorant"white"
    ticklabelcolor::RGBA = colorant"gray8"
    flexpointcolor::RGBA = colorant"dodgerblue3"
    signalcolor::RGBA = colorant"brown1"
    enabledbuttoncolor::RGBA = colorant"paleturquoise2"
    enabledbuttoncolor_hover::RGBA = colorant"paleturquoise1"
    enabledbuttoncolor_active::RGBA = colorant"paleturquoise1"
    enabledbuttonlabelcolor::RGBA = colorant"gray7"
    disabledbuttoncolor::RGBA = colorant"gray93"
    disabledbuttoncolor_hover::RGBA = colorant"gray86"
    disabledbuttoncolor_active::RGBA = colorant"gray79"
    disabledbuttonlabelcolor::RGBA = colorant"gray7"
    fadedlabelcolor::RGBA = colorant"gray20"
end

struct CurrentStyle
    theme::Observable{Attributes}
    background::Observable{RGBA}
    ticklabelcolor::Observable{RGBA}
    flexpointcolor::Observable{RGBA}
    signalcolor::Observable{RGBA}
    enabledbuttoncolor::Observable{RGBA}
    enabledbuttoncolor_hover::Observable{RGBA}
    enabledbuttoncolor_active::Observable{RGBA}
    enabledbuttonlabelcolor::Observable{RGBA}
    disabledbuttoncolor::Observable{RGBA}
    disabledbuttoncolor_hover::Observable{RGBA}
    disabledbuttoncolor_active::Observable{RGBA}
    disabledbuttonlabelcolor::Observable{RGBA}
    fadedlabelcolor::Observable{RGBA}
end

function CurrentStyle(style::Style)::CurrentStyle
    CurrentStyle(
        Observable(style.theme),
        Observable(style.background),
        Observable(style.ticklabelcolor),
        Observable(style.flexpointcolor),
        Observable(style.signalcolor),
        Observable(style.enabledbuttoncolor),
        Observable(style.enabledbuttoncolor_hover),
        Observable(style.enabledbuttoncolor_active),
        Observable(style.enabledbuttonlabelcolor),
        Observable(style.disabledbuttoncolor),
        Observable(style.disabledbuttoncolor_hover),
        Observable(style.disabledbuttoncolor_active),
        Observable(style.disabledbuttonlabelcolor),
        Observable(style.fadedlabelcolor)
    )
end

function updatestyle!(currentstyle::CurrentStyle, newstyle::Style)
    currentstyle.theme[] = newstyle.theme
    currentstyle.background[] = newstyle.background
    currentstyle.ticklabelcolor[] = newstyle.ticklabelcolor
    currentstyle.flexpointcolor[] = newstyle.flexpointcolor
    currentstyle.signalcolor[] = newstyle.signalcolor
    currentstyle.enabledbuttoncolor[] = newstyle.enabledbuttoncolor
    currentstyle.enabledbuttoncolor_hover[] = newstyle.enabledbuttoncolor_hover
    currentstyle.enabledbuttoncolor_active[] = newstyle.enabledbuttoncolor_active
    currentstyle.enabledbuttonlabelcolor[] = newstyle.enabledbuttonlabelcolor
    currentstyle.disabledbuttoncolor[] = newstyle.disabledbuttoncolor
    currentstyle.disabledbuttoncolor_hover[] = newstyle.disabledbuttoncolor_hover
    currentstyle.disabledbuttoncolor_active[] = newstyle.disabledbuttoncolor_active
    currentstyle.disabledbuttonlabelcolor[] = newstyle.disabledbuttonlabelcolor
    currentstyle.fadedlabelcolor[] = newstyle.fadedlabelcolor
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