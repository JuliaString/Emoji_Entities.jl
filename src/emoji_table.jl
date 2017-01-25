VER = UInt32(1)

immutable Emoji_Table{T} <: AbstractEntityTable
    ver::UInt32
    tim::String
    inf::String
    base32::UInt32
    base2c::UInt32
    nam::StrTable{T}
    ind::Vector{UInt16}
    val16::Vector{UInt16}
    ind16::Vector{UInt16}
    val32::Vector{UInt16}
    ind32::Vector{UInt16}
    val2c::StrTable{T}
    ind2c::Vector{UInt16}
    max2c::UInt32
end
