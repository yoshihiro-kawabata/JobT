module ApplicationHelper

    def html_newline(str)
      h(str).gsub(/(\\r\\n|\\r|\\n)/, "<br>").html_safe
    end

end
