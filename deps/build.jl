using JSON
using StrTables

include("../src/emoji_table.jl")

const fname = "emoji_pretty.json"
const vers  = "master" # Julia used 0f0cf4ea8845eb52d26df2a48c3c31c3b8cad14e
const dpath = "https://raw.githubusercontent.com/iamcal/emoji-data/"

const datapath = joinpath(Pkg.dir(), "Emoji_Entities", "data")

function sortsplit!{T}(index::Vector{UInt16}, vec::Vector{Tuple{T, UInt16}}, base)
    sort!(vec)
    len = length(vec)
    valvec = Vector{T}(len)
    indvec = Vector{UInt16}(len)
    for (i, val) in enumerate(vec)
        valvec[i], ind = val
        indvec[i] = ind
        index[ind] = UInt16(base + i)
    end
    base += len
    valvec, indvec, base
end

function make_emoji_tables(dpath, ver, fname)
    lname = joinpath(datapath, fname)
    if isfile(lname)
        println("Loaded: ", lname)
        src = lname
    else
        src = string(dpath, ver, '/', fname)
        download(src, lname)
        println("Saved to: ", lname)
    end
    emojidata = JSON.parsefile(lname)

    symnam = Vector{String}()
    symval = Vector{Vector{Char}}()
    ind = 0
    for emoji in emojidata
        # Make a vector of Chars out of hex data
        unified = emoji["unified"]
        unistr = [Char(parse(UInt32, str, 16)) for str in split(unified,'-')]
        vecnames = emoji["short_names"]
        for name in vecnames
            println('#', ind += 1, '\t', unified, '\t', name)
            push!(symnam, name)
            push!(symval, unistr)
        end
    end
    println()

    # Get emoji names sorted
    srtnam = sortperm(symnam)
    srtval = symval[srtnam]

    # BMP characters
    l16 = Vector{Tuple{UInt16, UInt16}}()
    # non-BMP characters (in range 0x10000 - 0x1ffff)
    l32 = Vector{Tuple{UInt16, UInt16}}()
    # Vector of characters
    l2c = Vector{Tuple{String, UInt16}}()

    max2c = 1
    for i in eachindex(srtnam)
        chrs = srtval[i]
        len = length(chrs)
        if len > 1
            max2c = max(max2c, len)
            push!(l2c, (String(chrs), i))
        else
            ch = chrs[1]
            if ch > '\U1ffff'
                error("Character $ch too large: $(UInt32(ch))")
            elseif ch > '\uffff'
                push!(l32, (ch%UInt16, i))
            else
                push!(l16, (ch%UInt16, i))
            end
        end
    end

    # We now have 3 vectors, for single BMP characters, for non-BMP characters, and for strings
    # each has the value and a index into the name table
    # We need to create a vector the same size as the name table, that gives the index
    # of into one of the three tables, in order to go from names to 1 or 2 output characters
    # We also need, for each of the 3 tables, a sorted vector that goes from the indices
    # in each table to the index into the name table (so that we can find multiple names for
    # each character)

    indvec = Vector{UInt16}(length(srtnam))
    vec16, ind16, base32 = sortsplit!(indvec, l16, 0)
    vec32, ind32, base2c = sortsplit!(indvec, l32, base32)
    vec2c, ind2c, basefn = sortsplit!(indvec, l2c, base2c)

    (VER, string(now()), src,
     base32%UInt32, base2c%UInt32, StrTable(symnam[srtnam]), indvec,
     vec16, ind16, vec32, ind32, StrTable(vec2c), ind2c, max2c%UInt32)
end

println("Creating tables")
tup = make_emoji_tables(dpath, vers, fname)
savfile = joinpath(datapath, "emoji.dat")
println("Saving tables to ", savfile)
StrTables.save(savfile, tup)
println("Done")
