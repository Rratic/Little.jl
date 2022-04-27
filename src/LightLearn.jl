module LightLearn
using Gtk
using Cairo
using ColorTypes:RGB24
using FileIO
using Markdown
using TOML

include("draw.jl")

grids=Matrix{Any}(nothing,16,16)
levelid=""
plyx=0
plyy=0
count=0
formal=false
interval=0.5
canvas=GtkCanvas()
records=Dict{String,Int}()

export solid # 通用接口
include("types.jl")

include("data.jl")

export about,menu,level,help,submit,mvw,mva,mvs,mvd,look # 通用接口
export guess # 特殊接口
export interval # 可调变量
include("control.jl")

export init,vis,quit
function init() # __init__
	init_save()
	init_source()
	init_canvas()
	init_coord()
	showall(window::GtkWindow)
	nothing
end
function vis(b::Bool)
	visible(window::GtkWindow,b)
end

function init_save()
	if haskey(ENV,"LOCALAPPDATA")
		cd(@inbounds(ENV["LOCALAPPDATA"]))
		if !in("LightLearn",readdir("./";sort=false))
			mkdir("LightLearn")
		elseif in("save.toml",readdir("LightLearn";sort=false))
			io=open("LightLearn/save.toml","r")
			dict=TOML.tryparse(io)
			if isa(dict,TOML.ParserError)
				println("位于 $(joinpath(pwd(),"LightLearn/save.toml"))的TOML格式导入失败")
			else
				dict::Dict
				global records=dict["records"]
			end
			close(io)
		end
	else
		println("未找到环境参数 \"LOCALAPPDATA\" ，将无法存档")
	end
end
function init_source()
	cd(dirname(@__DIR__))
	for s in readdir("img";sort=false)
		load_imgsource(s[1:end-4],"img/$s")
	end
end
function init_canvas()
	global window=GtkWindow("LightLearn",544,528;resizable=false)
	push!(window,canvas)
	Gtk.init_cairo_context(canvas)
end
function init_coord()
	ctx=getgc(canvas::GtkCanvas)
	set_source_rgb(ctx,0.75,0.75,0.75) # 背景填充
	rectangle(ctx,0,0,544,528)
	fill(ctx)
	for i in 1:16
		fill_text(ctx,"$i",512,(i-1)<<5,16,16,16)
		fill_text(ctx,"$i",(i-1)<<5,512,16,16,16)
	end
end

@guarded draw(canvas::GtkCanvas) do widget
	init_coord()
	_draw()
end

function quit()
	vis(false)
	global window=nothing
	global canvas=nothing
	if haskey(ENV,"LOCALAPPDATA")
		cd(@inbounds(ENV["LOCALAPPDATA"]))
		io=open("LightLearn/save.toml","w")
		TOML.print(io,Dict(
			"records"=>records::Dict{String,Int},
		))
		close(io)
	end
end

end
