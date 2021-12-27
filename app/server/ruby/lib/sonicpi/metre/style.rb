require_relative "distribution"

module SonicPi
  class Style

    STYLE_LOOKUP = {
      triplet_swing: {
        :beat_groupings => [2,2,2,2],
        :distributions => {
          -1 => [NormalDistribution.new, NormalDistribution.new(0.33333),
            NormalDistribution.new, NormalDistribution.new(0.33333),
            NormalDistribution.new, NormalDistribution.new(0.33333),
            NormalDistribution.new, NormalDistribution.new(0.33333)]
        }
      }
    }

    attr_reader :beat_groupings, :lowest_metrical_level

    def initialize(beat_groupings, distributions)
      @beat_groupings = beat_groupings
      @distributions = distributions
      @lowest_metrical_level = @distributions.keys.min
    end

    def sample_distributions
      samples = {}
      @distributions.each do |metrical_level, dist_array|
        samples[metrical_level] = dist_array.map { |dist| dist.sample }
      end
      return samples
    end

    def self.lookup(style_name)
      s = STYLE_LOOKUP[style_name]
      return Style.new(s[:beat_groupings], s[:distributions])
    end
  end
end
