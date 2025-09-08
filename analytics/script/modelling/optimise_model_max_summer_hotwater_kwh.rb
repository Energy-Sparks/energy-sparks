require 'require_all'
require_relative '../lib/dashboard.rb'
require_rel '../test_support'
require './script/report_config_support.rb'
require 'ruby-prof'
require 'write_xlsx'

module Logging
  @logger = Logger.new('log/optimise model max summer hw kwh ' + Time.now.strftime('%H %M') + '.log')
  logger.level = :debug
end

@manual_estimations = {
  # abbey lane
  6615809         => {  kwh: 250..250,   certainty: 0.85, comment: 'current model too high' },
  9330192104      => {  kwh: 0..125,     certainty: 0.20, comment: 'very difficult to tell' },
  80000000106982  => {  kwh: 450..500,   certainty: 0.65, comment: 'difficult' },
  # all saints
  15719508        => {  kwh: 125..140,   certainty: 0.85, comment: 'current model wrong as bifurcation of summer data' },
  15718809        => {  kwh: 0..0,       certainty: 0.95, comment: 'a few stange low heating outliers' },
  80000000114491  => {  kwh: 125..140,   certainty: 0.85, comment: 'current model wrong as bifurcation of summer data' },
  # aspire - no charts?
  # all saints & st richards - no charts?
  # aviemore  - no charts
  # athelstan - no charts
  2148244308  => {  kwh: 800..850,   certainty: 0.9, comment: 'current model working very well' },
  # balliefield
  6508101  => {  kwh: 650..750,   certainty: 0.65, comment: 'current model wrong as bifurcation of summer data' },
  # bankwood
  6326701  => {  kwh: 400..400,   certainty: 0.80, comment: 'a few stange low heating outliers' },
  # barcombe - no charts?
  # bathampton
  16642504  => {  kwh: 0..10,   certainty: 0.90, comment: 'heating only' },
  # batheaston
  45750004        => {  kwh: 100..190,   certainty: 0.75, comment: 'current model completly wrong assigns most days 175 as non heating' },
  9208860909      => {  kwh: 25..30,     certainty: 0.90, comment: 'heating only' },
  80000000145512  => {  kwh: 100..190,   certainty: 0.75, comment: 'current model completly wrong assigns most days 175 as non heating' },
  # bishop sutton
  8891205403  => {  kwh: 0..10,   certainty: 0.90, comment: 'heating only' },
  # brunswick
  6504306  => {  kwh: 700..800,   certainty: 0.75, comment: 'difficult to determine whether heating ever off, no obvious separation' },
  # caldecott
  9102173605      => {  kwh: 80..150,   certainty: 0.80, comment: 'not a full years worth of data starts May 2020' },
  9088174803      => {  kwh: 250..350,   certainty: 0.4, comment: 'not a full years worth of data starts Feb 2020' },
  80000000123087  => {  kwh: 300..500,   certainty: 0.4, comment: 'not a full years worth of data starts May 2020, not clear whether heating ever off?' },
  # castle
  4186869705      => {  kwh: 300..400,   certainty: 0.70, comment: 'probably heating only although heating probably not turned off' },
  # chantry - no charts
  # Cefn Hengoed - no charts
  # Catsfield - no charts
  # Christchurch
  13605606      => {  kwh: 70..110,   certainty: 0.80, comment: 'model misses a few low heating days as non heating days' },
  # Coit
  6460705      => {  kwh: 450..600,   certainty: 0.90, comment: 'model does a good job of separating' },
  # Combe Down - no charts
  # Christchil
  13610902      => {  kwh: 350..450,   certainty: 0.90, comment: 'model does a good job of separating' },
  # Dalenigh - no charts
  # Dallington  - no charts
  # Ditchling
  78503110      => {  kwh: 105..115,   certainty: 0.90, comment: 'model does a good job of separating' },
  # Durham Sixth Form
  10274100        => {  kwh: 115..130,    certainty: 0.90, comment: 'model does a good job of separating' },
  8879383007      => {  kwh: 0..10,       certainty: 0.90, comment: 'heating only' },
  10328108        => {  kwh: 200..330,    certainty: 0.90, comment: 'model does a good job of separating, big gap' },
  80000000114310  => {  kwh: 400..500,    certainty: 0.90, comment: 'model assigns a few low heating dayas as non heating days' },
  # durham st margarets
  12193907        => {  kwh: 0..0,         certainty: 0.90, comment: 'heating only' },
  12192602        => {  kwh: 80..100,     certainty: 0.80, comment: 'model does a good job of separating' },
  12192501        => {  kwh: 580..640,    certainty: 0.40, comment: 'models messes up completely, limited separation' },
  80000000114230  => {  kwh: 650..850,    certainty: 0.90, comment: 'models misses a reasonable number of non heating days, but there is clear separation' },
  # ecclesall
  2155853706        => {  kwh: 250..500,         certainty: 0.90, comment: 'model does a good job of separating' },
  # ecclesfield
  6554602        => {  kwh: 450..500,         certainty: 0.90, comment: 'model does a good job of separating, but limited separation' },
  # farr - no charts
  # freshford
  67095200        => {  kwh: 0..0,         certainty: 0.90, comment: 'kitchen/hot water only, model does good job' },
  # frome college - no charts
  # golden grove
  9109952508        => {  kwh: 250..700,   certainty: 0.90, comment: 'models misses a small number of non heating days, but there is clear separation' },
  # grantown - no charts
  # hamsey no charts
  # green lane
  9216058605      => {  kwh: 0..0,         certainty: 0.60, comment: 'probably heating only - so model probably doing a good job' },
  9216058504      => {  kwh: 0..0,         certainty: 0.20, comment: 'probably heating only, models thinks hw only but heating probably never turned off!' },
  10302505        => {  kwh: 320..350,     certainty: 0.90, comment: 'model gets it wrong, but 2 heating regimes' },
  80000000114219  => {  kwh: 480..520,     certainty: 0.90, comment: 'model gets it wrong, but 2 heating regimes' },
  # hugh sexey - no charts
  # herstmonceux - no charts
  # heron hall - no charts
  # ikb - no charts
  # hunwick
  8817452200        => {  kwh: 0..0,         certainty: 0.90, comment: 'heating only, model good' },
  # inverness - no charts
  # inver - no charts
  # kensington
  61561206        => {  kwh: 450..500,       certainty: 0.90, comment: 'limted separation, but model does good job' },
  # king edward
  6517203        => {  kwh: 2000..4000,      certainty: 0.90, comment: 'big separation  - model working' },
  # king james 1
  10308607        => {  kwh: 0..20,           certainty: 0.90, comment: 'heating only, only turned off for a few summer days' },
  10307706        => {  kwh: 0..300,          certainty: 0.01, comment: 'impossible to tell what is going onmeter faulty before 1 Dec 2019, on 7 days per week, different post COVID' },
  10308203        => {  kwh: 0..20,           certainty: 0.30, comment: 'heating only, probably' },
  9335373908      => {  kwh: 270..500,      certainty: 0.20, comment: 'limited separation difficult to distiguish between heating and hw at mild temperatures' },
  80000000136770  => {  kwh: 500..750,      certainty: 0.70, comment: 'model seems to be working ok' },
  # kingfisher no charts
  # lamphey
  9306088907        => {  kwh: 150..200,      certainty: 0.70, comment: 'model probably assigns some heating days to non heating' },
  # little horstead
  8913915100        => {  kwh: 0..10,        certainty: 0.90, comment: 'heating only - model correct' },
  # long furlong
  8913915100        => {  kwh: 15..320,      certainty: 0.50, comment: 'hw noisy model probably assigns some heating days to non heating' },
  # marksbury no chart
  # milton leys no chart
  # miller no chart
  # mossbrook
  6538402        => {  kwh: 0..0,          certainty: 0.90, comment: 'model competely wrong as heating only, but not turned off? some bifurcation' },
  # mundella
  9091095306     => {  kwh: 340..340,      certainty: 0.90, comment: 'small separation  - model working well' },
  6319210        => {  kwh: 80..100,       certainty: 0.70, comment: 'small separation  - model working ok' },
  6319300        => {  kwh: 180..220,      certainty: 0.90, comment: 'small separation  - difficult to tell how to separate' },
  80000000107006 => {  kwh: 480..500,      certainty: 0.90, comment: 'small separation  - model working well' },
  # oakfield
  13610307        => {  kwh: 0..10,        certainty: 0.90, comment: 'heating only - model correct' },
  13610408        => {  kwh: 280..1000,    certainty: 0.90, comment: 'model working large separation' },
  80000000136970  => {  kwh: 280..1000,    certainty: 0.90, comment: 'heating only - model correct' },
  # paulton
  13678903        => {  kwh: 220..300,     certainty: 0.90, comment: 'model does ol job of separating - 4 mis-assigned' },
  # pennyland - no chart
  # pensford - no chart
  # pentrehod - no chart
  # pneyrhoel - no chart
  # pevensey
  9088027004        => {  kwh: 280..320,   certainty: 0.80, comment: 'models does ok to good job of separation' },
  # plumpton - no chart
  # portsmouth
  9088027004        => {  kwh: 400..650,   certainty: 0.75, comment: 'models does ok to good job of separation' },
  68351006          => {  kwh: 0..0,       certainty: 0.80, comment: 'heating only - model good' },
  14601805          => {  kwh: 350..500,   certainty: 0.80, comment: 'models does ok to good job of separation, misses a few' },
  14601603          => {  kwh: 100..200,   certainty: 0.50, comment: 'model gets it wrong - COVID issue?' },
  80000000116581    => {  kwh: 1000..1500,   certainty: 0.80, comment: 'models does ok job of separation, missassigns a few hw days as heating in colder weather' },
  # prenderghast
  9178098904        => {  kwh: 800..1000,   certainty: 0.01, comment: 'models probably doing a good job, very difficult to know what is going on, suspect high hw consumption mimicking heating' },
  # prince bishops
  9308062001        => {  kwh: 200..220,   certainty: 0.80, comment: 'models very good job of limited separation' },
  # ralph allen
  9313345903        => {  kwh: 750..1000,   certainty: 0.80, comment: 'bifurcation of hw, models does good job, but assigns a few heating days as non heating because of sd of bifurcation' },
  51068901          => {  kwh: 580..880,    certainty: 0.80, comment: 'models very good job of separation' },
  80000000138522    => {  kwh: 1300..1750,  certainty: 0.80, comment: 'some bifurcation of hw, models very good job of separation' },
  # red rose
  9305046403        => {  kwh: 0..0,       certainty: 0.90,  comment: 'heating only - and on all weekends' },
  14349002          => {  kwh: 200..350,   certainty: 0.5,   comment: 'models does reasonable job with limitedish separation' },
  80000000002125    => {  kwh: 280..320,   certainty: 0.4,  comment: 'model messes up' },
  # Ribbon
  9158112702        => {  kwh: 350..500,       certainty: 0.6,  comment: 'models misassigns colder hw days because of +tve regression slope' },
  # Ringmer
  75869205          => {  kwh: 480..520,   certainty: 0.60, comment: 'models very good job of limited separation' },
  # robsack
  15224503          => {  kwh: 440..610,   certainty: 0.60, comment: 'models does a  good job maybe misassigning some non heating days to heating?' },
  # roundhill
  75665806          => {  kwh: 50..100,    certainty: 0.60, comment: 'messed up missing meter data, but models does good separation job' },
  75665705          => {  kwh: 25..30,     certainty: 0.60, comment: '95% heating only, mopdels does reasonable job' },
  50974804          => {  kwh: 0..140,     certainty: 0.10, comment: 'gas on all weekend, small consumer, difficult to tell function' },
  50974602          => {  kwh: 480..520,   certainty: 0.10, comment: 'messes up because manual m3=>kWh adjustment not applied' },
  50974703          => {  kwh: 580..600,   certainty: 0.10, comment: 'model messes up not sure why? ' },
  80000000109005    => {  kwh: 600..650,   certainty: 0.75, comment: 'models good job of limited separation' },
  # royal high
  180601          => {  kwh: 60..80,     certainty: 0.20, comment: 'on all weekend, probably heating only, but not turned off in summer so model messes up' },
  181401          => {  kwh: 160..180,   certainty: 0.60, comment: 'models good job of separation, perhaps a few hw misassignments in cold weather' },
  181210          => {  kwh: 0..0,       certainty: 0.90, comment: 'hw only model correct' },
  180702          => {  kwh: 480..520,   certainty: 0.60, comment: 'on all weekend, difficult to know what is going on, missing data or heating turned off all summer 2019' },
  180208          => {  kwh: 100..150,   certainty: 0.01, comment: 'incomplete dataset, data missing?' },
  180006          => {  kwh: 480..520,   certainty: 0.60, comment: 'on all weekend, model probably correctly assigning to heat only' },
  181502          => {  kwh: 100..150,   certainty: 0.01, comment: 'incomplete dataset, data missing?' },
  180803          => {  kwh: 1400..1500, certainty: 0.40, comment: 'on all weekend, model wrong because of COVID switchoff' },
  180410          => {  kwh: 480..520,   certainty: 0.03, comment: 'incomplete dataset, data missing?' },
  181109          => {  kwh: 480..520,   certainty: 0.03, comment: 'incomplete dataset, data missing?' },
  80000000109348  => {  kwh: 800..4000,  certainty: 0.50, comment: 'models doing good job or messy data' },
  # sacred heart
  15234304        => {  kwh: 180..190,   certainty: 0.5, comment: 'model doing reasonable jovb with limited separation' },
  # saltford
  47939506        => {  kwh: 200..200,   certainty: 0.01, comment: 'impossible to tell what is heating and what isnt' },
  # saundersfoot
  78575708        => {  kwh: 400..500,   certainty: 0.10, comment: 'heating may be on all year' },
  # south amlling - no charts
  # st bernard lovell - no charts
  # st andrews
  87681203        => {  kwh: 89..200,   certainty: 0.9, comment: 'model good, clear separation between heating and non heating' },
  # St Bedes
  9090353207     => {  kwh: 0..0,   certainty: 0.7,  comment: 'heating on at weekends, probably heating only' },
  8834264005     => {  kwh: 0..0,   certainty: 0.7,  comment: 'heating on at weekends, probably heating only' },
  80000008403344 => {  kwh: 0..0,   certainty: 0.10, comment: 'heating on at weekends, bivariate distribution from 2 meters confuses model bimodel probably wrong' },
  # St Benedicts
  9090353207     => {  kwh: 70..80,   certainty: 0.8, comment: 'model good, a few heating days assigned as non-heating' },
  # St Johns Catholic Bath
  9206222810     => {  kwh: 210..215,   certainty: 0.8, comment: 'model good, correctly separates messy data' },
  # St Louis
  9206222810     => {  kwh: 0..0,   certainty: 0.9, comment: 'some weekend, heating only' },
  # st marks
  8841599005     => {  kwh: 0..0,   certainty: 0.9, comment: 'meter data all zero from Apr 2020 to now!!!!!!!!!!! model gives up?' },
  13685103       => {  kwh: 0..0,   certainty: 0.9, comment: 'meter data all zero from Apr 2020 to now!!!!!!!!!!! model gives up?' },
  13685204       => {  kwh: 0..0,   certainty: 0.9, comment: 'meter data all zero from Apr 2020 to now!!!!!!!!!!! model gives up?' },
  13685002       => {  kwh: 0..0,   certainty: 0.9, comment: 'meter data all zero from Apr 2020 to now!!!!!!!!!!! model gives up?' },
  13684909       => {  kwh: 0..0,   certainty: 0.9, comment: 'meter data all zero from Apr 2020 to now!!!!!!!!!!! model gives up?' },
  80000000109328 => {  kwh: 0..0,   certainty: 0.9, comment: 'meter data all zero from Apr 2020 to now!!!!!!!!!!! model gives up?' },
  # st martins garden
  9116469608      => {  kwh: 0..0,   certainty: 0.9, comment: 'some weekend, heating only, model good' },
  11476701        => {  kwh: 825..1350,   certainty: 0.9, comment: 'some weekend, very bad r2, model good' },
  11476903        => {  kwh: 0..0,   certainty: 0.4, comment: 'very strange summer usage significantly higher than winter, babelled as kitchen' },
  80000000143108  => {  kwh: 1250..1550,   certainty: 0.5, comment: 'despite very bad r2 model seems to be working' },
  # st michaels garden
  51068306      => {  kwh: 120..200,   certainty: 0.9, comment: 'poorish r2 but model provides good separation' },
  # st nicolas
  8908639402      => {  kwh: 160..320,   certainty: 0.01, comment: 'model gets obvious separation wrong' },
  # st philips
  16747810        => {  kwh: 160..320,   certainty: 0.4,   comment: 'heating probably left on summer 2019 but not previously, but model probably gets separation right' },
  16747608        => {  kwh: 160..320,   certainty: 0.01,  comment: 'heating on at weekends, new boiler in last 2 years?, modelling fails - not sure why' },
  80000000143560  => {  kwh: 680..700,   certainty: 0.9,   comment: 'despite poor data modelling seems to work well' },
  # st richards catholic
  8814676600      => {  kwh: 50..250,     certainty: 0.8, comment: 'model good, clear separation' },
  82043504        => {  kwh: 200..200,    certainty: 0.4, comment: 'probably hot water only, model wrong, messed up by COVID?' },
  15496604        => {  kwh: 250..260,    certainty: 0.8, comment: 'model good, clear separation' },
  82044001        => {  kwh: 0..0,        certainty: 0.9, comment: 'heating only, model correct' },
  80000000114612  => {  kwh: 500..1000,   certainty: 0.5, comment: 'model gets separation wrong but data unclear and messy' },
  # st saviours
  46341710        => {  kwh: 100..150,   certainty: 0.9,   comment: 'separation reasonable, a few non heating days assigned as heating, so really high off the scale values' },
  4234023603      => {  kwh: 85..90,     certainty: 0.1,   comment: 'heating at weekends, messy data difficult to tell how well model working, perhaps too high' },
  80000000109153  => {  kwh: 85..90,     certainty: 0.9,   comment: 'heating on at weekends,  messy data difficult to tell how well model working, perhaps too high' },
  # St Stephens
  13918504        => {  kwh: 70..150,    certainty: 0.9, comment: 'model does good job of separation' },
  13918605        => {  kwh: 0..0,       certainty: 0.1, comment: 'data messed up, unclear what is going on' },
  80000000145517  => {  kwh: 350..360,   certainty: 0.9, comment: 'messy data, model probably working' },
  # st thomas of canterbury
  6354605        => {  kwh: 0..0,     certainty: 0.01, comment: 'heating on 24x7? COVID turn off? model separation may be ok' },
  # stanton drew - no charts
  # tain - not charts
  # tanfield
  8904906502      => {  kwh: 80..150,    certainty: 0.3,   comment: 'turned off for COVID, hence model misassigns all to heating' },
  76187307        => {  kwh: 400..500,   certainty: 0.85,  comment: 'heat and hw separation correct' },
  11139604        => {  kwh: 180..200,   certainty: 0.9,   comment: 'messy data, model probably working' },
  80000000147894  => {  kwh: 700..1000,  certainty: 0.9,   comment: 'messy data, model assigns some heating days to non heating days' },
  # the haven
  8907137204        => {  kwh: 20..20,    certainty: 0.01, comment: 'difficult to understand what is going on' },
  8907148400        => {  kwh: 75..85,    certainty: 0.9, comment: 'good model separation' },
  80000000002169    => {  kwh: 75..85,    certainty: 0.9, comment: 'good model separation' },
  # toft hill
  11160707          => {  kwh: 0..0,    certainty: 0.9, comment: 'heating only, model good' },
  # tomnacross - no charts
  # trinity
  10545307          => {  kwh: 200..400,    certainty: 0.9, comment: 'separation working well, 1 misassigned day' },
  # twerton
  4223705708        => {  kwh: 150..400,    certainty: 0.9, comment: 'separation working well, 1 misassigned day' },
  # walkley
  6500803           => {  kwh: 0..0,    certainty: 0.01,     comment: 'possibly heating left on all year, model assumes hot water alll year, so wrong' },
  9337391909        => {  kwh: 450..500,    certainty: 0.5,  comment: 'possibly heating left on all year, separation wrong',  },
  80000000107094    => {  kwh: 0..0,    certainty: 0.01,     comment: 'no idea what is going on at school!' },
  # watercliffe
  9209120604        => {  kwh: 280..300,    certainty: 0.9, comment: 'separation working well' },
  # west whitney - no charts
  # wellsway - no charts
  # westfield
  51015307        => {  kwh: 680..720,    certainty: 0.5, comment: 'separation probably correct' },
  # whiteways
  2163409301      => {  kwh: 1000..1500,    certainty: 0.9, comment: 'COVID mess, but separation appears to be working'  },
  # widcombe infant
  15976809        => {  kwh: 300..700,    certainty: 0.5, comment: 'heating on at weekends, thermostatic winter control very poor, separation wrong' },
  # wimbledon high
  620361806       => {  kwh: 0..0,        certainty: 0.5, comment: 'COVID mess, on at weekends, maybe heating only, left on all year' },
  14494606        => {  kwh: 80..110,     certainty: 0.5, comment: 'COVID mess, on at weekends, possible hw only, difficult' },
  14493806        => {  kwh: 100..150,    certainty: 0.5, comment: 'COVID mess, go back a year' },
  14494404        => {  kwh: 500..500,    certainty: 0.01, comment: 'data missing per Nov 2021?' },
  8838683001      => {  kwh: 680..720,    certainty: 0.01, comment: 'data post Apr 2020 missing' },
  80000000102692  => {  kwh: 320..2000,    certainty: 0.01, comment: 'COVID issues separation wrong' },
  # windmill - no charts
  # wingate
  1335642507      => {  kwh: 80..80,    certainty: 0.01, comment: 'COVID issues, data messy, unclear what is going on' },
  # wivlesfield
  9188991203      => {  kwh: 200..210,    certainty: 0.9, comment: 'good model separation' },
  # woodthorpe
  9120550903      => {  kwh: 400..500,    certainty: 0.9, comment: 'good model separation' },
  # wooton st peters
  13947702        => {  kwh: 70..150,    certainty: 0.8, comment: 'reasonable model separation' },
  # wybourne
  9297324003        => {  kwh: 300..320,    certainty: 0.9, comment: 'good model separation' },
  # ysgoly Frenni - no charts
  # ysgol  Bro Ingli - no charts
}

