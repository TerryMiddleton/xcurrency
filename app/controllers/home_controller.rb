class HomeController < ApplicationController
  
  around_filter :shopify_session, :except => 'welcome'
  
  def welcome
    current_host = "#{request.host}#{':' + request.port.to_s if request.port != 80}"
    @callback_url = "http://#{current_host}/login"
  end
  
  def createfirstvariant(id)
      
      vprod = ShopifyAPI::Variant.find(id)
      
      vprod.add_metafield(ShopifyAPI::Metafield.new({:description => 'Current Base Price',:namespace => 'xcurrency',:key => 'MostCurrentPrice',:value => (@rsscad.to_f * vprod.price.to_f).to_s,:value_type => 'string'}))

          vprod.save

  end
  
  
  
  def delvariantmetafield(id, mkey)
      
      vprod = ShopifyAPI::Variant.find(id)
      
      vprod.metafields.each do |m|
          
          if m.key == mkey
              m.destroy
           end
        end
  end
  
  def deleteallappmetafields
      # Shop level
      # Product level
      # Variant level
      
      #vprod = ShopifyAPI::Variant.find(:all)
      vprod = ShopifyAPI::Variant.all(:params => {:limit => 250})
      
      vprod.each do |m|
          
          m.metafields.each do |y|
          
          if y.namespace == 'xcurrency'
              y.destroy
          end
          end
      end

  end
  
  
  def setbasepricemetafield (id)
      # If should be run only once as it will take the variants current price
      # and set a metafield so that if all else fails we can get set the base
      # price back to the original price.
      
      # If this metafield key=baseprice does not exist call this function
      
      variant = ShopifyAPI::Variant.find(id)
      
  end
  
  def setbaseprice (id, price)
      # Sets initial base price value in metafied
      # This MUST be done first so that the products will always have a base price to fall back on
      
      vprod = ShopifyAPI::Variant.find(id)
      
      vprod.add_metafield(ShopifyAPI::Metafield.new({                                                                     :description => 'Original Base Price',:namespace => 'xcurrency',:key => 'Base Price',:value => price,:value_type => 'string'}))
      vprod.save
      
      
  end
  
  def getcurrencyrate
      # get currency rate.  Add sources in case one is unavailable
        require 'RSS'
      
        #Source One
        
        rsstitle = RSS::Parser.parse(open('http://www.bankofcanada.ca/stats/assets/rates_rss/noon/en_USD.xml').read, false).item.title
        @rsscad = rsstitle.from(4).to(5).to_f.round(4)
        @rssusd = 1.0000 - @rsscad
        #@rsscad = 0.90395
        
        # Source Two
        # csv_textCAD = File.read('app/assets/xcurrency.csv')
        # csvCAD = CSV.parse(csv_textCAD, :headers => false)
        # csvCAD.each do |row|
        #     @yrateCAD = row[1].to_f
        # end
        
        # csv_textUSD = File.read('app/assets/xcurrencyUSD.csv')
        # csvUSD = CSV.parse(csv_textUSD, :headers => false)
        # csvUSD.each do |row|
        #    @yrateUSD = row[1].to_f
        #end

    Rails.logger.info "Currency Rate for CAD is: #{@rsscad} - #{rsstitle}"
      
  end
  
  def loopthroughproducts
      
      # Check to see if a product has variants
      
      
            
            #@variantsprice = ShopifyAPI::Variant.find(:all, :params=>{:limit=>250})
            @variantsprice = ShopifyAPI::Variant.all(:params => {:limit => 250})
          
        @variantsprice.each do |v|
        
            metafound =  ShopifyAPI::Metafield.find(:first,:params=>{:resource => "variants", :resource_id => v.id, :key => 'Base Price'})
        
            if metafound.nil?
                setbaseprice(v.id, v.price) # Make sure base price is set
                updateprice(v.id, v.price)  # Now go update price of variant
                else
                # Update price based on most current currency rate
                updateprice(v.id, metafound.value)
                
            end
        end
    
    #updateprice(359590331)
    
    #@variantsprice = ShopifyAPI::Variant.find(:all)
  
  end

def updateprice(id,price)
    
    
    #metafound =  ShopifyAPI::Metafield.find(:first,:params=>{:resource => "variants", :resource_id => id, :key => 'Base Price'})
    
    vprod = ShopifyAPI::Variant.find(id)
    vprod.price = price.to_f * @rsscad
    vprod.save
    @pcnt += 1
    Rails.logger.info "#{vprod.sku} price updated to #{vprod.price} | #{vprod.title}"
    
end

  def index
      Rails.logger.info "START XCURRENCY"
      Rails.logger.info "#{DateTime.now}"
      @pcnt = 0
      #@products = ShopifyAPI::Product.find(:all)
  
    # Does Variant have metafield with base price.

#@products = ShopifyAPI::Product.find(:all)

    # Get Currency Rates
        getcurrencyrate
  
    # Loop through Variants
       loopthroughproducts
     
     Rails.logger.info "#{DateTime.now}"
     Rails.logger.info "END XCURRENCY"
  #deleteallappmetafields
  #@variantsprice = ShopifyAPI::Variant.find(:all)

  
  #createfirstvariant(359590331)
  #delvariantmetafield(359590331,"Base Price")
  #indexold
      
end
  
  def indexold




      
    # get 10 products
    #@products = ShopifyAPI::Product.find(:all, :params => {:limit => 10})

    # get latest 5 orders
    #@orders   = ShopifyAPI::Order.find(:all, :params => {:limit => 5, :order => "created_at DESC" })
    
    # get all product skus and pricing
    # @variantsprice = ShopifyAPI::Variant.find(:all)
    
    #@variantsprice.each do |getmeta|
    #   @variantsproduct = ShopifyAPI::Metafield.find(:all)
    #   end
    # @variantsprice = ShopifyAPI::Variant.find(:all)
    
    #    @dmeta = vpmeta.metafields.find(:all)

#@dmeta = Variant.ShopifyAPI::Metafield.find(:all)
    
    
    # @variantsprice.each do |vpmeta|
          
          
    #    @dmeta = vpmeta.metafields.find(:all, :params => vpmeta.id)
                #                           @dmeta = vpmeta.ShopifyAPI::Metafield.find(:all)
                #             @dmeta = vpmeta.metafields.find(:all)
                          
                               
             
             # vpmeta.metafields.each do |killmeta|
             #        @gothere='true'
             #   killmeta.destroy
             #   end
                #end
    
    #@variantsprice = ShopifyAPI::Variant.find(:all)
    #@variantsproduct = ShopifyAPI::Metafield.find(:all)
    #@variantsprice = ShopifyAPI::Variant.find(:all)

#      if killmeta.namespace == 'variant'
#               metafield = ShopifyAPI::Metafield.find(vpmeta.id)
#  killmeta.destroy
              #            end
            
            #           end
    

#vpmeta.add_metafield(ShopifyAPI::Metafield.new({                                                                     :description => 'Current Base Price3',:namespace => 'variant',:key => 'todaysbase',:value => vpmeta.price.to_s,:value_type => 'string'}))
    
    #   vpmeta.add_metafield(ShopifyAPI::Metafield.new({                                                                     :description => 'Current Base Price',:namespace => 'xcurrency',:key => 'lastprice',:value => (@rsscad.to_f * vpmeta.price.to_f).to_s,:value_type => 'string'}))
    #    vpmeta.save
     

    
    # end
     #  @dmeta = ShopifyAPI::Metafield.find(:all)
    
  end
  
end