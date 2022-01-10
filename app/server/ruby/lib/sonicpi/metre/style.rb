require_relative "distribution"

module SonicPi
  class Style

    STYLE_LOOKUP = {
      triplet_swing: {
        :beat_divisions => [2,2,2,2],
        :distributions => {
          -1 => [NormalDistribution.new, NormalDistribution.new(0.33333),
            NormalDistribution.new, NormalDistribution.new(0.33333),
            NormalDistribution.new, NormalDistribution.new(0.33333),
            NormalDistribution.new, NormalDistribution.new(0.33333)]
        }
      },

      viennese_waltz: {
        :beat_divisions => [2,2,2],
        :distributions => {
          0 => [NormalDistribution.new, NormalDistribution.new(-0.33333), NormalDistribution.new]
        }
      },

      jembe: {
        :beat_divisions => [3,3,3,3],
        :distributions => {
          -1 => [NormalDistribution.new(0, 0.05892), NormalDistribution.new(-0.1331, 0.08848), NormalDistribution.new(-0.01906, 0.07308),
            NormalDistribution.new(0.01449, 0.06796), NormalDistribution.new(-0.1108, 0.08602), NormalDistribution.new(0.0002142, 0.09496),
            NormalDistribution.new(0.03905, 0.07029), NormalDistribution.new(-0.1214, 0.08488), NormalDistribution.new(-0.01752, 0.07722),
            NormalDistribution.new(-0.0005375, 0.07086), NormalDistribution.new(-0.1659, 0.07611), NormalDistribution.new(-0.01680, 0.07935)]
        }
      }
    }

    attr_reader :name, :beat_divisions, :lowest_metrical_level

    def initialize(name, beat_divisions, distributions)
      @name = name
      @beat_divisions = beat_divisions
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
      raise "Unknown style #{style_name}" unless s
      return Style.new(style_name, s[:beat_divisions], s[:distributions])
    end
  end
end
