# frozen_string_literal: true

source 'https://supermarket.chef.io'

group :ark do
  cookbook 'seven_zip', '= 2.0.2'
  cookbook 'windows', '= 4.3.4'
end


group :integration do
  cookbook 'postgres', path: 'test/fixtures/postgres'
end

metadata
