SCHEDULER.every '300s' do
  require 'versacommerce_api'
  VersacommerceAPI::Base.site = "http://api:#{ENV['SHOP_KEY']}@#{ENV['SHOP_NAME']}.versacommerce.de/api"

  orders = VersacommerceAPI::Order.all
  orders_this_week = orders.select{|o| o.created_at >= 6.days.ago.beginning_of_day}
  orders_last_week = orders.select{|o| o.created_at >= 13.days.ago.beginning_of_day &&  o.created_at < 6.days.ago.beginning_of_day}

  send_event('ordercount', { current: orders_this_week.size, last: orders_last_week.size })
  send_event('ordervalue', { current: orders_this_week.map(&:total).sum, last: orders_last_week.map(&:total).sum })


  origins = orders_this_week.group_by(&:origin_name).map do |origin_name, orders|
    origin_name ||= "Online-Shop"
    {label: origin_name, value: orders.size}
  end

  send_event('origins', { items: origins })

  states = orders.select{|o| o.status.in?(["open", "in_progress"])}.group_by(&:status).map do |status, orders|
    status = "Neu" if status == "open"
    status = "In Bearbeitung" if status == "in_progress"
    {label: status, value: orders.size}
  end

  send_event('states', { items: states })
end


