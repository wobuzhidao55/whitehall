class Admin::GroupsController < Admin::BaseController
  before_filter :load_organisation
  before_filter :load_group, only: [:edit, :update, :destroy]

  def index
    @groups = Group.includes(:organisation).order("organisations.name, groups.name")
  end

  def new
    @group = @organisation.groups.build
  end

  def create
    @group = @organisation.groups.build(params[:group])
    if @group.save
      redirect_to admin_organisation_path(@organisation, anchor: "groups"), notice: %{"#{@group.name}" created.}
    else
      render action: "new"
    end
  end

  def edit
    @group = Group.find(params[:id])
  end

  def update
    if @group.update_attributes(params[:group])
      redirect_to admin_organisation_path(@organisation, anchor: "groups"), notice: %{"#{@group.name}" updated.}
    else
      render action: "edit"
    end
  end

  def destroy
    if @group.destroy
      redirect_to admin_organisation_path(@organisation, anchor: "groups"), notice: %{"#{@group.name}" destroyed.}
    else
      message = "Cannot destroy a group with memberships or organisation"
      redirect_to admin_organisation_path(@organisation, anchor: "groups"), alert: message
    end
  end

  private

  def load_organisation
    @organisation = Organisation.find(params[:organisation_id])
  end

  def load_group
    @group = Group.find(params[:id])
  end

end
