class StaticController < ApplicationController
  rescue_from AbstractController::ActionNotFound, with: :render_404

  def deposit_agreement
    respond_to do |format|
      format.html
    end
  end

  def data_deposit_agreement
    respond_to do |format|
      format.html
    end
  end

  def zotero
    respond_to do |format|
      format.html
      format.js { render layout: false }
    end
  end

  def mendeley
    respond_to do |format|
      format.html
      format.js { render layout: false }
    end
  end

end
