############################################################
# Charts, maps, etc. from your data
#
# Assigning the generic p plot to a variable is handy for
# inserting plots into notebook chunks.
#
############################################################

# sample_filtered <- sample %>%
#   filter(cma != 'C11')
#
# plot_c11_yoy <- ggplot(data = sample_filtered, aes(x = reorder(cma, yoy), y = yoy)) +
#   geom_bar(colour = 'white', stat = 'identity') +
#   scale_y_continuous(expand = c(0, 0), limits = c(0, 25)) +
#   coord_flip() +
#   labs(
#     title = 'Year-over-year house price change in Canada\'s biggest cities',
#     caption = 'THE GLOBE AND MAIL, SOURCE: TERANET-NATIONAL BANK',
#     x = '',
#     y = ''
#   ) +
#   theme_classic()
#
# plot(p_c11_yoy)
#
# ggsave(p_c11_yoy, file = here::here(dir_plots, 'C11_YoY.png'), width = 6.5, height = 6.5, units = 'in', dpi = 300)
