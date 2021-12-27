require_relative "bar"
require_relative "style"

module SonicPi
  class Metre
    
    TIME_SIGNATURE_LOOKUP = {
      '2/4' => [2,2],
      '3/4' => [2,2,2],
      '4/4' => [2,2,2,2],
      '6/8' => [3,3],
      '9/8' => [3,3,3],
      '12/8' => [3,3,3,3]
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
    end

    def note_to_pulse_units(current_beat, level, duration)
      if level == 0
        # Lookup number of pulse units in current beat
        @beat_groupings[current_beat] * duration
      else
        # Assume pulse units are further divisible by 2
        (2 ** (level + 1)) * duration
      end
    end

    def metrical_level_indices(current_beat, total_elapsed_pulse_units, lowest_metrical_level)
      indices = []
      indices[0] = current_beat
    
      level = -1
      position = total_elapsed_pulse_units
      indices[-level] = position.floor
    
      (2..-lowest_metrical_level).each do |i|
        level -= 1
        position *= 2
        indices[-level] = position.floor
      end
      return indices
    end

    def sleep_time(pulse_units)
      pulse_units.to_f / beat_groupings[0]
    end
  end


  class SynchronisedMetre < Metre
    attr_reader :style, :timings
    
    def initialize(metre, style_name=nil)
      super(metre)

      if style_name
        @style = Style.lookup(style_name)
        raise "Style #{style_name} requires beat groupings #{@style.beat_groupings} but metre has #{@beat_groupings}" unless @beat_groupings == @style.beat_groupings
      end
      @timings = {}
      recalculate_timings if @style

      @current_bar_number = __thread_locals.get(:sonic_pi_bar_number)
      @current_bar_number = 0 unless @current_bar_number
      @mutex = Mutex.new
    end

    def sp_thread_safe?
      true
    end

    def get_timing(current_beat, total_elapsed_pulse_units)
      return 0 unless @style
      lowest_level = @style.lowest_metrical_level
      indices = metrical_level_indices(current_beat, total_elapsed_pulse_units, lowest_level)
      timing_shift = 0
      (lowest_level..0).each do |level|
        timing_shift += @timings[level][indices[-level]] if @timings[level]
      end
      return timing_shift
    end
    
    def request_bar(requested_bar_number)
      @mutex.synchronize do
        if requested_bar_number > @current_bar_number
          recalculate_timings if @style
          @current_bar_number = requested_bar_number
        end
      end
      return @current_bar_number
    end
    
    private
    def recalculate_timings
      @timings = @style.sample_distributions
    end
  end

end
