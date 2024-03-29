require 'spec_helper'

describe AvetmissData::Package do
  let(:package) { AvetmissData::Package.new }

  context '<<' do
    let!(:enrolment_store) { AvetmissData::Stores::V7::Enrolment.new }
    before { package.enrolment_stores << enrolment_store }
    specify { expect(enrolment_store.package).to eq(package) }
  end

  context 'create package' do
    before do
      package.enrolment_stores << AvetmissData::Stores::V7::Enrolment.new(unit_competency_identifier: 'BSBRES401A',
                                                                      package: package)
    end

    specify { expect(package.enrolment_stores.length).to eq(1) }
    let!(:enrolment_store) { package.enrolment_stores.first }
    specify { expect(enrolment_store.unit_competency_identifier).to eq('BSBRES401A') }

    specify { expect(package.enrolment_stores.first.package).to eq(package) }
  end

  context 'load package from zip' do
    let(:package) { AvetmissData::Package.from_zip_file(zip_file) }

    context '7.0' do
      let(:zip_file) { AvetmissData::ZipFile.new('spec/fixtures/zip_files/v7/valid.zip', '7.0') }

      specify { expect(package.submission_stores.length).to eq(1) }
      specify { expect(package.rto_stores.length).to eq(1) }
      specify { expect(package.rto_delivery_location_stores.length).to eq(1) }
      specify { expect(package.course_stores.length).to eq(1) }
      specify { expect(package.unit_of_competency_stores.length).to eq(1) }
      specify { expect(package.client_stores.length).to eq(32) }
      specify { expect(package.client_postal_detail_stores.length).to eq(5) }
      specify { expect(package.disability_stores.length).to eq(1) }
      specify { expect(package.achievement_stores.length).to eq(1) }
      specify { expect(package.enrolment_stores.length).to eq(5) }
      specify { expect(package.qual_completion_stores.length).to eq(1) }

      let!(:rto_store) { package.rto_stores.first }
      specify { expect(rto_store.training_organisation_identifier).to eq('0101') }
      let!(:enrolment_store) { package.enrolment_stores.first }
      specify { expect(enrolment_store.unit_competency_identifier).to eq('BSBRES401A') }

      specify { expect(package.client_stores.first.package).to eq(package) }
    end

    context '6.1' do
      let(:zip_file) { AvetmissData::ZipFile.new('spec/fixtures/zip_files/v6/valid.zip', '6.1') }

      specify { expect(package.rto_stores.length).to eq(1) }
      specify { expect(package.rto_delivery_location_stores.length).to eq(1) }
      specify { expect(package.course_stores.length).to eq(1) }
      specify { expect(package.unit_of_competency_stores.length).to eq(1) }
      specify { expect(package.client_stores.length).to eq(32) }
      specify { expect(package.client_postal_detail_stores.length).to eq(5) }
      specify { expect(package.disability_stores.length).to eq(1) }
      specify { expect(package.achievement_stores.length).to eq(1) }
      specify { expect(package.enrolment_stores.length).to eq(5) }
      specify { expect(package.qual_completion_stores.length).to eq(1) }

      let!(:rto_store) { package.rto_stores.first }
      specify { expect(rto_store.training_organisation_identifier).to eq('0101') }
      let!(:enrolment_store) { package.enrolment_stores.first }
      specify { expect(enrolment_store.unit_competency_identifier).to eq('BSBRES401A') }

      specify { expect(package.client_stores.first.package).to eq(package) }
    end
  end

  context '#stores_list_for' do
    let(:client_store) { AvetmissData::Stores::V7::Client.new }
    subject { package.store_list_for(client_store) }
    specify { expect(subject).to equal(package.client_stores) }
    specify { expect(subject).not_to equal(package.enrolment_stores) }
  end

  context '#[]' do
    let!(:enrolment_store) { AvetmissData::Stores::V7::Enrolment.new }
    before { package.enrolment_stores << enrolment_store }
    specify { expect(package[:enrolment_stores]).to include(enrolment_store) }
  end

  context '#[]=' do
    let!(:enrolment_store) { AvetmissData::Stores::V7::Enrolment.new }
    before { package[:enrolment_stores] = [enrolment_store] }
    specify { expect(package.enrolment_stores).to include(enrolment_store) }
  end

  context '#each_store' do
    let(:client_store) { AvetmissData::Stores::V7::Client.new }
    let(:rto_store) { AvetmissData::Stores::V7::Rto.new }
    before do
      package.client_stores << client_store
      package.rto_stores << rto_store
    end

    specify { expect { |b| package.each_store(&b) }.to yield_successive_args(rto_store, client_store) }
  end

  context '#unit_of_competency_stores=' do
    before { package.unit_of_competency_stores = [] }
    specify { expect(package.unit_of_competency_stores).to be_a AvetmissData::StoresList }
  end
end
