# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/spec_helper'

describe ZipCodeJp do
  describe 'If you want to search from the zip code.' do
    it 'zip code exists.' do
      address = ZipCodeJp.find '102-0072'
      expect(address.prefecture).to eq('東京都')
      expect(address.prefecture_kana).to eq('トウキョウト')
      expect(address.prefecture_code).to eq(13)
      expect(address.city).to eq('千代田区')
      expect(address.city_kana).to eq('チヨダク')
      expect(address.town).to eq('飯田橋')
      expect(address.town_kana).to eq('イイダバシ')
    end

    it 'multi address zip code.' do
      addresses = ZipCodeJp.find '452-0961'
      expect(addresses.class).to eq(Array)
      addresses.each do |address|
        expect(address.prefecture).to eq('愛知県')
        expect(address.prefecture_kana).to eq('アイチケン')
        expect(address.city).to eq('清須市')
        expect(address.city_kana).to eq('キヨスシ')
        expect(address.town).to match(/春日.+/)
        expect(address.town_kana).to match(/ハルヒ.+/)
        expect(address.prefecture_code).to eq(23)
      end
    end

    it 'zip code does not exists.' do
      address = ZipCodeJp.find '000-0000'
      expect(address).to eq(false)
    end
  end

  describe '#find_first' do
    subject { ZipCodeJp.find_first zip_code }

    context 'when the zip code specifies an area' do
      let(:zip_code) { '102-0072' }

      it { is_expected.to be_an(ZipCodeJp::Address) }
    end

    context 'when the zip code specifies multiple areas' do
      let(:zip_code) { '0790177' }

      it { is_expected.to be_an(ZipCodeJp::Address) }
    end

    context 'when the zip code specifies no area' do
      let(:zip_code) { '0000000' }

      it { is_expected.to eq(false) }
    end
  end

  describe 'ZipCodeJp.export_json' do
    it 'does NOT raise any errors' do
      expect { ZipCodeJp.export_json }.not_to raise_error
    end
  end
end
