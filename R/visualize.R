# =======================================================================
# Graphics. Use the `write_plot` function to write the plot directly
# to the `plots/` folder, using the variable name as the filename.
# =======================================================================

# plot_house_price_change <- sample %>%
#   filter(cma != 'C11') %>%
#   ggplot(aes(x = reorder(cma, yoy), y = yoy)) +
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
# plot_house_price_change
#
# write_plot(plot_house_price_change)
