require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe Admin::ProviderOrgsController do

  # This should return the minimal set of attributes required to create a valid
  # Admin::ProviderOrg. As you add validations to Admin::ProviderOrg, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { {  } }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # Admin::ProviderOrgsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET index" do
    it "assigns all admin_provider_orgs as @admin_provider_orgs" do
      provider_org = ProviderOrg.create! valid_attributes
      get :index, {}, valid_session
      assigns(:provider_orgs).should eq([provider_org])
    end
  end

  describe "GET show" do
    it "assigns the requested admin_provider_org as @admin_provider_org" do
      provider_org = ProviderOrg.create! valid_attributes
      get :show, {:id => provider_org.to_param}, valid_session
      assigns(:provider_org).should eq(provider_org)
    end
  end

  describe "GET new" do
    it "assigns a new admin_provider_org as @admin_provider_org" do
      get :new, {}, valid_session
      assigns(:provider_org).should be_a_new(ProviderOrg)
    end
  end

  describe "GET edit" do
    it "assigns the requested admin_provider_org as @admin_provider_org" do
      provider_org = ProviderOrg.create! valid_attributes
      get :edit, {:id => provider_org.to_param}, valid_session
      assigns(:provider_org).should eq(provider_org)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new ProviderOrg" do
        expect {
          post :create, {:provider_org => valid_attributes}, valid_session
        }.to change(ProviderOrg, :count).by(1)
      end

      it "assigns a newly created admin_provider_org as @admin_provider_org" do
        post :create, {:provider_org => valid_attributes}, valid_session
        assigns(:provider_org).should be_a(ProviderOrg)
        assigns(:provider_org).should be_persisted
      end

      it "redirects to the created admin_provider_org" do
        post :create, {:provider_org => valid_attributes}, valid_session
        response.should redirect_to([:admin, ProviderOrg.last])
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved admin_provider_org as @admin_provider_org" do
        # Trigger the behavior that occurs when invalid params are submitted
        ProviderOrg.any_instance.stub(:save).and_return(false)
        post :create, {:provider_org => {  }}, valid_session
        assigns(:provider_org).should be_a_new(ProviderOrg)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        ProviderOrg.any_instance.stub(:save).and_return(false)
        post :create, {:provider_org => {  }}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested admin_provider_org" do
        provider_org = ProviderOrg.create! valid_attributes
        # Assuming there are no other admin_provider_orgs in the database, this
        # specifies that the ProviderOrg created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        ProviderOrg.any_instance.should_receive(:update_attributes).with({ "these" => "params" })
        put :update, {:id => provider_org.to_param, :provider_org => { "these" => "params" }}, valid_session
      end

      it "assigns the requested admin_provider_org as @admin_provider_org" do
        provider_org = ProviderOrg.create! valid_attributes
        put :update, {:id => provider_org.to_param, :provider_org => valid_attributes}, valid_session
        assigns(:provider_org).should eq(provider_org)
      end

      it "redirects to the admin_provider_org" do
        provider_org = ProviderOrg.create! valid_attributes
        put :update, {:id => provider_org.to_param, :provider_org => valid_attributes}, valid_session
        response.should redirect_to([:admin, provider_org])
      end
    end

    describe "with invalid params" do
      it "assigns the admin_provider_org as @admin_provider_org" do
        provider_org = ProviderOrg.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        ProviderOrg.any_instance.stub(:save).and_return(false)
        put :update, {:id => provider_org.to_param, :provider_org => {  }}, valid_session
        assigns(:provider_org).should eq(provider_org)
      end

      it "re-renders the 'edit' template" do
        provider_org = ProviderOrg.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        ProviderOrg.any_instance.stub(:save).and_return(false)
        put :update, {:id => provider_org.to_param, :provider_org => {  }}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested admin_provider_org" do
      provider_org = ProviderOrg.create! valid_attributes
      expect {
        delete :destroy, {:id => provider_org.to_param}, valid_session
      }.to change(ProviderOrg, :count).by(-1)
    end

    it "redirects to the admin_provider_orgs list" do
      provider_org = ProviderOrg.create! valid_attributes
      delete :destroy, {:id => provider_org.to_param}, valid_session
      response.should redirect_to(admin_provider_orgs_url)
    end
  end

end
