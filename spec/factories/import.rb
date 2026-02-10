# frozen_string_literal: true

FactoryBot.define do
  factory :import do
    status { 'pending' }
    file_location { '/tmp/test_import.json' }
  end
end
