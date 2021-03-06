class ConsumablesController < ApplicationController
	before_filter :check_for_user
  # GET /consumables
  # GET /consumables.json
  def index
    @consumables = Consumable.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @consumables }
    end
  end

  def order
      buffer = params[:b] ? 0 : params[:b].to_i 
      @consumables = Consumable.all.delete_if{|c| c.total_count >= (c.target - buffer)}
      @skip_sidebar = true
  end

  # GET /consumables/1
  # GET /consumables/1.json
  def show
    @consumable = Consumable.find(params[:id])
    Building.all.each do |building|
        if @consumable.inventories.where(:room_id => building.room_ids).count == 0
            Inventory.create(:consumable_id => @consumable.id, :room_id => building.storeroom.id, :count => 0)
        end
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @consumable }
    end
  end

  # GET /consumables/new
  # GET /consumables/new.json
  def new
    @consumable = Consumable.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @consumable }
    end
  end

  # GET /consumables/1/edit
  def edit
    @consumable = Consumable.find(params[:id])
  end

  # POST /consumables
  # POST /consumables.json
  def create
    @consumable = Consumable.new(params[:consumable])

    respond_to do |format|
      if @consumable.save
        format.html { redirect_to @consumable, notice: 'Consumable was successfully created.' }
        format.json { render json: @consumable, status: :created, location: @consumable }
      else
        format.html { render action: "new" }
        format.json { render json: @consumable.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /consumables/1
  # PUT /consumables/1.json
  def update
    @consumable = Consumable.find(params[:id])

    respond_to do |format|
      if @consumable.update_attributes(params[:consumable])
        format.html { redirect_to @consumable, notice: 'Consumable was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @consumable.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /consumables/1
  # DELETE /consumables/1.json
  def destroy
    @consumable = Consumable.find(params[:id])
    @consumable.inventories.each do |i|
        i.delete
    end
    @consumable.destroy

    respond_to do |format|
      format.html { redirect_to consumables_url }
      format.json { head :no_content }
    end
  end
end
