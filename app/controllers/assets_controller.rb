class AssetsController < ApplicationController
	before_filter :check_for_admin, :only => ['new', 'edit', 'create', 'update', 'destroy']
	# GET /assets
	# GET /assets.json
	def index
		@assets = Asset.all

		respond_to do |format|
			format.html # index.html.erb
			format.json { render json: @assets }
		end
	end

	# GET /assets/1
	# GET /assets/1.json
	def show
		@asset = Asset.find(params[:id])

		respond_to do |format|
			format.html # show.html.erb
			format.json { render json: @asset }
		end
	end

	# GET /assets/new
	# GET /assets/new.json
	def new
		@asset = Asset.new

		respond_to do |format|
			format.html # new.html.erb
			format.json { render json: @asset }
		end
	end

	# GET /assets/1/edit
	def edit
		@asset = Asset.find(params[:id])
	end

	# POST /assets
	# POST /assets.json
	def create
		@asset = Asset.new(params[:asset])

		respond_to do |format|
			if @asset.save
				format.html { redirect_to @asset, notice: 'Asset was successfully created.' }
				format.json { render json: @asset, status: :created, location: @asset }
			else
				format.html { render action: "new" }
				format.json { render json: @asset.errors, status: :unprocessable_entity }
			end
		end
	end

	# PUT /assets/1
	# PUT /assets/1.json
	def update
		@asset = Asset.find(params[:id])

		respond_to do |format|
			if @asset.update_attributes(params[:asset])
				format.html { redirect_to @asset, notice: 'Asset was successfully updated.' }
				format.json { head :no_content }
			else
				format.html { render action: "edit" }
				format.json { render json: @asset.errors, status: :unprocessable_entity }
			end
		end
	end

	# DELETE /assets/1
	# DELETE /assets/1.json
	def destroy
		@asset = Asset.find(params[:id])
		@asset.destroy

		respond_to do |format|
			format.html { redirect_to assets_url }
			format.json { head :no_content }
		end
	end

	def quick
		@tag = Asset.where(:tag => params[:tag]).first
		if @tag
			flash[:notice] = "Found asset."
			redirect_to @tag, :notice => "Found asset."
		else
			flash[:alert] = "Can't find asset."
			redirect_to params[:return], :notice => "Can't find asset"
		end
	end

	def move
		r = params[:room_name].split(' - ')
		@room = Room.where(:name => r[1]).where(:building_id => Building.where(:name => r[0]).first.id).first
		bad = []
		params[:tags].each_line do |t|
			a = Asset.where(:tag => t.chomp).first
			if a
				a.room = @room
				a.save
			else
				bad << t.chomp
			end
		end
		if bad.length == 0
			redirect_to home_tools_path(:t => 'move'), :notice => 'Moved assets.'
		else
			render home_tools_path, :notice => "#{bad.length} bad tags were submitted."
		end
	end

	def mass
		count = 0
		final = nil
		params[:pairs].each_line do |line|
			line.chomp!
			asset = Asset.create(:super => false, :name => "")
			asset.room_name = params[:room_name]
			asset.os = params[:os]
			asset.model_name = params[:model_name]
			asset.purchase_date = params[:purchase_date]
			asset.cost = params[:cost]
			asset.vendor_id = params[:vendor_id]
			asset.notes = params[:notes]
			x = line.split(',')
			asset.tag = x[0]
			asset.serial = x[1]
			if asset.save
				count += 1
				final = asset
			else
				raise asset.errors.inspect
			end
		end

		if count == 0
			redirect_to home_tools_path, :notice => 'No assets were created.'
		else
			redirect_to final.room, :notice => "Created #{count} assets."
		end
	end
end