class OptimiseMeterMaxSummerHotWaterKwh
  attr_reader :meter
  def initialize(meter, manual_estimations)
    @meter = meter
    @manual_estimations = manual_estimations
  end

  def self.heat_meters(school)
    [
      school.all_heat_meters,
      school.storage_heater_meters,
      school.storage_heater_meter
    ].flatten.compact.uniq
  end

  def analyse
    results = {}
    end_date = meter.amr_data.end_date
    start_date = [end_date - 364, meter.amr_data.start_date].max
    period = SchoolDatePeriod.new(:optimisation, 'optmisation', start_date, end_date)
    AnalyseHeatingAndHotWater::HeatingNonHeatingDisaggregationModelBase.model_types.each do |model_type|
      model = meter.heating_model(period, :simple_regression_temperature_no_overrides, model_type)

      model_results = model.non_heating_model.model_results
      results[model_type] = model_results.is_a?(Hash) ? model_results : { fixed: model_results}
      results[model_type][:average_max_non_heating_day_kwh] = model.non_heating_model.average_max_non_heating_day_kwh
    end
    results[:overridden_max_summer_hot_water_kwh] = overridden_max_summer_hot_water_kwh
    results[:manual] = @manual_estimations[@meter.mpan_mprn] unless @manual_estimations[@meter.mpan_mprn].nil?
    results
  end

  def overridden_max_summer_hot_water_kwh
    attributes = meter.attributes(:heating_model)
    return nil if attributes.nil?
    attributes.fetch(:max_summer_daily_heating_kwh, nil)
  end
