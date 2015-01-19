class DataController < ApplicationController
  def index

  end
  def data
    ga = Gattica.new({
    :email => params[:email],
    :password => params[:password]
                 })
    ga.profile_id = params[:profile_id]
    data = ga.get({
    :start_date   => (Date.today-1.month).to_s,
    :end_date     => Date.today.to_s,
    :dimensions   => ['source'],
    :metrics      => [ 'bounceRate', 'avgsessionDuration', 'visits'],

            })
    data_json = data.to_h['points'].to_json
    parsed_json = ActiveSupport::JSON.decode(data_json)
    data_table = GoogleVisualr::DataTable.new
    data_table.new_column('number', 'x')
    data_table.new_column('number', 'A')
    data_table.new_column('number', 'B')
    data_table.new_column('number', 'C')
    data_table.new_column('number', 'D')
    data_prepared = parsed_json.map { |item| [item['bounceRate'].to_f, item['avgsessionDuration'].to_f] }
    kmeans = KMeans.new(data_prepared, :centrods => 4, :distance_measure => :euclidean_distance)
    result = kmeans.view
    @data = result
    result[0].each {|item| data_table.add_row([data_prepared[item][0],data_prepared[item][1], nil, nil,nil])}
    result[1].each {|item| data_table.add_row([data_prepared[item][0], nil, data_prepared[item][1], nil,nil])}
    result[2].each {|item| data_table.add_row([data_prepared[item][0], nil, nil, data_prepared[item][1], nil])}
    result[3].each {|item| data_table.add_row([data_prepared[item][0], nil, nil, nil, data_prepared[item][1]])}

    opts   = {
      :width => 800, :height => 800, :title => 'Кластеризация',
      :hAxis => { :title => 'Процент отказов'    , :minValue => -50},
      :vAxis => { :title => 'Длительность посещения' , :minValue => -50 },
      :legend => 'yes'
    
    }
    @chart = GoogleVisualr::Interactive::ScatterChart.new(data_table, opts)
    data1 = ga.get({
    :start_date   => (Date.today-1.month).to_s,
    :end_date     => Date.today.to_s,
    :dimensions   => ['source','date'],
    :metrics      => [ 'bounceRate', 'avgsessionDuration', 'visits'],

            })
    s = []
    data_json = data1.to_h['points'].to_json
    parsed_json = ActiveSupport::JSON.decode(data_json)
    #s[0] = (parsed_json[0]['visits']+parsed_json[1]['visits']+parsed_json[2]['visits'])/3
    #parsed_json[1..parsed_json.length].each_with_index do |item, index|
    #   s[index] = [0.8*item['visits'].to_f+(1-0.8)*s[index.to_i-1], item['source']
    #end
    #@data = data_json
    data_table1 = GoogleVisualr::DataTable.new
    data_table1.new_column('number', 'x')
    data_table1.new_column('number', 'x1')
    data_table1.new_column('number', 'y1')
    data_table1.new_column('number', 'x2')
    data_table1.new_column('number', 'y2')
    #s.each_with_index do |item, index| 
    #  data_table1.add_row([index, item, nil])
    #end
    #parsed_json.each_with_index do |item, index| 
    #  data_table1.add_row([index, nil, item['visits']])
    #end
    @chart1 = GoogleVisualr::Interactive::LineChart.new(data_table1, opts)
    visits = []
    #result[0].each do |data_id|
    #  parsed_json[data_id.to_i].each do |item|
    #    #data_table1.add_row([item['date'], item['visits'], nil, nil, nil])
    #    visits << item['visits']
    #  end 
    #end 
    #result[1].each do |data_id|
    #  parsed_json[data_id].each do |item|
    #    #data_table1.add_row([item['date'], nil, item['visits'], nil, nil])
    #  end 
    #end 
    #result[2].each do |data_id|
    #   parsed_json[data_id].each do |item|
    #    #data_table1.add_row([item['date'], nil, nil, item['visits'], nil])
    #   end 
    #end 
    #result[3].each do |data_id|
    #  parsed_json[data_id].each do |item|
    #    #data_table1.add_row([item['date'], nil, nil, nil, item['visits']])
    #  end 
    #end 
    result.each_with_index do |item, index|
         item.map do |item_2| 
    @data = visits
  end
  def select_account
    if params[:password].nil? || params[:email].nil?
      redirect_to "/"
    end
    ga = Gattica.new({
    :email => params[:email],
    :password => params[:password]
                 })
    @accounts = ga.accounts
    @email = params[:email]
    @password = params[:password]
  end
end
