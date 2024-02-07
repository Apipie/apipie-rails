require "spec_helper"

describe ExtendedController do

  it 'includes params from both original controller and extending concern' do
    expect(Apipie["extended#create"].params.keys).to eq [:oauth, :user, :admin]
    user_param = Apipie["extended#create"].params[:user]
    expect(user_param.validator.params_ordered.map(&:name)).to eq [:name, :password, :from_concern]
  end

  it 'includes updated metadata' do
    expect(Apipie['extended#create'].metadata).to eq metadata: 'data'
  end
end
