# frozen_string_literal: true

require File.expand_path('../test_helper', File.dirname(__FILE__))

class BaseTest < Minitest::Test
  def setup
    super
    Coverband.configure do |config|
      config.root                = Dir.pwd
      config.s3_bucket           = nil
      config.root_paths          = ['/app_path/']
      config.ignore              = ['vendor']
      config.reporting_frequency = 100.0
      config.reporter            = 'std_out'
      config.store               = Coverband::Adapters::RedisStore.new(Redis.new)
    end
  end

  test 'defaults ' do
    coverband = Coverband::Collectors::Coverage.instance.reset_instance
    assert_equal ['vendor', 'internal:prelude', 'schema.rb'], coverband.instance_variable_get('@ignore_patterns')
  end

  test 's3 options' do
    Coverband::Collectors::Coverage.instance.reset_instance
    Coverband.configure do |config|
      config.s3_bucket = 'bucket'
      config.s3_region = 'region'
      config.s3_access_key_id = 'key_id'
      config.s3_secret_access_key = 'secret'
    end
    assert_equal 'bucket', Coverband.configuration.s3_bucket
    assert_equal 'region', Coverband.configuration.s3_region
    assert_equal 'key_id', Coverband.configuration.s3_access_key_id
    assert_equal 'secret', Coverband.configuration.s3_secret_access_key
  end

  test 'store raises issues' do
    Coverband::Collectors::Coverage.instance.reset_instance
    assert_raises RuntimeError do
      Coverband.configure do |config|
        config.store = 'fake'
      end
    end
  end
end
