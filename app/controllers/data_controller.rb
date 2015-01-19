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
    :metrics      => [ 'bounceRate', 'avgsessionDuration'],

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
      :width => 800, :height => 800, :title => 'Age vs. Weight comparison',
      :hAxis => { :title => 'Процент отказов'    , :minValue => 0},
      :vAxis => { :title => 'Длительность посещения' , :minValue => 0 },
      :legend => 'yes'
    
    }
    @chart = GoogleVisualr::Interactive::ScatterChart.new(data_table, opts)
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
