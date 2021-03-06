__precompile__(true)

module DataCleaner

using DataFrames

export iconv, iconv!, readtable_cn, fillna, fillna!, naplot

iconv(fn, from = "GBK", to = "UTF-8") = readstring(`iconv -f $from -t $to $fn`)

iconv!(fn, from = "GBK", to = "UTF-8") = write(fn, iconv(fn, from, to))

function readtable_cn(fn, args...; kwargs...)
    fn_utf = tempname()
    write(fn_utf, replace(iconv(fn), r"([^,])(?=\r\n)", s"\1,"))
    df = readtable(fn_utf, args...; kwargs...)
end

DataFrames.isna(x::Real) = isnan(x)

DataFrames.isna(x::AbstractArray{Real}) = isnan.(x)

fillna(x, o...) = fillna!(copy(x), o...)

fillna!(df::DataFrame, o...) = map(fillna!, df.columns)

function fillna!(x::AbstractArray, o...)
    for i in eachindex(x)[2:end]
        isna(x[i], o...) && (x[i] = x[i - 1])
    end
    for i in eachindex(x)[end-1:-1:1]
        isna(x[i], o...) && (x[i] = x[i + 1])
    end
    x
end

function fillna!(x::AbstractArray, y::AbstractArray, f::Function)
    for i in eachindex(x)
        isna(x[i]) && (x[i] = f(y[i]))
    end
    x
end

naplot(x::AbstractVector) = Main.plot(isna(x))

naplot(x::AbstractMatrix) = Main.heatmap(isna(x))

function naplot(df::DataFrame)
    x = 1:size(df, 2) # string.(df.colindex.names)
    y = 1:size(df, 1)
    m = hcat([Float64.(isna(col)) for col in df.columns]...)
    Main.heatmap(x, y, m)
end

end
