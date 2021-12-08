module SonicPi
    class Metre

        TIME_SIGNATURE_LOOKUP = {
            '2_4' => [2,2],
            '3_4' => [2,2,2],
            '4_4' => [2,2,2,2],
            '6_8' => [3,3],
            '9_8' => [3,3,3],
            '12_8' => [3,3,3,3]
        }

        attr_reader :beat_groupings, :beats, :pulse_units

        def initialize(metre)
            if is_list_like?(metre)
                @beat_groupings = metre
            else
                @beat_groupings = TIME_SIGNATURE_LOOKUP[metre]
            end
            @beats = @beat_groupings.length
            @pulse_units = @beat_groupings.sum
        end
    end
end
