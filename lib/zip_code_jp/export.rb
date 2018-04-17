# -*- coding: utf-8 -*-
require 'zip'
require 'json'
require 'nokogiri'
require 'open-uri'
require 'csv'
require 'nkf'
require 'yaml'

module ZipCodeJp
  class Export
    KOGAKI_ZIP_DISTRIBUTION_URL = 'http://www.post.japanpost.jp/zipcode/dl/kogaki/zip/ken_all.zip'
    BUSINESS_ZIP_DISTRIBUTION_URL = 'http://www.post.japanpost.jp/zipcode/dl/jigyosyo/zip/jigyosyo.zip'

    class << self
      def execute
        zip_codes().each do |prefix, value|
          file_path = "#{ZipCodeJp::DATA_DIR}/zip_code/#{prefix}.json"
          File.open(file_path, 'wb') do |file|
            file.write JSON.generate(value)
          end
        end
      end

      private

      def get_kogaki_hash(row)
        {
          :zip_code        => row[2],
          :prefecture      => NKF.nkf('-S -w', row[6]),
          :prefecture_kana => NKF.nkf('-S -w', row[3]),
          :city            => NKF.nkf('-S -w', row[7]),
          :city_kana       => NKF.nkf('-S -w', row[4]),
          :town            => NKF.nkf('-S -w', row[8]),
          :town_kana       => NKF.nkf('-S -w', row[5])
        }
      end

      def get_business_hash(row)
        {
          :zip_code        => row[7],
          :prefecture      => NKF.nkf('-S -w', row[3]),
          :city            => NKF.nkf('-S -w', row[4]),
          :town            => NKF.nkf('-S -w', row[5])
        }
      end

      def zip_codes
        zip_codes = {}
        prefecture_codes = YAML.load(File.open("#{ZipCodeJp::DATA_DIR}/prefecture_code.yml"))

        [
          [:get_kogaki_hash, KOGAKI_ZIP_DISTRIBUTION_URL],
          [:get_business_hash, BUSINESS_ZIP_DISTRIBUTION_URL]
        ].each do |hash_method_name, url|
          Zip::File.open(open(url).path) do |archives|
            archives.each do |a|
              CSV.parse(a.get_input_stream.read) do |row|
                h = self.send(hash_method_name, row)
                h[:prefecture_code] = prefecture_codes.invert[h[:prefecture]]
                first_prefix  = h[:zip_code].slice(0,3)
                second_prefix = h[:zip_code].slice(3,4)
                zip_codes[first_prefix] = {} unless zip_codes[first_prefix]

                if zip_codes[first_prefix][second_prefix] && !zip_codes[first_prefix][second_prefix].instance_of?(Array)
                  zip_codes[first_prefix][second_prefix] = [zip_codes[first_prefix][second_prefix]]
                end

                if zip_codes[first_prefix][second_prefix].instance_of?(Array)
                  zip_codes[first_prefix][second_prefix].push h
                else
                  zip_codes[first_prefix] = zip_codes[first_prefix].merge({second_prefix => h})
                end
              end
            end
          end
        end

        zip_codes
      end
    end
  end
end
