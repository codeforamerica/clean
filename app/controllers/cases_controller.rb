class CasesController < ActionController::Base
  http_basic_authenticate_with name: ENV['EW_USERNAME'], password: ENV['EW_PASSWORD']

  def download_pdf
    # Protect with basic auth
    cases = Case.where(public_id: params[:public_id])
    if cases.count == 1
      redirect_to cases.first.temporary_pdf_download_link
    elsif cases.count > 1
      puts "WARNING - multiple cases found with same public_id: #{params[:public_id]}"
      redirect_to cases.first.temporary_pdf_download_link
    else
      puts "WARNING - case with public_id #{params[:public_id]} was accessed but not found"
      render inline: "Sorry! It looks like that case doesn't exist. Please contact Jake Soloman at jacob@codeforamerica.org to find out what might have gone wrong."
    end
  end
end