end

def flatten_results(results)
  results.map do |model, values|
    values.is_a?(Hash) ? values.map { |type, value| [ :"#{model}:#{type}", value ] } : [[ model, values ]]
  end.flatten(1).to_h
end

def all_model_keys(results)
  results.map do |_school_name, mpxns|
    mpxns.map do |mpxn, result|
      result.keys
    end
  end.flatten.uniq
end

def save_results_to_csv(results)
  model_keys = all_model_keys(results)
  filename = 'Results\\' + "max summer hot water kwh analysis.csv"
  column_names = ['school name', 'mpxn', model_keys].flatten
  puts "Saving readings to #{filename}"
  CSV.open(filename, 'w') do |csv|
    csv << column_names
    results.each do |school_name, mpxns|
      mpxns.each do |mpxn, result|
        csv << [school_name, mpxn, model_keys.map { |cn| result.fetch(cn, nil) }].flatten
      end
    end
  end
end

def test_script_config(school_name_pattern_match, source_db, attribute_overrides)
  {
    logger1:                  { name: TestDirectory.instance.log_directory + "/model fitting %{time}.log", format: "%{severity.ljust(5, ' ')}: %{msg}\n" },
    schools:                    school_name_pattern_match,
    source:                     source_db,
    meter_attribute_overrides:  attribute_overrides,
    model_fitting:            {
      control: {
        display_average_calculation_rate: true,
        report_failed_charts:   :summary,
        compare_results: [
          :summary,
          :quick_comparison,
          { comparison_directory: ENV['ANALYTICSTESTRESULTDIR'] + '\Models\Base\\' },
          { output_directory:     ENV['ANALYTICSTESTRESULTDIR'] + '\Models\New\\' }
        ]
      }
    },
  }
