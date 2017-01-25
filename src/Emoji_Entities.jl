__precompile__()
"""
# Public API (nothing is exported)

* lookupname(str)
* matchchar(char)
* matches(str)
* longestmatches(str)
* completions(str)
"""
module Emoji_Entities

using StrTables

include("emoji_table.jl")

const _tab =
    Emoji_Table(StrTables.load(joinpath(Pkg.dir("Emoji_Entities"), "data", "emoji.dat"))...)

const _empty_str = ""
const _empty_str_vec = Vector{String}()

function _get_str(ind)
    ind <= _tab.base32 && return string(Char(_tab.val16[ind]))
    ind <= _tab.base2c && return string(Char(_tab.val32[ind - _tab.base32] + 0x10000))
    _tab.val2c[ind - _tab.base2c]
end
    
function _get_strings(val, tab, ind::Vector{UInt16})
    rng = searchsorted(tab, val)
    isempty(rng) && return _empty_str_vec
    _tab.nam[ind[rng]]
end

"""Given a LaTeX name, return the string it represents, or an empty string if not found"""
function lookupname(str::AbstractString)
    rng = searchsorted(_tab.nam, str)
    isempty(rng) ? _empty_str : _get_str(_tab.ind[rng.start])
end

"""Given a character, return all exact matches to the character as a vector"""
matchchar(ch::Char) =
    (ch <= '\uffff'
     ? _get_strings(ch%UInt16, _tab.val16, _tab.ind16)
     : (ch <= '\U1ffff' ? _get_strings(ch%UInt16, _tab.val32, _tab.ind32) : _empty_str_vec))

"""Given a string, return all exact matches to the string as a vector"""
function matches end
matches(str::AbstractString) = matches(String(str))
function matches(vec::String)
    if isempty(vec)
        _empty_str_vec
    elseif length(vec) == 1
        matchchar(vec[1])
    else
        _get_strings(vec, _tab.val2c, _tab.ind2c)
    end
end

"""Given a string, return all of the longest matches to the beginning of the string as a vector"""
function longestmatches end
longestmatches(str::AbstractString) = longestmatches(convert(Vector{Char}, str))
function longestmatches(vec::Vector{Char})
    isempty(vec) && return _empty_str_vec
    ch = vec[1]
    len = length(vec)
    len == 1 && return matchchar(ch)
    # Get range that matches the first character, if any
    rng = StrTables.matchfirstrng(_tab.val2c, string(ch))
    if !isempty(rng)
        maxlen = min(len, _tab.max2c)
        # Truncate vec
        vec = vec[1:maxlen]
        # Need to find longest matching strings
        for l = 2:maxlen
            length(rng) == 1 && break
            prevrng = rng
            rng = StrTables.matchfirstrng(_tab.val2c, string(vec[1:l]))
            isempty(rng) && (rng = prevrng; break)
        end
        return _tab.nam[_tab.ind2c[rng]]
    end
    # Fall through and check only the first character
    matchchar(ch)
end


"""Given a string, return all of the LaTeX names that start with that string, if any"""
function completions end
completions(str::AbstractString) = completions(String(str))
completions(str::String) = StrTables.matchfirst(_tab.nam, str)

end # module
