module ProductSettingsHelper
	def product_setting
    if @product_setting.multilevel_pricing?
      'Multilevel pricing enabled.'
    else
      'Multilevel pricing disabled.'
    end
  end
end