end

def run_all_heat_non_heat_models_for_school(school_name, source_db, results, attributes)
  puts "==============================Doing #{school_name} ================================"

  begin
    school = SchoolFactory.new.load_or_use_cached_meter_collection(:name, school_name, source_db, meter_attributes_overrides: attributes)

    heat_meters = OptimiseMeterMaxSummerHotWaterKwh.heat_meters(school)

    heat_meters.each do |heat_meter|
      analyser = OptimiseMeterMaxSummerHotWaterKwh.new(heat_meter, @manual_estimations)
      analysis = analyser.analyse
      results[school_name][heat_meter.mpan_mprn] = flatten_results(analysis)
    end
  rescue EnergySparksNotEnoughDataException => e
    puts "Giving up"
    puts e.message
  end
end

def meter_attribute_overrides
  @meter_attribute_overrides ||= {
    6615809  => { heating_non_heating_day_fixed_kwh_separation: 235.0 }, # abbey lane
    9330192104  => { heating_non_heating_day_fixed_kwh_separation: 125.0 }, # abbey lane
    80000000106982  => { heating_non_heating_day_separation_model_override: :either }, # abbey lane
    15718809   => { function_switch: :heating_only }, # All Saints
    15719508  => { heating_non_heating_day_fixed_kwh_separation: 150.0 }, # All Saints
    80000000114491  => { heating_non_heating_day_fixed_kwh_separation: 150.0 }, # All Saints
    2148244308  => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # athelston
    6326701     => { heating_non_heating_day_separation_model_override: :fixed_single_value_temperature_sensitive_regression_model }, # bankwood
    6508101     => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # balliefield
    6504306     => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # brunswick
    9088174803  => { heating_non_heating_day_separation_model_override: :either }, # caldicot
    9102173605  => { heating_non_heating_day_separation_model_override: :no_idea }, # caldicot
    80000000123087  => { heating_non_heating_day_separation_model_override: :no_idea }, # caldicot
    13605606   => { heating_non_heating_day_separation_model_override: :fixed_single_value_temperature_sensitive_regression_model }, # christ church
    6460705    => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # Coit
    13610902   => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # Critchill
    78503110   => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # Ditchling
    10328108   => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # Durham Sixth
    8879383007 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model_covid_tolerant }, # Durham Sixth
    10274100   => { heating_non_heating_day_separation_model_override: :either }, # Durham Sixth
    80000000114310  => { heating_non_heating_day_fixed_kwh_separation: 500.0 }, # Durham Sixth
    12192501   => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # Durham St M
    12192602   => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # Durham St M
    12193907   => { function_switch: :heating_only }, # Durham St
    80000000114230 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model_covid_tolerant }, # Durham St M
    2155853706 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model_covid_tolerant }, # Eccleshall
    6554602 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # Ecclesfield
    9109952508 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model_covid_tolerant }, # Golden Grove
    10302505 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model_covid_tolerant }, # Green Lane
    9216058504 => { function_switch: :kitchen_only }, # Green Lane
    9216058605 => { function_switch: :heating_only }, # Green Lane
    80000000114219 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model_covid_tolerant }, # Green Lane
    8817452200 =>  { function_switch: :heating_only }, # Hunwick
    61561206 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model_covid_tolerant }, # Kensington Prep
    6517203 => { heating_non_heating_day_separation_model_override: :either }, # King Edward
    9335373908 => { heating_non_heating_day_separation_model_override: :either }, # King James
    10308203 => { function_switch: :heating_only }, # King James
    10307706 => { heating_non_heating_day_separation_model_override: :no_idea }, # King James
    10308607 => { function_switch: :heating_only }, # King James
    80000000136770 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # King James
    9306088907 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # Lamphey
    8913915100 => { function_switch: :heating_only }, # Little Horsted
    74118502 => { heating_non_heating_day_separation_model_override: :either }, # Long Furlong
    6538402 => { function_switch: :heating_only }, # Mossbrook
    9091095306 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # Mundella
    6319210 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # Mundella
    6319300 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model_covid_tolerant }, # Mundella
    80000000107006 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # Mundella
    13610307 => { function_switch: :heating_only }, # Oakfield
    13610408 => { heating_non_heating_day_separation_model_override: :either }, # Oakfield
    80000000136970 => { heating_non_heating_day_separation_model_override: :either }, # Oakfield
    9088027004 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model_covid_tolerant }, # Pevensey
    14601603 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model_covid_tolerant }, # Portsmouth
    14601805 => { heating_non_heating_day_separation_model_override: :either }, # Portsmouth
    68351006 => { function_switch: :heating_only }, # Portsmouth
    9153680108 => { heating_non_heating_day_separation_model_override: :either }, # Portsmouth
    80000000116581 => { heating_non_heating_day_separation_model_override: :either }, # Portsmouth
    9178098904 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model_covid_tolerant }, # Prendaghast
    9308062001 => { heating_non_heating_day_separation_model_override: :either }, # Prince Bishop
    14349002 => { heating_non_heating_day_separation_model_override: :no_idea }, # Red Rose
    9305046403 => { function_switch: :heating_only }, # Red Rose
    80000000002125 => { heating_non_heating_day_separation_model_override: :fixed_single_value_temperature_sensitive_regression_model }, # Red Rose
    9158112702  => { heating_non_heating_day_fixed_kwh_separation: 400.0 }, # ribbon
    75869205 => { heating_non_heating_day_separation_model_override: :fixed_single_value_temperature_sensitive_regression_model }, # Ringmer
    15224503 => { heating_non_heating_day_separation_model_override: :fixed_single_value_temperature_sensitive_regression_model }, # Robsack
    181109 => { heating_non_heating_day_separation_model_override: :no_idea }, # Royal High
    180410 => { heating_non_heating_day_separation_model_override: :no_idea }, # Royal High
    180803 => { function_switch: :heating_only }, # Royal High
    181502 => { heating_non_heating_day_separation_model_override: :no_idea }, # Royal High
    180006 => { heating_non_heating_day_fixed_kwh_separation: 100.0 }, # Royal High
    180208 => { function_switch: :heating_only }, # Royal High
    180702 => { function_switch: :heating_only }, # Royal High
    181210 => { function_switch: :heating_only }, # Royal High
    181401 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model_covid_tolerant }, # Royal High
    180601 => { heating_non_heating_day_separation_model_override: :no_idea }, # Royal High
    80000000109348 => { heating_non_heating_day_fixed_kwh_separation: 2000.0 }, # Royal High
    15234304 => { heating_non_heating_day_separation_model_override: :either }, # Sacred Heart
    47939506 => { heating_non_heating_day_separation_model_override: :no_idea }, # Saltford
    78575708 => { heating_non_heating_day_separation_model_override: :fixed_single_value_temperature_sensitive_regression_model }, # Saundersfoot
    8834264005 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # St Bedes
    9090353207 => { heating_non_heating_day_separation_model_override: :either }, # St Bedes
    80000008403344 => { heating_non_heating_day_separation_model_override: :fixed_single_value_temperature_sensitive_regression_model }, # St Bedes
    19161200 => { function_switch: :heating_only }, # St Louis
    16747608 => { heating_non_heating_day_separation_model_override: :either }, # St Philips
    16747810 => { heating_non_heating_day_separation_model_override: :either }, # St Philips
    80000000143560 => { heating_non_heating_day_separation_model_override: :either }, # St Philips
    82044001 => { function_switch: :heating_only }, # St Richards C
    15496604 => { heating_non_heating_day_separation_model_override: :either }, # St Richards C
    82043504 => { function_switch: :kitchen_only }, # St Richards C
    8814676600 => { heating_non_heating_day_separation_model_override: :either }, # St Richards C
    80000000114612 => { heating_non_heating_day_separation_model_override: :either }, # St Richards C
    6354605 => { heating_non_heating_day_separation_model_override: :either }, # St Thomas of C
    67285306 => { heating_non_heating_day_separation_model_override: :either }, # St Benedict
    8908639402 => { heating_non_heating_day_fixed_kwh_separation: 200.0 }, # St Nicolas
    11139604 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # St Micolas
    76187307 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # St Micolas
    8904906502 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model_covid_tolerant }, # St Micolas
    80000000147894 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # St Micolas
    8903472804 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # The Durham Federation, good example
    8907148400 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # The Haven
    8907137204 => { function_switch: :kitchen_only }, # The Haven
    80000000002169 => { heating_non_heating_day_separation_model_override: :either }, # The Haven
    11160707 => { function_switch: :heating_only }, # Toft Hill
    10545307 => { heating_non_heating_day_separation_model_override: :either }, # Trinity
    9337391909 => { heating_non_heating_day_fixed_kwh_separation: 500.0 }, # Walkley
    6500803 => { heating_non_heating_day_separation_model_override: :fixed_single_value_temperature_sensitive_regression_model }, # Walkley
    80000000107094 => { heating_non_heating_day_separation_model_override: :fixed_single_value_temperature_sensitive_regression_model }, # Walkley
    9209120604 => { heating_non_heating_day_separation_model_override: :either }, # Watercliffe Meadow
    2163409301 => { heating_non_heating_day_separation_model_override: :either }, # Whiteways
    14494404 => { heating_non_heating_day_separation_model_override: :not_enough_data }, # Wimbledon
    14493806 => { heating_non_heating_day_separation_model_override: :not_enough_data }, # Wimbledon
    9377457904 => { heating_non_heating_day_separation_model_override: :not_enough_data }, # Wimbledon
    620361806 => { heating_non_heating_day_separation_model_override: :not_enough_data }, # Wimbledon
    80000000102692 => { heating_non_heating_day_separation_model_override: :not_enough_data }, # Wimbledon
    1335642507 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # Wingate
    9188991203 => { heating_non_heating_day_separation_model_override: :either }, # Wivelsfield
    9120550903 =>  { heating_non_heating_day_fixed_kwh_separation: 350.0 }, # Woodthorpe
    13947702 =>  { heating_non_heating_day_fixed_kwh_separation: 140.0 }, # Wooton St Peters
    9297324003 => { heating_non_heating_day_separation_model_override: :fixed_single_value_temperature_sensitive_regression_model }, # Wybourne
  }.select { |_k, v| !v.nil? }
