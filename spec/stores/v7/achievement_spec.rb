require 'spec_helper'

describe AvetmissData::Stores::V7::Achievement do
  context 'imports the NAT00100 file' do

    context 'NAT File' do
      specify { expect(AvetmissData::Stores::V7::Achievement.file_name).not_to be_blank }
      specify { expect(AvetmissData::Stores::V7::Achievement.file_name).to eq('NAT00100') }
    end

    context 'NAT Record Parse' do
      let!(:line) { File.open('spec/fixtures/nat_files/v7/NAT00100.txt').first }
      subject { AvetmissData::Stores::V7::Achievement.from_line(line) }

      specify { expect(subject).not_to be_blank }
      specify { expect(subject.client_identifier).to eq('12345') }
      specify { expect(subject.prior_education_achievement_identifier).to eq('008') }
      specify { expect(subject.extras).to be_blank }
    end
  end
end
