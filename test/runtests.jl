using Emoji_Entities
using Base.Test

# Test the functions lookupname, matches, longestmatches, completions
# Check that characters from all 3 tables (BMP, non-BMP, string) are tested

EE = Emoji_Entities

@testset "Emoji_Entities" begin
@testset "lookupname" begin
    @test EE.lookupname("foobar")   == ""
    @test EE.lookupname("sailboat") == "\u26f5"
    @test EE.lookupname("ring")     == "\U1f48d"
    @test EE.lookupname("flag-us")  == "\U1f1fa\U1f1f8"
end

@testset "matches" begin
    @test isempty(EE.matches("\u2020"))
    for (chrs, exp) in (("\u26f5", ["boat", "sailboat"]),
                        ("\U1f48d", ["ring"]),
                        ("\U1f596", ["spock-hand"]),
                        ("\U1f1fa\U1f1f8", ["flag-us", "us"]))
        res = EE.matches(chrs)
        @test length(res) >= length(exp)
        @test intersect(res, exp) == exp
    end
end

@testset "longestmatches" begin
    @test isempty(EE.longestmatches("\u2020 abcd"))
    for (chrs, exp) in (("\u26f5 abcd", ["boat", "sailboat"]),
                        ("\U1f48d abcd", ["ring"]))
#                        ("\U1f1fa\U1f1f8 foo", ["flag-us", "us"]))
        res = EE.longestmatches(chrs)
        @test length(res) >= length(exp)
        @test intersect(res, exp) == exp
    end
end

@testset "completions" begin
    @test isempty(EE.completions("ScottPaulJones"))
    for (chrs, exp) in (("al", ["alarm_clock", "alembic", "alien"]),
                        ("um", ["umbrella", "umbrella_on_ground", "umbrella_with_rain_drops"]))
        res = EE.completions(chrs)
        @test length(res) >= length(exp)
        @test intersect(res, exp) == exp
    end
end
end
