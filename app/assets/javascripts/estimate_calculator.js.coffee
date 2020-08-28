class @EstimateCalculator

  # Calculate the line total for estimate
  @updateLineTotal = (elem) ->
    container = elem.parents("tr.fields")
    cost = jQuery(container).find("input.cost").val()
    qty = jQuery(container).find("input.qty").val()
    cost = 0 if not cost? or cost is "" or not jQuery.isNumeric(cost)
    qty = 0 if not qty? or qty is "" or not jQuery.isNumeric(qty)
    line_total = ((parseFloat(cost) * parseFloat(qty)))
    tax_total = applyTax(line_total, elem)
    grand_total = line_total + tax_total
    jQuery(container).find(".line_total").text(grand_total.toFixed(2))

  # Calculate grand total from line totals
  @updateEstimateTotal = ->
    total = 0
    tax_amount = 0
    discount_amount = 0
    estimate_tax_amount = 0.0
    $('table.estimate_grid_fields tr:visible .line_total').each ->
      line_total = parseFloat($(this).text())
      total += line_total
      tax_amount += applyTax(line_total, $(this))
    discount_amount = applyDiscount(total)

    $('#estimate_sub_total').val total.toFixed(2)
    $('#estimate_sub_total_lbl').text total.toFixed(2)
    $('#estimate_estimate_total').val total.toFixed(2)
    $('#estimate_total_lbl').text total.toFixed(2)
    $('.estimate_total_strong').html total.toFixed(2)
    $('#tax_amount_lbl').text tax_amount.toFixed(2)
    $('#estimate_tax_amount').val tax_amount.toFixed(2)
    $('#estimate_discount_amount_lbl').text discount_amount.toFixed(2)
    $('#estimate_discount_amount').val (discount_amount * -1).toFixed(2)
    total_balance = parseFloat($('#estimate_total_lbl').text() - discount_amount)

    if $('#estimate_tax_id').val() != ""
      estimate_tax_amount = getEstimateTax(total_balance).toFixed(2)
      $("#estimate_estimate_tax_amount").val estimate_tax_amount
    else
      $("#estimate_estimate_tax_amount").val estimate_tax_amount

    estimate_tax_amount = parseFloat(estimate_tax_amount)
    total_balance += estimate_tax_amount
    $('#estimate_estimate_total').val total_balance.toFixed(2)
    $('#estimate_total_lbl').text total_balance.toFixed(2)
    $('.estimate_total_strong').html total_balance.toFixed(2)
    $('.estimate_total_strong').formatCurrency({symbol: window.currency_symbol})
    $("#estimate_sub_total_lbl, #estimate_total_lbl, .tax_amount").formatCurrency({symbol: window.currency_symbol});
    TaxCalculator.applyAllLineItemTaxes()

  getEstimateTax = (total) ->
    tax_percentage = parseFloat($("#estimate_tax_id option:selected").data('tax_percentage'))
    total * (parseFloat(tax_percentage) / 100.0)

  # Apply Tax on totals
  applyTax = (line_total,elem) ->
    tax1 = elem.parents("tr").find("select.tax1 option:selected").attr('data-tax_1')
    tax2 = elem.parents("tr").find("select.tax2 option:selected").attr('data-tax_2')
    tax1 = 0 if not tax1? or tax1 is ""
    tax2 = 0 if not tax2? or tax2 is ""
    # if line total is 0
    tax1=tax2=0 if line_total is 0
    discount_amount = applyDiscount(line_total)
    total_tax = (parseFloat(tax1) + parseFloat(tax2))
    (line_total - discount_amount) * (parseFloat(total_tax) / 100.0)

  # Apply discount percentage on subtotals
  applyDiscount = (subtotal) ->
    discount_percentage = $("#estimate_discount_percentage").val()
    discount_type = $("select#discount_type").val()
    discount_percentage = 0 if not discount_percentage? or discount_percentage is ""
    if discount_type == "%" then (subtotal * (parseFloat(discount_percentage) / 100.0)) else parseFloat(discount_percentage) # Remove parseFloat from discount_percentage
