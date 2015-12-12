require "spec_helper"

describe "param groups" do

  it "lets reuse the params description in more actions" do
    user_create_desc = Apipie["users#create"].params[:user]
    user_create_params = user_create_desc.validator.params_ordered.map(&:name)

    user_update_desc = Apipie["users#update"].params[:user]
    user_update_params = user_update_desc.validator.params_ordered.map(&:name)

    common = user_update_params & user_create_params
    expect(common.sort_by(&:to_s)).to eq(user_update_params.sort_by(&:to_s))
  end

  it "allows using groups is nested param descriptions" do
    user_create_desc = Apipie["users#update"].params[:user]
    user_create_params = user_create_desc.validator.params_ordered.map(&:name)
    expect(user_create_params.map(&:to_s).sort).to eq(%w[membership name pass])
  end

  it "should allow adding additional params to group" do
    user_create_desc = Apipie["users#create"].params[:user]
    user_create_params = user_create_desc.validator.params_ordered.map(&:name)
    expect(user_create_params.map(&:to_s).sort).to eq(%w[membership name pass permalink])
  end

  context "hash param" do
    it "influences only its childs" do
      expect(Apipie["users#create"].params[:user].required).to be true
      expect(Apipie["users#update"].params[:user].required).to be true
    end
  end

  it "lets you reuse a group definition from different controller" do
    arch_v1_desc = Apipie["1.0#architectures#create"].params[:architecture]
    arch_v1_params = arch_v1_desc.validator.params_ordered.map(&:name)

    arch_v2_desc = Apipie["2.0#architectures#create"].params[:architecture]
    arch_v2_params = arch_v2_desc.validator.params_ordered.map(&:name)

    expect(arch_v1_params.sort_by(&:to_s)).to eq(arch_v2_params.sort_by(&:to_s))
  end

  it "should replace parameter name in a group when it comes from concern" do
    expect(Apipie["overridden_concern_resources#update"].params.has_key?(:user)).to eq(true)
  end

  it "shouldn't replace parameter name in a group redefined in the controller" do
    expect(Apipie["overridden_concern_resources#create"].params.has_key?(:concern)).to eq(true)
    expect(Apipie["overridden_concern_resources#create"].params.has_key?(:user)).to eq(false)
  end

it "shouldn't replace name of a parameter defined in the controller" do
    expect(Apipie["overridden_concern_resources#custom"].params.has_key?(:concern)).to eq(true)
    expect(Apipie["overridden_concern_resources#custom"].params.has_key?(:user)).to eq(false)
  end

end

