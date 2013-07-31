require "spec_helper"

describe "param groups" do

  it "lets reuse the params description in more actions" do
    user_create_desc = Apipie["users#create"].params[:user]
    user_create_params = user_create_desc.validator.hash_params_ordered.map(&:name)

    user_update_desc = Apipie["users#update"].params[:user]
    user_update_params = user_update_desc.validator.hash_params_ordered.map(&:name)

    common = user_update_params & user_create_params
    common.sort_by(&:to_s).should == user_update_params.sort_by(&:to_s)
  end

  it "allows using groups is nested param descriptions" do
    user_create_desc = Apipie["users#update"].params[:user]
    user_create_params = user_create_desc.validator.hash_params_ordered.map(&:name)
    user_create_params.map(&:to_s).sort.should == %w[membership name pass]
  end

  it "should allow adding additional params to group" do
    user_create_desc = Apipie["users#create"].params[:user]
    user_create_params = user_create_desc.validator.hash_params_ordered.map(&:name)
    user_create_params.map(&:to_s).sort.should == %w[membership name pass permalink]
  end

  context "hash param" do
    it "influences only its childs" do
      Apipie["users#create"].params[:user].required.should be true
      Apipie["users#update"].params[:user].required.should be true
    end
  end

  it "lets you reuse a group definition from different controller" do
    arch_v1_desc = Apipie["1.0#architectures#create"].params[:architecture]
    arch_v1_params = arch_v1_desc.validator.hash_params_ordered.map(&:name)

    arch_v2_desc = Apipie["2.0#architectures#create"].params[:architecture]
    arch_v2_params = arch_v2_desc.validator.hash_params_ordered.map(&:name)

    arch_v1_params.sort_by(&:to_s).should == arch_v2_params.sort_by(&:to_s)
  end
end

