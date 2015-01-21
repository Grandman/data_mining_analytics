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
    data_table.new_column('number', 'Кластер 1')
    data_table.new_column('number', 'Кластер 2')
    data_table.new_column('number', 'Кластер 3')
    data_table.new_column('number', 'Кластер 4')
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
    parsed_json1 = ActiveSupport::JSON.decode(data_json)
    parsed_json1.sort_by{ |item| item['date'] }
    visits = []
    visits[0] = {}
    visits[1] = {}
    visits[2] = {}
    visits[3] = {}
    result.each_with_index do |cluster, index|
      cluster.each do |item|
        array = parsed_json1.select { |row| row['source'] == parsed_json[item]['source'] }  
        array.each { |arr| if visits[index][arr['date']].nil? then visits[index][arr['date']] = 0 else visits[index][arr['date']] += arr['visits'].to_i end }   
      end
    end

    data_table1 = GoogleVisualr::DataTable.new
    data_table1.new_column('date', 'x')
    data_table1.new_column('number', 'Посещения')
    data_table1.new_column('number', 'Прогноз')
    max = 0
    max_index = 0
    visits.each_with_index do |item, index|
     if max < item.length
        max = item.length 
        max_index = index
     end
    end
    opts   = {
      :width => 800, :height => 800, :title => "Прогнозирование для кластера #{max_index + 1}",
      :hAxis => { :title => 'Дата'    },
      :vAxis => { :title => 'Количество посещений' },
      :legend => 'yes'
    
    }
    visits[max_index].each do |key, value|
      data_table1.add_row([Date.parse(key),value, nil]) 
    end
    array_of_max_cluster = visits[max_index].collect {|key, value| [key,value]}

    s[0] = (array_of_max_cluster[0][1]+array_of_max_cluster[1][1]+array_of_max_cluster[2][1])/3
    array_of_max_cluster[0...array_of_max_cluster.length].each_with_index do |item, index|
      s[index+1] = 0.8*item[1]+(1-0.8)*s[index-1]
      data_table1.add_row([Date.parse(item[0]), nil, s[index]])
    end 
    @chart1 = GoogleVisualr::Interactive::LineChart.new(data_table1, opts)
    @data = array_of_max_cluster 
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
