class ItemsController < ApplicationController

	def index
		@items = Item.all.order(:number)
	end

	# def show
	# 	@item = Item.find(params[:id])
	# end

	def new
		@item = Item.new
	end

	# def edit
	# end

	def create
		@item = Item.new(item_params)
		if @item.link[0..18] != "http://devpost.com/"
			redirect_to new_item_path, alert: "Bad link."
		else
			doc = Nokogiri::HTML(open(@item.link))
			@item.name = doc.xpath('//h1[@id="app-title"]/text()')
			@item.pic_url = doc.xpath('//img[@class="software_photo_image image-replacement"]/@src')[0]
			@item.blurb = doc.xpath('//p[@class="large"]/text()')[0]
			@item.mu = MU_PRIOR
			@item.sigma_sq = SIGMA_SQ_PRIOR

			if @item.save
				redirect_to items_path, notice: 'Item successfully created'
			else
				render 'new', alert: "Bad Link."
			end
		end
	end

	# def update
	# 	@item = Item.find(params[:id])
	# 	if @item.update(item_params)
	# 		redirect_to @item, notice:'Item successfully updated'
	# 	else
	# 		render 'edit'
	# 	end
	# end

	def destroy
		@item = Item.find(params[:id])
		@item.destroy unless @item.nil?
		redirect_to events_path
	end	

	private

		def item_params
			params[:item].permit(:number, :link)
		end

end
