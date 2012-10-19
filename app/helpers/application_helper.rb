module ApplicationHelper
	def icon_text(icon, text)
		# haml do
		# 	haml_tag :i, :class => icon
		# 	haml_concat text
		# end
		"<i class='#{icon}'></i>\n#{text}".html_safe
	end
end
