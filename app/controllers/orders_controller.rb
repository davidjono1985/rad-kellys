class OrdersController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:webhook]


    def index
      @wishlists = current_user.wishlists
      @orders = current_user.orders
    end

     
    def new
      @item = Item.find(params[:item_id])
      @session = Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      line_items: [{ 
        name: @item.name,
        description: "from #{@item.category}",
        # images: ["#{@item.picture.service_url if @item.picture.attached?}"],
        amount: (@item.price * 100).to_i,
        currency: 'aud',
        quantity: 1,
      }],
      payment_intent_data: {
        metadata: {
          user_id: current_user.id,
          item_id: @item.id
        }
      },
      success_url: "#{root_url}orders/complete",
      cancel_url: "#{root_url}",
      )
    end


    def complete
    @items = current_user.items
    end
  
    def webhook
      payment_id = params[:data][:object][:payment_intent]
      payment = Stripe::PaymentIntent.retrieve(payment_id)
      item_id = payment.metadata.item_id
      user_id = payment.metadata.user_id
      p "item id #{item_id}"
      p "user id #{user_id}"
      
      @orders = Order.new
      @orders.user_id = user_id
      @orders.item_id = item_id
      @orders.save
      
      @item = Item.find(item_id)
      @item.sold = true
      @item.save
      render plain: "Success"

    end



 

end
