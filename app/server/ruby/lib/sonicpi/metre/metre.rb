require_relative "bar"
require_relative "distribution"

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
    
    attr_reader :beat_groupings, :total_beats, :total_pulse_units, :style, :timings
    
    def initialize(metre, style=nil)
      if is_list_like?(metre)
        @beat_groupings = metre
      else
        @beat_groupings = TIME_SIGNATURE_LOOKUP[metre]
      end
      @total_beats = @beat_groupings.length
      @total_pulse_units = @beat_groupings.sum
      @style = style
      @timings = Array.new(@total_pulse_units, 0)
      @current_bar_number = __thread_locals.get(:sonic_pi_bar_number)
      @current_bar_number = 0 unless @current_bar_number
      @mutex = Mutex.new
    end
    
    def sp_thread_safe?
      true
    end
    
    def get_timing(pulse_unit)
      @timings[pulse_unit]
    end
    
    def register_bar(requested_bar_number)
      @mutex.synchronize do
        if requested_bar_number > @current_bar_number
          recalculate_timings
          @current_bar_number = requested_bar_number
        end
      end
      return @current_bar_number
    end
    
    private
    def recalculate_timings
      @timings[0] = @timings[0] + 1
    end
  end
end
