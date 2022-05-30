class PostPdfController < ApplicationController
    skip_before_action :login_required

    def index
        send_data PracticePdf::PostPdf.new.render, filename: "post_pdf.pdf", type: 'application/pdf',disposition: 'inline'

      respond_to do |format|
        format.pdf do
          post_pdf = PracticePdf::PostPdf.new().render
          send_data post_pdf,
            filename: 'post_pdf.pdf',
            type: 'application/pdf',
            disposition: 'inline' # 外すとダウンロード
        end
      end
    end
  end