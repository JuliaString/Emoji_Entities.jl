using Emoji_Entities

@static VERSION < v"0.7.0-DEV" ? (using Base.Test) : (using Test)

# Test the functions lookupname, matches, longestmatches, completions
# Check that characters from all 3 tables (BMP, non-BMP, string) are tested

EE = Emoji_Entities

ee_matchchar(ch)       = EE.matchchar(EE.default, ch)
ee_lookupname(nam)     = EE.lookupname(EE.default, nam)
ee_longestmatches(str) = EE.longestmatches(EE.default, str)
ee_matches(str)        = EE.matches(EE.default, str)
ee_completions(str)    = EE.completions(EE.default, str)

@testset "Emoji_Entities" begin
@testset "lookupname" begin
    @test ee_lookupname(SubString("My name is Spock", 12)) == ""
    @test ee_lookupname("foobar")   == ""
    @test ee_lookupname("sailboat") == "\u26f5"
    @test ee_lookupname("ring")     == "\U1f48d"
    @test ee_lookupname("flag-us")  == "\U1f1fa\U1f1f8"
end

@testset "matches" begin
    @test isempty(ee_matches(""))
    @test isempty(ee_matches("\u2020"))
    @test isempty(ee_matches(SubString("This is \u2020", 9)))
    for (chrs, exp) in (("\u26f5", ["boat", "sailboat"]),
                        ("\U1f48d", ["ring"]),
                        ("\U1f596", ["spock-hand"]),
                        ("\U1f1fa\U1f1f8", ["flag-us", "us"]))
        res = ee_matches(chrs)
        @test length(res) >= length(exp)
        @test intersect(res, exp) == exp
    end
end

@testset "longestmatches" begin
    @test isempty(ee_longestmatches("\u2020 abcd"))
    @test isempty(ee_longestmatches(SubString("This is \U2020", 9)))
    for (chrs, exp) in (("\u26f5 abcd", ["boat", "sailboat"]),
                        ("\U1f48d abcd", ["ring"]),
                        ("\U1f1fa\U1f1f8 foo", ["flag-us", "us"]))
        res = ee_longestmatches(chrs)
        @test length(res) >= length(exp)
        @test intersect(res, exp) == exp
    end
end

@testset "completions" begin
    @test isempty(ee_completions("ScottPaulJones"))
    @test isempty(ee_completions(SubString("My name is Scott", 12)))
    for (chrs, exp) in (("al", ["alarm_clock", "alembic", "alien"]),
                        ("um", ["umbrella", "umbrella_on_ground", "umbrella_with_rain_drops"]))
        res = ee_completions(chrs)
        @test length(res) >= length(exp)
        @test intersect(res, exp) == exp
    end
end
end
