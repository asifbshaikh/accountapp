module HorizontalProfitAndLossHelper
  def clean_output(amount)
    amount.zero? && 0.0 || amount
  end
end