end

def v2
  a = {
        10274100    => { heating_non_heating_day_separation_model_override: :either }, # Durham Sixth
    10302505  => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model_covid_tolerant }, # Green Lane
    10307706  => { heating_non_heating_day_separation_model_override: :no_idea }, # King James
    10308203  => { function_switch: :heating_only }, # King James
    10308607  => { function_switch: :heating_only }, # King James
    10328108    => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # Durham Sixth
    10545307  => { heating_non_heating_day_separation_model_override: :either }, # Trinity
    11139604  => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # St Micolas
    11160707  => { function_switch: :heating_only }, # Toft Hill
    12192501    => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # Durham St M
    12192602    => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # Durham St M
    12193907    => { function_switch: :heating_only }, # Durham St
    1335642507  => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # Wingate
    13605606    => { heating_non_heating_day_separation_model_override: :fixed_single_value_temperature_sensitive_regression_model }, # christ church
    13610307  => { function_switch: :heating_only }, # Oakfield
    13610408  => { heating_non_heating_day_separation_model_override: :either }, # Oakfield
    13610902    => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # Critchill
    13947702  =>  { heating_non_heating_day_fixed_kwh_separation: 140.0 }, # Wooton St Peters
    14349002  => { heating_non_heating_day_separation_model_override: :no_idea }, # Red Rose
    14493806  => { heating_non_heating_day_separation_model_override: :not_enough_data }, # Wimbledon
    14494404  => { heating_non_heating_day_separation_model_override: :not_enough_data }, # Wimbledon
    14601603  => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model_covid_tolerant }, # Portsmouth
    14601805  => { heating_non_heating_day_separation_model_override: :either }, # Portsmouth
    15224503  => { heating_non_heating_day_separation_model_override: :fixed_single_value_temperature_sensitive_regression_model }, # Robsack
    15234304  => { heating_non_heating_day_separation_model_override: :either }, # Sacred Heart
    15496604  => { heating_non_heating_day_separation_model_override: :either }, # St Richards C
    15718809    => { function_switch: :heating_only }, # All Saints
    15719508    => { heating_non_heating_day_fixed_kwh_separation: 150.0 }, # All Saints
    16747608  => { heating_non_heating_day_separation_model_override: :either }, # St Philips
    16747810  => { heating_non_heating_day_separation_model_override: :either }, # St Philips
    180006  => { heating_non_heating_day_fixed_kwh_separation: 100.0 }, # Royal High
    180208  => { function_switch: :heating_only }, # Royal High
    180410  => { heating_non_heating_day_separation_model_override: :no_idea }, # Royal High
    180601  => { heating_non_heating_day_separation_model_override: :no_idea }, # Royal High
    180702  => { function_switch: :heating_only }, # Royal High
    180803  => { function_switch: :heating_only }, # Royal High
    181109  => { heating_non_heating_day_separation_model_override: :no_idea }, # Royal High
    181210  => { function_switch: :heating_only }, # Royal High
    181401  => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model_covid_tolerant }, # Royal High
    181502  => { heating_non_heating_day_separation_model_override: :no_idea }, # Royal High
    19161200  => { function_switch: :heating_only }, # St Louis
    2148244308    => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # athelston
    2155853706  => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model_covid_tolerant }, # Eccleshall
    2163409301  => { heating_non_heating_day_separation_model_override: :either }, # Whiteways
    47939506  => { heating_non_heating_day_separation_model_override: :no_idea }, # Saltford
    61561206  => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model_covid_tolerant }, # Kensington Prep
    620361806   => { heating_non_heating_day_separation_model_override: :not_enough_data }, # Wimbledon
    6319210   => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # Mundella
    6319300   => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model_covid_tolerant }, # Mundella
    6326701       => { heating_non_heating_day_separation_model_override: :fixed_single_value_temperature_sensitive_regression_model }, # bankwood
    6354605   => { heating_non_heating_day_separation_model_override: :either }, # St Thomas of C
    6460705     => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # Coit
    6500803   => { heating_non_heating_day_separation_model_override: :fixed_single_value_temperature_sensitive_regression_model }, # Walkley
    6504306       => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # brunswick
    6508101       => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # balliefield
    6517203   => { heating_non_heating_day_separation_model_override: :either }, # King Edward
    6538402   => { function_switch: :heating_only }, # Mossbrook
    6554602   => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # Ecclesfield
    6615809   => { heating_non_heating_day_fixed_kwh_separation: 235.0 }, # abbey lane
    67285306  => { heating_non_heating_day_separation_model_override: :either }, # St Benedict
    68351006  => { function_switch: :heating_only }, # Portsmouth
    74118502  => { heating_non_heating_day_separation_model_override: :either }, # Long Furlong
    75869205  => { heating_non_heating_day_separation_model_override: :fixed_single_value_temperature_sensitive_regression_model }, # Ringmer
    76187307  => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # St Micolas
    78503110    => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # Ditchling
    78575708  => { heating_non_heating_day_separation_model_override: :fixed_single_value_temperature_sensitive_regression_model }, # Saundersfoot
    82043504  => { function_switch: :kitchen_only }, # St Richards C
    82044001  => { function_switch: :heating_only }, # St Richards C
    8814676600  => { heating_non_heating_day_separation_model_override: :either }, # St Richards C
    8817452200  =>  { function_switch: :heating_only }, # Hunwick
    8834264005  => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # St Bedes
    8879383007  => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model_covid_tolerant }, # Durham Sixth
    8903472804  => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # The Durham Federation, good example
    8904906502  => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model_covid_tolerant }, # St Micolas
    8907137204  => { function_switch: :kitchen_only }, # The Haven
    8907148400  => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # The Haven
    8908639402  => { heating_non_heating_day_fixed_kwh_separation: 200.0 }, # St Nicolas
    8913915100  => { function_switch: :heating_only }, # Little Horsted
    9088027004  => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model_covid_tolerant }, # Pevensey
    9088174803    => { heating_non_heating_day_separation_model_override: :either }, # caldicot
    9090353207  => { heating_non_heating_day_separation_model_override: :either }, # St Bedes
    9091095306  => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # Mundella
    9102173605    => { heating_non_heating_day_separation_model_override: :no_idea }, # caldicot
    9109952508  => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model_covid_tolerant }, # Golden Grove
    9120550903  =>  { heating_non_heating_day_fixed_kwh_separation: 350.0 }, # Woodthorpe
    9153680108  => { heating_non_heating_day_separation_model_override: :either }, # Portsmouth
    9158112702    => { heating_non_heating_day_fixed_kwh_separation: 400.0 }, # ribbon
    9178098904  => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model_covid_tolerant }, # Prendaghast
    9188991203  => { heating_non_heating_day_separation_model_override: :either }, # Wivelsfield
    9209120604  => { heating_non_heating_day_separation_model_override: :either }, # Watercliffe Meadow
    9216058504  => { function_switch: :kitchen_only }, # Green Lane
    9216058605  => { function_switch: :heating_only }, # Green Lane
    9297324003  => { heating_non_heating_day_separation_model_override: :fixed_single_value_temperature_sensitive_regression_model }, # Wybourne
    9305046403  => { function_switch: :heating_only }, # Red Rose
    9306088907  => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # Lamphey
    9308062001  => { heating_non_heating_day_separation_model_override: :either }, # Prince Bishop
    9330192104    => { heating_non_heating_day_fixed_kwh_separation: 125.0 }, # abbey lane
    9335373908  => { heating_non_heating_day_separation_model_override: :either }, # King James
    9337391909  => { heating_non_heating_day_fixed_kwh_separation: 500.0 }, # Walkley
    9377457904  => { heating_non_heating_day_separation_model_override: :not_enough_data }, # Wimbledon
  }
