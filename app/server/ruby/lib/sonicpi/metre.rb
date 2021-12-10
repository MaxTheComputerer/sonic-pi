module SonicPi
    class Metre

        TIME_SIGNATURE_LOOKUP = {
            '2_4' => [2,2],
            '3_4' => [2,2,2],
            '4_4' => [2,2,2,2],
            '6_8' => [3,3],
            '9_8' => [3,3,3],
            '12_8' => [3,3,3,3]
        }.freeze

        attr_reader :beat_groupings, :total_beats, :total_pulse_units

        def initialize(metre)
            if is_list_like?(metre)
                @beat_groupings = metre
            else
                @beat_groupings = TIME_SIGNATURE_LOOKUP[metre]
            end
            @total_beats = @beat_groupings.length
            @total_pulse_units = @beat_groupings.sum
            freeze
        end

        def sp_thread_safe?
            true
        end
    end

    class Bar

        attr_reader :current_beat, :current_pulse_unit, :metre

        def initialize
            @metre = __thread_locals.get(:sonic_pi_metre)
            @current_beat = 0
            @current_pulse_unit = 0
        end

        def sp_thread_safe?
            true
        end

        def total_elapsed_pulse_units
            pulse_units = 0
            (0...@current_beat).each do |i|
                pulse_units += @metre.beat_groupings[i]
            end
            pulse_units += @current_pulse_unit
            pulse_units
        end

        def total_remaining_pulse_units
            @metre.total_pulse_units - total_elapsed_pulse_units
        end

        def beat_remaining_pulse_units
            @metre.beat_groupings[@current_beat] - @current_pulse_unit
        end

        def note_to_pulse_units(level, duration)
            if level == 0
                # Lookup number of pulse units in current beat
                @metre.beat_groupings[@current_beat]
            else
                # Assume pulse units are further divisible by 2
                (2 ** (level + 1)) * duration
            end
        end

        def fit_note?(level, duration)
            total_remaining_pulse_units >= note_to_pulse_units(level, duration)
        end

        def add_note(level, duration)
            raise "Cannot fit a note of this length into the bar" unless fit_note?(level, duration)
            pulse_units_to_add = note_to_pulse_units(level, duration)
            while pulse_units_to_add > 0 and pulse_units_to_add >= beat_remaining_pulse_units do
                pulse_units_to_add -= beat_remaining_pulse_units
                @current_beat += 1
                @current_pulse_unit = 0
            end
            @current_pulse_unit += pulse_units_to_add
        end

        def calculate_sleep_time(pulse_units)
            pulse_units.to_f / @metre.beat_groupings[0]
        end
    end
end
