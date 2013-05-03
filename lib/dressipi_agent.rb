require 'barbarian'
require 'mechanize'
class DressipiAgent < Barbarian::Agent

  state :landing_page do
    @page = session.get('http://localhost:3000')
  end

  state :signup do
    session.get('http://localhost:3000/fashion_fingerprint')
    submit_height_and_weight
    submit_body_proportions
    submit_chest_and_waist
    submit_sizes
    submit_reveal_and_conceal
    submit_eye_colour
    submit_hair_colour
    submit_skin_colour
    submit_investment_colours
    submit_favourite_colours
    submit_fashion_confidence
    submit_want_to_change
    submit_enjoy_shopping
    submit_weekday_occupation
    submit_dressing_up
    submit_age
    submit_garments_step_1
    submit_garments_step_2
  end

  state :browsing do
  end


  state :browse_category do
    cat = %w(1 6 2 9 8 12 7 3).sample
    kind = %w(must_have good_1 good_2).sample
    session.get("http://localhost:3000/style_profile/must_haves/#{cat}/#{kind}")
  end

  state :likes do
    session.get('http://localhost:3000/style_profile/likes')
  end


  state :maybenots do
    session.get('http://localhost:3000/style_profile/must_avoids')
  end

  state :colours do
    session.get('http://localhost:3000/fashion_fingerprint/your_colours')
  end

  state :body_shape do
    session.get('http://localhost:3000/fashion_fingerprint/your_bodyshape')
  end

  state :personality do
    session.get('http://localhost:3000/fashion_fingerprint/your_personality')
  end
  
  def submit_height_and_weight
    check_path('/fashion_fingerprint/height_and_weight')
    form = form_at('#content form.new_user').tap do |form|  
      form['user[ff_api_profile][imperial_height][feet]'] = 5
      form['user[ff_api_profile][imperial_height][inches]'] = rand(9)
      form['user[ff_api_profile][imperial_weight][pounds]'] = rand(14)
      form['user[ff_api_profile][imperial_weight][stones]'] = 8 + rand(4)
    end
    session.submit(form)
  end

  def submit_body_proportions
    check_path('/fashion_fingerprint/body_proportions')

    form = form_at('#content form.edit_user').tap  do |form|
      form['user[ff_api_profile][body_proportions]'] = %w(shoulders_hips_equal shoulders_wider_than_hips hips_wider_than_shoulders).sample
    end
    session.submit(form)
  end

  def submit_chest_and_waist
    check_path('/fashion_fingerprint/bust_and_waist')
    form = form_at('#content form.edit_user').tap  do |form|
      form['user[ff_api_profile][bust_proportions]'] = "medium"
      form['user[ff_api_profile][waist_proportions]'] = %w(defined undefined).sample
    end
    session.submit(form)
  end

  def submit_sizes
    check_path('/fashion_fingerprint/sizes')
    form = form_at('#content form.edit_user').tap  do |form|
      form['user[ff_api_profile][tops_sizing_range_id]'] = "50"
      form['user[ff_api_profile][tops_size_id]'] = %w(5 6).sample
      form['user[ff_api_profile][dresses_sizing_range_id]'] = "50"
      form['user[ff_api_profile][dresses_size_id]'] = %w(5 6).sample
      form['user[ff_api_profile][trousers_sizing_range_id]'] = "50"
      form['user[ff_api_profile][trousers_size_id]'] = %w(5 6).sample
    end
    session.submit(form)
  end

  def submit_random_radiobutton
    form = form_at('#content form.edit_user')
    form.radiobuttons.sample.check
    session.submit(form)
  end    
  def submit_reveal_and_conceal
    check_path('/fashion_fingerprint/reveal_and_conceal')
    form = form_at('#content form.edit_user')
    session.submit(form)
  end

  def submit_eye_colour
    check_path('/fashion_fingerprint/eye_colour')
    submit_random_radiobutton
  end

  def submit_hair_colour
    check_path('/fashion_fingerprint/hair_colour')
    submit_random_radiobutton
    end

  def submit_skin_colour
    check_path('/fashion_fingerprint/skin_colour')
    submit_random_radiobutton
  end

  def submit_investment_colours
    check_path('/fashion_fingerprint/investment_colours')
    form = form_at('#content form.edit_user')
    form.checkboxes.sample.check
    session.submit(form)
  end

  def submit_favourite_colours
    check_path('/fashion_fingerprint/favourite_colours')
    form = form_at('#content form.edit_user')
    form.checkboxes.sample(3).each {|colour| colour.check}
    session.submit(form)
  end

  def submit_fashion_confidence
    check_path('/fashion_fingerprint/fashion_confidence')
    submit_random_radiobutton
  end

  def submit_want_to_change
    check_path('/fashion_fingerprint/want_to_change')
    submit_random_radiobutton
  end

  def submit_enjoy_shopping
    check_path('/fashion_fingerprint/enjoy_shopping')
    submit_random_radiobutton
  end

  def submit_weekday_occupation
    check_path('/fashion_fingerprint/weekday_occupation')
    form = form_at('#content form.edit_user')
    form.checkboxes.reject {|field| field.dom_class =~ /other/}.sample.check
    session.submit(form)
  end

  def submit_dressing_up
    check_path('/fashion_fingerprint/dressing_up')
    form = form_at('#content form.edit_user')
    form.checkboxes.reject {|field| field.dom_class =~ /other/}.sample.check
    session.submit(form)
  end

  def submit_age
    check_path('/fashion_fingerprint/age')
    form = form_at('#content form.edit_user')
    form.field_with(:name => /age/).value = 25 + rand(30)
    session.submit(form)
  end    

  def submit_garments_step_1
    check_path('/fashion_fingerprint/garments_step_1')
    form = form_at('#content form.edit_user')
    product_codes = session.page.search('.product-cell').collect {|x|  x['data-product-code']}
    prefix = session.page.at('#votes')['data-prefix']
    #these swaps are just to simulate load - we don't actually use the result
    2.times {|i| do_swap(i, 'garments_step_1', product_codes)}

    product_codes.each do |p|
      form.add_field! "#{prefix}[#{p}]", '1'
    end
    session.submit(form)
  end

  def submit_garments_step_2
    check_path('/fashion_fingerprint/garments_step_2')
    form = form_at('#content form.edit_user')
    product_codes = session.page.search('.product-cell').collect {|x|  x['data-product-code']}
    prefix = session.page.at('#votes')['data-prefix']
    #these swaps are just to simulate load - we don't actually use the result
    2.times {|i| do_swap(i, 'garments_step_2', product_codes)}

    product_codes.each do |p|
      form.add_field! "#{prefix}[#{p}]", '1'
    end
    session.submit(form)
  end

  def do_swap index, state, product_codes
    session.get('/fashion_fingerprint/swap', [[:product_code,product_codes.sample],
                                              [:state, state],
                                              [:offset, (index +1) * 30]] + product_codes.collect {|code| ['current_products[]', code]})

  end
end