b = {
2125  => { heating_non_heating_day_separation_model_override: :fixed_single_value_temperature_sensitive_regression_model }, # Red Rose
2169  => { heating_non_heating_day_separation_model_override: :either }, # The Haven
102692  => { heating_non_heating_day_separation_model_override: :not_enough_data }, # Wimbledon
106982    => { heating_non_heating_day_separation_model_override: :either }, # abbey lane
107006  => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # Mundella
107094  => { heating_non_heating_day_separation_model_override: :fixed_single_value_temperature_sensitive_regression_model }, # Walkley
109348  => { heating_non_heating_day_fixed_kwh_separation: 2000.0 }, # Royal High
114219  => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model_covid_tolerant }, # Green Lane
114230  => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model_covid_tolerant }, # Durham St M
114310    => { heating_non_heating_day_fixed_kwh_separation: 500.0 }, # Durham Sixth
114491    => { heating_non_heating_day_fixed_kwh_separation: 150.0 }, # All Saints
114612  => { heating_non_heating_day_separation_model_override: :either }, # St Richards C
116581  => { heating_non_heating_day_separation_model_override: :either }, # Portsmouth
123087    => { heating_non_heating_day_separation_model_override: :no_idea }, # caldicot
136770  => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # King James
136970  => { heating_non_heating_day_separation_model_override: :either }, # Oakfield
143560  => { heating_non_heating_day_separation_model_override: :either }, # St Philips
147894  => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # St Micolas
8403344   => { heating_non_heating_day_separation_model_override: :fixed_single_value_temperature_sensitive_regression_model }, # St Bedes

  }
end

school_name_pattern_match = ['*']
source_db = :unvalidated_meter_data

school_names = RunTests.resolve_school_list(source_db, school_name_pattern_match)

results = {}

school_names.each do |school_name|
  results[school_name] ||= {}
  run_all_heat_non_heat_models_for_school(school_name, source_db, results, meter_attribute_overrides)
end

save_results_to_csv(results)

script = test_script_config(school_name_pattern_match, source_db, meter_attribute_overrides)
RunTests.new(script).run
