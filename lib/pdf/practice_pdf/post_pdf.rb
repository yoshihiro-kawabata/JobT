module PracticePdf
    class PostPdf < Prawn::Document
        def initialize(params,user,group)
            super(page_size: 'A4')
            font_families.update('Test' => { normal: 'config/fonts/ipam.ttf'})
            font 'Test'
    
            params.size.times do |n|
                renta = []
                renta.push(group.name,user.name,params[n].createdate,params[n].daytask,params[n].emotion,params[n].learn,params[n].transition,params[n].admincom)
                render_table(renta)
                unless n == params.size - 1
                    start_new_page 
                end
            end
                number_pages('<page> / <total>', at: [bounds.right - 50, 0])
        end

        private

        def render_table(params)
            rows = [
                [{ content: '日報', colspan: 3 }],
                ['部署', params[0],'日付'],
                ['氏名', params[1] ,params[2]],
                [{ content: '「事実」何があったか', colspan: 3 }],
                [{ content: params[3], colspan: 3 }],
                [{ content: '「感情」どう思ったか', colspan: 3 }],
                [{ content: params[4], colspan: 3 }],
                [{ content: '「学習」何を学んだか', colspan: 3 }],
                [{ content: params[5], colspan: 3 }],
                [{ content: '「変化」何を変えるか', colspan: 3 }],
                [{ content: params[6], colspan: 3 }],
                [{ content: '管理者コメント', colspan: 3 }],
                [{ content: params[7], colspan: 3 }]
              ]
              # セルの高さ30、左上詰め詰め
              table rows, cell_style: { height: 50, padding: 2,margin: 20 } do
                # 文字サイズ,位置
                cells.size = 15
                cells.align = :center
                # 1行目の背景色をff7500に
                row(4).align = :left
                row(6).align = :left
                row(8).align = :left
                row(10).align = :left
                row(12).align = :left
                # 1行目の背景色をff7500に
                row(0).background_color = 'ee827c'
                row(3).background_color = 'e8d3c7'
                row(5).background_color = '84b9cb'
                row(7).background_color = 'ada250'
                row(9).background_color = 'c7dc68'
                row(11).background_color = 'c8c2be'
                # 1列目の横幅を30に
                columns(0).width = 100
                # 1列目の横幅を30に
                columns(1).width = 320
                # 1列目の横幅を30に
                columns(2).width = 100
                # 1列目の横幅を30に
                columns(0..12).height = 25
                row(4).height = 100
                row(6).height = 100
                row(8).height = 100
                row(10).height = 100
                row(12).height = 100
                # 枠線左右上だけ
                columns(2).row(1).borders = %i[left right top]                
                columns(2).row(2).borders = %i[left right bottom]    
              end
        end
    end
end