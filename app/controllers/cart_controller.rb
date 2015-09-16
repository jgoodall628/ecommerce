class CartController < ApplicationController

  before_filter :authenticate_user!, :except => [:add_to_cart, :view_order, :empty_cart]
  before_action :set_order
  def add_to_cart
    @line_item = LineItem.new
    @line_item.product = Product.find(params[:product_id])
    @line_item.quantity = params[:quantity]
    @line_item.line_item_total = @line_item.product.price * @line_item.quantity
    @line_item.order_id = @order.id
    @line_item.save

    redirect_to root_path
  end

  def view_order
    @line_items = @order.line_items
  end

  def checkout
    @line_items = @order.line_items
    @order.user_id = current_user.id

    sum = 0
    @line_items.each do |line_item|
      # @order.order_items[line_item.product_id] = line_item.quantity
      sum += line_item.line_item_total
    end
    @order.subtotal = sum
    @order.sales_tax = 0.07
    @order.grand_total = @order.sales_tax*@order.subtotal + @order.subtotal
    @order.save

    @line_items.each do |line_item|
      line_item.product.quantity -= line_item.quantity
      line_item.product.save
    end
    cookies.delete(:order_id)

  end
  def order_complete
    def order_complete
    @order = Order.find(params[:order_id])
    @amount = (@order.grand_total.to_f.round(2) * 100).to_i

    customer = Stripe::Customer.create(
      :email => current_user.email,
      :card => params[:stripeToken]
    )

    charge = Stripe::Charge.create(
      :customer => customer.id,
      :amount => @amount,
      :description => 'Rails Stripe customer',
      :currency => 'usd'
    )

    rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to charges_path
  end
  end

  def empty_cart
    @order.destroy
    cookies.delete(:order_id)

    redirect_to root_path
  end

  private
  def set_order
    if cookies.signed[:order_id]
      @order = Order.find(cookies.signed[:order_id])
    else
      @order = Order.new
      @order.save
      cookies.signed[:order_id] = @order.id
    end

  end
end
