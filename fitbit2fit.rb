#!/usr/bin/env ruby

require 'pp'

require 'fitgem'
require 'google/apis/fitness_v1'
Fit = Google::Apis::FitnessV1

POUND_TO_KG = 0.453592

def curr_weight
  client = Fitgem::Client.new({:consumer_key => ENV['FITBIT_CONSUMER_KEY'], :consumer_secret => ENV['FITBIT_CONSUMER_SECRET'], :token => ENV['FITBIT_ACCESS_TOKEN'], :secret => ENV['FITBIT_ACCESS_SECRET'], :user_id => ENV['FITBIT_USER_ID']})
  # access_token = client.reconnect(ENV['FITBIT_ACCESS_TOKEN'], ENV['FITBIT_ACCESS_SECRET'])
  #p client.user_info
  weight = client.user_info["user"]["weight"]
  raise "That's not a number" unless weight.kind_of? Numeric
  weight
end

def fit
  @fit_service ||= begin
    Google::Apis::RequestOptions.default.authorization = Google::Auth.get_application_default
    Fit::FitnessService.new
  end
end

def ensure_data_source
  curr_sources = fit.list_user_data_sources("me")
  pp curr_sources
  puts "\n\n"
  # check it
  match = curr_sources.data_source.select {|i| i.name == "Fitbit Aria via fitbit2fit"}
  if match.size == 0
    source = Fit::DataSource.new({
    "name": "Fitbit Aria via fitbit2fit",
    "type": "raw",
    "application": Fit::Application.new({
      "detailsUrl": "https://github.com/lstoll/fitbit2fit",
      "name": "Fitbit2Fit",
      "version": "1"
    }),
    "data_type": Fit::DataType.new({
      "field": [
        {
          "name": "weight",
          "format": "floatPoint"
        }
      ],
      "name": "com.google.weight"
    }),
    #"device": Fit::Device({
    #  "manufacturer": "Fitbit Aria",
    #}),
    })

    #puts "\n\n"
    #pp source
    fit.create_user_data_source "me", source
    puts "--> Created data source"
  end
end

def set_weight(weight)
  #ensure_data_source
  #p fit.methods
  ensure_data_source

  # get raw:com.google.weight:com.google.android.apps.fitness:user_input

  unix_time = Time.now.to_i
  unix_nano = unix_time * 1000000000

  # #pp fit.methods
  # puts "----"
  # pp fit.get_user_data_source_dataset "me", "derived:com.google.weight:com.google.android.gms:merge_weight", "1046947342000000-#{unix_nano}"
  # puts "----"

  ds = fit.list_user_data_sources("me").data_source.select {|i| i.name == "Fitbit Aria via fitbit2fit"}.first
  # pp ds

  weight_val = Fit::Value.new
  weight_val.fp_val = weight

  data_point = Fit::DataPoint.new
  data_point.start_time_nanos = unix_nano.to_s
  data_point.end_time_nanos = unix_nano.to_s
  data_point.data_type_name = "com.google.weight"
  data_point.value = [weight_val]

  data_set = Fit::Dataset.new
  data_set.data_source_id = ds.data_stream_id
  data_set.min_start_time_ns = unix_nano.to_s
  data_set.max_end_time_ns = unix_nano.to_s
  data_set.point = [data_point]

  pp data_set
  res = fit.patch_user_data_source_dataset("me", ds.data_stream_id, "#{unix_nano}-#{unix_nano}", data_set)
  echo "--> Weight updated to #{weight}"
  pp res
end

begin
  weight = curr_weight
  weight_kg = curr_weight * POUND_TO_KG
  set_weight(weight_kg)
rescue Google::Apis::ClientError => e
  puts e
  puts e.body
end
